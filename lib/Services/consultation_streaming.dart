import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

/// A single parsed Server-Sent-Event: `event: <name>` + `data: <json/text>`.
class SseEvent {
  final String event;
  final dynamic data; // decoded JSON if possible, otherwise raw string

  SseEvent({required this.event, required this.data});

  @override
  String toString() => 'SseEvent(event: $event, data: $data)';
}

/// POST /api/v1/consultation/{session_id}/answer-stream
/// text/event-stream response.
/// Events: 'token' {text}, 'error' {message},
///         'done' {next_question, history_complete, new_flags}.
Stream<SseEvent> submitAnswerStream({
  required String baseUrl,
  required String token,
  required String sessionId,
  required String answer,
}) async* {
  final uri = Uri.parse("$baseUrl/api/v1/consultation/$sessionId/answer-stream");
  final request = http.Request("POST", uri)
    ..headers["Content-Type"] = "application/json"
    ..headers["Authorization"] = "Bearer $token"
    ..body = jsonEncode({"answer": answer});

  final streamedResponse = await http.Client().send(request);

  String? currentEvent;
  final buffer = StringBuffer();

  await for (final line in streamedResponse.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())) {
    if (line.startsWith("event:")) {
      currentEvent = line.substring(6).trim();
    } else if (line.startsWith("data:")) {
      buffer.write(line.substring(5).trim());
    } else if (line.isEmpty) {
      // blank line = end of one SSE message
      if (currentEvent != null && buffer.isNotEmpty) {
        final raw = buffer.toString();
        dynamic decoded;
        try {
          decoded = jsonDecode(raw);
        } catch (_) {
          decoded = raw;
        }
        yield SseEvent(event: currentEvent, data: decoded);
      }
      currentEvent = null;
      buffer.clear();
    }
  }
}

/// GET /api/v1/consultation/{session_id}/pipeline?token=...
/// Auth via query param (EventSource can't set headers), not the Bearer header.
/// Sequential 'step' events (translate, completeness, summarize, diagnose)
/// with status running|done, then a final 'complete' event {note, diagnosis}
/// or 'error'.
Stream<SseEvent> consultationPipeline({
  required String baseUrl,
  required String sessionId,
  required String accessToken,
}) async* {
  final uri = Uri.parse(
    "$baseUrl/api/v1/consultation/$sessionId/pipeline?token=$accessToken",
  );
  final request = http.Request("GET", uri);
  final streamedResponse = await http.Client().send(request);

  String? currentEvent;
  final buffer = StringBuffer();

  await for (final line in streamedResponse.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())) {
    if (line.startsWith("event:")) {
      currentEvent = line.substring(6).trim();
    } else if (line.startsWith("data:")) {
      buffer.write(line.substring(5).trim());
    } else if (line.isEmpty) {
      if (currentEvent != null && buffer.isNotEmpty) {
        final raw = buffer.toString();
        dynamic decoded;
        try {
          decoded = jsonDecode(raw);
        } catch (_) {
          decoded = raw;
        }
        yield SseEvent(event: currentEvent, data: decoded);
      }
      currentEvent = null;
      buffer.clear();
    }
  }
}

/// A single message received over the voice-stream WebSocket.
class VoiceStreamMessage {
  final String type; // ready, ack, processing, transcript, token, done, error
  final Map<String, dynamic> data;

  VoiceStreamMessage({required this.type, required this.data});

  factory VoiceStreamMessage.fromJson(Map<String, dynamic> json) {
    return VoiceStreamMessage(
      type: (json['type'] ?? '').toString(),
      data: json,
    );
  }

  @override
  String toString() => 'VoiceStreamMessage(type: $type, data: $data)';
}

/// WS /api/v1/consultation/{session_id}/voice-stream?token=...
/// Wraps the raw WebSocketChannel with helpers matching the documented protocol:
///   1. call `start()` with the mime type first
///   2. call `sendAudioChunk(bytes)` for each binary audio frame
///   3. call `stop()` (or `close()`) when done
/// Listen to `messages` for parsed server events.
class VoiceStreamConnection {
  final WebSocketChannel _channel;
  final Stream<VoiceStreamMessage> messages;

  VoiceStreamConnection._(this._channel, this.messages);

  factory VoiceStreamConnection.connect({
    required String baseUrl, // host only, no scheme, e.g. "example.com" or "example.com:443"
    required String sessionId,
    required String accessToken,
    bool secure = true,
  }) {
    final scheme = secure ? "wss" : "ws";
    final uri = Uri.parse(
      "$scheme://$baseUrl/api/v1/consultation/$sessionId/voice-stream?token=$accessToken",
    );
    final channel = WebSocketChannel.connect(uri);

    final messages = channel.stream
        .where((event) => event is String) // JSON text frames only
        .map((event) => VoiceStreamMessage.fromJson(
              jsonDecode(event as String) as Map<String, dynamic>,
            ));

    return VoiceStreamConnection._(channel, messages);
  }

  /// Must be sent first, before any binary audio frames.
  void start({String mimeType = "audio/webm;codecs=opus"}) {
    _channel.sink.add(jsonEncode({"type": "start", "mime_type": mimeType}));
  }

  /// Send a chunk of raw binary audio data.
  void sendAudioChunk(List<int> bytes) {
    _channel.sink.add(bytes);
  }

  /// Signals the server that audio is finished; alternatively just close().
  void stop() {
    _channel.sink.add(jsonEncode({"type": "stop"}));
  }

  Future<void> close() => _channel.sink.close();
}
