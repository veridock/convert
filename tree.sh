#!/bin/bash

# Universal File Converter - Project Structure Generator
# Generates complete project structure with all necessary files

set -e  # Exit on any error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_NAME="universal-file-converter"
BASE_DIR="${1:-$PROJECT_NAME}"

# Function to create directory and log it
create_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${BLUE}📁${NC} Created directory: $dir"
    fi
}

# Function to create file with optional content
create_file() {
    local file="$1"
    local content="$2"
    local executable="$3"

    if [ ! -f "$file" ]; then
        if [ -n "$content" ]; then
            echo "$content" > "$file"
        else
            touch "$file"
        fi

        if [ "$executable" = "true" ]; then
            chmod +x "$file"
            echo -e "${GREEN}🔧${NC} Created executable: $file"
        else
            echo -e "${CYAN}📄${NC} Created file: $file"
        fi
    fi
}

# Function to create .gitkeep files for empty directories
create_gitkeep() {
    local dir="$1"
    create_file "$dir/.gitkeep" "# This file ensures the directory is tracked by Git"
}

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Universal File Converter Generator       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Generating project structure in: ${GREEN}$BASE_DIR${NC}"
echo ""

# Create base directory
create_dir "$BASE_DIR"
cd "$BASE_DIR"

# ========================================
# ROOT FILES
# ========================================

echo -e "${PURPLE}Creating root files...${NC}"

# Main documentation
create_file "README.md" "# Universal File Converter System

Kompleksowy, wielopoziomowy system konwersji plików między różnymi formatami.

## 🚀 Szybki Start

