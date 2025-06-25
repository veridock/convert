# Universal File Converter System

Kompleksowy, wielopoziomowy system konwersji plików między różnymi formatami i typami dokumentów, obrazów, audio i video.

## 🚀 Szybki Start

```bash
# Klonowanie projektu
git clone github.com:veridock/convert.git
cd convert

# Instalacja zależności
chmod +x config/*.sh
./config/install_dependencies.sh

# Pierwsza konwersja
make imagemagick jpg png photo.jpg
```

## 📋 Spis Treści

- [Instalacja](#instalacja)
- [Podstawowe Użycie](#podstawowe-użycie)
- [Dostępne Biblioteki](#dostępne-biblioteki)
- [Rozwiązywanie Konfliktów](#rozwiązywanie-konfliktów)
- [Zaawansowane Opcje](#zaawansowane-opcje)
- [Przykłady Użycia](#przykłady-użycia)
- [Rozwiązywanie Problemów](#rozwiązywanie-problemów)

## 🛠️ Instalacja

### Automatyczna Instalacja

```bash
# Instalacja wszystkich narzędzi (rekomendowane)
./config/install_dependencies.sh

# Tylko podstawowe narzędzia
./config/install_dependencies.sh --check
```

### Manualna Instalacja

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install imagemagick graphicsmagick pandoc libreoffice ffmpeg sox ghostscript poppler-utils inkscape librsvg2-bin wkhtmltopdf
```

#### CentOS/RHEL/Fedora
```bash
sudo yum install ImageMagick GraphicsMagick pandoc libreoffice ffmpeg sox ghostscript poppler-utils inkscape librsvg2-tools wkhtmltopdf
```

#### macOS (Homebrew)
```bash
brew install imagemagick graphicsmagick pandoc libreoffice ffmpeg sox ghostscript poppler inkscape librsvg wkhtmltopdf
```

#### Arch Linux
```bash
sudo pacman -S imagemagick graphicsmagick pandoc libreoffice-fresh ffmpeg sox ghostscript poppler inkscape librsvg wkhtmltopdf
```

## 🎯 Podstawowe Użycie

### Składnia Podstawowa

```bash
make [biblioteka] [format_źródłowy] [format_docelowy] [plik_wejściowy] [plik_wyjściowy]
```

### Przykłady Podstawowe

```bash
# Konwersja obrazów
make imagemagick jpg png photo.jpg output.png
make ffmpeg png gif animation.png
make graphicsmagick tiff webp scan.tiff

# Konwersja dokumentów
make pandoc md pdf document.md
make libreoffice docx pdf presentation.docx
make ghostscript pdf png document.pdf

# Konwersja audio/video
make ffmpeg mp4 webm video.mp4
make sox wav mp3 audio.wav
```

### Automatyczne Generowanie Nazw

```bash
# Automatyczna nazwa: input.jpg → input.png
make imagemagick jpg png input.jpg

# Ręczna nazwa
make imagemagick jpg png input.jpg custom_output.png
```

## 📚 Dostępne Biblioteki

### 🖼️ Przetwarzanie Obrazów

| Biblioteka | Mocne Strony | Obsługiwane Formaty |
|------------|--------------|-------------------|
| **imagemagick** | Najszersze wsparcie formatów, wysoka jakość | jpg, png, gif, bmp, tiff, svg, pdf, eps, webp, ico |
| **graphicsmagick** | Szybkość przetwarzania wsadowego | jpg, png, gif, bmp, tiff, svg, pdf, webp |
| **ffmpeg** | Multimedia, animacje, batch processing | jpg, png, gif, bmp, tiff, video formats |
| **pillow** | Python, programmatic access | jpg, png, gif, bmp, tiff, webp |
| **opencv** | Zaawansowane przetwarzanie obrazów | jpg, png, bmp, tiff |
| **inkscape** | Profesjonalne SVG | svg, eps, pdf, png |
| **rsvg** | Lekka konwersja SVG | svg, png, pdf |

### 📄 Przetwarzanie Dokumentów

| Biblioteka | Mocne Strony | Obsługiwane Formaty |
|------------|--------------|-------------------|
| **pandoc** | Języki znaczników, dokumenty akademickie | md, html, latex, docx, pdf, epub, rst |
| **libreoffice** | Dokumenty biurowe, prezentacje | doc, docx, xls, xlsx, ppt, pptx, odt, ods, odp, pdf |
| **ghostscript** | Profesjonalne PDF, PostScript | pdf, ps, eps, png, jpg |
| **poppler** | Szybka ekstrakcja PDF | pdf, png, jpg, txt |
| **wkhtmltopdf** | HTML do PDF z CSS | html, pdf |

### 🎵 Przetwarzanie Multimediów

| Biblioteka | Mocne Strony | Obsługiwane Formaty |
|------------|--------------|-------------------|
| **ffmpeg** | Standard przemysłu, wszystkie formaty | mp4, avi, mkv, mov, mp3, wav, flac, aac |
| **sox** | Zaawansowane przetwarzanie audio | wav, mp3, flac, aac, ogg |

## 🔍 Rozwiązywanie Konfliktów

Gdy kilka bibliotek obsługuje tę samą konwersję, użyj interaktywnego wyboru:

```bash
# Sprawdź dostępne opcje dla konwersji PDF → SVG
./help.sh pdf svg

# Wynik:
# [1] imagemagick    Quality: 4/5, Speed: 3/5
# [2] inkscape       Quality: 5/5, Speed: 2/5
# [3] ghostscript    Quality: 3/5, Speed: 4/5
# Select a converter (1-3):
```

### Automatyczne Sprawdzanie Konfliktów

```bash
# Sprawdź wszystkie konflikty w systemie
make check-conflicts

# Pokaż macierz kompatybilności
./help/conflict_checker.sh matrix

# Pokaż rekomendacje
./help/conflict_checker.sh recommend
```

## ⚙️ Zaawansowane Opcje

### Zmienne Środowiskowe

#### ImageMagick
```bash
# Jakość obrazu (0-100)
IM_QUALITY=95 make imagemagick jpg png photo.jpg

# Zmiana rozmiaru
IM_RESIZE="1920x1080>" make imagemagick png jpg large.png

# Kombinacja opcji
IM_QUALITY=90 IM_RESIZE="50%" make imagemagick tiff jpg scan.tiff
```

#### FFmpeg
```bash
# Jakość video (high, medium, low)
FF_QUALITY=high make ffmpeg mov mp4 video.mov

# Rozdzielczość i bitrate
FF_RESOLUTION=1280x720 FF_BITRATE=2M make ffmpeg avi mp4 video.avi

# Audio
FF_AUDIO_BITRATE=320k make ffmpeg flac mp3 audio.flac

# Przycinanie
FF_START_TIME=00:01:30 FF_DURATION=00:02:00 make ffmpeg mp4 mp4 video.mp4 trimmed.mp4
```

#### Pandoc
```bash
# Spis treści i numeracja
PANDOC_TOC=1 PANDOC_NUMBERED=1 make pandoc md pdf document.md

# Własny CSS
PANDOC_CSS=style.css make pandoc md html document.md

# Silnik PDF
PANDOC_PDF_ENGINE=xelatex make pandoc latex pdf document.tex

# Bibliografia
PANDOC_BIBLIO=refs.bib PANDOC_CSL=apa.csl make pandoc md pdf paper.md
```

#### LibreOffice
```bash
# Jakość PDF
LO_PDF_QUALITY=3 LO_PDF_COMPRESS=1 make libreoffice docx pdf document.docx

# Własny filtr eksportu
LO_EXPORT_FILTER="HTML (StarWriter)" make libreoffice odt html doc.odt

# Timeout
LO_TIMEOUT=120 make libreoffice xlsx pdf large_spreadsheet.xlsx
```

## 📖 Przykłady Użycia

### 🖼️ Przetwarzanie Obrazów

```bash
# Podstawowa konwersja
make imagemagick jpg png photo.jpg

# Wysoka jakość
IM_QUALITY=98 make imagemagick raw tiff photo.raw

# Zmiana rozmiaru z zachowaniem proporcji
IM_RESIZE="1920x1080>" make imagemagick png jpg screenshot.png

# Konwersja wsadowa (w skrypcie)
for file in *.jpg; do
    make imagemagick jpg webp "$file"
done

# Animacja z FFmpeg
FF_FPS=10 make ffmpeg png gif frame_%03d.png animation.gif

# SVG do wysokiej jakości PNG
make inkscape svg png vector.svg raster.png

# PDF do obrazów (każda strona)
make ghostscript pdf png document.pdf page_%02d.png
```

### 📄 Dokumenty

```bash
# Markdown do PDF z spisem treści
PANDOC_TOC=1 make pandoc md pdf README.md documentation.pdf

# Prezentacja PowerPoint do PDF
make libreoffice pptx pdf presentation.pptx

# HTML do PDF z CSS
PANDOC_CSS=styles.css make pandoc html pdf webpage.html

# LaTeX do HTML
make pandoc latex html paper.tex

# Word do format otwarty
make libreoffice docx odt document.docx

# Excel do CSV
make libreoffice xlsx csv data.xlsx

# Konwersja z bibliografią
PANDOC_BIBLIO=references.bib make pandoc md pdf thesis.md
```

### 🎵 Audio i Video

```bash
# Podstawowa konwersja video
make ffmpeg avi mp4 video.avi

# Wysokiej jakości video
FF_QUALITY=high FF_BITRATE=5M make ffmpeg mov mp4 video.mov

# Zmiana rozdzielczości
FF_RESOLUTION=1280x720 make ffmpeg mp4 mp4 video.mp4 hd_video.mp4

# Konwersja audio z wysoką jakością
FF_AUDIO_BITRATE=320k make ffmpeg flac mp3 audio.flac

# Przycinanie video
FF_START_TIME=00:01:00 FF_DURATION=00:03:00 make ffmpeg mp4 mp4 long_video.mp4 clip.mp4

# Audio processing z SoX
make sox wav mp3 recording.wav

# Video do GIF
FF_FPS=15 FF_RESOLUTION=480x270 make ffmpeg mp4 gif video.mp4 animation.gif
```

### 🔄 Łańcuchy Konwersji

Gdy bezpośrednia konwersja nie jest dostępna:

```bash
# DOC → DOCX → PDF
make libreoffice doc docx old_document.doc
make libreoffice docx pdf old_document.docx

# GIF → PNG → JPG (dla lepszej jakości)
make imagemagick gif png animation.gif
make imagemagick png jpg animation.png

# SVG → PDF → PNG (dla określonej rozdzielczości)
make inkscape svg pdf vector.svg
IM_RESIZE="2048x2048" make imagemagick pdf png vector.pdf
```

## 🛠️ Narzędzia Pomocnicze

### Lista Dostępnych Bibliotek
```bash
make list-libraries
```

### Lista Obsługiwanych Formatów
```bash
make list-formats
```

### Pomoc dla Konkretnej Biblioteki
```bash
# Szczegółowa pomoc
make imagemagick --help
make pandoc --help
make ffmpeg --help

# Krótki opis
./converters/imagemagick.sh --description
```

### Sprawdzenie Wsparcia Formatu
```bash
# Czy biblioteka obsługuje konwersję?
./converters/imagemagick.sh --check-support jpg png
echo $?  # 0 = tak, 1 = nie
```

## 🔧 Rozwiązywanie Problemów

### Częste Problemy

#### "Library not found"
```bash
# Sprawdź instalację
./config/install_dependencies.sh --check

# Zainstaluj brakujące narzędzia
./config/install_dependencies.sh
```

#### "Conversion failed"
```bash
# Sprawdź czy plik istnieje
ls -la input_file.ext

# Sprawdź uprawnienia
chmod 644 input_file.ext

# Sprawdź format pliku
file input_file.ext

# Użyj verbose mode (dla niektórych konwerterów)
IM_VERBOSE=1 make imagemagick jpg png photo.jpg
```

#### "Permission denied"
```bash
# Nadaj uprawnienia skryptom
chmod +x help.sh
chmod +x converters/*.sh
chmod +x config/*.sh
```

### Debug Mode

```bash
# Włącz debug dla Makefile
make -d imagemagick jpg png photo.jpg

# Sprawdź komendy konwertera
bash -x converters/imagemagick.sh jpg png input.jpg output.png
```

### Logi i Monitoring

```bash
# Monitoruj proces konwersji
watch -n 1 'ps aux | grep -E "(convert|ffmpeg|pandoc|libreoffice)"'

# Sprawdź wykorzystanie zasobów
htop

# Logi systemowe (Linux)
journalctl -f | grep -E "(convert|ffmpeg|pandoc)"
```

## 📊 Porównanie Wydajności

### Szybkość Konwersji (relatywna)

| Konwersja | ImageMagick | GraphicsMagick | FFmpeg | Inkscape |
|-----------|-------------|----------------|--------|----------|
| JPG → PNG | 3/5 | 4/5 | 5/5 | - |
| SVG → PNG | 2/5 | - | - | 4/5 |
| PDF → PNG | 3/5 | 3/5 | 4/5 | - |

### Jakość Konwersji

| Konwersja | ImageMagick | GraphicsMagick | FFmpeg | Inkscape |
|-----------|-------------|----------------|--------|----------|
| JPG → PNG | 5/5 | 4/5 | 4/5 | - |
| SVG → PNG | 4/5 | - | - | 5/5 |
| PDF → PNG | 4/5 | 3/5 | 3/5 | - |

## 🔐 Bezpieczeństwo

### Weryfikacja Plików
```bash
# Sprawdź typ pliku przed konwersją
file suspicious_file.jpg

# Ograniczenia rozmiaru (przykład)
MAX_SIZE=100M timeout 300 make imagemagick jpg png large_file.jpg
```

### Izolacja Procesów
```bash
# Uruchom w sandboxie (Linux)
firejail --private=temp make imagemagick jpg png photo.jpg

# Ograniczenia zasobów
ulimit -v 1000000  # Limit pamięci (KB)
ulimit -t 300      # Limit czasu CPU (sekundy)
```

## 🤝 Rozszerzanie Systemu

### Dodawanie Nowej Biblioteki

1. Stwórz plik `converters/new_library.sh`
2. Zaimplementuj wymagane funkcje:
   - `show_help()`
   - `check_support()`
   - `get_quality_rating()`
   - `get_speed_rating()`
   - `convert_file()`
3. Dodaj wpis do Makefile
4. Przetestuj funkcjonalność

### Szablon Nowego Konwertera

```bash
#!/bin/bash
# New Library Converter Template

SUPPORTED_INPUT="format1 format2"
SUPPORTED_OUTPUT="format3 format4"

show_help() {
    echo "Help for new library"
}

check_support() {
    local from_format="$1"
    local to_format="$2"
    # Implementacja sprawdzania wsparcia
}

convert_file() {
    local from_format="$1"
    local to_format="$2"
    local input_file="$3"
    local output_file="$4"
    # Implementacja konwersji
}

# Handle arguments...
```

## 📞 Wsparcie

### Zgłaszanie Problemów
- Użyj `make check-conflicts` przed zgłoszeniem
- Dołącz wyjście `./config/install_dependencies.sh --check`
- Podaj przykład komendy, która nie działa

### Prośby o Nowe Funkcje
- Sprawdź czy biblioteka jest już obsługiwana
- Podaj przypadki użycia
- Zaproponuj implementację

## 📜 Licencja

Ten projekt jest udostępniany na licencji Apache 2. Zobacz plik LICENSE.

## 🙏 Podziękowania

- Społeczność ImageMagick
- Projekt Pandoc
- Zespół FFmpeg
- Wszyscy kontrybutorzy bibliotek open source
