#!/bin/bash

echo "Please enter the new package name:"
read name

if [ -z "$name" ]; then
    echo "Error: Package name cannot be empty."
    exit 1
fi

current_name="stuff"

echo "Renaming package from $current_name to $name..."

find . -type f -not -path '*/\.*' -exec sh -c '
    if file -b --mime-type "$1" | grep -q "^text/"; then
        sed -i "" "s/$2/$3/g" "$1"
    fi
' sh {} "$current_name" "$name" \;

if [ -d "$current_name" ]; then
    mv "$current_name" "$name"
else
    echo "Warning: Directory '$current_name' not found. Skipping directory rename."
fi

echo "Package renamed successfully."

# Remove this setup script
script_path=$(realpath "$0")
rm "$script_path"

echo "Setup script removed."
