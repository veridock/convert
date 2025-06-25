#!/bin/bash

# Batch Processor - Convert multiple files efficiently

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

CONVERTER_DIR="../converters"
LOG_DIR="./logs"
TEMP_DIR="./temp"

# Create directories
mkdir -p "$LOG_DIR" "$TEMP_DIR"

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOG_DIR/batch_$(date +%Y%m%d).log"

    echo "[$timestamp] [$level] $message" >> "$log_file"

    case "$level" in
        ERROR) echo -e "${RED}[ERROR]${NC} $message" ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        INFO)  echo -e "${GREEN}[INFO]${NC} $message" ;;
        DEBUG) [ "$BATCH_DEBUG" = "1" ] && echo -e "${CYAN}[DEBUG]${NC} $message" ;;
    esac
}

# Function to show progress
show_progress() {
    local current="$1"
    local total="$2"
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "\r${BLUE}Progress:${NC} ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d/%d (%d%%)" "$current" "$total" "$percentage"
}

# Function to estimate remaining time
estimate_time() {
    local start_time="$1"
    local current="$2"
    local total="$3"

    if [ "$current" -eq 0 ]; then
        echo "calculating..."
        return
    fi

    local elapsed=$(($(date +%s) - start_time))
    local rate=$(echo "scale=2; $current / $elapsed" | bc -l 2>/dev/null || echo "0")
    local remaining=$((total - current))
    local eta=$(echo "scale=0; $remaining / $rate" | bc -l 2>/dev/null || echo "0")

    if [ "$eta" -gt 0 ]; then
        local hours=$((eta / 3600))
        local minutes=$(((eta % 3600) / 60))
        local seconds=$((eta % 60))

        if [ "$hours" -gt 0 ]; then
            printf "%dh %dm %ds" "$hours" "$minutes" "$seconds"
        elif [ "$minutes" -gt 0 ]; then
            printf "%dm %ds" "$minutes" "$seconds"
        else
            printf "%ds" "$seconds"
        fi
    else
        echo "calculating..."
    fi
}

# Function to convert single file
convert_single_file() {
    local library="$1"
    local from_format="$2"
    local to_format="$3"
    local input_file="$4"
    local output_dir="$5"
    local converter="$CONVERTER_DIR/$library.sh"

    # Generate output filename
    local basename=$(basename "$input_file" ".$from_format")
    local output_file="$output_dir/$basename.$to_format"

    # Skip if output already exists and not in overwrite mode
    if [ -f "$output_file" ] && [ "$BATCH_OVERWRITE" != "1" ]; then
        log_message "WARN" "Skipping $input_file - output exists"
        return 2
    fi

    # Check if converter exists
    if [ ! -f "$converter" ]; then
        log_message "ERROR" "Converter not found: $library"
        return 1
    fi

    # Check if conversion is supported
    if ! bash "$converter" --check-support "$from_format" "$to_format" 2>/dev/null; then
        log_message "ERROR" "Conversion not supported: $from_format → $to_format by $library"
        return 1
    fi

    # Perform conversion
    log_message "DEBUG" "Converting: $input_file → $output_file"

    if bash "$converter" "$from_format" "$to_format" "$input_file" "$output_file" >/dev/null 2>&1; then
        log_message "INFO" "Success: $(basename "$input_file")"
        return 0
    else
        log_message "ERROR" "Failed: $(basename "$input_file")"
        return 1
    fi
}

