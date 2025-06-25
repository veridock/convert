#!/bin/bash

# Benchmark Script for Conversion Performance

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

CONVERTER_DIR="../converters"
TEMP_DIR="./temp"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Function to format time
format_time() {
    local seconds="$1"
    if (( $(echo "$seconds < 1" | bc -l) )); then
        echo "${seconds}s"
    elif (( $(echo "$seconds < 60" | bc -l) )); then
        printf "%.2fs" "$seconds"
    else
        local minutes=$(echo "$seconds / 60" | bc -l)
        local remaining=$(echo "$seconds % 60" | bc -l)
        printf "%.0fm %.1fs" "$minutes" "$remaining"
    fi
}

# Function to format file size
format_size() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB")
    local unit=0
    local size="$bytes"

    while (( $(echo "$size >= 1024" | bc -l) )) && [ $unit -lt 3 ]; do
        size=$(echo "scale=2; $size / 1024" | bc)
        ((unit++))
    done

    printf "%.2f%s" "$size" "${units[$unit]}"
}

# Function to get file size
get_file_size() {
    local file="$1"
    if [ -f "$file" ]; then
        stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Function to calculate quality score (basic implementation)
calculate_quality_score() {
    local original="$1"
    local converted="$2"
    local from_format="$3"
    local to_format="$4"

    local orig_size=$(get_file_size "$original")
    local conv_size=$(get_file_size "$converted")

    if [ "$orig_size" -eq 0 ] || [ "$conv_size" -eq 0 ]; then
        echo "0"
        return
    fi

    # Basic quality heuristics
    local size_ratio=$(echo "scale=4; $conv_size / $orig_size" | bc)
    local quality_score=5

    # Adjust based on format characteristics
    case "$from_format:$to_format" in
        *:jpg|*:jpeg)
            # Lossy compression - smaller size might indicate lower quality
            if (( $(echo "$size_ratio < 0.1" | bc -l) )); then
                quality_score=2
            elif (( $(echo "$size_ratio < 0.3" | bc -l) )); then
                quality_score=3
            elif (( $(echo "$size_ratio < 0.7" | bc -l) )); then
                quality_score=4
            fi
            ;;
        jpg:png|jpeg:png)
            # Lossless conversion from lossy - size increase is expected
            quality_score=4
            ;;
        *:png|*:tiff|*:bmp)
            # Lossless formats - quality should be preserved
            quality_score=5
            ;;
    esac

    echo "$quality_score"
}

# Function to benchmark single converter
benchmark_converter() {
    local converter="$1"
    local test_file="$2"
    local from_format="$3"
    local to_format="$4"

    local converter_name=$(basename "$converter" .sh)
    local output_file="$TEMP_DIR/benchmark_${converter_name}_$$.$to_format"

    echo -e "${CYAN}Testing: $converter_name${NC}"

    # Check if converter supports this conversion
    if ! bash "$converter" --check-support "$from_format" "$to_format" 2>/dev/null; then
        echo -e "  ${RED}✗ Not supported${NC}"
        return 1
    fi

    # Measure conversion time
    local start_time=$(date +%s.%N)

    if bash "$converter" "$from_format" "$to_format" "$test_file" "$output_file" >/dev/null 2>&1; then
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc)

        # Check if output file was created
        if [ ! -f "$output_file" ]; then
            echo -e "  ${RED}✗ Failed - no output file${NC}"
            return 1
        fi

        # Get file sizes
        local orig_size=$(get_file_size "$test_file")
        local conv_size=$(get_file_size "$output_file")

        # Calculate quality score
        local quality=$(calculate_quality_score "$test_file" "$output_file" "$from_format" "$to_format")

        # Display results
        echo -e "  ${GREEN}✓ Success${NC}"
        echo -e "    Time: $(format_time "$duration")"
        echo -e "    Size: $(format_size "$orig_size") → $(format_size "$conv_size")"

        local size_change=""
        if [ "$orig_size" -gt 0 ]; then
            local ratio=$(echo "scale=1; ($conv_size - $orig_size) * 100 / $orig_size" | bc)
            if (( $(echo "$ratio > 0" | bc -l) )); then
                size_change=" (+$ratio%)"
            elif (( $(echo "$ratio < 0" | bc -l) )); then
                size_change=" ($ratio%)"
            fi
        fi
        echo -e "    Change: $size_change"
        echo -e "    Quality: $quality/5"

        # Cleanup
        rm -f "$output_file"

        # Return metrics for comparison
        echo "$converter_name|$duration|$conv_size|$quality" >> "$TEMP_DIR/benchmark_results_$$.tmp"

    else
        echo -e "  ${RED}✗ Conversion failed${NC}"
        return 1
    fi
}

