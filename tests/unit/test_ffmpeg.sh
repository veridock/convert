#!/bin/bash

# Test FFmpeg conversion functionality

# Source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/../test_helpers.sh"

# Test FFmpeg is installed
test_ffmpeg_installed() {
    assert_success "command -v ffmpeg" "FFmpeg should be installed"
}

# Test audio conversion
test_audio_conversion() {
    local input_file="${TEST_FIXTURES_DIR}/test_audio/sample.mp3"
    local output_file="${TEST_TEMP_DIR}/output.wav"
    
    # Convert MP3 to WAV
    assert_success "ffmpeg -i '${input_file}' -y '${output_file}' 2>/dev/null" \
                   "Should convert MP3 to WAV"
    
    # Verify output file exists and has content
    assert_file_exists "${output_file}" "Output WAV file should be created"
    
    # Verify output format (basic check)
    local file_type=$(file -b "${output_file}")
    assert_success "echo '${file_type}' | grep -q 'WAVE'" \
                   "Output should be a WAV file"
}

# Test video conversion
test_video_conversion() {
    local input_file="${TEST_FIXTURES_DIR}/test_video/sample.mp4"
    local output_file="${TEST_TEMP_DIR}/output.avi"
    
    # Skip if input file doesn't exist
    if [ ! -f "${input_file}" ]; then
        echo -e "${YELLOW}⚠️  Skipping video conversion test - sample video not found${NC}"
        return 0
    fi
    
    # Convert MP4 to AVI
    assert_success "ffmpeg -i '${input_file}' -y '${output_file}' 2>/dev/null" \
                   "Should convert MP4 to AVI"
    
    # Verify output file exists and has content
    assert_file_exists "${output_file}" "Output AVI file should be created"
    
    # Verify output format (basic check)
    local file_type=$(file -b "${output_file}")
    assert_success "echo '${file_type}' | grep -q 'AVI'" \
                   "Output should be an AVI file"
}

# Main test execution
main() {
    echo -e "\n${YELLOW}Running FFmpeg Tests${NC}"
    echo "=================="
    
    setup
    
    # Run tests
    test_ffmpeg_installed
    test_audio_conversion
    test_video_conversion
    
    # Print summary
    print_test_summary
    
    # Clean up
    teardown
    
    # Exit with non-zero status if any tests failed
    if [ ${FAIL_COUNT} -gt 0 ]; then
        exit 1
    fi
}

# Run main function
main "$@"

