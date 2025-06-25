#!/bin/bash

# LibreOffice Converter
# Supports: Office document formats

SUPPORTED_INPUT="doc docx xls xlsx ppt pptx odt ods odp rtf csv txt"
SUPPORTED_OUTPUT="pdf ps eps odt ods odp docx xlsx pptx html txt csv"

declare -A QUALITY_MATRIX=(
    ["docx,pdf"]="5"     ["pdf,docx"]="2"
    ["xlsx,pdf"]="5"     ["pptx,pdf"]="5"
    ["odt,pdf"]="5"      ["ods,pdf"]="4"
    ["doc,docx"]="4"     ["docx,odt"]="4"
    ["xls,xlsx"]="4"     ["xlsx,ods"]="4"
    ["ppt,pptx"]="4"     ["pptx,odp"]="4"
    ["csv,xlsx"]="5"     ["xlsx,csv"]="4"
    ["txt,odt"]="3"      ["odt,txt"]="4"
)

declare -A SPEED_MATRIX=(
    ["docx,pdf"]="3"     ["xlsx,pdf"]="3"
    ["pptx,pdf"]="2"     ["odt,pdf"]="3"
    ["doc,docx"]="4"     ["docx,odt"]="3"
    ["xls,xlsx"]="4"     ["xlsx,ods"]="3"
    ["csv,xlsx"]="5"     ["xlsx,csv"]="5"
    ["txt,odt"]="4"      ["odt,txt"]="4"
)

show_help() {
    cat << EOF
LibreOffice Document Converter Help
===================================

LibreOffice provides robust conversion between office document formats.

Supported Input Formats:
  $SUPPORTED_INPUT

Supported Output Formats:
  $SUPPORTED_OUTPUT

Environment Variables:
  LO_EXPORT_FILTER  - Specific export filter to use
  LO_QUALITY        - Export quality (high, medium, low)
  LO_HEADLESS       - Run in headless mode (default: 1)
  LO_TIMEOUT        - Conversion timeout in seconds (default: 60)

PDF Export Options (set via LO_PDF_*):
  LO_PDF_QUALITY     - PDF quality level (1-3, 3=highest)
  LO_PDF_COMPRESS    - Enable PDF compression (1/0)
  LO_PDF_IMAGES      - Image compression level (1-3)
  LO_PDF_FORMS       - Export forms (1/0)
  LO_PDF_BOOKMARKS   - Export bookmarks (1/0)

Common Export Filters:
  PDF: writer_pdf_Export, calc_pdf_Export, impress_pdf_Export
  HTML: HTML (StarWriter), calc_html_Export
  CSV: Text - txt - csv (StarCalc)
  ODT: writer8
  DOCX: MS Word 2007 XML

Examples:
  make libreoffice docx pdf document.docx
  LO_PDF_QUALITY=3 make libreoffice xlsx pdf spreadsheet.xlsx
  LO_EXPORT_FILTER="HTML (StarWriter)" make libreoffice odt html doc.odt
EOF
}

check_support() {
    local from_format="$1"
    local to_format="$2"

    if [[ " $SUPPORTED_INPUT " =~ " $from_format " ]] && [[ " $SUPPORTED_OUTPUT " =~ " $to_format " ]]; then
        return 0
    else
        return 1
    fi
}

get_quality_rating() {
    local from_format="$1"
    local to_format="$2"
    local key="${from_format},${to_format}"

    echo "${QUALITY_MATRIX[$key]:-3}"
}

get_speed_rating() {
    local from_format="$1"
    local to_format="$2"
    local key="${from_format},${to_format}"

    echo "${SPEED_MATRIX[$key]:-3}"
}

get_export_filter() {
    local from_format="$1"
    local to_format="$2"

    # Use custom filter if specified
    if [ -n "$LO_EXPORT_FILTER" ]; then
        echo "$LO_EXPORT_FILTER"
        return
    fi

    # Auto-detect filter based on formats
    case "$to_format" in
        pdf)
            case "$from_format" in
                doc|docx|odt|rtf|txt) echo "writer_pdf_Export" ;;
                xls|xlsx|ods|csv) echo "calc_pdf_Export" ;;
                ppt|pptx|odp) echo "impress_pdf_Export" ;;
                *) echo "writer_pdf_Export" ;;
            esac
            ;;
        html)
            case "$from_format" in
                doc|docx|odt|rtf|txt) echo "HTML (StarWriter)" ;;
                xls|xlsx|ods|csv) echo "calc_html_Export" ;;
                *) echo "HTML (StarWriter)" ;;
            esac
            ;;
        csv)
            echo "Text - txt - csv (StarCalc)"
            ;;
        txt)
            echo "Text"
            ;;
        docx)
            echo "MS Word 2007 XML"
            ;;
        xlsx)
            echo "Calc MS Excel 2007 XML"
            ;;
        pptx)
            echo "Impress MS PowerPoint 2007 XML"
            ;;
        odt)
            echo "writer8"
            ;;
        ods)
            echo "calc8"
            ;;
        odp)
            echo "impress8"
            ;;
        ps)
            echo "writer_ps_Export"
            ;;
        eps)
            echo "draw_eps_Export"
            ;;
        *)
            echo ""
            ;;
    esac
}

