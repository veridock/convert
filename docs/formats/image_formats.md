# 📷 Image Formats

[🏠 Home](../index.md) | [📋 Formats](../formats/) | [📚 Guides](../guides/) | [🔧 API](../api/) | [❓ FAQ](../FAQ.md)

---

## Supported Formats

### Raster Formats
- **JPEG** (`.jpg`, `.jpeg`)
  - Lossy compression
  - Best for photographs
  - Supports EXIF data

- **PNG** (`.png`)
  - Lossless compression
  - Supports transparency
  - Ideal for web graphics

- **WebP** (`.webp`)
  - Modern format by Google
  - Better compression than JPEG/PNG
  - Supports both lossy and lossless compression

- **TIFF** (`.tif`, `.tiff`)
  - High-quality format
  - Supports layers and transparency
  - Common in professional photography

### Vector Formats
- **SVG** (`.svg`)
  - Scalable vector graphics
  - XML-based
  - Ideal for logos and icons

- **EPS** (`.eps`)
  - Encapsulated PostScript
  - Common in print industry
  - Vector-based

## Conversion Matrix

| From \ To | JPEG | PNG  | WebP | SVG  |
|-----------|------|------|------|------|
| **JPEG**  | -    | ✓    | ✓    | ✗    |
| **PNG**   | ✓    | -    | ✓    | ✗    |
| **WebP**  | ✓    | ✓    | -    | ✗    |
| **SVG**   | ✓    | ✓    | ✓    | -    |

> Note: Vector to raster conversions may require resolution specification

## Recommended Converters

### Batch Processing
```bash
# Convert all JPG to WebP with quality 80
make batch imagemagick jpg webp "*.jpg" WEBP_QUALITY=80

# Convert SVG to PNG with specific size
make batch rsvg svg png "*.svg" OUTPUT_WIDTH=1024
```

### Single File Conversion
```bash
# Convert PNG to WebP with lossless compression
make pillow png webp input.png output.webp

# Convert JPG to PNG with transparency
make imagemagick jpg png input.jpg output.png -transparent white
```

## Common Issues

### Loss of Quality
- Use lossless formats (PNG, WebP) when quality is critical
- For JPEG, use higher quality settings (85-95%)
- Consider using progressive JPEGs for web

### Transparency Handling
- JPEG doesn't support transparency (converts to white/black)
- PNG-8 vs PNG-24: Choose based on color depth needs
- For WebP, ensure browser compatibility

## Best Practices

1. **For Web**: Use WebP with JPEG/PNG fallbacks
2. **For Print**: Prefer TIFF or high-quality JPEG
3. **For Icons**: Use SVG when possible
4. **For Photos**: Use WebP or high-quality JPEG

---

📝 *Need help with a specific format? [Open an issue](https://github.com/yourusername/universal-file-converter/issues)*

