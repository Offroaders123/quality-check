#!/bin/bash

# This one is specifically for new downloads from Bandcamp, from FLAC files to M4A.
# So I don't yet have the ones with custom tagging to worry about.

# Ensure correct usage
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <lossless_dir> <output_dir>"
    exit 1
fi

# Ensure ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed. Please install it before running this script."
    exit 1
fi

# Ensure afconvert is available (macOS only)
if ! command -v afconvert &> /dev/null; then
    echo "afconvert is not available. Are you using macOS?"
    exit 1
fi

# Input and output directories
LOSSLESS_DIR="$1"   # Directory containing lossless source files (e.g., FLAC/WAV)
OUTPUT_DIR="$2"     # Directory where new AAC files will be stored

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Loop through each FLAC file
for lossless_file in "$LOSSLESS_DIR"/*.flac; do

    filename=$(basename -- "$lossless_file")
    base="${filename%.*}"

    output_file="$OUTPUT_DIR/$base.m4a"

    echo "Processing $filename..."

    # Re-encode the lossless file to AAC 256kbps and remux into .m4a
    afconvert -f m4af -d aac -s 3 -ue vbrq 127 -q 127 "$lossless_file" "$OUTPUT_DIR/$base.temp.m4a"

    # Remux the new AAC stream into the original container with metadata,
    # copies all global metadata from in.flac to out.m4a, and
    # copies audio stream metadata from in.flac to out.m4a
    ffmpeg -i "$lossless_file" -i "$OUTPUT_DIR/$base.temp.m4a" \
    -map 0:1 -map_metadata 0 \
    -map 1:a -c copy \
    "$output_file"

    # Preserve original file timestamps
    touch -r "$lossless_file" "$output_file"

    # Clean up temporary files
    # rm "$OUTPUT_DIR/$base.temp.m4a"

    echo "Finished processing $filename"
done

echo "All files processed successfully."
