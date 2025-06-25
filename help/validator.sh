#!/bin/bash

# File Validator - Comprehensive file format validation and integrity checking

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to detect file format
detect_format() {
    local file="$1"

    # Use file command for magic number detection
    local file_output=$(file -b "$file" 2>/dev/null)

    # Extract format from file output
    case "$file_output" in
        *"JPEG image"*) echo "jpg" ;;
        *"PNG image"*) echo "png" ;;
        *"GIF image"*) echo "gif" ;;
        *"TIFF image"*) echo "tiff" ;;
        *"Bitmap image"*|*"PC bitmap"*) echo "bmp" ;;
        *"SVG"*) echo "svg" ;;
        *"PDF document"*) echo "pdf" ;;
        *"PostScript"*) echo "ps" ;;
        *"EPS"*) echo "eps" ;;
        *"WebP"*) echo "webp" ;;
        *"Microsoft Word"*|*"DOCX"*) echo "docx" ;;
        *"Microsoft Excel"*|*"XLSX"*) echo "xlsx" ;;
        *"Microsoft PowerPoint"*|*"PPTX"*) echo "pptx" ;;
        *"OpenDocument Text"*) echo "odt" ;;
        *"OpenDocument Spreadsheet"*) echo "ods" ;;
        *"OpenDocument Presentation"*) echo "odp" ;;
        *"HTML"*) echo "html" ;;
        *"XML"*) echo "xml" ;;
        *"ASCII text"*|*"UTF-8"*)
            # Check extension for text files
            case "${file,,}" in
                *.md|*.markdown) echo "md" ;;
                *.tex|*.latex) echo "latex" ;;
                *.rst) echo "rst" ;;
                *.csv) echo "csv" ;;
                *.json) echo "json" ;;
                *.yaml|*.yml) echo "yaml" ;;
                *) echo "txt" ;;
            esac ;;
        *"WAVE audio"*) echo "wav" ;;
        *"MP3"*|*"MPEG"*"audio"*) echo "mp3" ;;
        *"FLAC audio"*) echo "flac" ;;
        *"Ogg"*) echo "ogg" ;;
        *"MP4"*|*"MPEG-4"*) echo "mp4" ;;
        *"AVI"*) echo "avi" ;;
        *"Matroska"*) echo "mkv" ;;
        *"WebM"*) echo "webm" ;;
        *) echo "unknown" ;;
    esac
}

# Function to get file extension
get_extension() {
    local file="$1"
    echo "${file##*.}" | tr '[:upper:]' '[:lower:]'
}

# Function to validate image files
validate_image() {
    local file="$1"
    local format="$2"
    local issues=()

    # Check with ImageMagick if available
    if command -v identify >/dev/null 2>&1; then
        local identify_output=$(identify "$file" 2>&1)
        if [ $? -ne 0 ]; then
            issues+=("ImageMagick identify failed: ${identify_output}")
        else
            local dimensions=$(echo "$identify_output" | awk '{print $3}')
            local depth=$(echo "$identify_output" | awk '{print $5}')
            echo -e "  ${GREEN}✓${NC} Dimensions: $dimensions"
            echo -e "  ${GREEN}✓${NC} Color depth: $depth"
        fi
    fi

    # Format-specific checks
    case "$format" in
        jpg|jpeg)
            # Check for EXIF data corruption
            if command -v exiftool >/dev/null 2>&1; then
                local exif_check=$(exiftool "$file" 2>&1 | grep -i error)
                if [ -n "$exif_check" ]; then
                    issues+=("EXIF data issues: $exif_check")
                fi
            fi
            ;;
        png)
            # Check PNG integrity
            if command -v pngcheck >/dev/null 2>&1; then
                local png_check=$(pngcheck "$file" 2>&1)
                if [ $? -ne 0 ]; then
                    issues+=("PNG integrity check failed: $png_check")
                fi
            fi
            ;;
        svg)
            # Check SVG syntax
            if command -v xmllint >/dev/null 2>&1; then
                local xml_check=$(xmllint --noout "$file" 2>&1)
                if [ $? -ne 0 ]; then
                    issues+=("SVG XML syntax error: $xml_check")
                fi
            fi
            ;;
    esac

    # Print issues
    for issue in "${issues[@]}"; do
        echo -e "  ${RED}✗${NC} $issue"
    done

    return ${#issues[@]}
}