# Function to process files in parallel
process_parallel() {
    local library="$1"
    local from_format="$2"
    local to_format="$3"
    local output_dir="$4"
    shift 4
    local files=("$@")

    local max_jobs="${BATCH_PARALLEL:-$(nproc)}"
    local job_count=0
    local pids=()
    local total=${#files[@]}
    local completed=0
    local success=0
    local failed=0
    local skipped=0
    local start_time=$(date +%s)

    log_message "INFO" "Starting parallel processing with $max_jobs jobs"

    # Function to wait for job completion
    wait_for_job() {
        local pid="$1"
        wait "$pid"
        local exit_code=$?

        case "$exit_code" in
            0) ((success++)) ;;
            1) ((failed++)) ;;
            2) ((skipped++)) ;;
        esac

        ((completed++))
        show_progress "$completed" "$total"

        if [ "$completed" -lt "$total" ]; then
            local eta=$(estimate_time "$start_time" "$completed" "$total")
            echo -n " ETA: $eta"
        fi
    }

    # Process files
    for file in "${files[@]}"; do
        # Wait if we have too many jobs
        while [ ${#pids[@]} -ge "$max_jobs" ]; do
            for i in "${!pids[@]}"; do
                if ! kill -0 "${pids[i]}" 2>/dev/null; then
                    wait_for_job "${pids[i]}"
                    unset 'pids[i]'
                    pids=("${pids[@]}")  # Reindex array
                    break
                fi
            done
            sleep 0.1
        done

        # Start new job
        (convert_single_file "$library" "$from_format" "$to_format" "$file" "$output_dir") &
        local pid=$!
        pids+=("$pid")
    done

    # Wait for remaining jobs
    for pid in "${pids[@]}"; do
        wait_for_job "$pid"
    done

    echo ""  # New line after progress
    log_message "INFO" "Batch processing completed: $success success, $failed failed, $skipped skipped"

    return "$failed"
}

# Function to process files sequentially
process_sequential() {
    local library="$1"
    local from_format="$2"
    local to_format="$3"
    local output_dir="$4"
    shift 4
    local files=("$@")

    local total=${#files[@]}
    local completed=0
    local success=0
    local failed=0
    local skipped=0
    local start_time=$(date +%s)

    log_message "INFO" "Starting sequential processing"

    for file in "${files[@]}"; do
        convert_single_file "$library" "$from_format" "$to_format" "$file" "$output_dir"
        local exit_code=$?

        case "$exit_code" in
            0) ((success++)) ;;
            1) ((failed++)) ;;
            2) ((skipped++)) ;;
        esac

        ((completed++))
        show_progress "$completed" "$total"

        if [ "$completed" -lt "$total" ]; then
            local eta=$(estimate_time "$start_time" "$completed" "$total")
            echo -n " ETA: $eta"
        fi
    done

    echo ""  # New line after progress
    log_message "INFO" "Batch processing completed: $success success, $failed failed, $skipped skipped"

    return "$failed"
}

