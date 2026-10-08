#!/bin/bash

# Functions -------------------------------------------------------------------
# -----------------------------------------------------------------------------

execute_command() {
    echo -e "  \033[36m$ $1\033[0m"
    eval "$1"
}

install_environment_command() {
    if ! execute_command "$1"; then
        echo "Environment setup failed. The configured project files were kept." >&2
        echo "Retry 'pixi install' before committing the new lockfile." >&2
        if [ "$decision_hub" = "y" ]; then
            echo "Then run 'pixi install -e decision-hub'." >&2
        fi
        if [ "$install_hooks" = "y" ]; then
            echo "Then run 'pixi r pre-commit install'." >&2
        fi
        exit 1
    fi
}

prompt_yes_no() {
    local default="${4:-y}"
    local choices="Y/n"
    [ "$default" = "n" ] && choices="y/N"
    echo -e "\n\033[1;34m? $1\033[0m"
    while true; do
        if ! read -r -p "  $2 [$choices]: " response; then
            # Handle EOF (Ctrl+D)
            echo -e ""
            exit 1
        fi
        case $response in
            '') eval "$3='$default'"; return 0 ;;
            [Yy]*) eval "$3='y'"; return 0 ;;
            [Nn]*) eval "$3='n'"; return 0 ;;
            *) echo "  Please answer yes (y) or no (n)." ;;
        esac
    done
}

exit_gracefully() {
    if [ "$revert_on_exit" = true ]; then
        echo -e "\n\033[31mAborting Setup:\033[0m"

        # Revert to initial commit
        echo -e "  Reverting changes to initial commit:"
        execute_command "git reset --hard $(git rev-list --max-parents=0 HEAD)"
        execute_command "git clean -fd"

        # Remove .pixi directory if it exists
        if [ -d ".pixi" ]; then
            echo -e "  Removing .pixi directory:"
            execute_command "rm -rf .pixi"
        fi

        revert_on_exit=false
        exit 1
    fi
}

# Validate before enabling rollback: rejecting a name must preserve local work.
current_name="package_name"
name=$(basename "$(pwd)" | tr '-' '_')
name_lower=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')

# Check case-insensitively so generated projects also work on macOS filesystems.
for entry in * .[!.]* ..?*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue
    if [ "$entry" = "$current_name" ] && [ "$name" = "$current_name" ]; then
        continue
    fi
    if [ "$(printf '%s' "$entry" | tr '[:upper:]' '[:lower:]')" = "$name_lower" ]; then
        printf "Cannot initialize package '%s': its name conflicts with '%s' (case-insensitive).\n" "$name" "$entry" >&2
        printf "Rename the project directory and run 'bash setup.sh' again. No files were changed.\n" >&2
        exit 1
    fi
done

# Trap to handle cleanup only after validation succeeds.
trap exit_gracefully SIGINT SIGTERM EXIT
revert_on_exit=true

# ? Setup Mode
prompt_yes_no "Setup Mode" "Wanna sit back and enjoy the ride (accept all defaults)?" use_opinionated_setup

if [ "${use_opinionated_setup}" = "y" ]; then
    echo -e "\n  \033[32m✔ Using opinionated setup with recommended options.\033[0m"

    run_pixi="y"
    install_hooks="y"
    create_readme="y"
    persistent_agent_context="y"
    decision_hub="n"
    echo "  Decision Hub is off by default; choose guided setup to enable it."
else
    echo -e "\n\033[33mℹ You will be prompted for each option during the setup.\033[0m"

    run_pixi=""
    install_hooks=""
    create_readme=""
    persistent_agent_context=""
    decision_hub=""
fi

# == Package Name ==

echo -e "\n\033[1m== Package Name ==\033[0m"

find . -type f -not -path '*/\.*' -not -name 'setup.sh' -exec sh -c '
    if file -b --mime-type "$1" | grep -q "^text/"; then
        if [ "$(uname)" = "Darwin" ]; then
            # macOS (BSD sed)
            sed -i "" "s/$2/$3/g" "$1"
        else
            # Linux (GNU sed)
            sed -i "s/$2/$3/g" "$1"
        fi
    fi
' sh {} "$current_name" "$name" \;

if [ "$name" != "$current_name" ] && [ -d "$current_name" ]; then
    mv "$current_name" "$name"
    echo -e "  \033[32m✔ Directory renamed to $name\033[0m"
fi

echo -e "  \033[32m✔ Package renamed to $name\033[0m"

# == Install Python Environment ==

echo -e "\n\033[1m== Install Python Environment ==\033[0m"
if [ -z "$run_pixi" ]; then
    prompt_yes_no "Pixi Install" "Do you want to run 'pixi install'?" run_pixi
fi

# == Persistent Agent Context ==

echo -e "\n\033[1m== Persistent Agent Context ==\033[0m"
echo "  AGENTS.md guides agents to workflow rules, implementation references,"
echo "  and session notes. The notes and skill directory start empty."
echo "  This also includes scripts/ with .adhoc/reference/ and ignored .adhoc/scratch/."

if [ -z "$persistent_agent_context" ]; then
    prompt_yes_no "Persistent Agent Context" "Do you want to keep persistent agent context for this project?" persistent_agent_context
fi

if [ "${persistent_agent_context}" = "y" ]; then
    # The initialized project should not inherit instructions for maintaining the starter.
    sed '/^<!-- starter-only:start -->$/,/^<!-- starter-only:end -->$/d' AGENTS.md > AGENTS.md.tmp &&
        mv AGENTS.md.tmp AGENTS.md || exit 1
    echo -e "  \033[32m✔ Kept AGENTS.md, AGENTS/, .agents/skills/, and scripts/.\033[0m"
