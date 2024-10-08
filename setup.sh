#!/bin/bash

echo -e "\033[1mPlease enter the new package name:\033[0m"
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
echo -e "\n\033[1m== Renaming Package ==\033[0m"
echo -e "  From: \033[36m$current_name\033[0m"
echo -e "  To:   \033[36m$name\033[0m\n"

find . -type f -not -path '*/\.*' -exec sh -c '
    if file -b --mime-type "$1" | grep -q "^text/"; then
        sed -i "" "s/$2/$3/g" "$1"
    fi
' sh {} "$current_name" "$name" \;

if [ -d "$current_name" ]; then
    mv "$current_name" "$name"
    echo -e "  \033[32m✔ Directory renamed successfully\033[0m"
else
    echo -e "  \033[33m⚠ Warning: Directory '$current_name' not found. Skipping directory rename.\033[0m"
fi

echo -e "  \033[32m✔ Package renamed successfully.\033[0m"

# Ask if the user wants to run "pixi install"
echo -e "\n\033[1m== Additional Setup ==\033[0m"
read -p "Do you want to run 'pixi install'? (y/n): " run_pixi

if [ "$run_pixi" = "y" ] || [ "$run_pixi" = "Y" ]; then
    echo -e "\n  Running 'pixi install'..."
    pixi install
    echo -e "  \033[32m✔ 'pixi install' completed.\033[0m"

    # Ask if the user wants to install pre-commit hooks
    read -p "Do you want to install pre-commit hooks? (y/n): " install_hooks

    if [ "$install_hooks" = "y" ] || [ "$install_hooks" = "Y" ]; then
        echo -e "\n  Installing pre-commit hooks..."
        pixi r pre-commit install
        echo -e "  \033[32m✔ Pre-commit hooks installed successfully.\033[0m"
    fi
fi

# Delete existing README.md and rename .README.md
echo -e "\n\033[1m== Updating README ==\033[0m"
if [ -f "README.md" ]; then
    rm README.md
    echo -e "  \033[32m✔ Existing README.md deleted.\033[0m"
fi

if [ -f ".README.md" ]; then
    mv .README.md README.md
    echo -e "  \033[32m✔ .README.md renamed to README.md.\033[0m"
else
    echo -e "  \033[33m⚠ Warning: .README.md not found. No changes made to README files.\033[0m"
fi

echo -e "\n\033[1m== Setup Complete ==\033[0m"

# Remove this setup script
script_path=$(realpath "$0")
rm "$script_path"

echo -e "  \033[32m🚀 Setup script launched into oblivion.\033[0m"