\`\`\`bash
# Instalacja zależności
./config/install_dependencies.sh

# Pierwsza konwersja
make imagemagick jpg png photo.jpg
\`\`\`

## 📖 Dokumentacja

- [Instalacja](docs/guides/getting_started.md)
- [Przykłady użycia](examples/basic_usage.md)
- [Plan rozwoju](ROADMAP.md)

## 🛠️ Dostępne Konwertery

- ImageMagick, Pandoc, FFmpeg, LibreOffice, SoX i więcej...

## 📞 Wsparcie

Sprawdź [FAQ](docs/FAQ.md) lub zgłoś problem na GitHub.
"

# Roadmap
create_file "ROADMAP.md" "# Universal File Converter - Plan Rozbudowy

## 🎯 Aktualna Wersja: v1.0

### ✅ Zaimplementowane Funkcje
- Podstawowy system konwersji
- Modularne konwertery
- Interaktywna pomoc

## 🚀 Roadmap

### v1.1 - Q3 2025
- Cache system
- Queue management
- Real-time monitoring

### v1.2 - Q4 2025
- REST API
- Web interface
- Plugin system

### v2.0 - Q3 2026
- Cloud integration
- Mobile apps
- AI/ML features
"

# License
create_file "LICENSE" "MIT License

Copyright (c) $(date +%Y) Universal File Converter Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"

# Gitignore
create_file ".gitignore" "# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Temporary files
temp/
*.tmp
*.temp
*.swp
*.swo
*~

# Logs
logs/*.log
*.log

# Cache
cache/
.cache/

# Build outputs
build/
dist/
node_modules/

# IDE files
.vscode/
.idea/
*.sublime-*

# Environment files
.env
.env.local
.env.production

# Test outputs
test-output/
coverage/

# Generated files
*.pyc
__pycache__/
"

# Main help script
create_file "help.sh" "#!/bin/bash

# Interactive help script - Main entry point
echo \"Universal File Converter - Interactive Help\"
echo \"Usage: ./help.sh [from_format] [to_format]\"
echo \"For full documentation, see README.md\"
" true

# Main Makefile
create_file "Makefile" "# Universal File Converter System
# Main interface for file conversions

SHELL := /bin/bash
CONVERTER_DIR := ./converters
HELP_DIR := ./help

# Color definitions
GREEN := \\033[0;32m
YELLOW := \\033[0;33m
BLUE := \\033[0;34m
NC := \\033[0m

.PHONY: help list-libraries search benchmark validate batch

help:
	@echo -e \"\$(BLUE)Universal File Converter System\$(NC)\"
	@echo \"Usage: make [library] [from_format] [to_format] [input_file] [output_file]\"

list-libraries:
	@echo -e \"\$(GREEN)Available Libraries:\$(NC)\"
	@ls \$(CONVERTER_DIR)/*.sh 2>/dev/null | sed 's/.*\\///' | sed 's/.sh//' || echo \"No converters found\"

search:
	@echo \"Search functionality - implement converter search\"

benchmark:
	@echo \"Benchmark functionality - implement performance testing\"

validate:
	@echo \"Validation functionality - implement file validation\"

batch:
	@echo \"Batch processing functionality - implement batch conversion\"
"

# Package.json for optional Node.js dependencies
create_file "package.json" "{
  \"name\": \"universal-file-converter\",
  \"version\": \"1.0.0\",
  \"description\": \"Universal file conversion system\",
  \"main\": \"web/api/server.js\",
  \"scripts\": {
    \"start\": \"node web/api/server.js\",
    \"test\": \"bash tests/run_tests.sh\",
    \"install-deps\": \"./config/install_dependencies.sh\"
  },
  \"keywords\": [\"converter\", \"files\", \"multimedia\", \"documents\"],
  \"license\": \"MIT\",
  \"dependencies\": {},
  \"devDependencies\": {}
}
"

# Python requirements
create_file "requirements.txt" "# Python dependencies for converters
Pillow>=10.0.0
opencv-python>=4.8.0
reportlab>=4.0.0
python-docx>=0.8.11
openpyxl>=3.1.0
"

# Environment example
create_file ".env.example" "# Universal File Converter Environment Variables

# General settings
UC_DEBUG=0
UC_LOG_LEVEL=INFO
UC_TEMP_DIR=./temp
UC_OUTPUT_DIR=./output

# Performance settings
UC_MAX_PARALLEL_JOBS=4
UC_MEMORY_LIMIT=2GB
UC_TIMEOUT=300

# Cache settings
UC_CACHE_ENABLED=1
UC_CACHE_DIR=./cache
UC_CACHE_TTL=3600

# Quality settings
UC_DEFAULT_QUALITY=high
UC_OPTIMIZE_SIZE=0

# Security settings
UC_MAX_FILE_SIZE=100MB
UC_ALLOWED_EXTENSIONS=jpg,png,pdf,docx,mp4
UC_SANDBOX_MODE=0
"

# ========================================
# CONVERTERS DIRECTORY
# ========================================

echo -e "${PURPLE}Creating converters...${NC}"
create_dir "converters"

# Converter template
create_file "converters/_template.sh" "#!/bin/bash

# Template for new converters
# Copy this file and modify for your converter

SUPPORTED_INPUT=\"format1 format2\"
SUPPORTED_OUTPUT=\"format3 format4\"

show_help() {
    echo \"Converter Template Help\"
    echo \"Modify this template for your specific converter\"
}

check_support() {
    local from_format=\"\$1\"
    local to_format=\"\$2\"
    # Implementation here
    return 1
}

convert_file() {
    local from_format=\"\$1\"
    local to_format=\"\$2\"
    local input_file=\"\$3\"
    local output_file=\"\$4\"
    # Implementation here
}

case \"\$1\" in
    --help) show_help ;;
    --check-support) check_support \"\$2\" \"\$3\" ;;
    *)
        if [ \$# -eq 4 ]; then
            convert_file \"\$1\" \"\$2\" \"\$3\" \"\$4\"
        else
            echo \"Usage: \$0 [from] [to] [input] [output]\"
        fi
        ;;
esac
" true

# Individual converters (stubs)
converters=(
    "imagemagick"
    "graphicsmagick"
    "pandoc"
    "libreoffice"
    "ffmpeg"
    "sox"
    "ghostscript"
    "poppler"
    "inkscape"
    "rsvg"
    "wkhtmltopdf"
    "pillow"
    "opencv"
)

for converter in "${converters[@]}"; do
    create_file "converters/${converter}.sh" "#!/bin/bash

# ${converter^} Converter
# TODO: Implement ${converter} conversion functionality

echo \"${converter^} converter - implementation needed\"
echo \"Usage: \$0 [from_format] [to_format] [input_file] [output_file]\"
" true
done

# ========================================
# HELP DIRECTORY
# ========================================

echo -e "${PURPLE}Creating help scripts...${NC}"
create_dir "help"

help_scripts=(
    "conflict_checker.sh"
    "benchmark.sh"
    "validator.sh"
    "batch_processor.sh"
    "format_predictor.sh"
    "quality_analyzer.sh"
    "report_generator.sh"
)

for script in "${help_scripts[@]}"; do
    create_file "help/${script}" "#!/bin/bash

# ${script%.*} - TODO: Implement functionality
echo \"${script%.*} - implementation needed\"
" true
done

# ========================================
# CONFIG DIRECTORY
# ========================================

echo -e "${PURPLE}Creating configuration files...${NC}"
create_dir "config"

create_file "config/install_dependencies.sh" "#!/bin/bash

# Dependency Installation Script
echo \"Installing Universal File Converter dependencies...\"
echo \"TODO: Implement dependency installation\"
" true

config_files=(
    "conversion_chains.conf"
    "quality_profiles.conf"
    "format_mappings.conf"
    "security_rules.conf"
    "performance_settings.conf"
)

for config in "${config_files[@]}"; do
    create_file "config/${config}" "# ${config%.*} configuration
# TODO: Add configuration options
"
done

# ========================================
# SCRIPTS DIRECTORY
# ========================================

echo -e "${PURPLE}Creating utility scripts...${NC}"
create_dir "scripts"

utility_scripts=(
    "cleanup.sh"
    "auto_update.sh"
    "system_check.sh"
    "format_detector.sh"
    "repair_files.sh"
    "export_config.sh"
)

for script in "${utility_scripts[@]}"; do
    create_file "scripts/${script}" "#!/bin/bash

# ${script%.*} utility
echo \"${script%.*} - implementation needed\"
" true
done

# ========================================
# EXAMPLES DIRECTORY
# ========================================

echo -e "${PURPLE}Creating examples...${NC}"
create_dir "examples"
create_dir "examples/sample_files"

create_file "examples/basic_usage.md" "# Basic Usage Examples

## Image Conversion
\`\`\`bash
make imagemagick jpg png photo.jpg
\`\`\`

## Document Conversion
\`\`\`bash
make pandoc md pdf document.md
\`\`\`

## Audio Conversion
\`\`\`bash
make sox wav mp3 audio.wav
\`\`\`
"

create_file "examples/advanced_examples.md" "# Advanced Usage Examples

TODO: Add advanced conversion examples
"

create_file "examples/batch_examples.md" "# Batch Processing Examples

TODO: Add batch processing examples
"

create_file "examples/troubleshooting.md" "# Troubleshooting Guide

TODO: Add common issues and solutions
"

# Sample files
create_file "examples/sample_files/README.md" "# Sample Files

This directory contains sample files for testing conversions.
Add your test files here.
"

sample_files=(
    "sample.txt:This is a sample text file for testing conversions."
    "sample.md:# Sample Markdown\n\nThis is a **sample** markdown file."
    "sample.html:<!DOCTYPE html><html><head><title>Sample</title></head><body><h1>Sample HTML</h1></body></html>"
    "sample.json:{\"sample\": true, \"data\": [1, 2, 3]}"
    "sample.csv:name,age,city\nJohn,30,New York\nJane,25,London"
)

for sample in "${sample_files[@]}"; do
    filename="${sample%:*}"
    content="${sample#*:}"
    create_file "examples/sample_files/${filename}" "$(echo -e "$content")"
done

# ========================================
# TEMPLATES DIRECTORY
# ========================================

echo -e "${PURPLE}Creating templates...${NC}"
create_dir "templates"
create_dir "templates/quality_presets"
create_dir "templates/batch_templates"
create_dir "templates/workflow_templates"

# Quality presets
quality_presets=("fast.conf" "balanced.conf" "highest.conf")
for preset in "${quality_presets[@]}"; do
    create_file "templates/quality_presets/${preset}" "# ${preset%.*} quality preset
# TODO: Add quality settings
"
done

# Batch templates
batch_templates=(
    "image_optimization.sh"
    "document_conversion.sh"
    "audio_processing.sh"
)

for template in "${batch_templates[@]}"; do
    create_file "templates/batch_templates/${template}" "#!/bin/bash

# ${template%.*} batch template
echo \"${template%.*} - implementation needed\"
" true
done

# Workflow templates
workflow_templates=(
    "enterprise_workflow.yaml"
    "personal_workflow.yaml"
    "creative_workflow.yaml"
)

for workflow in "${workflow_templates[@]}"; do
    create_file "templates/workflow_templates/${workflow}" "# ${workflow%.*} workflow
# TODO: Add workflow definition
"
done

# ========================================
# TESTS DIRECTORY
# ========================================

echo -e "${PURPLE}Creating test structure...${NC}"
create_dir "tests"
create_dir "tests/unit"
create_dir "tests/integration"
create_dir "tests/performance"
create_dir "tests/fixtures"
create_dir "tests/fixtures/test_images"
create_dir "tests/fixtures/test_documents"
create_dir "tests/fixtures/test_audio"

create_file "tests/run_tests.sh" "#!/bin/bash

# Test Runner
echo \"Running Universal File Converter tests...\"
echo \"TODO: Implement test execution\"
" true

# Unit tests
unit_tests=(
    "test_imagemagick.sh"
    "test_pandoc.sh"
    "test_ffmpeg.sh"
    "test_helpers.sh"
)

for test in "${unit_tests[@]}"; do
    create_file "tests/unit/${test}" "#!/bin/bash

# ${test%.*} unit tests
echo \"${test%.*} tests - implementation needed\"
" true
done

# Integration tests
integration_tests=(
    "test_batch_processing.sh"
    "test_conflict_resolution.sh"
    "test_format_chains.sh"
)

for test in "${integration_tests[@]}"; do
    create_file "tests/integration/${test}" "#!/bin/bash

# ${test%.*} integration tests
echo \"${test%.*} tests - implementation needed\"
" true
done

# Performance tests
performance_tests=(
    "benchmark_suite.sh"
    "memory_tests.sh"
    "stress_tests.sh"
)

for test in "${performance_tests[@]}"; do
    create_file "tests/performance/${test}" "#!/bin/bash

# ${test%.*} performance tests
echo \"${test%.*} tests - implementation needed\"
" true
done

# Test fixtures
create_gitkeep "tests/fixtures/test_images"
create_gitkeep "tests/fixtures/test_documents"
create_gitkeep "tests/fixtures/test_audio"

# ========================================
# DOCS DIRECTORY
# ========================================

echo -e "${PURPLE}Creating documentation...${NC}"
create_dir "docs"
create_dir "docs/api"
create_dir "docs/guides"
create_dir "docs/formats"

# API docs
api_docs=(
    "converter_api.md"
    "helper_functions.md"
    "configuration.md"
)

for doc in "${api_docs[@]}"; do
    create_file "docs/api/${doc}" "# ${doc%.*}

TODO: Add API documentation
"
done

# Guides
guides=(
    "getting_started.md"
    "advanced_usage.md"
    "plugin_development.md"
    "performance_tuning.md"
)

for guide in "${guides[@]}"; do
    create_file "docs/guides/${guide}" "# ${guide%.*}

TODO: Add guide content
"
done

# Format docs
format_docs=(
    "image_formats.md"
    "document_formats.md"
    "audio_formats.md"
    "video_formats.md"
)

for format_doc in "${format_docs[@]}"; do
    create_file "docs/formats/${format_doc}" "# ${format_doc%.*}

TODO: Add format documentation
"
done

create_file "docs/FAQ.md" "# Frequently Asked Questions

## General Questions

### Q: How do I install the converter?
A: Run \`./config/install_dependencies.sh\`

### Q: Which formats are supported?
A: See the format documentation in docs/formats/

TODO: Add more FAQ entries
"

# ========================================
# FUTURE DIRECTORIES (v1.1+)
# ========================================

echo -e "${PURPLE}Creating future structure...${NC}"

# Plugins (v1.2+)
create_dir "plugins"
create_dir "plugins/official"
create_dir "plugins/community"
create_file "plugins/plugin_api.md" "# Plugin API Documentation

TODO: Add plugin development guide
"
create_file "plugins/plugin_manager.sh" "#!/bin/bash

# Plugin Manager
echo \"Plugin manager - implementation needed\"
" true

# Web interface (v1.2+)
create_dir "web"
create_dir "web/api"
create_dir "web/frontend"
create_dir "web/api/routes"
create_dir "web/api/middleware"
create_dir "web/frontend/src"
create_dir "web/frontend/public"

create_file "web/api/server.js" "// Universal File Converter API Server
// TODO: Implement REST API
console.log('API Server - implementation needed');
"

create_file "web/frontend/package.json" "{
  \"name\": \"universal-file-converter-frontend\",
  \"version\": \"1.0.0\",
  \"description\": \"Web frontend for Universal File Converter\",
  \"main\": \"src/index.js\",
  \"dependencies\": {},
  \"scripts\": {
    \"start\": \"echo 'Frontend - implementation needed'\"
  }
}
"

create_file "web/docker-compose.yml" "version: '3.8'

services:
  api:
    build: ./api
    ports:
      - \"3000:3000\"

  frontend:
    build: ./frontend
    ports:
      - \"3001:3001\"

# TODO: Complete Docker configuration
"

# Mobile (v2.0+)
create_dir "mobile"
create_dir "mobile/react-native"
create_dir "mobile/electron"

create_gitkeep "mobile/react-native"
create_gitkeep "mobile/electron"

# Deployment
create_dir "deployment"
create_dir "deployment/docker"
create_dir "deployment/kubernetes"
create_dir "deployment/ansible"
create_dir "deployment/terraform"

create_file "deployment/docker/Dockerfile" "# Universal File Converter Docker Image
FROM ubuntu:22.04

# TODO: Add Docker configuration
RUN echo \"Docker image - implementation needed\"
"

create_file "deployment/docker/docker-compose.yml" "version: '3.8'

services:
  converter:
    build: .
    volumes:
      - ./input:/app/input
      - ./output:/app/output

# TODO: Complete Docker Compose configuration
"

create_file "deployment/kubernetes/deployment.yaml" "apiVersion: apps/v1
kind: Deployment
metadata:
  name: universal-file-converter

# TODO: Add Kubernetes manifests
"

create_file "deployment/ansible/install.yml" "---
- name: Install Universal File Converter
  hosts: all
  tasks:
    - name: TODO - Add Ansible tasks
      debug:
        msg: \"Ansible playbook - implementation needed\"
"

create_file "deployment/terraform/main.tf" "# Universal File Converter Infrastructure

# TODO: Add Terraform configuration
"

# ========================================
# RUNTIME DIRECTORIES
# ========================================

echo -e "${PURPLE}Creating runtime directories...${NC}"

# Runtime directories with .gitkeep
runtime_dirs=("logs" "temp" "output" "cache")
for dir in "${runtime_dirs[@]}"; do
    create_dir "$dir"
    create_gitkeep "$dir"
    create_file "$dir/README.md" "# ${dir^} Directory

This directory is used for ${dir} files.
Contents are not tracked by Git.
"
done

# ========================================
# GITHUB WORKFLOWS
# ========================================

echo -e "${PURPLE}Creating GitHub workflows...${NC}"
create_dir ".github"
create_dir ".github/workflows"

create_file ".github/workflows/ci.yml" "name: Continuous Integration

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Run tests
      run: bash tests/run_tests.sh

# TODO: Complete CI configuration
"

create_file ".github/workflows/release.yml" "name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Create release
      run: echo \"Release automation - implementation needed\"

# TODO: Complete release automation
"

create_file ".github/ISSUE_TEMPLATE.md" "## Issue Description

**Type**: Bug Report / Feature Request / Question

**Description**:
<!-- Describe the issue -->

**Steps to Reproduce** (for bugs):
1.
2.
3.

**Expected Behavior**:
<!-- What should happen -->

**Actual Behavior**:
<!-- What actually happened -->

**Environment**:
- OS:
- Version:
- Converter:

**Additional Context**:
<!-- Any other information -->
"

create_file ".github/PULL_REQUEST_TEMPLATE.md" "## Pull Request Description

**Type**: Bug Fix / Feature / Documentation / Refactor

**Description**:
<!-- Describe your changes -->

**Changes Made**:
-
-
-

**Testing**:
<!-- How did you test these changes? -->

**Checklist**:
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes (or documented)

**Related Issues**:
<!-- Reference any related issues -->
"

create_file ".github/CONTRIBUTING.md" "# Contributing to Universal File Converter

Thank you for your interest in contributing!

## How to Contribute

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Update documentation
6. Submit a pull request

## Development Setup

\`\`\`bash
git clone your-fork-url
cd universal-file-converter
./config/install_dependencies.sh
\`\`\`

## Code Style

- Use bash best practices
- Add comments for complex logic
- Follow existing naming conventions
- Test your changes

## Reporting Issues

Use the GitHub issue template and provide:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- Environment details

## Questions?

Feel free to open an issue for questions!
"

# ========================================
# EDITOR CONFIGURATION
# ========================================

echo -e "${PURPLE}Creating editor configuration...${NC}"

create_file ".editorconfig" "root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.sh]
indent_size = 4

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
"

create_file ".shellcheckrc" "# ShellCheck configuration
disable=SC2034  # Unused variables (for templates)
disable=SC1091  # Source file not found (for dynamic sourcing)
"

create_file ".pre-commit-config.yaml" "repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.9.0
    hooks:
      - id: shellcheck
        args: [--severity=warning]
"

# ========================================
# FINAL SUMMARY
# ========================================

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║               PROJECT GENERATED                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Count files and directories
file_count=$(find . -type f | wc -l)
dir_count=$(find . -type d | wc -l)

echo -e "${BLUE}📊 Project Statistics:${NC}"
echo -e "   📁 Directories: $dir_count"
echo -e "   📄 Files: $file_count"
echo -e "   🔧 Executable scripts: $(find . -name '*.sh' -type f | wc -l)"
echo -e "   📚 Documentation files: $(find . -name '*.md' -type f | wc -l)"
echo ""

echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "   1️⃣  cd $BASE_DIR"
echo -e "   2️⃣  ./config/install_dependencies.sh"
echo -e "   3️⃣  ./help.sh"
echo -e "   4️⃣  make help"
echo ""

echo -e "${CYAN}🔧 Key Files to Implement:${NC}"
echo -e "   • converters/*.sh - Conversion logic"
echo -e "   • help/*.sh - Helper utilities"
echo -e "   • config/install_dependencies.sh - Dependency installation"
echo -e "   • Makefile - Main interface"
echo ""

echo -e "${PURPLE}🚀 Development Priority:${NC}"
echo -e "   1. Implement core converters (imagemagick, pandoc, ffmpeg)"
echo -e "   2. Create help utilities (search, validate, benchmark)"
echo -e "   3. Build dependency installer"
echo -e "   4. Add comprehensive tests"
echo -e "   5. Expand documentation"
echo ""

echo -e "${GREEN}✅ Project structure ready for development!${NC}"