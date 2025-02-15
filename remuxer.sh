#!/bin/bash

# Ensure ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed. Please install it before running this script."
    exit 1
fi

# Input and output directories
ORIGINAL_DIR="original_aac_files"   # Directory containing original AAC files with metadata
LOSSLESS_DIR="lossless_files"       # Directory containing lossless source files (e.g., FLAC/WAV)
OUTPUT_DIR="reencoded_files"        # Directory where new AAC files will be stored

mkdir -p "$OUTPUT_DIR"

# Loop through each original AAC file
for orig_file in "$ORIGINAL_DIR"/*.m4a; do
    [ -e "$orig_file" ] || continue

    filename=$(basename -- "$orig_file")
    base="${filename%.*}"

    lossless_file="$LOSSLESS_DIR/$base.flac"  # Adjust this if your lossless files have different extensions (e.g., .wav)
    output_file="$OUTPUT_DIR/$filename"

    if [[ ! -f "$lossless_file" ]]; then
        echo "Skipping $filename: No matching lossless file found."
        continue
    fi

    echo "Processing $filename..."

    # Extract metadata from the original file
    ffmpeg -i "$orig_file" -map_metadata 0 -f ffmetadata "$OUTPUT_DIR/$base.metadata"

    # Re-encode the lossless file to AAC 256kbps and remux into .m4a
    ffmpeg -i "$lossless_file" -c:a libfdk_aac -b:a 256k -movflags +faststart -y "$OUTPUT_DIR/$base.temp.m4a"

    # Remux the new AAC stream into the original container with metadata
    ffmpeg -i "$OUTPUT_DIR/$base.temp.m4a" -i "$OUTPUT_DIR/$base.metadata" -map_metadata 1 -c copy -y "$output_file"

    # Clean up temporary files
    rm "$OUTPUT_DIR/$base.temp.m4a" "$OUTPUT_DIR/$base.metadata"

    echo "Finished processing $filename"
done

echo "All files processed successfully."
