# ❓ Frequently Asked Questions

[🏠 Home](../index.md) | [📋 Formats](../formats/) | [📚 Guides](../guides/) | [🔧 API](../api/) | [❓ FAQ](../FAQ.md)

---

## 🔍 General Questions

### Q: How do I install the converter?
**A:** Run the installation script:
```bash
./config/install_dependencies.sh
```

### Q: Which formats are supported?
**A:** The converter supports a wide range of formats. See the [format documentation](../formats/) for a complete list.

### Q: How do I search for available converters?
**A:** Use the search command:
```bash
make search [from_format] [to_format]
# Example:
make search md pdf
```

## 🔄 Conversion

### Q: How do I convert a file?
**A:** Use the following syntax:
```bash
make [converter] [from_format] [to_format] [input_file] [output_file]
# Example:
make pandoc md pdf document.md document.pdf
```

### Q: How do I convert multiple files at once?
**A:** Use the batch processing feature:
```bash
make batch [converter] [from_format] [to_format] "file_pattern"
# Example:
make batch imagemagick jpg png "*.jpg"
```

## ⚡ Performance

### Q: How can I improve conversion speed?
**A:** Try these tips:
1. Use faster converters (check benchmark results with `make benchmark`)
2. Increase system resources if possible
3. For batch processing, enable parallel mode:
   ```bash
   BATCH_PARALLEL=1 make batch ...
   ```

## 🛠️ Troubleshooting

### Q: I'm getting a 'command not found' error
**A:** This usually means a required tool is not installed. Try:
```bash
make install-deps
```

### Q: My converted file looks incorrect
**A:** Try these steps:
1. Check if the converter supports your specific format variant
2. Try a different converter
3. Check the file with `make validate [file]`

---

📝 *Need more help? [Open an issue](https://github.com/yourusername/universal-file-converter/issues) or [check the documentation](../index.md).*

