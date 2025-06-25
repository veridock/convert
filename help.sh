#!/bin/bash

# Universal File Converter - Interactive Help System
# Main entry point for the conversion system

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

CONVERTER_DIR="./converters"
HELP_DIR="./help"

# Function to display header
show_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        Universal File Converter System        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to show main help
show_main_help() {
    show_header

    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 [from_format] [to_format]  # Find converters for specific conversion"
    echo "  $0 --help                     # Show this help"
    echo "  $0 --list                     # List all available formats"
    echo ""

    echo -e "${CYAN}Quick Commands:${NC}"
    echo "  make help                      # Show Makefile help"
    echo "  make list-libraries            # List available converter libraries"
    echo "  make search [from] [to]        # Search for converters"
    echo "  make validate [file]           # Validate file format"
    echo "  make benchmark [file] [from] [to]  # Benchmark conversions"
    echo ""

    echo -e "${GREEN}Examples:${NC}"
    echo "  $0 pdf svg                     # Find PDF to SVG converters"
    echo "  $0 jpg png                     # Find JPG to PNG converters"
    echo "  make imagemagick jpg png input.jpg output.png"
    echo "  make pandoc md pdf document.md"
    echo ""

    echo -e "${PURPLE}Available Converter Libraries:${NC}"
    if [ -d "$CONVERTER_DIR" ]; then
        for converter in "$CONVERTER_DIR"/*.sh; do
            if [ -f "$converter" ] && [ "$(basename "$converter")" != "_template.sh" ]; then
                converter_name=$(basename "$converter" .sh)
                echo -e "  • ${GREEN}$converter_name${NC}"
            fi
        done
    else
        echo -e "  ${YELLOW}No converters found (run ./config/install_dependencies.sh)${NC}"
    fi
    echo ""

    echo -e "${BLUE}Next Steps:${NC}"
    echo "  1. Install dependencies: ./config/install_dependencies.sh"
    echo "  2. Check status: ./config/install_dependencies.sh --check"
    echo "  3. Try a conversion: make imagemagick jpg png sample.jpg"
    echo "  4. Read documentation: cat README.md"
}

# Function to show all supported formats
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

# Function to find converters for specific format conversion
find_converters() {
    local from_format="$1"
    local to_format="$2"
    local converters=()
    local counter=1

    echo -e "${YELLOW}Searching for converters: ${from_format} → ${to_format}${NC}"
    echo ""

    if [ ! -d "$CONVERTER_DIR" ]; then
        echo -e "${RED}Converters directory not found${NC}"
        echo "Please run: ./config/install_dependencies.sh"
        return 1
    fi

    # Check each converter
    for converter in "$CONVERTER_DIR"/*.sh; do
        if [ -f "$converter" ] && [ "$(basename "$converter")" != "_template.sh" ]; then
            converter_name=$(basename "$converter" .sh)

            # For now, show basic info since converters are stubs
            echo -e "${GREEN}[$counter]${NC} ${CYAN}$converter_name${NC}"
            echo -e "    Status: Available (implementation needed)"
            echo -e "    Command: make $converter_name $from_format $to_format [input] [output]"
            echo ""

            converters+=("$converter_name")
            ((counter++))
        fi
    done

    if [ ${#converters[@]} -eq 0 ]; then
        echo -e "${RED}No converters found${NC}"
        echo ""
        echo -e "${YELLOW}Suggestions:${NC}"
        echo "• Install dependencies: ./config/install_dependencies.sh"
        echo "• Check available formats: $0 --list"
        echo "• Read documentation: cat README.md"
        return 1
    fi

    echo -e "${PURPLE}Total converters found: ${#converters[@]}${NC}"
    echo ""
    echo -e "${BLUE}Example usage:${NC}"
    echo "make ${converters[0]} $from_format $to_format input.$from_format output.$to_format"
}

# Function to show quick setup guide
show_quick_setup() {
    echo -e "${BLUE}Quick Setup Guide:${NC}"
    echo ""

    echo -e "${YELLOW}1. Install Dependencies:${NC}"
    echo "   ./config/install_dependencies.sh"
    echo ""

    echo -e "${YELLOW}2. Check Installation:${NC}"
    echo "   ./config/install_dependencies.sh --check"
    echo ""

    echo -e "${YELLOW}3. Try Basic Conversion:${NC}"
    echo "   # Create a test file"
    echo "   echo 'Hello World' > test.txt"
    echo "   # Convert (when pandoc is available)"
    echo "   make pandoc txt md test.txt test.md"
    echo ""

    echo -e "${YELLOW}4. Explore Features:${NC}"
    echo "   make search jpg png    # Find converters"
    echo "   make list-libraries    # List libraries"
    echo "   make help             # Show all options"
    echo ""
}

# Main function
main() {
    case "${1:-help}" in
        "--help"|"-h"|"help")
            show_main_help
            ;;
        "--list"|"list")
            show_all_formats
            ;;
        "--setup"|"setup")
            show_quick_setup
            ;;
        "")
            show_main_help
            ;;
        *)
            if [ $# -eq 2 ]; then
                find_converters "$1" "$2"
            else
                echo -e "${RED}Invalid arguments${NC}"
                echo "Usage: $0 [from_format] [to_format]"
                echo "       $0 --help"
                exit 1
            fi
            ;;
    esac
}

# Check if we're in the right directory
if [ ! -f "Makefile" ]; then
    echo -e "${RED}Error: Not in Universal File Converter directory${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Run main function with all arguments
main "$@"
