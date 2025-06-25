#!/bin/bash

# ImageMagick Converter
# Supports: Most image formats, basic PDF operations

SUPPORTED_INPUT="jpg jpeg png gif bmp tiff tga webp ico svg pdf ps eps ppm pgm pbm pcx"
SUPPORTED_OUTPUT="jpg jpeg png gif bmp tiff tga webp ico svg pdf ps eps ppm pgm pbm pcx"

# Quality ratings (1-5, 5 being best)
declare -A QUALITY_MATRIX=(
    ["jpg,png"]="5"    ["png,jpg"]="4"
    ["svg,png"]="5"    ["png,svg"]="2"
    ["pdf,png"]="4"    ["png,pdf"]="3"
    ["tiff,jpg"]="4"   ["jpg,tiff"]="4"
    ["gif,png"]="5"    ["png,gif"]="3"
    ["bmp,png"]="5"    ["png,bmp"]="4"
    ["webp,png"]="5"   ["png,webp"]="4"
)

# Speed ratings (1-5, 5 being fastest)
declare -A SPEED_MATRIX=(
    ["jpg,png"]="4"    ["png,jpg"]="4"
    ["svg,png"]="2"    ["png,svg"]="3"
    ["pdf,png"]="2"    ["png,pdf"]="2"
    ["tiff,jpg"]="3"   ["jpg,tiff"]="3"
    ["gif,png"]="4"    ["png,gif"]="4"
    ["bmp,png"]="5"    ["png,bmp"]="5"
    ["webp,png"]="4"   ["png,webp"]="3"
)

show_help() {
    cat << EOF
ImageMagick Converter Help
==========================

ImageMagick is a powerful image manipulation toolkit that supports over 200 formats.

Supported Input Formats:
  $SUPPORTED_INPUT

Supported Output Formats:
  $SUPPORTED_OUTPUT

Special Features:
  - High-quality image processing
  - Batch operations
  - Image effects and transformations
  - PDF to image conversion
  - Vector to raster conversion

Quality Options (set via IM_QUALITY environment variable):
  - 95-100: Highest quality (large files)
  - 85-94:  High quality (recommended)
  - 75-84:  Good quality (balance)
  - 60-74:  Acceptable quality (smaller files)

Size Options (set via IM_RESIZE environment variable):
  - "50%": Resize to 50% of original
  - "800x600": Resize to specific dimensions
  - "800x600!": Force exact dimensions (may distort)
  - "800x600>": Only resize if larger than specified

Examples:
  IM_QUALITY=90 make imagemagick jpg png photo.jpg
  IM_RESIZE="1920x1080>" make imagemagick png jpg large.png
EOF
}

check_support() {
    local from_format="$1"
    local to_format="$2"

    # Check if formats are supported
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

convert_file() {
    local from_format="$1"
    local to_format="$2"
    local input_file="$3"
    local output_file="$4"

    # Check if ImageMagick is installed
    if ! command -v convert &> /dev/null; then
        echo "Error: ImageMagick not installed. Install with: sudo apt-get install imagemagick"
        return 1
    fi

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' does not exist"
        return 1
    fi

    # Build ImageMagick command
    local cmd="convert"
    local options=()

    # Add input file
    options+=("$input_file")

    # Format-specific input options
    case "$from_format" in
        pdf|ps|eps)
            options=("-density" "300" "${options[@]}")
            ;;
        svg)
            options=("-background" "transparent" "${options[@]}")
            ;;
    esac

    # Quality settings
    if [ -n "$IM_QUALITY" ]; then
        case "$to_format" in
            jpg|jpeg)
                options+=("-quality" "$IM_QUALITY")
                ;;
            png)
                # PNG quality is different (0-9, where 9 is best compression)
                png_quality=$((9 - (IM_QUALITY - 50) / 10))
                options+=("-quality" "$png_quality")
                ;;
            webp)
                options+=("-quality" "$IM_QUALITY")
                ;;
        esac
    fi

    # Resize options
    if [ -n "$IM_RESIZE" ]; then
        options+=("-resize" "$IM_RESIZE")
    fi

    # Format-specific output options
    case "$to_format" in
        jpg|jpeg)
            options+=("-background" "white" "-flatten")
            ;;
        png)
            if [ "$from_format" != "svg" ]; then
                options+=("-background" "transparent")
            fi
            ;;
        gif)
            options+=("-colors" "256")
            ;;
        webp)
            options+=("-define" "webp:lossless=false")
            ;;
    esac

    # Add output file
    options+=("$output_file")

    # Execute conversion
    echo "Executing: $cmd ${options[*]}"
    if "$cmd" "${options[@]}"; then
        echo "✓ Conversion successful: $output_file"

        # Show file info
        if command -v identify &> /dev/null; then
            echo "Output info: $(identify "$output_file")"
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
        echo "ImageMagick - Comprehensive image manipulation and conversion toolkit"
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
