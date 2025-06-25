#!/bin/bash

# Universal File Converter - Dependency Installation Script

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Show installation status
show_status() {
    local tool="$1"
    local command="$2"

    if command_exists "$command"; then
        echo -e "  ${GREEN}✓${NC} $tool"
        return 0
    else
        echo -e "  ${RED}✗${NC} $tool"
        return 1
    fi
}

# Install package based on OS
install_package() {
    local package="$1"
    local os="$2"

    echo -e "${BLUE}Installing $package...${NC}"

    case "$os" in
        "debian")
            sudo apt-get update && sudo apt-get install -y $package
            ;;
        "redhat")
            if command_exists dnf; then
                sudo dnf install -y $package
            elif command_exists yum; then
                sudo yum install -y $package
            else
                echo -e "${RED}Neither dnf nor yum found${NC}"
                return 1
            fi
            ;;
        "arch")
            sudo pacman -S --noconfirm $package
            ;;
        "macos")
            if command_exists brew; then
                brew install $package
            else
                echo -e "${RED}Homebrew not found. Please install Homebrew first.${NC}"
                echo "Visit: https://brew.sh"
                return 1
            fi
            ;;
        *)
            echo -e "${YELLOW}Please install $package manually for your system${NC}"
            return 1
            ;;
    esac
}

# Install Python packages
install_python_package() {
    local package="$1"

    echo -e "${BLUE}Installing Python package: $package${NC}"

    if command_exists pip3; then
        pip3 install --user "$package"
    elif command_exists pip; then
        pip install --user "$package"
    else
        echo -e "${RED}pip not found. Please install Python and pip first.${NC}"
        return 1
    fi
}

# Install core converters
install_core_converters() {
    local os=$(detect_os)
    echo -e "${BLUE}Installing core conversion tools...${NC}"
    echo ""

    # Image processing
    echo -e "${YELLOW}Image Processing Tools:${NC}"

    if ! command_exists convert; then
        echo "Installing ImageMagick..."
        case "$os" in
            "debian") install_package "imagemagick" "$os" ;;
            "redhat") install_package "ImageMagick" "$os" ;;
            "arch") install_package "imagemagick" "$os" ;;
            "macos") install_package "imagemagick" "$os" ;;
        esac
    fi

    if ! command_exists gm; then
        echo "Installing GraphicsMagick..."
        case "$os" in
            "debian") install_package "graphicsmagick" "$os" ;;
            "redhat") install_package "GraphicsMagick" "$os" ;;
            "arch") install_package "graphicsmagick" "$os" ;;
            "macos") install_package "graphicsmagick" "$os" ;;
        esac
    fi

    # Document processing
    echo -e "${YELLOW}Document Processing Tools:${NC}"

    if ! command_exists pandoc; then
        echo "Installing Pandoc..."
        case "$os" in
            "debian") install_package "pandoc" "$os" ;;
            "redhat") install_package "pandoc" "$os" ;;
            "arch") install_package "pandoc" "$os" ;;
            "macos") install_package "pandoc" "$os" ;;
        esac
    fi

    if ! command_exists libreoffice; then
        echo "Installing LibreOffice..."
        case "$os" in
            "debian") install_package "libreoffice" "$os" ;;
            "redhat") install_package "libreoffice" "$os" ;;
            "arch") install_package "libreoffice-fresh" "$os" ;;
            "macos") install_package "libreoffice" "$os" ;;
        esac
    fi

    # Multimedia processing
    echo -e "${YELLOW}Multimedia Processing Tools:${NC}"

    if ! command_exists ffmpeg; then
        echo "Installing FFmpeg..."
        case "$os" in
            "debian") install_package "ffmpeg" "$os" ;;
            "redhat")
                # Enable EPEL for RHEL/CentOS
                if ! command_exists ffmpeg; then
                    echo "Note: FFmpeg may require EPEL repository on RHEL/CentOS"
                    echo "Try: sudo dnf install epel-release && sudo dnf install ffmpeg"
                fi
                install_package "ffmpeg" "$os" ;;
            "arch") install_package "ffmpeg" "$os" ;;
            "macos") install_package "ffmpeg" "$os" ;;
        esac
    fi

    if ! command_exists sox; then
        echo "Installing SoX..."
        case "$os" in
            "debian") install_package "sox" "$os" ;;
            "redhat") install_package "sox" "$os" ;;
            "arch") install_package "sox" "$os" ;;
            "macos") install_package "sox" "$os" ;;
        esac
    fi
}

