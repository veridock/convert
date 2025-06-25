#!/bin/bash

# Test Runner for Universal File Converter
set -e

echo "🚀 Running Universal File Converter Test Suite"
echo "========================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables
TEST_DIR=$(dirname "$(readlink -f "$0")")
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test suite
run_test_suite() {
    local suite_name="$1"
    local test_dir="$2"
    
    echo -e "\n🔍 Running ${suite_name^} Tests..."
    echo "========================"
    
    for test_file in "${test_dir}"/*.sh; do
        if [ -f "$test_file" ] && [ -x "$test_file" ]; then
            echo -n "🧪 $(basename "$test_file")... "
            if "$test_file"; then
                echo -e "${GREEN}✓ PASSED${NC}"
                ((PASSED_TESTS++))
            else
                echo -e "${RED}✗ FAILED${NC}"
                ((FAILED_TESTS++))
            fi
            ((TOTAL_TESTS++))
        fi
    done
}

# Run unit tests
run_test_suite "unit" "${TEST_DIR}/unit"

# Run integration tests
run_test_suite "integration" "${TEST_DIR}/integration"

# Run performance tests if not in CI environment
if [ "$CI" != "true" ]; then
    run_test_suite "performance" "${TEST_DIR}/performance"
fi

# Print summary
echo -e "\n📊 Test Summary"
echo "============="
echo -e "Total Tests: ${TOTAL_TESTS}"
echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"

# Exit with non-zero status if any tests failed
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "❌ Some tests failed!"
    exit 1
else
    echo -e "✅ All tests passed!"
    exit 0
fi

