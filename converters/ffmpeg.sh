#!/bin/bash

# FFmpeg Converter
# Supports: Video, audio, and image formats

SUPPORTED_INPUT="mp4 avi mkv mov wmv flv webm m4v 3gp mp3 wav flac aac ogg m4a wma jpg jpeg png gif bmp tiff"
SUPPORTED_OUTPUT="mp4 avi mkv mov wmv flv webm m4v 3gp mp3 wav flac aac ogg m4a jpg jpeg png gif bmp tiff"

# Quality presets
declare -A QUALITY_MATRIX=(
    ["mp4,webm"]="4"     ["webm,mp4"]="4"
    ["avi,mp4"]="4"      ["mp4,avi"]="3"
    ["mov,mp4"]="5"      ["mp4,mov"]="4"
    ["flv,mp4"]="4"      ["mp4,flv"]="3"
    ["mp3,wav"]="5"      ["wav,mp3"]="4"
    ["flac,mp3"]="4"     ["mp3,flac"]="2"
    ["aac,mp3"]="4"      ["mp3,aac"]="4"
    ["ogg,mp3"]="4"      ["mp3,ogg"]="4"
    ["wav,flac"]="5"     ["flac,wav"]="5"
    ["jpg,png"]="4"      ["png,jpg"]="4"
)

declare -A SPEED_MATRIX=(
    ["mp4,webm"]="3"     ["webm,mp4"]="3"
    ["avi,mp4"]="4"      ["mp4,avi"]="4"
    ["mov,mp4"]="4"      ["mp4,mov"]="4"
    ["flv,mp4"]="3"      ["mp4,flv"]="4"
    ["mp3,wav"]="5"      ["wav,mp3"]="4"
    ["flac,mp3"]="3"     ["mp3,flac"]="5"
    ["aac,mp3"]="4"      ["mp3,aac"]="4"
    ["ogg,mp3"]="3"      ["mp3,ogg"]="3"
    ["wav,flac"]="2"     ["flac,wav"]="4"
    ["jpg,png"]="5"      ["png,jpg"]="5"
)

show_help() {
    cat << EOF
FFmpeg Multimedia Converter Help
================================

FFmpeg is a complete multimedia framework for audio, video, and image processing.

Supported Input Formats:
  Video: $SUPPORTED_INPUT
  Audio: mp3 wav flac aac ogg m4a wma opus
  Image: jpg jpeg png gif bmp tiff

Supported Output Formats:
  Video: $SUPPORTED_OUTPUT
  Audio: mp3 wav flac aac ogg m4a opus
  Image: jpg jpeg png gif bmp tiff

Environment Variables:

Video Options:
  FF_CODEC       - Video codec (libx264, libx265, libvpx-vp9, etc.)
  FF_BITRATE     - Video bitrate (e.g., 1M, 2000k)
  FF_RESOLUTION  - Output resolution (1920x1080, 1280x720, etc.)
  FF_FPS         - Frame rate (24, 30, 60)
  FF_CRF         - Constant Rate Factor for x264/x265 (18-28, lower=better)

Audio Options:
  FF_AUDIO_CODEC - Audio codec (aac, mp3, flac, opus)
  FF_AUDIO_BITRATE - Audio bitrate (128k, 192k, 320k)
  FF_SAMPLE_RATE - Sample rate (44100, 48000)

General Options:
  FF_PRESET      - Encoding preset (ultrafast, fast, medium, slow, veryslow)
  FF_THREADS     - Number of threads to use
  FF_START_TIME  - Start time for trimming (HH:MM:SS)
  FF_DURATION    - Duration for trimming (HH:MM:SS)

Quality Presets (set FF_QUALITY):
  - high: Best quality, larger files
  - medium: Balanced quality/size (default)
  - low: Faster encoding, smaller files

Examples:
  FF_QUALITY=high make ffmpeg mov mp4 video.mov
  FF_RESOLUTION=1280x720 FF_BITRATE=1M make ffmpeg avi mp4 video.avi
  FF_AUDIO_BITRATE=320k make ffmpeg flac mp3 audio.flac
  FF_START_TIME=00:01:30 FF_DURATION=00:02:00 make ffmpeg mp4 mp4 video.mp4 trimmed.mp4
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

is_video_format() {
    local format="$1"
    local video_formats="mp4 avi mkv mov wmv flv webm m4v 3gp"
    [[ " $video_formats " =~ " $format " ]]
}

is_audio_format() {
    local format="$1"
    local audio_formats="mp3 wav flac aac ogg m4a wma opus"
    [[ " $audio_formats " =~ " $format " ]]
}

is_image_format() {
    local format="$1"
    local image_formats="jpg jpeg png gif bmp tiff"
    [[ " $image_formats " =~ " $format " ]]
}

get_video_codec() {
    local format="$1"
    local codec="$FF_CODEC"

    if [ -z "$codec" ]; then
        case "$format" in
            mp4|m4v) codec="libx264" ;;
            webm) codec="libvpx-vp9" ;;
            avi) codec="libxvid" ;;
            mkv) codec="libx264" ;;
            mov) codec="libx264" ;;
            *) codec="libx264" ;;
        esac
    fi

    echo "$codec"
}

