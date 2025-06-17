#!/bin/bash -x

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <cut_time> <output_name>"
    echo "Example: $0 input.mp4 01:45:30.05 output"
    exit 1
fi

INPUT_FILE="$1"
CUT_TIME="$2"
OUTPUT_NAME="$3"

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File $INPUT_FILE does not exist"
    exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed"
    exit 1
fi

# Check if NVIDIA hardware is available
if ! nvidia-smi &> /dev/null; then
    echo "Warning: CUDA acceleration not available, falling back to CPU"
    HW_ACCEL=""
    VIDEO_CODEC="libx264"
else
    HW_ACCEL="-hwaccel cuda -hwaccel_output_format cuda"
    VIDEO_CODEC="h264_nvenc"
fi

echo "Cut the first part (from start to specified time)"
ffmpeg $HW_ACCEL -i "$INPUT_FILE" -c:v $VIDEO_CODEC -c:a aac -to "$CUT_TIME" -y "${OUTPUT_NAME}_01.mp4"

# Check if the first command succeeded
if [ $? -ne 0 ]; then
    echo "Error creating ${OUTPUT_NAME}_01.mp4"
    exit 1
fi

echo "Cut the second part (from specified time to end)"
ffmpeg $HW_ACCEL -i "$INPUT_FILE" -c:v $VIDEO_CODEC -c:a aac -ss "$CUT_TIME" -y "${OUTPUT_NAME}_02.mp4"

# Check if the second command succeeded
if [ $? -ne 0 ]; then
    echo "Error creating ${OUTPUT_NAME}_02.mp4"
    exit 1
fi

echo "Cut successful: ${OUTPUT_NAME}_01.mp4 and ${OUTPUT_NAME}_02.mp4 created"