# Function to validate document files
validate_document() {
    local file="$1"
    local format="$2"
    local issues=()

    case "$format" in
        pdf)
            # Check PDF integrity
            if command -v pdftk >/dev/null 2>&1; then
                local pdf_info=$(pdftk "$file" dump_data 2>&1)
                if [ $? -eq 0 ]; then
                    local pages=$(echo "$pdf_info" | grep "NumberOfPages" | awk '{print $2}')
                    echo -e "  ${GREEN}✓${NC} Pages: $pages"
                else
                    issues+=("PDF structure check failed")
                fi
            elif command -v pdfinfo >/dev/null 2>&1; then
                local pdf_info=$(pdfinfo "$file" 2>&1)
                if [ $? -eq 0 ]; then
                    local pages=$(echo "$pdf_info" | grep "Pages:" | awk '{print $2}')
                    echo -e "  ${GREEN}✓${NC} Pages: $pages"
                else
                    issues+=("PDF info extraction failed")
                fi
            fi
            ;;
        docx|xlsx|pptx)
            # Check Office document integrity (they are ZIP files)
            if command -v unzip >/dev/null 2>&1; then
                local zip_test=$(unzip -t "$file" 2>&1)
                if [ $? -ne 0 ]; then
                    issues+=("Office document ZIP structure corrupted")
                else
                    echo -e "  ${GREEN}✓${NC} ZIP structure valid"
                fi
            fi
            ;;
        html|xml)
            # Check XML/HTML syntax
            if command -v xmllint >/dev/null 2>&1; then
                local xml_check
                if [ "$format" = "html" ]; then
                    xml_check=$(xmllint --html --noout "$file" 2>&1)
                else
                    xml_check=$(xmllint --noout "$file" 2>&1)
                fi
                if [ $? -ne 0 ]; then
                    issues+=("Syntax error: $xml_check")
                else
                    echo -e "  ${GREEN}✓${NC} Syntax valid"
                fi
            fi
            ;;
        md|markdown)
            # Basic Markdown validation
            local line_count=$(wc -l < "$file")
            echo -e "  ${GREEN}✓${NC} Lines: $line_count"

            # Check for common Markdown syntax
            if grep -q "^#" "$file"; then
                echo -e "  ${GREEN}✓${NC} Contains headers"
            fi
            ;;
        json)
            # Validate JSON syntax
            if command -v jq >/dev/null 2>&1; then
                local json_check=$(jq empty "$file" 2>&1)
                if [ $? -ne 0 ]; then
                    issues+=("JSON syntax error: $json_check")
                else
                    echo -e "  ${GREEN}✓${NC} JSON syntax valid"
                fi
            elif command -v python3 >/dev/null 2>&1; then
                local json_check=$(python3 -m json.tool "$file" >/dev/null 2>&1)
                if [ $? -ne 0 ]; then
                    issues+=("JSON syntax error")
                else
                    echo -e "  ${GREEN}✓${NC} JSON syntax valid"
                fi
            fi
            ;;
        csv)
            # Validate CSV structure
            local line_count=$(wc -l < "$file")
            local first_line=$(head -n 1 "$file")
            local field_count=$(echo "$first_line" | tr ',' '\n' | wc -l)

            echo -e "  ${GREEN}✓${NC} Lines: $line_count"
            echo -e "  ${GREEN}✓${NC} Fields in header: $field_count"

            # Check for consistent field count
            local inconsistent_lines=$(awk -F',' -v expected="$field_count" 'NF != expected {print NR}' "$file" | head -5)
            if [ -n "$inconsistent_lines" ]; then
                issues+=("Inconsistent field count on lines: $inconsistent_lines")
            fi
            ;;
    esac

    # Print issues
    for issue in "${issues[@]}"; do
        echo -e "  ${RED}✗${NC} $issue"
    done

    return ${#issues[@]}
}