# Function to show benchmark summary
show_summary() {
    local results_file="$TEMP_DIR/benchmark_results_$$.tmp"

    if [ ! -f "$results_file" ]; then
        echo -e "${YELLOW}No successful conversions to summarize${NC}"
        return
    fi

    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}           BENCHMARK SUMMARY           ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"

    # Find fastest
    local fastest=$(sort -t'|' -k2 -n "$results_file" | head -1)
    local fastest_name=$(echo "$fastest" | cut -d'|' -f1)
    local fastest_time=$(echo "$fastest" | cut -d'|' -f2)

    # Find smallest output
    local smallest=$(sort -t'|' -k3 -n "$results_file" | head -1)
    local smallest_name=$(echo "$smallest" | cut -d'|' -f1)
    local smallest_size=$(echo "$smallest" | cut -d'|' -f3)

    # Find highest quality
    local best_quality=$(sort -t'|' -k4 -nr "$results_file" | head -1)
    local quality_name=$(echo "$best_quality" | cut -d'|' -f1)
    local quality_score=$(echo "$best_quality" | cut -d'|' -f4)

    echo -e "${GREEN}🏆 Fastest:${NC} $fastest_name ($(format_time "$fastest_time"))"
    echo -e "${GREEN}📦 Smallest output:${NC} $smallest_name ($(format_size "$smallest_size"))"
    echo -e "${GREEN}⭐ Best quality:${NC} $quality_name ($quality_score/5)"

    # Show detailed comparison table
    echo ""
    echo -e "${PURPLE}Detailed Comparison:${NC}"
    printf "%-15s %-10s %-12s %-8s\n" "Converter" "Time" "Size" "Quality"
    echo "───────────────────────────────────────────────"

    while IFS='|' read -r name time size quality; do
        printf "%-15s %-10s %-12s %-8s\n" \
            "$name" \
            "$(format_time "$time")" \
            "$(format_size "$size")" \
            "$quality/5"
    done < "$results_file"

    # Cleanup
    rm -f "$results_file"
}

# Function to create test file if needed
create_test_file() {
    local format="$1"
    local test_file="$TEMP_DIR/test_file.$format"

    case "$format" in
        txt)
            echo "This is a test file for benchmarking conversions." > "$test_file"
            echo "It contains multiple lines of text." >> "$test_file"
            echo "Lorem ipsum dolor sit amet, consectetur adipiscing elit." >> "$test_file"
            ;;
        md)
            cat > "$test_file" << 'EOF'
# Test Document

This is a **test** document for benchmarking.

## Features

- List item 1
- List item 2
- List item 3

```bash
echo "Code block example"
```

> This is a blockquote for testing.
EOF
            ;;
        html)
            cat > "$test_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Document</title>
</head>
<body>
    <h1>Test Document</h1>
    <p>This is a <strong>test</strong> document for benchmarking.</p>
    <ul>
        <li>List item 1</li>
        <li>List item 2</li>
    </ul>
</body>
</html>
EOF
            ;;
        *)
            echo "Cannot create test file for format: $format" >&2
            return 1
            ;;
    esac

    echo "$test_file"
}

# Main benchmark function
main() {
    local test_file="$1"
    local from_format="$2"
    local to_format="$3"

    if [ $# -ne 3 ]; then
        echo "Usage: $0 [test_file] [from_format] [to_format]"
        echo "       $0 --create-test [format]  # Create test file"
        exit 1
    fi

    # Handle test file creation
    if [ "$1" = "--create-test" ]; then
        local created_file=$(create_test_file "$2")
        if [ $? -eq 0 ]; then
            echo "Test file created: $created_file"
        fi
        exit 0
    fi

    # Check if test file exists
    if [ ! -f "$test_file" ]; then
        echo -e "${RED}Test file not found: $test_file${NC}"
        echo ""
        echo "You can create a test file with:"
        echo "  $0 --create-test $from_format"
        exit 1
    fi

    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              CONVERSION BENCHMARK               ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Test file:${NC} $test_file"
    echo -e "${YELLOW}Conversion:${NC} $from_format → $to_format"
    echo -e "${YELLOW}File size:${NC} $(format_size "$(get_file_size "$test_file")")"
    echo ""

    # Find all converters that support this conversion
    local supported_converters=()
    for converter in "$CONVERTER_DIR"/*.sh; do
        if [ -f "$converter" ]; then
            if bash "$converter" --check-support "$from_format" "$to_format" 2>/dev/null; then
                supported_converters+=("$converter")
            fi
        fi
    done

    if [ ${#supported_converters[@]} -eq 0 ]; then
        echo -e "${RED}No converters found for $from_format → $to_format${NC}"
        exit 1
    fi

    echo -e "${GREEN}Found ${#supported_converters[@]} compatible converter(s)${NC}"
    echo ""

    # Benchmark each converter
    for converter in "${supported_converters[@]}"; do
        benchmark_converter "$converter" "$test_file" "$from_format" "$to_format"
        echo ""
    done

    # Show summary
    show_summary
}

# Run main function
main "$@"
