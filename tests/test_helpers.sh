#!/bin/bash

# Test helper functions for Universal File Converter

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Initialize test environment
setup() {
    echo -e "\n${YELLOW}Setting up test environment...${NC}"
    # Create temporary directories if needed
    mkdir -p "${TEST_TEMP_DIR}"
    # Copy test fixtures to temp directory
    cp -r "${TEST_FIXTURES_DIR}"/* "${TEST_TEMP_DIR}/" 2>/dev/null || true
}

# Clean up test environment
teardown() {
    echo -e "\n${YELLOW}Cleaning up test environment...${NC}"
    # Remove temporary directories if they exist
    if [ -d "${TEST_TEMP_DIR}" ]; then
        rm -rf "${TEST_TEMP_DIR}"
    fi
}

# Assert that two values are equal
assert_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    ((TEST_COUNT++))
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓ PASS: ${message}${NC}"
        ((PASS_COUNT++))
        return 0
    else
        echo -e "${RED}✗ FAIL: ${message}${NC}"
        echo "  Expected: ${expected}"
        echo "  Actual:   ${actual}"
        ((FAIL_COUNT++))
        return 1
    fi
}

# Assert that a command succeeds
assert_success() {
    local command="$1"
    local message="${2:-Command should succeed}"
    
    ((TEST_COUNT++))
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS: ${message}${NC}"
        ((PASS_COUNT++))
        return 0
    else
        echo -e "${RED}✗ FAIL: ${message}${NC}"
        echo "  Command: ${command}"
        ((FAIL_COUNT++))
        return 1
    fi
}

# Assert that a file exists
assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: ${file}}"
    
    ((TEST_COUNT++))
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ PASS: ${message}${NC}"
        ((PASS_COUNT++))
        return 0
    else
        echo -e "${RED}✗ FAIL: ${message}${NC}"
        ((FAIL_COUNT++))
        return 1
    fi
}

# Print test summary
print_test_summary() {
    echo -e "\n${YELLOW}Test Summary:${NC}"
    echo "==========="
    echo "Total tests: ${TEST_COUNT}"
    echo -e "${GREEN}Passed: ${PASS_COUNT}${NC}"
    if [ ${FAIL_COUNT} -gt 0 ]; then
        echo -e "${RED}Failed: ${FAIL_COUNT}${NC}"
        return 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Initialize test environment variables
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TEST_FIXTURES_DIR="${TEST_DIR}/fixtures"
TEST_TEMP_DIR="/tmp/ufc_test_$(date +%s)"

export TEST_DIR TEST_FIXTURES_DIR TEST_TEMP_DIR

# Source the main script if it exists
if [ -f "${TEST_DIR}/../../convert.sh" ]; then
    . "${TEST_DIR}/../../convert.sh"
fi
