#!/bin/bash

# SoX Audio Converter
# Supports: Advanced audio processing and conversion

SUPPORTED_INPUT="wav mp3 flac aac ogg m4a aiff au raw"
SUPPORTED_OUTPUT="wav mp3 flac ogg aiff au"

declare -A QUALITY_MATRIX=(
    ["wav,mp3"]="4"      ["mp3,wav"]="5"
    ["flac,mp3"]="4"     ["mp3,flac"]="2"
    ["wav,flac"]="5"     ["flac,wav"]="5"
    ["ogg,wav"]="5"      ["wav,ogg"]="4"
    ["aac,wav"]="4"      ["wav,aac"]="3"
    ["aiff,wav"]="5"     ["wav,aiff"]="5"
    ["au,wav"]="4"       ["wav,au"]="4"
)

declare -A SPEED_MATRIX=(
    ["wav,mp3"]="4"      ["mp3,wav"]="5"
    ["flac,mp3"]="3"     ["mp3,flac"]="5"
    ["wav,flac"]="2"     ["flac,wav"]="4"
    ["ogg,wav"]="4"      ["wav,ogg"]="3"
    ["aac,wav"]="4"      ["wav,aac"]="4"
    ["aiff,wav"]="5"     ["wav,aiff"]="5"
)

show_help() {
    cat << EOF
SoX Audio Converter Help
========================

SoX (Sound eXchange) is the Swiss Army knife of audio processing.

Supported Input Formats:
  $SUPPORTED_INPUT

Supported Output Formats:
  $SUPPORTED_OUTPUT

Environment Variables:

Quality Options:
  SOX_QUALITY      - Overall quality (low, medium, high, highest)
  SOX_BITRATE      - Bitrate for compressed formats (128k, 192k, 320k)
  SOX_SAMPLE_RATE  - Output sample rate (22050, 44100, 48000, 96000)
  SOX_CHANNELS     - Number of channels (1=mono, 2=stereo)
  SOX_BITS         - Bit depth (8, 16, 24, 32)

Audio Effects:
  SOX_NORMALIZE    - Normalize audio (1/0)
  SOX_AMPLIFY      - Amplify by dB (e.g., "+3", "-6")
  SOX_TRIM_START   - Trim start time (HH:MM:SS or seconds)
  SOX_TRIM_END     - Trim end time (HH:MM:SS or seconds)
  SOX_FADE_IN      - Fade in duration (seconds)
  SOX_FADE_OUT     - Fade out duration (seconds)
  SOX_TEMPO        - Change tempo without pitch (0.5-2.0)
  SOX_PITCH        - Change pitch in semitones (+/-12)
  SOX_REVERB       - Add reverb (1/0)
  SOX_NOISE_REDUCE - Reduce noise (1/0)

Filter Options:
  SOX_LOWPASS      - Low-pass filter frequency (Hz)
  SOX_HIGHPASS     - High-pass filter frequency (Hz)
  SOX_BASS         - Bass adjustment in dB (+/-20)
  SOX_TREBLE       - Treble adjustment in dB (+/-20)

Format-Specific:
  SOX_MP3_QUALITY  - MP3 quality (0-9, 0=best, 9=worst)
  SOX_FLAC_COMPRESSION - FLAC compression (0-8, 8=best)
  SOX_OGG_QUALITY  - OGG quality (-1 to 10)

Examples:
  SOX_QUALITY=high make sox wav mp3 audio.wav
  SOX_SAMPLE_RATE=48000 SOX_BITRATE=320k make sox flac mp3 song.flac
  SOX_NORMALIZE=1 SOX_AMPLIFY="+3" make sox wav wav quiet.wav loud.wav
  SOX_TRIM_START=30 SOX_TRIM_END=90 make sox mp3 wav song.mp3 clip.wav
  SOX_TEMPO=1.2 SOX_PITCH=2 make sox wav wav slow.wav fast.wav
EOF
}

check_support() {
    local from_format="$1"
    local to_format="$2"

    if [[ " $SUPPORTED_INPUT " =~ " $from_format " ]] && [[ " $SUPPORTED_OUTPUT " =~ " $to_format " ]]; then
        return 0
    else
        return 1
    fi
}

