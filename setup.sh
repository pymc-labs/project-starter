#!/bin/bash

echo "Please enter the new package name:"
read name

# Validate the package name
if [[ ! $name =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
    echo "Error: Invalid package name. It must start with a letter and can only contain letters, numbers, and underscores. Use for example 'my_package_name' instead of 'My Package Name'."
    exit 1
fi

if [ -z "$name" ]; then
    echo "Error: Package name cannot be empty."
    exit 1
fi

# Rename the package
current_name="package_name"
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

# Ask if the user wants to run "pixi install"
echo "Do you want to run 'pixi install'? (y/n)"
read run_pixi

if [ "$run_pixi" = "y" ] || [ "$run_pixi" = "Y" ]; then
    echo "Running 'pixi install'..."
    pixi install
    echo "'pixi install' completed."

    # Ask if the user wants to install pre-commit hooks
    echo "Do you want to install pre-commit hooks? (y/n)"
    read install_hooks

    if [ "$install_hooks" = "y" ] || [ "$install_hooks" = "Y" ]; then
        echo "Installing pre-commit hooks..."
        pixi r pre-commit install
        echo "Pre-commit hooks installed successfully."
    fi
fi



# Delete existing README.md and rename .README.md
echo "Updating README files..."
if [ -f "README.md" ]; then
    rm README.md
    echo "Existing README.md deleted."
fi

if [ -f ".README.md" ]; then
    mv .README.md README.md
    echo ".README.md renamed to README.md."
else
    echo "Warning: .README.md not found. No changes made to README files."
fi

# Remove this setup script
script_path=$(realpath "$0")
rm "$script_path"

echo "Setup script removed."