# Function to show batch statistics
show_statistics() {
    local files=("$@")
    local total_size=0
    local file_count=${#files[@]}

    echo -e "${PURPLE}Batch Statistics:${NC}"

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            total_size=$((total_size + size))
        fi
    done

    local human_size=$(numfmt --to=iec-i --suffix=B "$total_size" 2>/dev/null || echo "${total_size} bytes")

    echo "  Files to process: $file_count"
    echo "  Total size: $human_size"
    echo "  Average size: $(numfmt --to=iec-i --suffix=B $((total_size / file_count)) 2>/dev/null || echo "$((total_size / file_count)) bytes")"

    # Estimate processing time based on file size and format
    local estimated_time="unknown"
    if [ "$total_size" -lt 10485760 ]; then  # < 10MB
        estimated_time="< 1 minute"
    elif [ "$total_size" -lt 104857600 ]; then  # < 100MB
        estimated_time="1-5 minutes"
    elif [ "$total_size" -lt 1073741824 ]; then  # < 1GB
        estimated_time="5-30 minutes"
    else
        estimated_time="> 30 minutes"
    fi

    echo "  Estimated time: $estimated_time"
    echo ""
}

# Function to validate batch parameters
validate_parameters() {
    local library="$1"
    local from_format="$2"
    local to_format="$3"
    local pattern="$4"

    # Check if converter exists
    if [ ! -f "$CONVERTER_DIR/$library.sh" ]; then
        log_message "ERROR" "Converter not found: $library"
        echo -e "${RED}Available converters:${NC}"
        ls "$CONVERTER_DIR"/*.sh | sed 's/.*\///' | sed 's/.sh//' | sort
        return 1
    fi

    # Check if conversion is supported
    if ! bash "$CONVERTER_DIR/$library.sh" --check-support "$from_format" "$to_format" 2>/dev/null; then
        log_message "ERROR" "Conversion not supported: $from_format → $to_format by $library"
        return 1
    fi

    # Find matching files
    local files=($(find . -maxdepth 1 -name "$pattern" -type f 2>/dev/null))
    if [ ${#files[@]} -eq 0 ]; then
        log_message "ERROR" "No files found matching pattern: $pattern"
        return 1
    fi

    log_message "INFO" "Found ${#files[@]} files matching pattern: $pattern"
    return 0
}

# Main function
main() {
    local library="$1"
    local from_format="$2"
    local to_format="$3"
    local pattern="$4"

    if [ $# -lt 4 ]; then
        cat << 'EOF'
Batch Processor - Convert multiple files efficiently

Usage: ./batch_processor.sh [library] [from_format] [to_format] [pattern]

Parameters:
  library      - Converter library to use (imagemagick, pandoc, ffmpeg, etc.)
  from_format  - Source format
  to_format    - Target format
  pattern      - File pattern (e.g., "*.jpg", "document_*.pdf")

Environment Variables:
  BATCH_PARALLEL=N    - Number of parallel jobs (default: CPU cores)
  BATCH_OVERWRITE=1   - Overwrite existing files (default: skip)
  BATCH_OUTPUT_DIR    - Output directory (default: ./output)
  BATCH_DEBUG=1       - Enable debug logging
  BATCH_SEQUENTIAL=1  - Force sequential processing

Examples:
  ./batch_processor.sh imagemagick jpg png "*.jpg"
  BATCH_PARALLEL=4 ./batch_processor.sh pandoc md pdf "doc_*.md"
  BATCH_OUTPUT_DIR=converted ./batch_processor.sh ffmpeg avi mp4 "video*.avi"
EOF
        exit 1
    fi

    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                BATCH PROCESSOR                   ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""

    # Validate parameters
    if ! validate_parameters "$library" "$from_format" "$to_format" "$pattern"; then
        exit 1
    fi

    # Setup
    local output_dir="${BATCH_OUTPUT_DIR:-./output}"
    mkdir -p "$output_dir"

    # Find files
    local files=($(find . -maxdepth 1 -name "$pattern" -type f 2>/dev/null))

    echo -e "${YELLOW}Configuration:${NC}"
    echo "  Library: $library"
    echo "  Conversion: $from_format → $to_format"
    echo "  Pattern: $pattern"
    echo "  Output directory: $output_dir"
    echo "  Parallel jobs: ${BATCH_PARALLEL:-$(nproc)}"
    echo "  Overwrite: ${BATCH_OVERWRITE:-0}"
    echo ""

    # Show statistics
    show_statistics "${files[@]}"

    # Confirm before proceeding
    if [ "$BATCH_AUTO" != "1" ]; then
        read -p "Proceed with batch conversion? [y/N]: " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            exit 0
        fi
    fi

    # Process files
    echo -e "${BLUE}Starting batch conversion...${NC}"
    echo ""

    if [ "$BATCH_SEQUENTIAL" = "1" ]; then
        process_sequential "$library" "$from_format" "$to_format" "$output_dir" "${files[@]}"
    else
        process_parallel "$library" "$from_format" "$to_format" "$output_dir" "${files[@]}"
    fi

    local exit_code=$?

    # Show final summary
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}           BATCH COMPLETE              ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"

    echo "Output directory: $output_dir"
    echo "Log file: $LOG_DIR/batch_$(date +%Y%m%d).log"

    if [ "$exit_code" -eq 0 ]; then
        echo -e "${GREEN}✓ All conversions successful${NC}"
    else
        echo -e "${YELLOW}⚠ Some conversions failed (check logs)${NC}"
    fi

    exit "$exit_code"
}

# Handle help
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    main
    exit 0
fi

# Run main function
main "$@"