get_audio_codec() {
    local format="$1"
    local codec="$FF_AUDIO_CODEC"

    if [ -z "$codec" ]; then
        case "$format" in
            mp3) codec="libmp3lame" ;;
            aac|m4a) codec="aac" ;;
            ogg) codec="libvorbis" ;;
            flac) codec="flac" ;;
            wav) codec="pcm_s16le" ;;
            opus) codec="libopus" ;;
            *) codec="aac" ;;
        esac
    fi

    echo "$codec"
}

convert_file() {
    local from_format="$1"
    local to_format="$2"
    local input_file="$3"
    local output_file="$4"

    # Check if FFmpeg is installed
    if ! command -v ffmpeg &> /dev/null; then
        echo "Error: FFmpeg not installed. Install with: sudo apt-get install ffmpeg"
        return 1
    fi

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' does not exist"
        return 1
    fi

    # Build FFmpeg command
    local cmd="ffmpeg"
    local options=("-i" "$input_file")

    # Threading
    if [ -n "$FF_THREADS" ]; then
        options+=("-threads" "$FF_THREADS")
    fi

    # Trimming options
    if [ -n "$FF_START_TIME" ]; then
        options+=("-ss" "$FF_START_TIME")
    fi

    if [ -n "$FF_DURATION" ]; then
        options+=("-t" "$FF_DURATION")
    fi

    # Format-specific options
    if is_video_format "$to_format"; then
        # Video conversion
        local video_codec=$(get_video_codec "$to_format")
        options+=("-c:v" "$video_codec")

        # Video quality settings
        case "$FF_QUALITY" in
            high)
                if [ "$video_codec" = "libx264" ] || [ "$video_codec" = "libx265" ]; then
                    options+=("-crf" "${FF_CRF:-18}")
                elif [ -n "$FF_BITRATE" ]; then
                    options+=("-b:v" "$FF_BITRATE")
                else
                    options+=("-b:v" "5M")
                fi
                ;;
            low)
                if [ "$video_codec" = "libx264" ] || [ "$video_codec" = "libx265" ]; then
                    options+=("-crf" "${FF_CRF:-28}")
                elif [ -n "$FF_BITRATE" ]; then
                    options+=("-b:v" "$FF_BITRATE")
                else
                    options+=("-b:v" "1M")
                fi
                ;;
            *)
                if [ "$video_codec" = "libx264" ] || [ "$video_codec" = "libx265" ]; then
                    options+=("-crf" "${FF_CRF:-23}")
                elif [ -n "$FF_BITRATE" ]; then
                    options+=("-b:v" "$FF_BITRATE")
                else
                    options+=("-b:v" "2M")
                fi
                ;;
        esac

        # Resolution
        if [ -n "$FF_RESOLUTION" ]; then
            options+=("-s" "$FF_RESOLUTION")
        fi

        # Frame rate
        if [ -n "$FF_FPS" ]; then
            options+=("-r" "$FF_FPS")
        fi

        # Encoding preset
        if [ -n "$FF_PRESET" ]; then
            options+=("-preset" "$FF_PRESET")
        fi

        # Audio codec for video files
        local audio_codec=$(get_audio_codec "$to_format")
        options+=("-c:a" "$audio_codec")

        if [ -n "$FF_AUDIO_BITRATE" ]; then
            options+=("-b:a" "$FF_AUDIO_BITRATE")
        fi

    elif is_audio_format "$to_format"; then
        # Audio conversion
        local audio_codec=$(get_audio_codec "$to_format")
        options+=("-c:a" "$audio_codec")

        # Audio quality
        if [ -n "$FF_AUDIO_BITRATE" ]; then
            options+=("-b:a" "$FF_AUDIO_BITRATE")
        else
            case "$FF_QUALITY" in
                high) options+=("-b:a" "320k") ;;
                low) options+=("-b:a" "128k") ;;
                *) options+=("-b:a" "192k") ;;
            esac
        fi

        # Sample rate
        if [ -n "$FF_SAMPLE_RATE" ]; then
            options+=("-ar" "$FF_SAMPLE_RATE")
        fi

        # Remove video stream
        options+=("-vn")

    elif is_image_format "$to_format"; then
        # Image conversion
        case "$to_format" in
            jpg|jpeg) options+=("-q:v" "2") ;;
            png) options+=("-compression_level" "6") ;;
        esac

        # Resolution for images
        if [ -n "$FF_RESOLUTION" ]; then
            options+=("-s" "$FF_RESOLUTION")
        fi
    fi

    # Overwrite output file
    options+=("-y")

    # Output file
    options+=("$output_file")

    # Execute conversion
    echo "Executing: $cmd ${options[*]}"
    if "$cmd" "${options[@]}" 2>/dev/null; then
        echo "✓ Conversion successful: $output_file"

        # Show file info
        if command -v ffprobe &> /dev/null; then
            echo "Output info:"
            ffprobe -v quiet -show_format -show_streams "$output_file" | grep -E "(duration|bit_rate|width|height|codec_name)" | head -5
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
        echo "FFmpeg - Complete multimedia framework for video, audio and image processing"
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
