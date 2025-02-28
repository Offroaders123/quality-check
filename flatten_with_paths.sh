#!/bin/bash

# Set the target directory (current directory by default)
TARGET_DIR="${1:-.}"

# Move and rename all files while preserving folder structure in filenames
find "$TARGET_DIR" -type f | while IFS= read -r file; do
    # Remove the leading "./" if present
    relative_path="${file#./}"

    # Replace directory slashes with hyphens and get the new filename
    new_filename="${relative_path//\//-}"

    # Define the new destination in the root of TARGET_DIR
    destination="$TARGET_DIR/$new_filename"

    # Handle duplicate filenames
    if [[ -e "$destination" ]]; then
        count=1
        while [[ -e "$TARGET_DIR/${new_filename%.*}_$count.${new_filename##*.}" ]]; do
            ((count++))
        done
        destination="$TARGET_DIR/${new_filename%.*}_$count.${new_filename##*.}"
    fi

    mv -- "$file" "$destination"
    echo "Moved: $file → $destination"
done

# Remove empty directories
find "$TARGET_DIR" -type d -empty -delete

echo "Flattening complete!"
