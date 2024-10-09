#!/bin/bash

# Debug flag
DEBUG=false

# Trap to handle cleanup on exit
trap exit_gracefully SIGINT SIGTERM EXIT

did_exit=false

execute_command() {
    echo -e "  \033[36m$ $1\033[0m"
    if [ "$DEBUG" = false ]; then
        eval "$1"
    fi
}

prompt_yes_no() {
    echo -e "\n\033[1;34m? $1\033[0m"
    read -p "  $2 [Y/n]: " $3
    eval "$3=\${$3:-y}" # Set default to 'y' if input is empty
}

prompt_input() {
    echo -e "\n\033[1;34m? $1\033[0m"
    read -p "  $2: " $3
}

validate_repo_url() {
    local url="$1"
    if [ -z "$url" ]; then
        echo -e "  \033[33m⚠ No repository URL provided. Skipping remote setup.\033[0m"
        setup_new_repo="n"
    else
        # Regex test for the URL pattern
        if ! [[ $url =~ ^git@github\.com:[A-Za-z0-9_-]+/[A-Za-z0-9_-]+\.git$ ]]; then
            echo -e "\n\033[1;31mｘ Error: Invalid repository URL format.\033[0m"
            echo -e "  · Argument must be a valid SSH URL of the form 'git@github.com:<user>/<repo>.git'"
            exit_gracefully
        fi
    fi
}

exit_gracefully() {
    if [ "$did_exit" = false ]; then
        echo -e "\n\033[31mAborting Setup:\033[0m"
        echo -e "  Reverting changes to initial commit:"
        execute_command "git reset --hard $(git rev-list --max-parents=0 HEAD)"
        execute_command "git clean -fd"
        did_exit=true
        exit 1
    fi
}

# ? Setup Mode
prompt_yes_no "Setup Mode" "Wanna sit back and enjoy the ride (accept all defaults)?" use_opinionated_setup

if [ "${use_opinionated_setup}" = "y" ]; then
    echo -e "  \033[32m✔ Using opinionated setup with recommended options.\033[0m"

    run_pixi="y"
    install_hooks="y"
    initial_push="y"
    create_readme="y"
    push_to_repo="y"

else
    echo -e "\n\033[33mℹ You will be prompted for each option during the setup.\033[0m"

    run_pixi=""
    install_hooks=""
    initial_push=""
    create_readme=""
    push_to_repo=""
fi

# == Package Name ==

echo -e "\n\033[1m== Package Name ==\033[0m"

# ? Package Name
current_name="package_name"
name=$(basename "$(pwd)" | tr '-' '_')

find . -type f -not -path '*/\.*' -not -name 'setup.sh' -exec sh -c '
    if file -b --mime-type "$1" | grep -q "^text/"; then
        sed -i "" "s/$2/$3/g" "$1"
    fi
' sh {} "$current_name" "$name" \;

if [ -d "$current_name" ]; then
    mv "$current_name" "$name"
    echo -e "  \033[32m✔ Directory renamed to $name\033[0m"
fi

echo -e "  \033[32m✔ Package renamed to $name\033[0m"

# == Install Python Environment ==

echo -e "\n\033[1m== Install Python Environment ==\033[0m"
if [ -z "$run_pixi" ]; then
    prompt_yes_no "Pixi Install" "Do you want to run 'pixi install'?" run_pixi
fi

if [ "${run_pixi}" = "y" ]; then
    execute_command "pixi install"
    echo -e "  \033[32m✔ 'pixi install' completed.\033[0m"

    # == Use Pre-commit Hooks ==

    echo -e "\n\033[1m== Use Pre-commit Hooks ==\033[0m"
    if [ -z "$install_hooks" ]; then
        prompt_yes_no "Pre-commit Hooks" "Do you want to use pre-commit hooks?" install_hooks
    fi

    if [ "${install_hooks}" = "y" ]; then
        execute_command "pixi r pre-commit install"
        echo -e "  \033[32m✔ Pre-commit hooks installed successfully.\033[0m"
    else
        echo -e "\n  Removing pre-commit configuration files and dependency..."
        execute_command "rm -f .pre-commit-config.yaml"
        execute_command "rm -f .github/workflows/code-style.yaml"
        execute_command "sed -i '' '/pre-commit = \"*\"/d' pyproject.toml"
        echo -e "  \033[32m✔ Pre-commit configuration files and dependency removed.\033[0m"
    fi
fi

# == Create README ==

echo -e "\n\033[1m== Create README ==\033[0m"

if [ -z "$create_readme" ]; then
    prompt_yes_no "README" "Do you want to create a README.md skeleton?" create_readme
fi

if [ "${create_readme}" = "y" ]; then
    execute_command "rm README.md"
    execute_command "mv template_README.md README.md"
    echo -e "  \033[32m✔ Created README.md for new project (skeleton only).\033[0m"
else
    execute_command "rm README.md template_README.md"
    echo -e "  \033[33mℹ Deleted 'project-starter' README.md.\033[0m"
fi

# == Push to Git Repository ==

echo -e "\n\033[1m== Push to Git Repository ==\033[0m"
if [ -z "$push_to_repo" ]; then
    prompt_yes_no "Push to GitHub" "Do you want to push the initialized project to GitHub?" push_to_repo
fi

if [ "${push_to_repo}" = "y" ]; then

    execute_command "git add . ':!setup.sh'"
    execute_command "git commit -m \"Initial commit\""
    execute_command "git push"
    echo -e "  \033[32m✔ Initial commit pushed to GitHub.\033[0m"
else
    echo -e "  \033[33mℹ Skipped initial commit and push. You can do this manually later.\033[0m"
fi

# == Clean Up ==

echo -e "\n\033[1m== Clean Up ==\033[0m"

script_path=$(realpath "$0")
execute_command "rm \"$script_path\""
echo -e "  \033[32m🗑️ Setup script has been deleted.\033[0m"


# Final message
echo -e "\n\033[1m🎉 == Setup Complete! == 🎉\033[0m"
echo -e "\n  \033[33mNote: To undo and start over, simply run:\033[0m"
echo -e "  \033[36m  git reset --hard && git clean -fd\033[0m"
