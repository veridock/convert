#!/bin/bash

# Conflict Checker - Finds overlapping format support between converters

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

CONVERTER_DIR="../converters"

# Function to get supported formats from a converter
get_converter_formats() {
    local converter="$1"
    local direction="$2"  # input or output

    if [ ! -f "$converter" ]; then
        return 1
    fi

    local formats
    if [ "$direction" = "input" ]; then
        formats=$(bash "$converter" --list-formats 2>/dev/null | grep "Input:" | cut -d: -f2)
    else
        formats=$(bash "$converter" --list-formats 2>/dev/null | grep "Output:" | cut -d: -f2)
    fi

    echo "$formats"
}

# Function to find all possible conversions
find_all_conversions() {
    declare -A conversions

    echo -e "${BLUE}Scanning all converters for supported conversions...${NC}"
    echo ""

    for converter in "$CONVERTER_DIR"/*.sh; do
        if [ -f "$converter" ]; then
            converter_name=$(basename "$converter" .sh)
            echo -n "Scanning $converter_name... "

            input_formats=$(get_converter_formats "$converter" "input")
            output_formats=$(get_converter_formats "$converter" "output")

            if [ -n "$input_formats" ] && [ -n "$output_formats" ]; then
                for input_fmt in $input_formats; do
                    for output_fmt in $output_formats; do
                        if [ "$input_fmt" != "$output_fmt" ]; then
                            key="${input_fmt}_to_${output_fmt}"
                            if [ -z "${conversions[$key]}" ]; then
                                conversions[$key]="$converter_name"
                            else
                                conversions[$key]="${conversions[$key]},$converter_name"
                            fi
                        fi
                    done
                done
                echo -e "${GREEN}✓${NC}"
            else
                echo -e "${YELLOW}⚠ (no format info)${NC}"
            fi
        fi
    done

    echo ""
    echo -e "${CYAN}Analysis Results:${NC}"
    echo "=================="

    # Find conflicts (multiple converters for same conversion)
    local conflicts=0
    local total_conversions=0

    for key in "${!conversions[@]}"; do
        IFS=',' read -ra converters_array <<< "${conversions[$key]}"
        total_conversions=$((total_conversions + 1))

        if [ ${#converters_array[@]} -gt 1 ]; then
            conflicts=$((conflicts + 1))
            from_fmt=$(echo "$key" | cut -d'_' -f1)
            to_fmt=$(echo "$key" | cut -d'_' -f3)

            echo -e "${YELLOW}Conflict:${NC} $from_fmt → $to_fmt"
            echo -e "  Available converters: ${GREEN}${conversions[$key]/,/, }${NC}"

            # Show quality/speed ratings if available
            echo "  Ratings:"
            for conv in "${converters_array[@]}"; do
                quality=$(bash "$CONVERTER_DIR/$conv.sh" --quality "$from_fmt" "$to_fmt" 2>/dev/null || echo "?")
                speed=$(bash "$CONVERTER_DIR/$conv.sh" --speed "$from_fmt" "$to_fmt" 2>/dev/null || echo "?")
                printf "    %-15s Quality: %s/5, Speed: %s/5\n" "$conv" "$quality" "$speed"
            done
            echo ""
        fi
    done

    echo -e "${BLUE}Summary:${NC}"
    echo "  Total conversions supported: $total_conversions"
    echo "  Conversions with conflicts: $conflicts"
    echo "  Unique conversions: $((total_conversions - conflicts))"

    if [ $conflicts -gt 0 ]; then
        echo ""
        echo -e "${PURPLE}💡 Tip:${NC} Use './help.sh [from_format] [to_format]' to interactively choose between conflicting converters"
    fi
}

# Function to show format coverage matrix
show_format_matrix() {
    echo -e "${BLUE}Format Conversion Matrix${NC}"
    echo "======================="
    echo ""

    # Get all unique formats
    local all_formats=()
    for converter in "$CONVERTER_DIR"/*.sh; do
        if [ -f "$converter" ]; then
            input_formats=$(get_converter_formats "$converter" "input")
            output_formats=$(get_converter_formats "$converter" "output")

            for fmt in $input_formats $output_formats; do
                if [[ ! " ${all_formats[*]} " =~ " $fmt " ]]; then
                    all_formats+=("$fmt")
                fi
            done
        fi
    done

    # Sort formats
    IFS=$'\n' all_formats=($(sort <<<"${all_formats[*]}"))

    # Create matrix header
    printf "%-8s" "From/To"
    for fmt in "${all_formats[@]:0:10}"; do  # Limit to first 10 for readability
        printf "%-6s" "$fmt"
    done
    echo ""

    # Create matrix rows
    for from_fmt in "${all_formats[@]:0:10}"; do
        printf "%-8s" "$from_fmt"
        for to_fmt in "${all_formats[@]:0:10}"; do
            if [ "$from_fmt" = "$to_fmt" ]; then
                printf "%-6s" "-"
            else
                # Check if conversion exists
                local converter_count=0
                for converter in "$CONVERTER_DIR"/*.sh; do
                    if [ -f "$converter" ]; then
                        if bash "$converter" --check-support "$from_fmt" "$to_fmt" 2>/dev/null; then
                            converter_count=$((converter_count + 1))
                        fi
                    fi
                done

                if [ $converter_count -eq 0 ]; then
                    printf "%-6s" "✗"
                elif [ $converter_count -eq 1 ]; then
                    printf "%-6s" "✓"
                else
                    printf "%-6s" "$converter_count"
                fi
            fi
        done
        echo ""
    done

    echo ""
    echo "Legend: ✓ = supported, ✗ = not supported, number = multiple converters available"
}

# Function to recommend optimal converters
recommend_converters() {
    echo -e "${PURPLE}Converter Recommendations${NC}"
    echo "========================"
    echo ""

    echo -e "${GREEN}Best for Images:${NC}"
    echo "  • ImageMagick - Most comprehensive, excellent quality"
    echo "  • GraphicsMagick - Faster than ImageMagick for batch processing"
    echo "  • FFmpeg - Good for basic image operations and batch processing"
    echo ""

    echo -e "${GREEN}Best for Documents:${NC}"
    echo "  • Pandoc - Excellent for markup languages and academic documents"
    echo "  • LibreOffice - Best for office document formats (docx, xlsx, pptx)"
    echo "  • Ghostscript - Superior PDF processing and PostScript"
    echo ""

    echo -e "${GREEN}Best for Audio/Video:${NC}"
    echo "  • FFmpeg - Industry standard, supports virtually everything"
    echo "  • SoX - Specialized for audio processing and effects"
    echo ""

    echo -e "${GREEN}Best for Vector Graphics:${NC}"
    echo "  • Inkscape - Professional SVG processing"
    echo "  • rsvg - Lightweight SVG to raster conversion"
    echo ""

    echo -e "${YELLOW}Performance Tips:${NC}"
    echo "  • For batch processing: GraphicsMagick > ImageMagick"
    echo "  • For quality: ImageMagick > GraphicsMagick"
    echo "  • For speed: FFmpeg (images) > ImageMagick"
    echo "  • For file size: Use appropriate quality settings"
}

# Main function
main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           Format Conversion Conflict Checker    ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""

    case "${1:-all}" in
        "matrix")
            show_format_matrix
            ;;
        "recommend")
            recommend_converters
            ;;
        "all"|*)
            find_all_conversions
            echo ""
            echo "----------------------------------------"
            recommend_converters
            ;;
    esac
}

# Run main function
main "$@"
