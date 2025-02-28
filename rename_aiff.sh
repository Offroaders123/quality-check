#!/bin/bash

# Set the target directory (current directory by default)
TARGET_DIR="${1:-.}"

# Find files without an extension and rename them
find "$TARGET_DIR" -type f | while IFS= read -r file; do
    mv -- "$file" "$file.aiff"
    echo "Renamed: $file → $file.aiff"
done

echo "Done!"