# Function to validate audio/video files
validate_media() {
    local file="$1"
    local format="$2"
    local issues=()

    # Check with FFprobe if available
    if command -v ffprobe >/dev/null 2>&1; then
        local ffprobe_output=$(ffprobe -v quiet -print_format json -show_format -show_streams "$file" 2>&1)
        if [ $? -ne 0 ]; then
            issues+=("FFprobe analysis failed: $ffprobe_output")
        else
            # Extract basic info
            if command -v jq >/dev/null 2>&1; then
                local duration=$(echo "$ffprobe_output" | jq -r '.format.duration // "unknown"')
                local bitrate=$(echo "$ffprobe_output" | jq -r '.format.bit_rate // "unknown"')
                local streams=$(echo "$ffprobe_output" | jq -r '.streams | length')

                echo -e "  ${GREEN}✓${NC} Duration: ${duration}s"
                echo -e "  ${GREEN}✓${NC} Bitrate: $bitrate"
                echo -e "  ${GREEN}✓${NC} Streams: $streams"

                # Check for video streams
                local video_streams=$(echo "$ffprobe_output" | jq -r '[.streams[] | select(.codec_type=="video")] | length')
                local audio_streams=$(echo "$ffprobe_output" | jq -r '[.streams[] | select(.codec_type=="audio")] | length')

                if [ "$video_streams" -gt 0 ]; then
                    echo -e "  ${GREEN}✓${NC} Video streams: $video_streams"
                    local resolution=$(echo "$ffprobe_output" | jq -r '.streams[] | select(.codec_type=="video") | "\(.width)x\(.height)" | select(. != "nullxnull")' | head -1)
                    if [ -n "$resolution" ] && [ "$resolution" != "nullxnull" ]; then
                        echo -e "  ${GREEN}✓${NC} Resolution: $resolution"
                    fi
                fi

                if [ "$audio_streams" -gt 0 ]; then
                    echo -e "  ${GREEN}✓${NC} Audio streams: $audio_streams"
                    local sample_rate=$(echo "$ffprobe_output" | jq -r '.streams[] | select(.codec_type=="audio") | .sample_rate | select(. != null)' | head -1)
                    if [ -n "$sample_rate" ]; then
                        echo -e "  ${GREEN}✓${NC} Sample rate: ${sample_rate}Hz"
                    fi
                fi
            fi
        fi
    fi

    # Format-specific checks
    case "$format" in
        wav)
            # Check WAV header
            if command -v soxi >/dev/null 2>&1; then
                local wav_info=$(soxi "$file" 2>&1)
                if [ $? -ne 0 ]; then
                    issues+=("WAV header validation failed")
                fi
            fi
            ;;
        mp3)
            # Check MP3 integrity
            if command -v mp3val >/dev/null 2>&1; then
                local mp3_check=$(mp3val "$file" 2>&1)
                if echo "$mp3_check" | grep -q "ERROR"; then
                    issues+=("MP3 integrity issues found")
                fi
            fi
            ;;
    esac

    # Print issues
    for issue in "${issues[@]}"; do
        echo -e "  ${RED}✗${NC} $issue"
    done

    return ${#issues[@]}
}