# Install specialized converters
install_specialized_converters() {
    local os=$(detect_os)
    echo -e "${YELLOW}Specialized Conversion Tools:${NC}"

    # PDF tools
    if ! command_exists gs; then
        echo "Installing Ghostscript..."
        case "$os" in
            "debian") install_package "ghostscript" "$os" ;;
            "redhat") install_package "ghostscript" "$os" ;;
            "arch") install_package "ghostscript" "$os" ;;
            "macos") install_package "ghostscript" "$os" ;;
        esac
    fi

    if ! command_exists pdftoppm; then
        echo "Installing Poppler utilities..."
        case "$os" in
            "debian") install_package "poppler-utils" "$os" ;;
            "redhat") install_package "poppler-utils" "$os" ;;
            "arch") install_package "poppler" "$os" ;;
            "macos") install_package "poppler" "$os" ;;
        esac
    fi

    if ! command_exists wkhtmltopdf; then
        echo "Installing wkhtmltopdf..."
        case "$os" in
            "debian") install_package "wkhtmltopdf" "$os" ;;
            "redhat") install_package "wkhtmltopdf" "$os" ;;
            "arch") install_package "wkhtmltopdf" "$os" ;;
            "macos") install_package "wkhtmltopdf" "$os" ;;
        esac
    fi

    # Vector graphics
    if ! command_exists inkscape; then
        echo "Installing Inkscape..."
        case "$os" in
            "debian") install_package "inkscape" "$os" ;;
            "redhat") install_package "inkscape" "$os" ;;
            "arch") install_package "inkscape" "$os" ;;
            "macos") install_package "inkscape" "$os" ;;
        esac
    fi

    if ! command_exists rsvg-convert; then
        echo "Installing librsvg..."
        case "$os" in
            "debian") install_package "librsvg2-bin" "$os" ;;
            "redhat") install_package "librsvg2-tools" "$os" ;;
            "arch") install_package "librsvg" "$os" ;;
            "macos") install_package "librsvg" "$os" ;;
        esac
    fi
}

# Install Python-based converters
install_python_converters() {
    echo -e "${YELLOW}Python-based Converters:${NC}"

    # Check if Python is available
    if ! command_exists python3 && ! command_exists python; then
        echo -e "${RED}Python not found. Installing Python...${NC}"
        local os=$(detect_os)
        case "$os" in
            "debian") install_package "python3 python3-pip" "$os" ;;
            "redhat") install_package "python3 python3-pip" "$os" ;;
            "arch") install_package "python python-pip" "$os" ;;
            "macos") install_package "python" "$os" ;;
        esac
    fi

    # Install Pillow for image processing
    echo "Installing Pillow (PIL)..."
    install_python_package "Pillow"

    # Install OpenCV for advanced image processing
    echo "Installing OpenCV..."
    install_python_package "numpy"  # Required for OpenCV
    install_python_package "opencv-python"

    # Install additional document processors
    echo "Installing python-docx..."
    install_python_package "python-docx"

    echo "Installing openpyxl..."
    install_python_package "openpyxl"

    echo "Installing reportlab (PDF generation)..."
    install_python_package "reportlab"
}

# Install additional utilities
install_utilities() {
    local os=$(detect_os)
    echo -e "${YELLOW}Additional Utilities:${NC}"

    # File type detection
    if ! command_exists file; then
        echo "Installing file utilities..."
        case "$os" in
            "debian") install_package "file" "$os" ;;
            "redhat") install_package "file" "$os" ;;
            "arch") install_package "file" "$os" ;;
            "macos") echo "file command already available on macOS" ;;
        esac
    fi

    # Compression tools
    if ! command_exists unzip; then
        echo "Installing archive utilities..."
        case "$os" in
            "debian") install_package "unzip zip" "$os" ;;
            "redhat") install_package "unzip zip" "$os" ;;
            "arch") install_package "unzip zip" "$os" ;;
            "macos") echo "Archive utilities already available on macOS" ;;
        esac
    fi

    # JSON processor
    if ! command_exists jq; then
        echo "Installing jq..."
        case "$os" in
            "debian") install_package "jq" "$os" ;;
            "redhat") install_package "jq" "$os" ;;
            "arch") install_package "jq" "$os" ;;
            "macos") install_package "jq" "$os" ;;
        esac
    fi

    # Basic calculator for scripts
    if ! command_exists bc; then
        echo "Installing bc calculator..."
        case "$os" in
            "debian") install_package "bc" "$os" ;;
            "redhat") install_package "bc" "$os" ;;
            "arch") install_package "bc" "$os" ;;
            "macos") echo "bc already available on macOS" ;;
        esac
    fi
}