get_quality_rating() {
    local from_format="$1"
    local to_format="$2"
    local key="${from_format},${to_format}"

    echo "${QUALITY_MATRIX[$key]:-3}"
}

get_speed_rating() {
    local from_format="$1"
    local to_format="$2"
    local key="${from_format},${to_format}"

    echo "${SPEED_MATRIX[$key]:-3}"
}

get_sox_format_options() {
    local format="$1"
    local direction="$2"  # input or output
    local options=()

    case "$format" in
        mp3)
            if [ "$direction" = "output" ]; then
                local quality="${SOX_MP3_QUALITY:-2}"
                options+=("-C" "$quality")

                if [ -n "$SOX_BITRATE" ]; then
                    # SoX doesn't directly support bitrate for MP3, use quality mapping
                    case "$SOX_BITRATE" in
                        128k|128) quality="5" ;;
                        192k|192) quality="3" ;;
                        320k|320) quality="0" ;;
                    esac
                    options+=("-C" "$quality")
                fi
            fi
            ;;
        flac)
            if [ "$direction" = "output" ]; then
                local compression="${SOX_FLAC_COMPRESSION:-5}"
                options+=("-C" "$compression")
            fi
            ;;
        ogg)
            if [ "$direction" = "output" ]; then
                local quality="${SOX_OGG_QUALITY:-6}"
                options+=("-C" "$quality")
            fi
            ;;
        wav)
            # WAV specific options
            if [ -n "$SOX_BITS" ]; then
                options+=("-b" "$SOX_BITS")
            fi
            ;;
    esac

    echo "${options[@]}"
}

build_effects_chain() {
    local effects=()

    # Trim at the beginning (input effect)
    if [ -n "$SOX_TRIM_START" ] || [ -n "$SOX_TRIM_END" ]; then
        local trim_cmd="trim"
        if [ -n "$SOX_TRIM_START" ]; then
            trim_cmd="$trim_cmd $SOX_TRIM_START"
        else
            trim_cmd="$trim_cmd 0"
        fi
        if [ -n "$SOX_TRIM_END" ]; then
            trim_cmd="$trim_cmd =$SOX_TRIM_END"
        fi
        effects+=("$trim_cmd")
    fi

    # Noise reduction (requires noise profile - simplified)
    if [ "$SOX_NOISE_REDUCE" = "1" ]; then
        effects+=("noisered" "noise.prof" "0.21")
    fi

    # High-pass filter
    if [ -n "$SOX_HIGHPASS" ]; then
        effects+=("highpass" "$SOX_HIGHPASS")
    fi

    # Low-pass filter
    if [ -n "$SOX_LOWPASS" ]; then
        effects+=("lowpass" "$SOX_LOWPASS")
    fi

    # Bass adjustment
    if [ -n "$SOX_BASS" ]; then
        effects+=("bass" "$SOX_BASS")
    fi

    # Treble adjustment
    if [ -n "$SOX_TREBLE" ]; then
        effects+=("treble" "$SOX_TREBLE")
    fi

    # Amplification
    if [ -n "$SOX_AMPLIFY" ]; then
        effects+=("gain" "$SOX_AMPLIFY")
    fi

    # Tempo change
    if [ -n "$SOX_TEMPO" ]; then
        effects+=("tempo" "$SOX_TEMPO")
    fi

    # Pitch change
    if [ -n "$SOX_PITCH" ]; then
        effects+=("pitch" "$SOX_PITCH")
    fi

    # Fade effects
    if [ -n "$SOX_FADE_IN" ] || [ -n "$SOX_FADE_OUT" ]; then
        local fade_cmd="fade"
        if [ -n "$SOX_FADE_IN" ]; then
            fade_cmd="$fade_cmd $SOX_FADE_IN"
        else
            fade_cmd="$fade_cmd 0"
        fi
        if [ -n "$SOX_FADE_OUT" ]; then
            fade_cmd="$fade_cmd 0 $SOX_FADE_OUT"
        fi
        effects+=("$fade_cmd")
    fi

    # Reverb
    if [ "$SOX_REVERB" = "1" ]; then
        effects+=("reverb" "50" "50" "100" "100" "0" "0")
    fi

    # Normalization (should be last)
    if [ "$SOX_NORMALIZE" = "1" ]; then
        effects+=("gain" "-n")
    fi

    echo "${effects[@]}"
}

