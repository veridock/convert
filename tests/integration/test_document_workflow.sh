#!/bin/bash

# Test document conversion workflow

# Source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/../test_helpers.sh"

# Test document conversion workflow
test_document_conversion_workflow() {
    echo -e "\n${YELLOW}Testing Document Conversion Workflow${NC}"
    echo "================================"
    
    # Create a test markdown file with metadata
    local input_file="${TEST_TEMP_DIR}/test_doc.md"
    cat > "${input_file}" << 'EOL'
---
title: Integration Test Document
author: Test Suite
date: 2023-06-25
---

# Integration Test

This is a test document for the conversion workflow.

## Features

- Markdown formatting
- Multiple sections
- Code blocks

```python
def hello():
    print("Hello, World!")
```
EOL

    # Convert to HTML
    local html_file="${TEST_TEMP_DIR}/output.html"
    assert_success "pandoc '${input_file}' -o '${html_file}'" \
                   "Should convert Markdown to HTML"
    
    # Verify HTML output
    assert_file_exists "${html_file}" "HTML output file should be created"
    assert_success "grep -q '<h1' '${html_file}'" \
                   "HTML should contain heading"
    assert_success "grep -q 'code class' '${html_file}'" \
                   "HTML should contain code block"

    # Convert to PDF if pdflatex is available
    if command -v pdflatex >/dev/null 2>&1; then
        local pdf_file="${TEST_TEMP_DIR}/output.pdf"
        assert_success "pandoc '${input_file}' -o '${pdf_file}'" \
                       "Should convert Markdown to PDF"
        assert_file_exists "${pdf_file}" "PDF output file should be created"
    fi

    # Convert to DOCX if possible
    if command -v pandoc >/dev/null 2>&1; then
        local docx_file="${TEST_TEMP_DIR}/output.docx"
        assert_success "pandoc '${input_file}' -o '${docx_file}'" \
                       "Should convert Markdown to DOCX"
        assert_file_exists "${docx_file}" "DOCX output file should be created"
    fi
}

# Main test execution
main() {
    echo -e "\n${YELLOW}Running Document Conversion Integration Tests${NC}"
    echo "========================================="
    
    setup
    
    # Run tests
    test_document_conversion_workflow
    
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
