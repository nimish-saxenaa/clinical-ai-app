# 🐛 Voice Recording Debug Guide

## Debug Prints Added

All debug prints use emoji prefixes for easy filtering in logs.

### 🎙️ Recording Flow Debug Prints

#### 1. **Start Recording** (`startVoiceStreaming()`)
```
🎙️ [DEBUG] Starting voice streaming...
🔑 [DEBUG] Access token: eyJhbGciOiJIUzI1NiIs...
📝 [DEBUG] Session ID: abc123-def456
🔌 [DEBUG] WebSocket connection created
```

#### 2. **WebSocket Connection** (VoiceStreamConnection)
```
🔌 [DEBUG WebSocket] Connecting to: wss://med-history-agent.decrackle.io/api/v1/consultation/{session_id}/voice-stream?token={token}
✅ [DEBUG WebSocket] Channel created
```

#### 3. **Server Events**
```
📨 [DEBUG WebSocket] Raw message received: {"type":"ready"}
📨 [DEBUG] Received event type: ready
📦 [DEBUG] Event data: {type: ready}
```

#### 4. **Recording Starts**
```
✅ [DEBUG] Server ready, sending start message...
📤 [DEBUG WebSocket] Sending start: {"type":"start","mime_type":"audio/aac"}
📤 [DEBUG] Sent start message with MIME type: audio/aac
🎤 [DEBUG] Microphone permission granted
🎵 [DEBUG] Audio stream started
```

#### 5. **Audio Chunks Streaming**
```
🔊 [DEBUG] Sent 10 audio chunks (4096 bytes each)
🔊 [DEBUG] Sent 20 audio chunks (4096 bytes each)
🔊 [DEBUG] Sent 30 audio chunks (4096 bytes each)
...
```

#### 6. **Stop Recording** (`sendVoiceAnswer()`)
```
⏹️ [DEBUG] Stopping recording...
📤 [DEBUG WebSocket] Sending stop: {"type":"stop"}
📤 [DEBUG] Sent stop message to server
🎤 [DEBUG] Audio recorder stopped
⏳ [DEBUG] Waiting for transcription...
```

#### 7. **Transcription Events**
```
📨 [DEBUG] Received event type: transcript
📝 [DEBUG] Transcript received, AI is thinking...
```

```
📨 [DEBUG] Received event type: token
🔤 [DEBUG] Token received: Hello
```

```
📨 [DEBUG] Received event type: done
✅ [DEBUG] Transcription complete
🔌 [DEBUG WebSocket] Closing connection
🔌 [DEBUG] WebSocket closed
❓ [DEBUG] Next question: How are you feeling today?
```

#### 8. **Error Handling**
```
❌ [DEBUG] Error received: Transcription failed
❌ [DEBUG] WebSocket error: Connection closed unexpectedly
❌ [DEBUG] Microphone permission denied
🔌 [DEBUG] WebSocket stream closed
```

---

## 📊 Expected Complete Flow Log

When everything works correctly, you should see:

```
🎙️ [DEBUG] Starting voice streaming...
🔑 [DEBUG] Access token: eyJhbGci...
📝 [DEBUG] Session ID: 12345
🔌 [DEBUG WebSocket] Connecting to: wss://med-history-agent.decrackle.io/...
🔌 [DEBUG] WebSocket connection created
✅ [DEBUG WebSocket] Channel created
📨 [DEBUG WebSocket] Raw message received: {"type":"ready"}
📨 [DEBUG] Received event type: ready
📦 [DEBUG] Event data: {type: ready}
✅ [DEBUG] Server ready, sending start message...
📤 [DEBUG WebSocket] Sending start: {"type":"start","mime_type":"audio/aac"}
📤 [DEBUG] Sent start message with MIME type: audio/aac
🎤 [DEBUG] Microphone permission granted
🎵 [DEBUG] Audio stream started
🔊 [DEBUG] Sent 10 audio chunks (4096 bytes each)
🔊 [DEBUG] Sent 20 audio chunks (4096 bytes each)
⏹️ [DEBUG] Stopping recording...
📤 [DEBUG WebSocket] Sending stop: {"type":"stop"}
📤 [DEBUG] Sent stop message to server
🎤 [DEBUG] Audio recorder stopped
⏳ [DEBUG] Waiting for transcription...
📨 [DEBUG] Received event type: transcript
📝 [DEBUG] Transcript received, AI is thinking...
📨 [DEBUG] Received event type: token
🔤 [DEBUG] Token received: Hello
📨 [DEBUG] Received event type: done
✅ [DEBUG] Transcription complete
🔌 [DEBUG WebSocket] Closing connection
🔌 [DEBUG] WebSocket closed
❓ [DEBUG] Next question: How are you feeling?
```

