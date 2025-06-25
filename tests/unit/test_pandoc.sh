#!/bin/bash

# Test Pandoc document conversion functionality

# Source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/../test_helpers.sh"

# Verify Pandoc is installed
test_pandoc_installed() {
    assert_success "command -v pandoc" "Pandoc should be installed"
}

# Test Markdown to HTML conversion
test_markdown_to_html() {
    local input_file="${TEST_FIXTURES_DIR}/test_documents/sample.md"
    local output_file="${TEST_TEMP_DIR}/output.html"
    
    # Skip if input file doesn't exist
    if [ ! -f "${input_file}" ]; then
        echo -e "${YELLOW}⚠️  Creating sample markdown file for testing${NC}"
        mkdir -p "$(dirname "${input_file}")"
        echo -e "# Test Document\n\nThis is a **test** document.\n\n- Item 1\n- Item 2" > "${input_file}"
    fi
    
    # Convert Markdown to HTML
    assert_success "pandoc '${input_file}' -o '${output_file}'" \
                   "Should convert Markdown to HTML"
    
    # Verify output file exists and has content
    assert_file_exists "${output_file}" "Output HTML file should be created"
    
    # Verify output contains expected content
    assert_success "grep -q '<h1' '${output_file}'" \
                   "Output should contain HTML heading"
}

# Test Markdown to PDF conversion
test_markdown_to_pdf() {
    # Skip if pdflatex is not installed (required for PDF generation)
    if ! command -v pdflatex >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Skipping PDF test - pdflatex not installed${NC}"
        return 0
    fi
    
    local input_file="${TEST_FIXTURES_DIR}/test_documents/sample.md"
    local output_file="${TEST_TEMP_DIR}/output.pdf"
    
    # Ensure input file exists
    if [ ! -f "${input_file}" ]; then
        test_markdown_to_html  # This will create the sample markdown file
    fi
    
    # Convert Markdown to PDF
    assert_success "pandoc '${input_file}' -o '${output_file}'" \
                   "Should convert Markdown to PDF"
    
    # Verify output file exists and has content
    assert_file_exists "${output_file}" "Output PDF file should be created"
    
    # Basic PDF verification (check if file starts with PDF magic number)
    assert_success "[ "$(head -c 4 '${output_file}')" = "%PDF" ]" \
                   "Output should be a valid PDF file"
}

# Test document metadata extraction
test_metadata_extraction() {
    local input_file="${TEST_FIXTURES_DIR}/test_documents/sample.md"
    
    # Add metadata to the markdown file if not present
    if ! grep -q '^---' "${input_file}" 2>/dev/null; then
        echo -e "---\ntitle: Test Document\nauthor: Test Author\ndate: 2023-01-01\n---\n$(cat "${input_file}")" > "${input_file}"
    fi
    
    # Extract metadata
    local metadata=$(pandoc '${input_file}' --template=meta.txt 2>/dev/null)
    
    # Verify metadata fields
    assert_success "echo '${metadata}' | grep -q 'title: Test Document'" \
                   "Should extract document title"
    assert_success "echo '${metadata}' | grep -q 'author: Test Author'" \
                   "Should extract document author"
}

# Main test execution
main() {
    echo -e "\n${YELLOW}Running Pandoc Document Conversion Tests${NC}"
    echo "=================================="
    
    setup
    
    # Run tests
    test_pandoc_installed
    test_markdown_to_html
    test_markdown_to_pdf
    test_metadata_extraction
    
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