convert_file() {
    local from_format="$1"
    local to_format="$2"
    local input_file="$3"
    local output_file="$4"

    # Check if SoX is installed
    if ! command -v sox &> /dev/null; then
        echo "Error: SoX not installed. Install with: sudo apt-get install sox"
        return 1
    fi

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' does not exist"
        return 1
    fi

    # Additional format support check
    if [ "$to_format" = "mp3" ] && ! sox --help 2>&1 | grep -q "AUDIO FILE FORMATS.*mp3"; then
        echo "Error: SoX compiled without MP3 support. Install libsox-fmt-mp3"
        return 1
    fi

    # Build SoX command
    local cmd="sox"
    local options=()

    # Input file and format options
    local input_opts=($(get_sox_format_options "$from_format" "input"))
    if [ ${#input_opts[@]} -gt 0 ]; then
        options+=("${input_opts[@]}")
    fi
    options+=("$input_file")

    # Output format options
    local output_opts=($(get_sox_format_options "$to_format" "output"))
    if [ ${#output_opts[@]} -gt 0 ]; then
        options+=("${output_opts[@]}")
    fi

    # Sample rate
    if [ -n "$SOX_SAMPLE_RATE" ]; then
        options+=("-r" "$SOX_SAMPLE_RATE")
    fi

    # Channels
    if [ -n "$SOX_CHANNELS" ]; then
        options+=("-c" "$SOX_CHANNELS")
    fi

    # Bit depth (for uncompressed formats)
    if [ -n "$SOX_BITS" ] && [[ "$to_format" =~ ^(wav|aiff|au)$ ]]; then
        options+=("-b" "$SOX_BITS")
    fi

    # Quality preset override
    case "$SOX_QUALITY" in
        low)
            if [ "$to_format" = "mp3" ]; then
                options+=("-C" "7")
            fi
            ;;
        medium)
            if [ "$to_format" = "mp3" ]; then
                options+=("-C" "4")
            fi
            ;;
        high)
            if [ "$to_format" = "mp3" ]; then
                options+=("-C" "2")
            fi
            ;;
        highest)
            if [ "$to_format" = "mp3" ]; then
                options+=("-C" "0")
            fi
            ;;
    esac

    # Output file
    options+=("$output_file")

    # Effects chain
    local effects=($(build_effects_chain))
    if [ ${#effects[@]} -gt 0 ]; then
        options+=("${effects[@]}")
    fi

    # Execute conversion
    echo "Executing: $cmd ${options[*]}"
    if "$cmd" "${options[@]}"; then
        echo "✓ Conversion successful: $output_file"

        # Show file info
        if command -v soxi &> /dev/null; then
            echo "Output info:"
            soxi "$output_file"
        elif command -v file &> /dev/null; then
            file "$output_file"
        fi

        return 0
    else
        echo "✗ Conversion failed"
        return 1
    fi
}

# Handle command line arguments
case "$1" in
    --help)
        show_help
        ;;
    --description)
        echo "SoX - Sound eXchange, advanced audio processing and conversion toolkit"
        ;;
    --list-formats)
        echo "Input: $SUPPORTED_INPUT"
        echo "Output: $SUPPORTED_OUTPUT"
        ;;
    --check-support)
        check_support "$2" "$3"
        ;;
    --quality)
        get_quality_rating "$2" "$3"
        ;;
    --speed)
        get_speed_rating "$2" "$3"
        ;;
    *)
        if [ $# -eq 4 ]; then
            convert_file "$1" "$2" "$3" "$4"
        else
            echo "Usage: $0 [from_format] [to_format] [input_file] [output_file]"
            echo "       $0 --help"
            exit 1
        fi
        ;;
esac
