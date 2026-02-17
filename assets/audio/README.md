# Audio Assets

This directory should contain Tamil pronunciation audio files.

The app uses Flutter TTS (Text-to-Speech) as the primary audio source, so audio files are optional.

If you want to add custom audio files:
- Name them according to the Tamil letter/word (e.g., `அ.mp3`, `நாய்.mp3`)
- Supported formats: MP3, WAV
- Place them in this directory

The AudioService will automatically fall back to TTS if audio files are not found.