# Function to check file accessibility and permissions
check_file_access() {
    local file="$1"
    local issues=()

    # Check if file exists
    if [ ! -f "$file" ]; then
        echo -e "  ${RED}✗${NC} File does not exist"
        return 1
    fi

    # Check if file is readable
    if [ ! -r "$file" ]; then
        issues+=("File is not readable")
    else
        echo -e "  ${GREEN}✓${NC} File is readable"
    fi

    # Check file size
    local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    if [ "$file_size" -eq 0 ]; then
        issues+=("File is empty (0 bytes)")
    else
        local human_size=$(numfmt --to=iec-i --suffix=B "$file_size" 2>/dev/null || echo "${file_size} bytes")
        echo -e "  ${GREEN}✓${NC} File size: $human_size"
    fi

    # Check file permissions
    local perms=$(stat -f%Mp%Lp "$file" 2>/dev/null || stat -c%a "$file" 2>/dev/null)
    echo -e "  ${GREEN}✓${NC} Permissions: $perms"

    # Print issues
    for issue in "${issues[@]}"; do
        echo -e "  ${RED}✗${NC} $issue"
    done

    return ${#issues[@]}
}

# Function to suggest converters for the detected format
suggest_converters() {
    local format="$1"
    local converters=()

    echo -e "${BLUE}Available converters for $format:${NC}"

    # Check each converter
    for converter in ../converters/*.sh; do
        if [ -f "$converter" ]; then
            converter_name=$(basename "$converter" .sh)

            # Get supported formats
            local supported_input=$(bash "$converter" --list-formats 2>/dev/null | grep "Input:" | cut -d: -f2)
            local supported_output=$(bash "$converter" --list-formats 2>/dev/null | grep "Output:" | cut -d: -f2)

            if [[ " $supported_input " =~ " $format " ]] || [[ " $supported_output " =~ " $format " ]]; then
                converters+=("$converter_name")
                local description=$(bash "$converter" --description 2>/dev/null || echo "No description")
                echo -e "  ${GREEN}•${NC} $converter_name - $description"
            fi
        fi
    done

    if [ ${#converters[@]} -eq 0 ]; then
        echo -e "  ${YELLOW}No converters found for format: $format${NC}"
    fi
}

# Function to perform security checks
security_check() {
    local file="$1"
    local format="$2"
    local warnings=()

    # Check file size limits
    local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    local max_size=$((100 * 1024 * 1024))  # 100MB

    if [ "$file_size" -gt "$max_size" ]; then
        warnings+=("Large file size (>100MB) - may cause performance issues")
    fi

    # Check for suspicious extensions
    local extension=$(get_extension "$file")
    local detected_format=$(detect_format "$file")

    if [ "$extension" != "$detected_format" ] && [ "$detected_format" != "unknown" ]; then
        warnings+=("Extension mismatch: .$extension but detected as $detected_format")
    fi

    # Format-specific security checks
    case "$format" in
        svg)
            # Check for script tags in SVG
            if grep -qi "<script" "$file"; then
                warnings+=("SVG contains script tags - potential security risk")
            fi
            ;;
        html)
            # Check for script tags
            if grep -qi "<script" "$file"; then
                warnings+=("HTML contains script tags")
            fi
            ;;
        pdf)
            # Check for JavaScript in PDF
            if command -v pdfinfo >/dev/null 2>&1; then
                local js_check=$(strings "$file" | grep -i javascript | head -1)
                if [ -n "$js_check" ]; then
                    warnings+=("PDF may contain JavaScript")
                fi
            fi
            ;;
    esac

    # Print warnings
    if [ ${#warnings[@]} -gt 0 ]; then
        echo -e "${YELLOW}Security Warnings:${NC}"
        for warning in "${warnings[@]}"; do
            echo -e "  ${YELLOW}⚠${NC} $warning"
        done
    else
        echo -e "  ${GREEN}✓${NC} No security issues detected"
    fi

    return ${#warnings[@]}
}

# Main validation function
main() {
    local file="$1"

    if [ $# -ne 1 ]; then
        echo "Usage: $0 [file]"
        echo "       $0 --help"
        exit 1
    fi

    if [ "$1" = "--help" ]; then
        cat << 'EOF'
File Validator - Comprehensive file format validation and integrity checking

Usage: ./validator.sh [file]

Features:
• File format detection and verification
• Integrity checking for images, documents, and media
• Security analysis for potential risks
• Converter suggestions for detected formats
• Detailed metadata extraction

Supported validation types:
• Images: JPEG, PNG, GIF, TIFF, BMP, SVG, WebP
• Documents: PDF, DOCX, XLSX, PPTX, ODT, HTML, XML, Markdown
• Data: JSON, CSV, YAML
• Media: MP3, WAV, FLAC, MP4, AVI, MKV, WebM

Examples:
  ./validator.sh document.pdf
  ./validator.sh image.jpg
  ./validator.sh data.json
EOF
        exit 0
    fi

    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                FILE VALIDATOR                    ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""

    local file="$1"
    echo -e "${YELLOW}File:${NC} $file"

    # Basic file access check
    echo -e "${PURPLE}File Access Check:${NC}"
    if ! check_file_access "$file"; then
        exit 1
    fi
    echo ""

    # Format detection
    local detected_format=$(detect_format "$file")
    local extension=$(get_extension "$file")

    echo -e "${PURPLE}Format Detection:${NC}"
    echo -e "  ${GREEN}✓${NC} Extension: .$extension"
    echo -e "  ${GREEN}✓${NC} Detected format: $detected_format"

    if [ "$extension" != "$detected_format" ] && [ "$detected_format" != "unknown" ]; then
        echo -e "  ${YELLOW}⚠${NC} Extension and detected format don't match"
    fi
    echo ""

    # Format-specific validation
    local validation_errors=0
    echo -e "${PURPLE}Format Validation:${NC}"

    case "$detected_format" in
        jpg|jpeg|png|gif|tiff|bmp|svg|webp)
            validate_image "$file" "$detected_format"
            validation_errors=$?
            ;;
        pdf|docx|xlsx|pptx|odt|ods|odp|html|xml|md|json|csv|yaml)
            validate_document "$file" "$detected_format"
            validation_errors=$?
            ;;
        wav|mp3|flac|aac|ogg|mp4|avi|mkv|webm)
            validate_media "$file" "$detected_format"
            validation_errors=$?
            ;;
        unknown)
            echo -e "  ${YELLOW}⚠${NC} Unknown format - limited validation available"
            ;;
        *)
            echo -e "  ${YELLOW}⚠${NC} Format not supported for detailed validation"
            ;;
    esac
    echo ""

    # Security check
    echo -e "${PURPLE}Security Analysis:${NC}"
    local security_warnings=$(security_check "$file" "$detected_format")
    echo ""

    # Converter suggestions
    if [ "$detected_format" != "unknown" ]; then
        suggest_converters "$detected_format"
        echo ""
    fi

    # Summary
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}               SUMMARY                 ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"

    if [ "$validation_errors" -eq 0 ]; then
        echo -e "${GREEN}✓ File validation passed${NC}"
    else
        echo -e "${RED}✗ File validation found $validation_errors issue(s)${NC}"
    fi

    if [ "$security_warnings" -eq 0 ]; then
        echo -e "${GREEN}✓ No security concerns${NC}"
    else
        echo -e "${YELLOW}⚠ $security_warnings security warning(s)${NC}"
    fi

    # Suggest next actions
    echo ""
    echo -e "${CYAN}Suggested actions:${NC}"
    if [ "$detected_format" != "unknown" ]; then
        echo -e "• Convert with: ${GREEN}make search $detected_format [target_format]${NC}"
        echo -e "• Benchmark conversion: ${GREEN}make benchmark $file $detected_format [target_format]${NC}"
    fi
    echo -e "• Check available converters: ${GREEN}make list-libraries${NC}"

    exit $((validation_errors + security_warnings))
}

# Run main function
main "$@"
