# 🔊 Audio Formats

[🏠 Home](../index.md) | [📋 Formats](../formats/) | [📚 Guides](../guides/) | [🔧 API](../api/) | [❓ FAQ](../FAQ.md)

---

## Supported Formats

### Lossy Audio
- **MP3** (`.mp3`)
  - Most widely supported format
  - Good balance of size and quality
  - Bitrate: 128-320 kbps recommended

- **AAC** (`.aac`, `.m4a`)
  - Better quality than MP3 at same bitrate
  - Used by Apple devices, YouTube, etc.
  - Common bitrate: 128-256 kbps

- **OGG Vorbis** (`.ogg`, `.oga`)
  - Open-source alternative to MP3
  - Better compression than MP3
  - Common in games and web audio

### Lossless Audio
- **FLAC** (`.flac`)
  - Free Lossless Audio Codec
  - Perfect audio quality
  - 40-60% smaller than WAV

- **ALAC** (`.m4a`, `.alac`)
  - Apple Lossless Audio Codec
  - Similar to FLAC but Apple-compatible
  - Used in Apple ecosystem

- **WAV** (`.wav`)
  - Uncompressed audio
  - Highest quality, largest file size
  - Common in professional audio

### Speech & Specialized
- **Opus** (`.opus`)
  - Optimized for speech and music
  - Excellent for streaming
  - Low latency

- **WMA** (`.wma`)
  - Windows Media Audio
  - Good compression
  - Primarily for Windows

## Conversion Matrix

| From \ To | MP3  | AAC  | FLAC | WAV  |
|-----------|------|------|------|------|
| **MP3**   | -    | ✓    | ✓    | ✓    |
| **AAC**   | ✓    | -    | ✓    | ✓    |
| **FLAC**  | ✓    | ✓    | -    | ✓    |
| **WAV**   | ✓    | ✓    | ✓    | -    |

> Note: Converting between lossy formats is not recommended due to quality loss

## Recommended Converters

### Basic Conversion
```bash
# Convert WAV to MP3 (192k)
make ffmpeg wav mp3 input.wav output.mp3 -b:a 192k

# Convert FLAC to AAC (VBR ~256k)
make ffmpeg flac aac input.flac output.m4a -c:a aac -q:a 1
```

### Batch Processing
```bash
# Convert all FLAC to MP3 (V0)
make batch ffmpeg flac mp3 "*.flac" -b:a 320k

# Normalize audio levels
make ffmpeg mp3 mp3 input.mp3 output.mp3 -af loudnorm=I=-16:LRA=11:TP=-1.5
```

### Advanced Operations
```bash
# Extract audio from video
make ffmpeg mp4 mp3 video.mp4 audio.mp3 -q:a 0 -map a

# Join multiple audio files
make ffmpeg concat mp3 "file1.mp3|file2.mp3" output.mp3 -c copy
```

## Common Issues

### Audio Quality
- Avoid multiple lossy re-encodings
- Use highest quality source available
- Consider bitrate requirements for your use case

### Metadata
- Preserve metadata with `-map_metadata 0`
- Edit with tools like `id3v2` or `ffmpeg -metadata`
- Check for cover art preservation

## Best Practices

1. **For Music**: FLAC for archiving, 320k MP3/AAC for distribution
2. **For Podcasts**: 128k MP3/AAC for speech
3. **For Mobile**: 192-256k VBR for music
4. **For Web**: Opus or AAC with fallback to MP3

---

📝 *Need help with audio conversion? [Open an issue](https://github.com/yourusername/universal-file-converter/issues)*