else
    execute_command "rm -rf AGENTS.md AGENTS"
    execute_command "rm -f .agents/skills/.gitkeep"
    execute_command "rm -f scripts/README.md scripts/.adhoc/README.md scripts/.adhoc/reference/.gitkeep scripts/.adhoc/scratch/.gitkeep"
    # Remove empty scaffold directories, preserving user-added skills and scripts.
    rmdir .agents/skills .agents 2>/dev/null || true
    rmdir scripts/.adhoc/reference scripts/.adhoc/scratch scripts/.adhoc scripts 2>/dev/null || true
    echo -e "  \033[33mℹ Removed the persistent agent context scaffold.\033[0m"
fi

# == Decision Hub ==

if [ "${persistent_agent_context}" = "y" ]; then
    if [ -z "$decision_hub" ]; then
        echo "  Decision Hub finds and downloads agent skills. Public skills need no account."
        echo "  Enable its CLI in a separate Pixi environment, with instructions in AGENTS/."
        prompt_yes_no "Decision Hub" "Do you want to include Decision Hub (dhub)?" decision_hub n
    fi
else
    decision_hub="n"
fi

if [ "${decision_hub}" = "y" ]; then
    sed '/^# decision-hub:/d' pyproject.toml > pyproject.toml.tmp &&
        mv pyproject.toml.tmp pyproject.toml || exit 1
    for doc in AGENTS.md template_README.md; do
        sed '/^<!-- decision-hub:/d' "$doc" > "$doc.tmp" && mv "$doc.tmp" "$doc" || exit 1
    done
    echo "  Kept Decision Hub. Use: pixi run -e decision-hub dhub --help"
else
    sed '/^# decision-hub:start$/,/^# decision-hub:end$/d' pyproject.toml > pyproject.toml.tmp &&
        mv pyproject.toml.tmp pyproject.toml || exit 1
    for doc in AGENTS.md template_README.md; do
        [ -f "$doc" ] || continue
        sed '/^<!-- decision-hub:start -->$/,/^<!-- decision-hub:end -->$/d' "$doc" > "$doc.tmp" &&
            mv "$doc.tmp" "$doc" || exit 1
    done
    rm -f AGENTS/CONVENTION/DECISION_HUB.md
fi

# Choose all dependencies before solving the new project's environment.
if [ "${run_pixi}" = "y" ]; then
    if [ -z "$install_hooks" ]; then
        prompt_yes_no "Pre-commit Hooks" "Do you want to use pre-commit hooks?" install_hooks
    fi
    if [ "${install_hooks}" = "n" ]; then
        rm -f .pre-commit-config.yaml .github/workflows/code-style.yaml
        sed '/^pre-commit = /d' pyproject.toml > pyproject.toml.tmp &&
            mv pyproject.toml.tmp pyproject.toml || exit 1
    fi
fi

# The starter's lock is for starter CI. Resolve current compatible versions once
# for each new project, then commit and retain that project's own lockfile.
rm -f pixi.lock
if [ "${run_pixi}" = "n" ]; then
    echo "  Run 'pixi install' to generate this project's lockfile before committing."
    if [ "${decision_hub}" = "y" ]; then
        echo "  Then run 'pixi install -e decision-hub' to install the optional CLI."
    fi
fi

# == Create README ==

echo -e "\n\033[1m== Create README ==\033[0m"

if [ -z "$create_readme" ]; then
    prompt_yes_no "README" "Do you want to create a README.md skeleton?" create_readme
fi

if [ "${create_readme}" = "y" ]; then
    if [ "${persistent_agent_context}" = "y" ]; then
        sed '/^<!-- agent-context:/d' template_README.md > README.md
    else
        sed '/^<!-- agent-context:start -->$/,/^<!-- agent-context:end -->$/d' template_README.md > README.md
    fi
    execute_command "rm template_README.md"
    echo -e "  \033[32m✔ Created README.md for new project (skeleton only).\033[0m"
else
    execute_command "rm README.md template_README.md"
    echo -e "  \033[33mℹ Deleted 'project-starter' README.md.\033[0m"
fi

# == Clean Up ==

echo -e "\n\033[1m== Clean Up ==\033[0m"

script_path=$(realpath "$0")
# These tests exercise the initializer and are not part of the new project.
execute_command "rm -f tests/test_setup.py"
execute_command "rm \"$script_path\""
echo -e "  \033[32m🗑️ Setup script has been deleted.\033[0m"

# Configuration is complete. A failed download must not roll back project files.
revert_on_exit=false
if [ "${run_pixi}" = "y" ]; then
    install_environment_command "pixi install"
    if [ "${decision_hub}" = "y" ]; then
        install_environment_command "pixi install -e decision-hub"
    fi
    if [ "${install_hooks}" = "y" ]; then
        install_environment_command "pixi r pre-commit install"
    fi
fi

# Final message
echo -e "\n\033[1m🎉 == Setup Complete! == 🎉\033[0m"
echo -e "\n  \033[33mNote: To undo and start over, simply run:\033[0m"
echo -e "  \033[36m  git reset --hard $(git rev-list --max-parents=0 HEAD) && git clean -fd\033[0m"

# Ask about committing and pushing
prompt_yes_no "Commit and Push" "Do you want to commit and push these changes?" commit_and_push

if [ "${commit_and_push}" = "y" ]; then
    echo -e "\n\033[1m== Committing and Pushing Changes ==\033[0m"
    execute_command "git add ."
    execute_command "git commit -m 'Initial setup with project-starter'"
    execute_command "git pull"
    execute_command "git push origin main"
    echo -e "  \033[32m✔ Changes committed and pushed successfully.\033[0m"
else
    echo -e "\n\033[33mℹ Changes have not been committed or pushed.\033[0m"
fi
