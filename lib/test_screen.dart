import 'package:clinical_ai_app/Models/consultation_models.dart';
import 'package:clinical_ai_app/Services/Consultation/consultation_functions.dart';
import 'package:clinical_ai_app/Services/Consultation/consultation_streaming.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({
    super.key,
    required this.sessionId,
    required this.accessToken,
    required this.question,
  });
  static const routeName = "/test-screen";
  final String sessionId;
  final String accessToken;
  final String question;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  AudioRecorder recorder = AudioRecorder();
  // Using AAC-LC (best for iOS & Android streaming)
  // Backend supports: audio/aac, audio/wav, audio/mp4
  final recordConfig = RecordConfig(
    encoder: AudioEncoder.aacLc,
    // Optional: customize if needed
    // sampleRate: 16000,     // 16kHz for speech (lower bandwidth)
    // bitRate: 128000,       // 128 kbps
    // numChannels: 1,        // Mono
  );
  VoiceStreamConnection? connection;
  late String quest = widget.question;
  String? ans;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(quest),
            ElevatedButton(
              onPressed: () async {
                connection = VoiceStreamConnection.connect(
                  sessionId: widget.sessionId,
                  accessToken: widget.accessToken,
                );

                connection?.messages.listen((event) async {
                  if (event.type == "ready") {
                    // Send start message with AAC MIME type
                    connection?.start(mimeType: "audio/aac");

                    if (await recorder.hasPermission()) {
                      final stream = await recorder.startStream(recordConfig);
                      stream.listen((audioChunk) {
                        connection?.sendAudioChunk(audioChunk);
                      });
                    } else {
                      print("no permission");
                    }
                  }
                  if (event.type == "done") {
                    await connection?.close();
                  }
                  if (event.type == "token") {
                    quest += event.data["text"];
                    setState(() {});
                  } else {
                    print(event.data);
                  }
                });
              },
              child: const Text("Test"),
            ),
            ElevatedButton(
              onPressed: () async {
                connection?.stopRecording();
                await recorder.stop();
              },
              child: const Text("Stop"),
            ),
            ElevatedButton(
              onPressed: () async {
                QaLogResponse res = await getQaLog(
                  token: widget.accessToken,
                  sessionId: widget.sessionId,
                );
                print(res.qaLog);
              },
              child: const Text("Stop"),
            ),

            Text(ans ?? ""),
          ],
        ),
      ),
    );
  }
}