---

## 🔍 How to View Debug Logs

### **In VS Code / Kiro IDE:**
1. Run the app: `flutter run`
2. Watch the Debug Console
3. Filter by emoji: Search for 🎙️, 🔌, 📨, etc.

### **In Terminal:**
```bash
# Run and filter logs
flutter run | grep DEBUG

# Or save to file
flutter run > debug.log 2>&1
```

### **In Android Studio:**
1. Run → Debug
2. Logcat tab
3. Filter by "DEBUG"

### **In Xcode (iOS):**
1. Run → Debug
2. Console output
3. Search for "[DEBUG]"

---

## 🚨 Common Issues and What to Look For

### **Issue 1: WebSocket Not Connecting**
**Look for:**
```
🔌 [DEBUG WebSocket] Connecting to: wss://...
```
**Missing:** `✅ [DEBUG WebSocket] Channel created`

**Solution:** Check network connectivity, backend URL, and SSL certificate.

---

### **Issue 2: Never Receives "ready" Event**
**Look for:**
```
✅ [DEBUG WebSocket] Channel created
```
**Missing:** `📨 [DEBUG] Received event type: ready`

**Solution:** Backend WebSocket handler may not be sending "ready" event. Check backend logs.

---

### **Issue 3: Start Message Not Sent**
**Look for:**
```
📨 [DEBUG] Received event type: ready
```
**Missing:** `📤 [DEBUG WebSocket] Sending start: ...`

**Solution:** Check if code reaches the `start()` call. May be a permission issue.

---

### **Issue 4: No Audio Chunks Being Sent**
**Look for:**
```
🎵 [DEBUG] Audio stream started
```
**Missing:** `🔊 [DEBUG] Sent 10 audio chunks...`

**Solution:** 
- Microphone not working
- Permissions not granted
- Recorder config issue

---

### **Issue 5: Stop Message Not Received**
**Look for:**
```
📤 [DEBUG WebSocket] Sending stop: {"type":"stop"}
```
**Missing:** `📨 [DEBUG] Received event type: transcript` or `done`

**Solution:** Backend may not be processing audio. Check backend logs for:
- Audio format compatibility
- Transcription service errors
- Audio data corruption

---

### **Issue 6: No Transcription**
**Look for:**
```
📤 [DEBUG] Sent stop message to server
```
**Missing:** `📨 [DEBUG] Received event type: done`

**Solution:** Backend transcription failing. Check:
- Audio format (should be AAC)
- Backend transcription service status
- Backend error logs

---

## 📝 Debugging Checklist

When testing, verify each step:

- [ ] WebSocket connection established
- [ ] "ready" event received
- [ ] Start message sent with correct MIME type
- [ ] Microphone permission granted
- [ ] Audio stream started
- [ ] Audio chunks being sent (check count increases)
- [ ] Stop message sent
- [ ] Transcript/done event received
- [ ] Next question appears

---

## 🛠️ Additional Debugging

### Enable More Verbose Logging

Add to `main.dart`:
```dart
void main() {
  debugPrint = (String? message, {int? wrapWidth}) {
    print('[${DateTime.now().toIso8601String()}] $message');
  };
  runApp(MyApp());
}
```

### Test WebSocket Manually

Use a WebSocket test tool to verify backend:
```bash
# Using websocat (install: brew install websocat)
websocat "wss://med-history-agent.decrackle.io/api/v1/consultation/SESSION_ID/voice-stream?token=TOKEN"

# Then send:
{"type":"start","mime_type":"audio/aac"}
# ... send audio chunks ...
{"type":"stop"}
```

---

## 📞 Share Debug Output

When reporting issues, share the complete log from:
1. 🎙️ Starting voice streaming
2. Through to either:
   - ✅ Transcription complete
   - ❌ Error occurred

This helps identify exactly where the flow breaks.
