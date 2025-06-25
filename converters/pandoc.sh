#!/bin/bash

# Pandoc Converter
# Supports: Document format conversions, markup languages

SUPPORTED_INPUT="md markdown txt rst latex tex html xhtml docx odt epub fb2 json yaml"
SUPPORTED_OUTPUT="md markdown txt rst latex tex html xhtml docx odt epub pdf ps json yaml"

# Quality ratings for document conversions
declare -A QUALITY_MATRIX=(
    ["md,html"]="5"      ["html,md"]="4"
    ["md,pdf"]="4"       ["docx,pdf"]="5"
    ["md,docx"]="4"      ["docx,md"]="3"
    ["html,pdf"]="4"     ["latex,pdf"]="5"
    ["rst,html"]="5"     ["html,rst"]="4"
    ["epub,pdf"]="3"     ["pdf,epub"]="2"
    ["docx,odt"]="4"     ["odt,docx"]="4"
    ["md,latex"]="4"     ["latex,md"]="3"
)

declare -A SPEED_MATRIX=(
    ["md,html"]="5"      ["html,md"]="4"
    ["md,pdf"]="3"       ["docx,pdf"]="3"
    ["md,docx"]="3"      ["docx,md"]="4"
    ["html,pdf"]="3"     ["latex,pdf"]="2"
    ["rst,html"]="4"     ["html,rst"]="4"
    ["epub,pdf"]="2"     ["pdf,epub"]="1"
    ["docx,odt"]="3"     ["odt,docx"]="3"
    ["md,latex"]="4"     ["latex,md"]="4"
)

show_help() {
    cat << EOF
Pandoc Document Converter Help
==============================

Pandoc is a universal document converter supporting many markup formats.

Supported Input Formats:
  $SUPPORTED_INPUT

Supported Output Formats:
  $SUPPORTED_OUTPUT

Environment Variables:
  PANDOC_TEMPLATE    - Custom template file
  PANDOC_CSS         - CSS file for HTML output
  PANDOC_BIBLIO      - Bibliography file
  PANDOC_CSL         - Citation style file
  PANDOC_TOC         - Set to '1' to include table of contents
  PANDOC_NUMBERED    - Set to '1' to number sections

PDF Engine Options (set via PANDOC_PDF_ENGINE):
  - pdflatex (default)
  - xelatex (better Unicode support)
  - lualatex (Lua extensions)
  - wkhtmltopdf (HTML to PDF)
  - weasyprint (CSS-based PDF)

Examples:
  PANDOC_TOC=1 make pandoc md pdf document.md
  PANDOC_CSS=style.css make pandoc md html document.md
  PANDOC_PDF_ENGINE=xelatex make pandoc latex pdf document.tex
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

normalize_format() {
    local format="$1"
    case "$format" in
        md) echo "markdown" ;;
        tex) echo "latex" ;;
        *) echo "$format" ;;
    esac
}

convert_file() {
    local from_format="$1"
    local to_format="$2"
    local input_file="$3"
    local output_file="$4"

    # Check if Pandoc is installed
    if ! command -v pandoc &> /dev/null; then
        echo "Error: Pandoc not installed. Install with: sudo apt-get install pandoc"
        return 1
    fi

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' does not exist"
        return 1
    fi

    # Normalize format names
    local norm_from=$(normalize_format "$from_format")
    local norm_to=$(normalize_format "$to_format")

    # Build Pandoc command
    local cmd="pandoc"
    local options=()

    # Input format
    options+=("-f" "$norm_from")

    # Output format
    options+=("-t" "$norm_to")

    # Input file
    options+=("$input_file")

    # Output file
    options+=("-o" "$output_file")

    # Format-specific options
    case "$norm_to" in
        pdf)
            if [ -n "$PANDOC_PDF_ENGINE" ]; then
                options+=("--pdf-engine=$PANDOC_PDF_ENGINE")
            fi

            # PDF-specific options
            options+=("-V" "geometry:margin=1in")

            if [ "$PANDOC_TOC" = "1" ]; then
                options+=("--toc")
            fi

            if [ "$PANDOC_NUMBERED" = "1" ]; then
                options+=("--number-sections")
            fi
            ;;

        html|xhtml)
            if [ -n "$PANDOC_CSS" ]; then
                options+=("--css=$PANDOC_CSS")
            fi

            if [ "$PANDOC_TOC" = "1" ]; then
                options+=("--toc")
            fi

            options+=("--standalone")
            ;;

        docx)
            if [ -n "$PANDOC_TEMPLATE" ]; then
                options+=("--reference-doc=$PANDOC_TEMPLATE")
            fi
            ;;

        latex)
            if [ "$PANDOC_TOC" = "1" ]; then
                options+=("--toc")
            fi

            if [ "$PANDOC_NUMBERED" = "1" ]; then
                options+=("--number-sections")
            fi
            ;;

        epub)
            if [ -n "$PANDOC_CSS" ]; then
                options+=("--css=$PANDOC_CSS")
            fi

            if [ "$PANDOC_TOC" = "1" ]; then
                options+=("--toc")
            fi
            ;;
    esac

    # Bibliography options
    if [ -n "$PANDOC_BIBLIO" ]; then
        options+=("--bibliography=$PANDOC_BIBLIO")

        if [ -n "$PANDOC_CSL" ]; then
            options+=("--csl=$PANDOC_CSL")
        fi
    fi

    # Custom template
    if [ -n "$PANDOC_TEMPLATE" ] && [ "$norm_to" != "docx" ]; then
        options+=("--template=$PANDOC_TEMPLATE")
    fi

    # Execute conversion
    echo "Executing: $cmd ${options[*]}"
    if "$cmd" "${options[@]}"; then
        echo "✓ Conversion successful: $output_file"

        # Show file info
        if [ -f "$output_file" ]; then
            file_size=$(du -h "$output_file" | cut -f1)
            echo "Output size: $file_size"
        fi

        return 0
    else
        echo "✗ Conversion failed"
        return 1
    fi
}

# Handle command line arguments
case "$1" in
    --help)
        show_help
        ;;
    --description)
        echo "Pandoc - Universal document converter for markup formats"
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
