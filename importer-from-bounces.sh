#!/bin/bash

# This one is specifically for creating high-quality M4A files from the bounces of my own music.
# I don't just use `importer.sh` instead because I don't have metadata to start with for these.

# Originally I have been downloading my songs from Bandcamp (after having disabled the
# price temporarily) with the metadata attached, but that is just as much of a hassle, and
# doing it this way is many less manual re-downloads to content I already have local access to.

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
for lossless_file in "$LOSSLESS_DIR"/*.wav; do

    filename=$(basename -- "$lossless_file")
    base="${filename%.*}"

    output_file="$OUTPUT_DIR/$base.m4a"

    echo "Processing $filename..."

    # Re-encode the lossless file to AAC 256kbps and remux into .m4a
    afconvert -f m4af -d aac -s 3 -ue vbrq 127 -q 127 "$lossless_file" "$output_file"

    # Preserve original file timestamps
    touch -r "$lossless_file" "$output_file"

    echo "Finished processing $filename"
done

echo "All files processed successfully."
