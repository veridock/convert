#!/bin/bash

# Interactive Converter Selection Script
# Usage: ./help.sh [from_format] [to_format]

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

CONVERTER_DIR="./converters"
CONFIG_DIR="./config"

# Function to display header
show_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        Universal File Converter Helper        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to find available converters for format pair
find_converters() {
    local from_format="$1"
    local to_format="$2"
    local converters=()
    local counter=1

    echo -e "${YELLOW}Searching for converters: ${from_format} → ${to_format}${NC}"
    echo ""

    # Check each converter
    for converter in "$CONVERTER_DIR"/*.sh; do
        if [ -f "$converter" ]; then
            converter_name=$(basename "$converter" .sh)

            # Check if converter supports this format conversion
            if bash "$converter" --check-support "$from_format" "$to_format" 2>/dev/null; then
                converters+=("$converter_name")

                # Get converter info
                description=$(bash "$converter" --description 2>/dev/null || echo "No description available")
                quality=$(bash "$converter" --quality "$from_format" "$to_format" 2>/dev/null || echo "Unknown")
                speed=$(bash "$converter" --speed "$from_format" "$to_format" 2>/dev/null || echo "Unknown")

                echo -e "${GREEN}[$counter]${NC} ${CYAN}$converter_name${NC}"
                echo -e "    Description: $description"
                echo -e "    Quality: $quality | Speed: $speed"
                echo ""

                ((counter++))
            fi
        fi
    done

    if [ ${#converters[@]} -eq 0 ]; then
        echo -e "${RED}No converters found for ${from_format} → ${to_format}${NC}"
        echo ""
        echo -e "${YELLOW}Suggestions:${NC}"
        suggest_alternatives "$from_format" "$to_format"
        return 1
    fi

    # Interactive selection
    echo -e "${PURPLE}Select a converter (1-${#converters[@]}) or 'q' to quit:${NC}"
    read -r choice

    if [ "$choice" = "q" ] || [ "$choice" = "Q" ]; then
        echo "Cancelled."
        return 1
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#converters[@]} ]; then
        selected_converter="${converters[$((choice-1))]}"
        echo -e "${GREEN}Selected: $selected_converter${NC}"

        # Show example usage
        echo ""
        echo -e "${BLUE}Example usage:${NC}"
        echo "make $selected_converter $from_format $to_format input.$from_format [output.$to_format]"
        echo ""

        # Ask if user wants to see detailed help for this converter
        echo -e "${YELLOW}Show detailed help for $selected_converter? (y/N):${NC}"
        read -r show_help
        if [ "$show_help" = "y" ] || [ "$show_help" = "Y" ]; then
            bash "$CONVERTER_DIR/$selected_converter.sh" --help 2>/dev/null || echo "No detailed help available"
        fi
    else
        echo -e "${RED}Invalid selection${NC}"
        return 1
    fi
}

# Function to suggest alternatives
suggest_alternatives() {
    local from_format="$1"
    local to_format="$2"

    echo -e "${CYAN}Try these alternative approaches:${NC}"
    echo ""

    # Suggest intermediate conversions
    if [ -f "$CONFIG_DIR/conversion_chains.conf" ]; then
        echo -e "${YELLOW}Possible conversion chains:${NC}"
        grep -E "^${from_format}.*${to_format}$" "$CONFIG_DIR/conversion_chains.conf" 2>/dev/null | head -3
        echo ""
    fi

    # Suggest similar formats
    echo -e "${YELLOW}Similar formats you might consider:${NC}"
    case "$from_format" in
        jpg|jpeg) echo "  Try: png, tiff, bmp, webp" ;;
        png) echo "  Try: jpg, gif, bmp, webp" ;;
        pdf) echo "  Try: ps, eps, svg" ;;
        doc|docx) echo "  Try: odt, rtf, txt" ;;
        *) echo "  Check format compatibility with: make list-formats" ;;
    esac
    echo ""
}

# Function to show all available formats
show_all_formats() {
    echo -e "${BLUE}All Supported Formats:${NC}"
    echo ""

    echo -e "${GREEN}Image Formats:${NC}"
    echo "  Raster: jpg, jpeg, png, gif, bmp, tiff, tga, webp, ico, ppm, pgm, pbm"
    echo "  Vector: svg, eps, ps, pdf (as image), wmf, emf"
    echo ""

    echo -e "${GREEN}Document Formats:${NC}"
    echo "  Office: doc, docx, xls, xlsx, ppt, pptx, odt, ods, odp"
    echo "  Text: txt, rtf, csv, tsv, json, xml, yaml"
    echo "  Markup: html, xhtml, markdown, md, rst, latex, tex"
    echo "  eBook: epub, mobi, azw3, fb2"
    echo "  PDF: pdf, ps, eps"
    echo ""

    echo -e "${GREEN}Audio Formats:${NC}"
    echo "  Compressed: mp3, aac, ogg, opus, m4a"
    echo "  Uncompressed: wav, flac, aiff, au"
    echo ""

    echo -e "${GREEN}Video Formats:${NC}"
    echo "  Common: mp4, avi, mkv, mov, wmv, flv, webm"
    echo "  Professional: mxf, prores, dnxhd"
    echo ""
}

# Main function
main() {
    show_header

    if [ $# -eq 0 ]; then
        echo -e "${YELLOW}Usage:${NC} $0 [from_format] [to_format]"
        echo -e "${YELLOW}       $0 --list-formats"
        echo ""
        echo -e "${CYAN}Examples:${NC}"
        echo "  $0 pdf svg       # Find PDF to SVG converters"
        echo "  $0 jpg png       # Find JPG to PNG converters"
        echo "  $0 --list-formats # Show all supported formats"
        echo ""
        exit 1
    fi

    if [ "$1" = "--list-formats" ]; then
        show_all_formats
        exit 0
    fi

    if [ $# -ne 2 ]; then
        echo -e "${RED}Error: Please provide both source and target formats${NC}"
        echo "Usage: $0 [from_format] [to_format]"
        exit 1
    fi

    local from_format="${1,,}"  # Convert to lowercase
    local to_format="${2,,}"    # Convert to lowercase

    if [ "$from_format" = "$to_format" ]; then
        echo -e "${YELLOW}Warning: Source and target formats are the same${NC}"
        echo "No conversion needed!"
        exit 0
    fi

    find_converters "$from_format" "$to_format"
}

# Run main function with all arguments
main "$@"
