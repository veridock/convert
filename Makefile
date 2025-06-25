# Universal File Converter System
# Usage: make [library] [from_format] [to_format] [input_file] [output_file]
# Example: make imagemagick jpg png input.jpg output.png

SHELL := /bin/bash
CONVERTER_DIR := ./converters
HELP_DIR := ./help
CONFIG_DIR := ./config

# Default output file generation
define generate_output
$(if $(5),$(5),$(basename $(4)).$(3))
endef

# Color definitions for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Help system
.PHONY: help list-libraries list-formats
help:
	@echo -e "$(BLUE)Universal File Converter System$(NC)"
	@echo "Usage: make [library] [from_format] [to_format] [input_file] [output_file]"
	@echo ""
	@echo "Available commands:"
	@echo "  help              - Show this help"
	@echo "  list-libraries    - List all available libraries"
	@echo "  list-formats      - List supported formats by library"
	@echo "  check-conflicts   - Check format conversion conflicts"
	@echo ""
	@echo "Interactive conflict resolution:"
	@echo "  ./help.sh [from_format] [to_format]"

list-libraries:
	@echo -e "$(GREEN)Available Conversion Libraries:$(NC)"
	@ls $(CONVERTER_DIR)/*.sh | sed 's/.*\///' | sed 's/.sh//' | sort

list-formats:
	@echo -e "$(GREEN)Supported Formats by Library:$(NC)"
	@for lib in $(CONVERTER_DIR)/*.sh; do \
		echo -e "$(YELLOW)$$(basename $$lib .sh):$(NC)"; \
		bash $$lib --list-formats 2>/dev/null || echo "  Format list not available"; \
		echo ""; \
	done

# Format conflict checker
check-conflicts:
	@echo -e "$(YELLOW)Checking for format conversion conflicts...$(NC)"
	@bash $(HELP_DIR)/conflict_checker.sh

# Image conversion libraries
imagemagick:
	@$(call convert_file,imagemagick,$(filter-out $@,$(MAKECMDGOALS)))

graphicsmagick:
	@$(call convert_file,graphicsmagick,$(filter-out $@,$(MAKECMDGOALS)))

ffmpeg:
	@$(call convert_file,ffmpeg,$(filter-out $@,$(MAKECMDGOALS)))

pillow:
	@$(call convert_file,pillow,$(filter-out $@,$(MAKECMDGOALS)))

opencv:
	@$(call convert_file,opencv,$(filter-out $@,$(MAKECMDGOALS)))

# Document conversion libraries
pandoc:
	@$(call convert_file,pandoc,$(filter-out $@,$(MAKECMDGOALS)))

libreoffice:
	@$(call convert_file,libreoffice,$(filter-out $@,$(MAKECMDGOALS)))

ghostscript:
	@$(call convert_file,ghostscript,$(filter-out $@,$(MAKECMDGOALS)))

poppler:
	@$(call convert_file,poppler,$(filter-out $@,$(MAKECMDGOALS)))

wkhtmltopdf:
	@$(call convert_file,wkhtmltopdf,$(filter-out $@,$(MAKECMDGOALS)))

# Audio/Video conversion
sox:
	@$(call convert_file,sox,$(filter-out $@,$(MAKECMDGOALS)))

# Specialized converters
inkscape:
	@$(call convert_file,inkscape,$(filter-out $@,$(MAKECMDGOALS)))

rsvg:
	@$(call convert_file,rsvg,$(filter-out $@,$(MAKECMDGOALS)))

# Conversion function
define convert_file
	@if [ ! -f "$(CONVERTER_DIR)/$(1).sh" ]; then \
		echo -e "$(RED)Error: Library $(1) not found$(NC)"; \
		exit 1; \
	fi; \
	if [ -z "$(word 1,$(2))" ] || [ -z "$(word 2,$(2))" ] || [ -z "$(word 3,$(2))" ]; then \
		echo -e "$(RED)Error: Missing arguments$(NC)"; \
		echo "Usage: make $(1) [from_format] [to_format] [input_file] [output_file]"; \
		exit 1; \
	fi; \
	FROM_FORMAT="$(word 1,$(2))"; \
	TO_FORMAT="$(word 2,$(2))"; \
	INPUT_FILE="$(word 3,$(2))"; \
	OUTPUT_FILE="$(call generate_output,$(1),$$FROM_FORMAT,$$TO_FORMAT,$$INPUT_FILE,$(word 4,$(2)))"; \
	echo -e "$(GREEN)Converting with $(1):$(NC) $$INPUT_FILE ($$FROM_FORMAT) -> $$OUTPUT_FILE ($$TO_FORMAT)"; \
	bash $(CONVERTER_DIR)/$(1).sh "$$FROM_FORMAT" "$$TO_FORMAT" "$$INPUT_FILE" "$$OUTPUT_FILE"
endef

# Install dependencies
install-deps:
	@echo -e "$(BLUE)Installing converter dependencies...$(NC)"
	@bash $(CONFIG_DIR)/install_dependencies.sh

# Prevent make from interpreting arguments as targets
%:
	@: