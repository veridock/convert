#!/bin/bash

# Generate test files for the converter tests

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
TEST_FIXTURES_DIR="${ROOT_DIR}/tests/fixtures"
AUDIO_DIR="${TEST_FIXTURES_DIR}/test_audio"
VIDEO_DIR="${TEST_FIXTURES_DIR}/test_video"
DOCS_DIR="${TEST_FIXTURES_DIR}/test_documents"

# Create directories if they don't exist
mkdir -p "${AUDIO_DIR}" "${VIDEO_DIR}" "${DOCS_DIR}"

echo -e "${YELLOW}Generating test files...${NC}"

# Generate sample audio file (1 second of silence)
generate_audio() {
    local output_file="$1"
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${YELLOW}⚠️  ffmpeg not found, skipping audio file generation${NC}"
        return 1
    fi
    
    echo -n "🔊 Generating ${output_file}... "
    if ffmpeg -f lavfi -i anullsrc -t 1 -c:a libmp3lame -q:a 9 "${output_file}" -y -loglevel error; then
        echo -e "${GREEN}✓ Done${NC}"
        return 0
    else
        echo -e "${YELLOW}✗ Failed${NC}"
        return 1
    fi
}

# Generate sample video file (1 second of color bars)
generate_video() {
    local output_file="$1"
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${YELLOW}⚠️  ffmpeg not found, skipping video file generation${NC}"
        return 1
    fi
    
    echo -n "🎥 Generating ${output_file}... "
    if ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=30 -c:v libx264 -pix_fmt yuv420p "${output_file}" -y -loglevel error; then
        echo -e "${GREEN}✓ Done${NC}"
        return 0
    else
        echo -e "${YELLOW}✗ Failed${NC}"
        return 1
    fi
}

# Generate sample document
generate_document() {
    local output_file="$1"
    echo -n "📄 Generating ${output_file}... "
    
    cat > "${output_file}" << 'EOL'
---
title: Sample Document
author: Test Suite
date: 2023-06-25
---

# Sample Document

This is a sample document for testing the conversion workflow.

## Features

- Markdown formatting
- Multiple sections
- Code blocks

```python
def hello():
    print("Hello, World!")
```
EOL
    
    if [ -f "${output_file}" ]; then
        echo -e "${GREEN}✓ Done${NC}"
        return 0
    else
        echo -e "${YELLOW}✗ Failed${NC}"
        return 1
    fi
}

# Generate test files
generate_audio "${AUDIO_DIR}/sample.mp3"
generate_audio "${AUDIO_DIR}/sample.wav"
generate_video "${VIDEO_DIR}/sample.mp4"
generate_video "${VIDEO_DIR}/sample.avi"
generate_document "${DOCS_DIR}/sample.md"

echo -e "\n${GREEN}Test file generation complete!${NC}"
echo "Test files are available in: ${TEST_FIXTURES_DIR}"
