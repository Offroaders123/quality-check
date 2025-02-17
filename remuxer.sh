#!/bin/bash

# Ensure correct usage
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <original_aac_dir> <lossless_dir> <output_dir>"
    exit 1
fi

# Ensure ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed. Please install it before running this script."
    exit 1
fi

# Input and output directories
ORIGINAL_DIR="$1"   # Directory containing original AAC files with metadata
LOSSLESS_DIR="$2"   # Directory containing lossless source files (e.g., FLAC/WAV)
OUTPUT_DIR="$3"     # Directory where new AAC files will be stored

# Ensure output directory exists
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

    # Re-encode the lossless file to AAC 256kbps and remux into .m4a
    afconvert -f m4af -d aac -s 3 -ue vbrq 127 -q 127 "$lossless_file" "$OUTPUT_DIR/$base.temp.m4a"

    # Remux the new AAC stream into the original container with metadata,
    # copies all global metadata from in.m4a to out.m4a, and
    # copies audio stream metadata from in.m4a to out.m4a
    ffmpeg -i "$orig_file" -i "$OUTPUT_DIR/$base.temp.m4a" \
    -map 0:1 -map_metadata 0 \
    -map 1:a -c copy \
    "$output_file"

    # Preserve original file timestamps
    touch -r "$orig_file" "$output_file"

    # Clean up temporary files
    rm "$OUTPUT_DIR/$base.temp.m4a"

    echo "Finished processing $filename"
done

echo "All files processed successfully."
