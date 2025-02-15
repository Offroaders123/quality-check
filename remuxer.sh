#!/bin/bash

# Ensure ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed. Please install it before running this script."
    exit 1
fi

# Input and output directories
ORIGINAL_DIR="original_aac_files"   # Directory containing original AAC files with metadata
LOSSLESS_DIR="lossless_files"       # Directory containing lossless source files (e.g., FLAC/WAV)

# Loop through each original AAC file
for orig_file in "$ORIGINAL_DIR"/*.m4a; do
    [ -e "$orig_file" ] || continue

    filename=$(basename -- "$orig_file")
    base="${filename%.*}"

    lossless_file="$LOSSLESS_DIR/$base.flac"  # Adjust if lossless files have a different extension
    output_file="$orig_file"  # Overwrite original file in place

    if [[ ! -f "$lossless_file" ]]; then
        echo "Skipping $filename: No matching lossless file found."
        continue
    fi

    echo "Processing $filename..."

    # Extract metadata from the original file
    ffmpeg -i "$orig_file" -map_metadata 0 -f ffmetadata "$base.metadata"

    # Get original file timestamps
    orig_mod_time=$(stat -f "%m" "$orig_file")

    # Re-encode the lossless file to AAC 256kbps and remux into .m4a
    ffmpeg -i "$lossless_file" -c:a libfdk_aac -b:a 256k -movflags +faststart -y "$base.temp.m4a"

    # Remux the new AAC stream into the original container with metadata
    ffmpeg -i "$base.temp.m4a" -i "$base.metadata" -map_metadata 1 -c copy -y "$output_file"

    # Restore original file timestamps
    touch -t "$(date -r "$orig_mod_time" +"%Y%m%d%H%M.%S")" "$output_file"

    # Clean up temporary files
    rm "$base.temp.m4a" "$base.metadata"

    echo "Finished processing $filename"
done

echo "All files processed successfully."