build_filter_options() {
    local to_format="$1"
    local options=""

    case "$to_format" in
        pdf)
            # PDF export options
            local quality="${LO_PDF_QUALITY:-2}"
            local compress="${LO_PDF_COMPRESS:-1}"
            local images="${LO_PDF_IMAGES:-2}"
            local forms="${LO_PDF_FORMS:-0}"
            local bookmarks="${LO_PDF_BOOKMARKS:-1}"

            options="Quality=${quality};CompressMode=${compress};ImageCompression=${images}"
            options="${options};ExportFormFields=${forms};ExportBookmarks=${bookmarks}"

            case "$LO_QUALITY" in
                high)
                    options="${options};Quality=3;ImageCompression=1"
                    ;;
                low)
                    options="${options};Quality=1;ImageCompression=3"
                    ;;
            esac
            ;;
        csv)
            # CSV export options
            options="59,34,UTF8"  # Semicolon, quotes, UTF-8
            ;;
    esac

    echo "$options"
}

convert_file() {
    local from_format="$1"
    local to_format="$2"
    local input_file="$3"
    local output_file="$4"

    # Check if LibreOffice is installed
    if ! command -v libreoffice &> /dev/null && ! command -v soffice &> /dev/null; then
        echo "Error: LibreOffice not installed. Install with package manager."
        return 1
    fi

    # Use soffice if available, otherwise libreoffice
    local lo_cmd="libreoffice"
    if command -v soffice &> /dev/null; then
        lo_cmd="soffice"
    fi

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' does not exist"
        return 1
    fi

    # Get absolute paths
    local abs_input=$(realpath "$input_file")
    local abs_output_dir=$(dirname "$(realpath "$output_file")")
    local output_basename=$(basename "$output_file" ".$to_format")

    # Get export filter
    local export_filter=$(get_export_filter "$from_format" "$to_format")
    if [ -z "$export_filter" ]; then
        echo "Error: No export filter found for $from_format to $to_format"
        return 1
    fi

    # Build filter options
    local filter_options=$(build_filter_options "$to_format")

    # Build LibreOffice command
    local cmd="$lo_cmd"
    local options=()

    # Headless mode (default)
    if [ "${LO_HEADLESS:-1}" = "1" ]; then
        options+=("--headless")
    fi

    # Convert command
    options+=("--convert-to" "$to_format")

    # Export filter with options
    if [ -n "$filter_options" ]; then
        options+=("--infilter=$export_filter:$filter_options")
    else
        options+=("--infilter=$export_filter")
    fi

    # Output directory
    options+=("--outdir" "$abs_output_dir")

    # Input file
    options+=("$abs_input")

    # Set timeout
    local timeout_val="${LO_TIMEOUT:-60}"

    # Execute conversion with timeout
    echo "Executing: timeout ${timeout_val}s $cmd ${options[*]}"

    if timeout "${timeout_val}s" "$cmd" "${options[@]}" >/dev/null 2>&1; then
        # LibreOffice creates output with original basename
        local lo_output="$abs_output_dir/$(basename "$input_file" ".${from_format}").${to_format}"

        # Rename if needed
        if [ "$lo_output" != "$(realpath "$output_file")" ]; then
            mv "$lo_output" "$output_file" 2>/dev/null
        fi

        if [ -f "$output_file" ]; then
            echo "✓ Conversion successful: $output_file"

            # Show file info
            file_size=$(du -h "$output_file" | cut -f1)
            echo "Output size: $file_size"

            return 0
        else
            echo "✗ Conversion failed - output file not found"
            return 1
        fi
    else
        echo "✗ Conversion failed or timed out"
        return 1
    fi
}

# Handle command line arguments
case "$1" in
    --help)
        show_help
        ;;
    --description)
        echo "LibreOffice - Comprehensive office document conversion suite"
        ;;
    --list-formats)
        echo "Input: $SUPPORTED_INPUT"
        echo "Output: $SUPPORTED_OUTPUT"
        ;;
    --check-support)
        check_support "$2" "$3"
        ;;
    --quality)
        get_quality_rating "$2" "$3"
        ;;
    --speed)
        get_speed_rating "$2" "$3"
        ;;
    *)
        if [ $# -eq 4 ]; then
            convert_file "$1" "$2" "$3" "$4"
        else
            echo "Usage: $0 [from_format] [to_format] [input_file] [output_file]"
            echo "       $0 --help"
            exit 1
        fi
        ;;
esac
