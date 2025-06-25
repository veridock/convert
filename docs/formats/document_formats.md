# 📄 Document Formats

[🏠 Home](../index.md) | [📋 Formats](../formats/) | [📚 Guides](../guides/) | [🔧 API](../api/) | [❓ FAQ](../FAQ.md)

---

## Supported Formats

### Office Documents
- **Microsoft Office**
  - Word (`.docx`, `.doc`)
  - Excel (`.xlsx`, `.xls`)
  - PowerPoint (`.pptx`, `.ppt`)
  - Outlook (`.msg`, `.pst`)

- **OpenDocument Format (ODF)**
  - Text (`.odt`)
  - Spreadsheet (`.ods`)
  - Presentation (`.odp`)
  - Graphics (`.odg`)

### PDF & E-books
- **PDF** (`.pdf`)
  - Portable Document Format
  - Supports text, images, forms
  - Common for sharing documents

- **E-book Formats**
  - EPUB (`.epub`)
  - MOBI (`.mobi`)
  - FB2 (`.fb2`)
  - AZW (`.azw`, `.azw3`)

### Markup & Plain Text
- **Markdown** (`.md`, `.markdown`)
  - Lightweight markup language
  - Easy to read and write
  - Common for documentation

- **HTML** (`.html`, `.htm`)
  - Web page format
  - Supports rich formatting
  - Can include CSS/JS

- **Plain Text** (`.txt`)
  - Unformatted text
  - Universal compatibility
  - Small file size

## Conversion Matrix

| From \ To | DOCX | PDF  | MD   | HTML |
|-----------|------|------|------|------|
| **DOCX**  | -    | ✓    | ✓    | ✓    |
| **PDF**   | ✓    | -    | ✓    | ✓    |
| **MD**    | ✓    | ✓    | -    | ✓    |
| **HTML**  | ✓    | ✓    | ✓    | -    |

> Note: Complex formatting may not be preserved in all conversions

## Recommended Converters

### Office Documents
```bash
# Convert DOCX to PDF
make libreoffice docx pdf document.docx document.pdf

# Convert XLSX to ODS
make libreoffice xlsx ods data.xlsx data.ods
```

### PDF Operations
```bash
# Convert PDF to Text
make poppler pdf txt document.pdf document.txt

# Merge multiple PDFs
make ghostscript pdf pdf "file1.pdf file2.pdf" combined.pdf
```

### Markdown & HTML
```bash
# Convert Markdown to PDF (using Pandoc)
make pandoc md pdf README.md documentation.pdf

# Convert HTML to Markdown
make pandoc html md page.html content.md
```

## Common Issues

### Formatting Loss
- Complex layouts may not convert perfectly
- Use simpler layouts for better compatibility
- Check the output after conversion

### Font Issues
- Embed fonts in PDFs when needed
- Use web-safe fonts for HTML output
- Consider system font availability

## Best Practices

1. **For Sharing**: Use PDF for universal compatibility
2. **For Editing**: Use DOCX or ODT
3. **For Web**: Use HTML or Markdown
4. **For E-books**: Use EPUB or MOBI
5. **For Archiving**: Use PDF/A format

---

📝 *Need help with document conversion? [Open an issue](https://github.com/yourusername/universal-file-converter/issues)*

