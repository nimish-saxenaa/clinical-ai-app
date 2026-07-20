# 🚨 Backend Issue - Voice Streaming

## Problem

Backend WebSocket is NOT sending the required "ready" event before expecting audio.

### Debug Output:
```
🔌 [DEBUG WebSocket] Connecting to: wss://...
✅ [DEBUG WebSocket] Channel created
📨 [DEBUG] Received event type: error
📦 [DEBUG] Event data: {type: error, message: No audio received}
```

### What's Missing:
- ❌ No `{"type":"ready"}` event from server
- ❌ Backend immediately sends error without waiting for audio

## Expected WebSocket Protocol

According to the API documentation, the flow should be:

### Server Side:
1. **Accept WebSocket connection**
2. **Send `{"type":"ready"}`** ← **THIS IS MISSING**
3. Wait for client `{"type":"start","mime_type":"..."}`
4. Receive binary audio chunks
5. Wait for client `{"type":"stop"}`
6. Process audio
7. Send response events

### Client Side (Our Implementation):
1. Connect to WebSocket ✅
2. Listen for `{"type":"ready"}` ✅
3. When ready received, send `{"type":"start","mime_type":"audio/aac"}` ✅
4. Stream binary audio chunks ✅
5. Send `{"type":"stop"}` when done ✅
6. Listen for transcription events ✅

## Current Backend Behavior (Wrong)

```python
# Backend appears to be doing this:
def on_connect(websocket):
    # Missing: send ready event
    # websocket.send(json.dumps({"type": "ready"}))
    
    # Immediately checks for audio (which hasn't been sent yet!)
    if no_audio_received:
        websocket.send(json.dumps({
            "type": "error",
            "message": "No audio received"
        }))
```

## Required Backend Fix

```python
def on_connect(websocket):
    # 1. Send ready event FIRST
    websocket.send(json.dumps({"type": "ready"}))
    
    # 2. Wait for start message from client
    start_message = await websocket.receive_json()
    assert start_message["type"] == "start"
    mime_type = start_message.get("mime_type", "audio/aac")
    
    # 3. Receive binary audio chunks
    audio_chunks = []
    while True:
        message = await websocket.receive()
        if isinstance(message, bytes):
            audio_chunks.append(message)
        elif isinstance(message, str):
            msg = json.loads(message)
            if msg["type"] == "stop":
                break
    
    # 4. Now process the audio
    if not audio_chunks:
        websocket.send(json.dumps({
            "type": "error",
            "message": "No audio received"
        }))
        return
    
    # Process transcription...
    transcription = transcribe(audio_chunks, mime_type)
    
    # Send response
    websocket.send(json.dumps({
        "type": "done",
        "transcription": transcription,
        "next_question": "..."
    }))
```

## Backend Team Contact

Please share this with the backend team along with the debug logs showing:
- WebSocket connects successfully
- No "ready" event received
- Immediate error response

## Workaround Attempted

We tried sending the start message immediately without waiting for ready, but backend still needs to be fixed to properly handle the protocol.

---

**Status:** Waiting for backend fix
**Priority:** High - Blocking voice recording feature
**Date Reported:** {{current_date}}
