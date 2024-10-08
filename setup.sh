#!/bin/bash

# Debug flag
DEBUG=false

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

validate_package_name() {
    local name="$1"
    if [[ ! $name =~ ^[a-z][a-z0-9_]*$ ]]; then
        echo -e "\n\033[1;31mｘ Error: Invalid package name.\033[0m"
        echo "   · Must start with a letter"
        echo "   · Can only contain"
        echo "      · lowercase letters [a-z]"
        echo "      · numbers [0-9]"
        echo "      · underscores [_]"
        echo "   Use for example 'my_package' not 'My Package Name'."
        exit_gracefully
    fi
}

validate_repo_url() {
    local url="$1"
    if [ -z "$url" ]; then
        echo -e "  \033[33m⚠ No repository URL provided. Skipping remote setup.\033[0m"
        setup_new_repo="n"
    else
        # Regex test for the URL pattern
        if ! [[ $url =~ ^git@github\.com:[A-Za-z0-9_-]+/[A-Za-z0-9_-]+\.git$ ]]; then
            echo -e "  \033[1;31mｘ Error: Invalid repository URL format.\033[0m"
            echo -e "  \033[33mℹ The URL should match the pattern: git@github.com:<user>/<repo>.git\033[0m"
            exit_gracefully
        fi
    fi
}

exit_gracefully() {
    echo -e "\n\033[31mAboring Setup:\033[0m"
    echo -e "  Reverting changes, try again:"
    execute_command "git reset --hard && git clean -fd"
    exit 1
}

rename_package() {
    local new_name="$1"
    local current_name="$2"

    find . -type f -not -path '*/\.*' -not -name 'setup.sh' -exec sh -c '
        if file -b --mime-type "$1" | grep -q "^text/"; then
            sed -i "" "s/$2/$3/g" "$1"
        fi
    ' sh {} "$current_name" "$new_name" \;

    if [ -d "$current_name" ]; then
        mv "$current_name" "$new_name"
        echo -e "  \033[32m✔ Directory renamed to $new_name\033[0m"
    fi

    echo -e "  \033[32m✔ Package renamed to $new_name\033[0m"
}

# ? Setup Mode
prompt_yes_no "Setup Mode" "Wanna sit back and enjoy the ride (accept all defaults)?" use_opinionated_setup

# == Package Details ==

echo -e "\n\033[1m== Package Details ==\033[0m"

# ? Package Name
prompt_input "Package Name" "Please enter the new package name" name
validate_package_name "$name"

if [ "${use_opinionated_setup}" = "y" ]; then
    # ? GitHub Repository
    prompt_input "GitHub Repository" "Enter the URL of your new GitHub repository" new_repo_url
    validate_repo_url "$new_repo_url"

    run_pixi="y"
    install_hooks="y"
    setup_new_repo="y"
    initial_push="y"
    create_readme="y"

    echo -e "\n\033[32m✔ Using opinionated setup with recommended options.\033[0m"
else
    run_pixi=""
    install_hooks=""
    setup_new_repo=""
    initial_push=""
    create_readme=""
    new_repo_url=""
    echo -e "\n\033[33mℹ You will be prompted for each option during the setup.\033[0m"
fi

rename_package "$name" "package_name"

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

# == Connect Git Repository ==

echo -e "\n\033[1m== Connect Git Repository ==\033[0m"
if [ -z "$setup_new_repo" ] && [ -z "$new_repo_url" ]; then
    echo -e "\n\033[33mℹ If proceeding, please create a new repository on GitHub.\033[0m"
    echo -e "\033[33m  Then, copy the SSH URL (e.g., git@github.com:<user>/<repo>.git).\033[0m"
    echo -e "\033[33m  You'll need this URL in the next step.\033[0m"
    prompt_yes_no "New Repository" "Do you want to connect a new remote repository?" setup_new_repo
fi

if [ "${setup_new_repo}" = "y" ] && [ -z "$new_repo_url" ]; then
    prompt_input "GitHub Repository" "Enter the URL of your new GitHub repository" new_repo_url
    validate_repo_url "$new_repo_url"
fi

if [ "${setup_new_repo}" = "y" ]; then
    execute_command "rm -rf .git"
    echo -e "  \033[32m✔ Existing .git folder removed.\033[0m"

    execute_command "git init > /dev/null 2>&1"
    echo -e "  \033[32m✔ New git repository initialized.\033[0m"

    execute_command "git remote add origin \"$new_repo_url\""
    echo -e "  \033[32m✔ New remote origin added: $new_repo_url\033[0m"

    prompt_yes_no "Initial Commit" "Do you want to push an initial commit?" initial_push
    if [ "${initial_push}" = "y" ]; then
        execute_command "git add ."
        execute_command "git commit -m \"Initial commit\""
        execute_command "git branch -M main"
        execute_command "git push -u origin main"
        echo -e "  \033[32m✔ Initial commit pushed to the new repository.\033[0m"
    else
        echo -e "  \033[33mℹ Skipped initial commit and push. You can do this manually later.\033[0m"
    fi
else
    echo -e "  \033[33mℹ Skipped new repository setup. Existing Git configuration remains unchanged.\033[0m"
    echo -e "  \033[33m⚠ Warning: Unless you intend to contribute to pymc-labs/project-starter,\033[0m"
    echo -e "  \033[33m   you should now configure a new git repository manually.\033[0m"
fi

# == Clean Up ==

echo -e "\n\033[1m== Clean Up ==\033[0m"

script_path=$(realpath "$0")
execute_command "rm \"$script_path\""
echo -e "  \033[32m🗑️ Setup script has been deleted.\033[0m"

if [ "$setup_new_repo" != "y" ] && [ "$setup_new_repo" != "Y" ]; then
    echo -e "\n  \033[33mNote: To undo this entire setup, you can run:\033[0m"
    echo -e "  \033[36m  git reset --hard && git clean -fd\033[0m"
else
    echo -e "  \033[33mNote: Your project is now set up with a new Git repository.\033[0m"
    echo -e "  \033[33mIf you need to start over, you need to delete the repository\033[0m"
    echo -e "  \033[33mboth locally and on GitHub, and clone the project-starter repository again.\033[0m"
fi

# Final message
echo -e "\n\033[1m🎉 == Setup Complete! == 🎉\033[0m"