# Check installation status
check_installation_status() {
    echo -e "${BLUE}Checking installation status...${NC}"
    echo ""

    echo -e "${PURPLE}Image Processing:${NC}"
    show_status "ImageMagick" "convert"
    show_status "GraphicsMagick" "gm"
    show_status "FFmpeg" "ffmpeg"
    show_status "Inkscape" "inkscape"
    show_status "librsvg" "rsvg-convert"
    echo ""

    echo -e "${PURPLE}Document Processing:${NC}"
    show_status "Pandoc" "pandoc"
    show_status "LibreOffice" "libreoffice"
    show_status "Ghostscript" "gs"
    show_status "Poppler" "pdftoppm"
    show_status "wkhtmltopdf" "wkhtmltopdf"
    echo ""

    echo -e "${PURPLE}Audio Processing:${NC}"
    show_status "SoX" "sox"
    show_status "FFmpeg" "ffmpeg"
    echo ""

    echo -e "${PURPLE}Python Tools:${NC}"
    show_status "Python" "python3"
    if command_exists python3; then
        python3 -c "import PIL" 2>/dev/null && echo -e "  ${GREEN}✓${NC} Pillow (PIL)" || echo -e "  ${RED}✗${NC} Pillow (PIL)"
        python3 -c "import cv2" 2>/dev/null && echo -e "  ${GREEN}✓${NC} OpenCV" || echo -e "  ${RED}✗${NC} OpenCV"
        python3 -c "import docx" 2>/dev/null && echo -e "  ${GREEN}✓${NC} python-docx" || echo -e "  ${RED}✗${NC} python-docx"
        python3 -c "import openpyxl" 2>/dev/null && echo -e "  ${GREEN}✓${NC} openpyxl" || echo -e "  ${RED}✗${NC} openpyxl"
    fi
    echo ""

    echo -e "${PURPLE}Utilities:${NC}"
    show_status "file" "file"
    show_status "jq" "jq"
    show_status "bc" "bc"
    show_status "unzip" "unzip"
    echo ""
}

# Show usage examples
show_examples() {
    echo -e "${BLUE}Usage Examples:${NC}"
    echo "=============="
    echo ""

    echo -e "${GREEN}Image Conversions:${NC}"
    echo "  make imagemagick jpg png photo.jpg"
    echo "  make ffmpeg png gif animation.png"
    echo "  IM_QUALITY=95 make imagemagick tiff jpg scan.tiff"
    echo ""

    echo -e "${GREEN}Document Conversions:${NC}"
    echo "  make pandoc md pdf document.md"
    echo "  make libreoffice docx pdf presentation.docx"
    echo "  PANDOC_TOC=1 make pandoc rst html manual.rst"
    echo ""

    echo -e "${GREEN}Audio/Video Conversions:${NC}"
    echo "  make ffmpeg mp4 webm video.mp4"
    echo "  FF_QUALITY=high make ffmpeg avi mp4 movie.avi"
    echo "  make sox wav mp3 audio.wav"
    echo ""

    echo -e "${GREEN}Interactive Help:${NC}"
    echo "  ./help.sh pdf svg          # Find PDF to SVG converters"
    echo "  make check-conflicts       # Check for format conflicts"
    echo "  make list-libraries        # List all available converters"
    echo ""
}

# Create directory structure
create_directories() {
    echo -e "${BLUE}Setting up directory structure...${NC}"

    mkdir -p converters
    mkdir -p help
    mkdir -p config
    mkdir -p examples
    mkdir -p temp
    mkdir -p output
    mkdir -p logs
    mkdir -p cache

    echo -e "${GREEN}✓${NC} Directory structure created"
}

# Main installation menu
main_menu() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        Universal File Converter Installation      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
    echo ""

    local os=$(detect_os)
    echo -e "${YELLOW}Detected OS: $os${NC}"
    echo ""

    if [ "$1" = "--check" ]; then
        check_installation_status
        return
    fi

    if [ "$1" = "--examples" ]; then
        show_examples
        return
    fi

    echo "Select installation option:"
    echo "1) Install core converters (recommended)"
    echo "2) Install specialized converters"
    echo "3) Install Python-based converters"
    echo "4) Install all converters"
    echo "5) Check installation status"
    echo "6) Show usage examples"
    echo "7) Create directory structure only"
    echo "q) Quit"
    echo ""

    read -p "Choose option [1-7, q]: " choice

    case $choice in
        1)
            create_directories
            install_core_converters
            install_utilities
            check_installation_status
            ;;
        2)
            install_specialized_converters
            check_installation_status
            ;;
        3)
            install_python_converters
            check_installation_status
            ;;
        4)
            create_directories
            install_core_converters
            install_specialized_converters
            install_python_converters
            install_utilities
            check_installation_status
            echo ""
            show_examples
            ;;
        5)
            check_installation_status
            ;;
        6)
            show_examples
            ;;
        7)
            create_directories
            ;;
        q|Q)
            echo "Installation cancelled."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            main_menu
            ;;
    esac
}

# Handle command line arguments
if [ $# -eq 0 ]; then
    main_menu
else
    main_menu "$1"
fi
