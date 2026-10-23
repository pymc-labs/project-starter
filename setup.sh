#!/bin/bash

# The central system of prok that holds the knowledge of PyMC Labs projects, on the company's Google Cloud.
# PROK_URL overrides it, to try setup against another instance.
prok_url="${PROK_URL:-https://prok-central-44370529026.europe-west3.run.app}"
prok_release="pymc-labs/prok"

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

        # Revert to the commit setup started from. Work that was there before setup is stashed, never deleted.
        echo -e "  Reverting changes to the commit setup started from:"
        if [ "$started_clean" = y ]; then
            execute_command "git reset --hard $start_head"
            execute_command "git clean -fd"
        else
            execute_command "git -c user.name=project-starter -c user.email=setup@project-starter.invalid stash push --include-untracked --quiet -m 'project-starter setup, aborted: your work and what setup had changed'"
            echo -e "  \033[33mYour uncommitted work is in the stash, together with what setup had changed: git stash show --include-untracked\033[0m"
        fi
        # Git leaves its hooks alone; a commit hook prok wrote during setup goes too.
        if [ "$had_commit_hook" = n ] && is_prok_hook; then
            execute_command "rm -f '$commit_hook'"
        fi

        # Remove .pixi directory if it exists
        if [ -d ".pixi" ]; then
            echo -e "  Removing .pixi directory:"
            execute_command "rm -rf .pixi"
        fi

        revert_on_exit=false
        exit 1
    fi
}

# Keeps the lines between the markers of a section and removes the markers, or removes the whole section.
# Markers stand on lines of their own: `<!-- name:start -->` in Markdown, `# name:start` elsewhere.
keep_section() {
    local file="$1" name="$2" keep="$3" open close
    [ -f "$file" ] || return 0
    case "$file" in
        *.md) open="<!-- $name:start -->"; close="<!-- $name:end -->" ;;
        *) open="# $name:start"; close="# $name:end" ;;
    esac
    if [ "$keep" = "y" ]; then
        sed "\|^$open\$|d; \|^$close\$|d" "$file" > "$file.tmp"
    else
        sed "\|^$open\$|,\|^$close\$|d" "$file" > "$file.tmp"
    fi
    mv "$file.tmp" "$file"
}

# Whether the commit hook of this clone is the one prok writes.
is_prok_hook() {
    grep -qs '^# Written by prok\.' "$commit_hook"
}

# The group prok's central system makes for a new project: its name in lower case, `-` for anything else, `-team`.
prok_team() {
    printf '%s-team' "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9-]/-/g' -e 's/^-*//')"
}

# Says why prok cannot be installed on this machine, or nothing when it can.
prok_install_blocker() {
    local node_major
    node_major=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null)
    if [ -z "$node_major" ] || [ "$node_major" -lt 24 ] || ! command -v npm >/dev/null 2>&1; then
        echo "prok needs Node 24 or later with npm (on macOS: brew install node)."
    elif ! command -v gh >/dev/null 2>&1; then
        echo "prok is installed with the GitHub CLI (on macOS: brew install gh)."
    elif ! gh api "repos/$prok_release" --silent >/dev/null 2>&1; then
        echo "the GitHub CLI cannot read $prok_release; log in with your PyMC Labs GitHub account: gh auth login."
    fi
}

install_prok() {
    local download
    download=$(mktemp -d) &&
        execute_command "gh release download -R $prok_release -p prok.tgz -D '$download' --clobber" &&
        execute_command "npm install -g '$download/prok.tgz'"
}

# The repository on GitHub that origin names, as owner/name, or nothing.
# Any URL of a GitHub host: SSH with a host alias, `ssh://` with a port, HTTPS with a user, a trailing `/` or `.git`.
github_repository() {
    local url owner name
    url=$(git remote get-url origin 2>/dev/null) || return 0
    case "$url" in *github*) ;; *) return 0 ;; esac
    url="${url%/}"
    url="${url%.git}"
    name="${url##*/}"
    url="${url%/*}"
    owner="${url##*[/:]}"
    case "$owner/$name" in
        */*/* | *[!A-Za-z0-9_./-]* | /* | */) return 0 ;;
    esac
    printf '%s/%s\n' "$owner" "$name"
}

# Logs in to the central system of prok; where Google has no login on this machine, it asks gcloud for one first.
prok_login() {
    prok whoami >/dev/null 2>&1 && return 0
    execute_command "prok login" && return 0
    if ! command -v gcloud >/dev/null 2>&1; then
        echo "  prok logs in with your PyMC Labs Google account through gcloud: https://cloud.google.com/sdk/docs/install" >&2
        return 1
    fi
    echo "  Log in to Google with your PyMC Labs account. A browser opens."
    execute_command "gcloud auth login" && execute_command "prok login"
}

# Makes Claude Code take the plugin of prok, or its newer version, with the commands prok prints for it.
install_claude_plugin() {
    local steps step
    command -v claude >/dev/null 2>&1 || return 0
    steps=$(prok install-agent-plugin --global 2>/dev/null | sed -n 's/^  \(claude plugin .*\)$/\1/p')
    [ -n "$steps" ] || return 0
    if [ -z "$claude_plugin" ]; then
        echo "  Claude Code gets prok's hooks and skill from a plugin, installed once per machine."
        prompt_yes_no "Claude Code" "Do you want to install the prok plugin for Claude Code?" claude_plugin
    fi
    [ "$claude_plugin" = "y" ] || return 0
    while IFS= read -r step; do
        execute_command "$step" </dev/null || return 1
    done <<< "$steps"
    echo "  Start Claude Code again for the plugin to take effect."
}

# Moves the shared instructions to .prok/instructions.md and runs prok init, which writes the rest. Where prok init
# fails, everything it and this function changed is undone, so that the project can go on without prok.
apply_prok() {
    local backup path created=""
    backup=$(mktemp -d) || return 1
    cp AGENTS.md .gitignore template_README.md "$backup/" || return 1
    [ ! -f .pre-commit-config.yaml ] || cp .pre-commit-config.yaml "$backup/" || return 1
    for path in .prok .claude .codex .opencode opencode.json .agents CLAUDE.md PROJECT_KNOWLEDGE.md; do
        [ -e "$path" ] || created="$created $path"
    done
    mkdir -p .prok
    keep_section AGENTS.md prok y
    keep_section AGENTS.md no-prok n
    mv AGENTS.md .prok/instructions.md
    git rm --cached --quiet --ignore-unmatch AGENTS.md
    keep_section .pre-commit-config.yaml prok y
    keep_section template_README.md prok y
    if execute_command "prok init --url '$prok_url' --project '$prok_project'"; then
        rm -rf "$backup"
        return 0
    fi
    for path in $created; do
        rm -rf "$path"
    done
    cp "$backup/AGENTS.md" "$backup/.gitignore" "$backup/template_README.md" .
    [ ! -f "$backup/.pre-commit-config.yaml" ] || cp "$backup/.pre-commit-config.yaml" .
    git reset --quiet -- AGENTS.md
    if [ "$had_commit_hook" = n ] && is_prok_hook; then
        rm -f "$commit_hook"
    fi
    rm -rf "$backup"
    return 1
}

# Asks prok to create the project and says what came of it: a new project, one that exists already, or a refusal.
create_prok_project() {
    local said status group
    echo -e "  \033[36m$ prok project create\033[0m"
    said=$(prok project create 2>&1)
    status=$?
    printf '%s\n' "$said"
    case "$status:$said" in
        0:*"exists already"*)
            echo -e "  \033[33m⚠ The prok project '$prok_project' existed before this repository, which now shares its knowledge.\033[0m"
            echo -e "  \033[33m  If it should have a project of its own: prok init --url $prok_url --project <new-name> && prok project create\033[0m"
            ;;
        *"exists already"*)
            echo -e "  \033[33m  To give this repository a project of its own: prok init --url $prok_url --project <new-name> && prok project create\033[0m"
            ;;
    esac
    [ "$status" -eq 0 ] || return 1
    # The README names the group the central system made, which differs where the obvious name was taken.
    group=$(printf '%s\n' "$said" | sed -n 's/.*through the group \([^ ]*\)\.$/\1/p')
    if [ -n "$group" ] && [ -f README.md ]; then
        sed "s|prok group add $(prok_team "$prok_project") |prok group add $group |g" README.md > README.md.tmp &&
            mv README.md.tmp README.md
    fi
}

# CI canonizes the world of a merged pull request as a workflow of this repository, once the project names it.
name_repository() {
    local repository
    repository=$(github_repository)
    if [ -z "$repository" ]; then
        echo -e "  \033[33mℹ No GitHub remote yet. Once there is one, run 'prok project add-repository <owner>/<name>' for CI.\033[0m"
    elif ! execute_command "prok project add-repository '$repository'"; then
        echo -e "  \033[33mℹ CI cannot canonize until a maintainer runs 'prok project add-repository $repository'.\033[0m"
    fi
}

# Connects the new project to the central system of prok. Each step can be retried by hand; none undoes the setup.
# prok_connected says whether it worked: prok's commit hook refuses commits until it has.
connect_prok() {
    prok_connected=n
    echo -e "\n\033[1m== Connect to prok ==\033[0m"
    if ! prok_login; then
        echo -e "  \033[33mℹ Not logged in to prok. Run 'gcloud auth login', then 'prok login' and 'prok project create'.\033[0m"
        return 0
    fi
    if create_prok_project; then
        prok_connected=y
        name_repository
    else
        echo -e "  \033[33mℹ The project was not created. The message above says why.\033[0m"
    fi
    execute_command "prok emit-agent-instructions" ||
        echo -e "  \033[33mℹ AGENTS.md and CLAUDE.md are written once you have a role in the project.\033[0m"
    install_claude_plugin ||
        echo -e "  \033[33mℹ The Claude Code plugin was not installed. Run 'prok install-agent-plugin --global' and what it prints.\033[0m"
    if command -v codex >/dev/null 2>&1; then
        echo "  Codex runs prok's hooks once you trust them: start Codex in this repository and run /hooks."
    fi
}

# Validate before enabling rollback: rejecting a name must preserve local work.
current_name="package_name"
directory=$(basename "$(pwd)")
name=$(printf '%s' "$directory" | tr '-' '_')
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

# What a rollback returns to: the commit setup started from, and whether the clone had a commit hook of its own.
start_head=$(git rev-parse HEAD)
started_clean=y
[ -z "$(git status --porcelain)" ] || started_clean=n
commit_hook=$(git rev-parse --git-path hooks/pre-commit)
had_commit_hook=n
[ ! -e "$commit_hook" ] || had_commit_hook=y

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
    use_prok="y"
    prok_project="$directory"
    install_prok_now="y"
    claude_plugin="y"
    decision_hub="y"
else
    echo -e "\n\033[33mℹ You will be prompted for each option during the setup.\033[0m"

    run_pixi=""
    install_hooks=""
    create_readme=""
    use_prok=""
    prok_project=""
    install_prok_now=""
    claude_plugin=""
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

# == Project Knowledge (prok) ==

echo -e "\n\033[1m== Project Knowledge (prok) ==\033[0m"
echo "  prok keeps what the project decides and finds out in one graph on PyMC Labs' Google Cloud,"
echo "  shared by the team and their agents in Claude Code, Codex and opencode. Agents get the"
echo "  entries that apply to a file before they edit it, and propose new ones in pull requests."

if [ -z "$use_prok" ]; then
    prompt_yes_no "prok" "Do you want to keep this project's knowledge in prok?" use_prok
fi

if [ "${use_prok}" = "y" ] && ! command -v prok >/dev/null 2>&1; then
    blocker=$(prok_install_blocker)
    if [ -n "$blocker" ]; then
        echo -e "  \033[33mℹ prok is not installed, and cannot be: $blocker\033[0m"
        use_prok="n"
    else
        if [ -z "$install_prok_now" ]; then
            prompt_yes_no "Install prok" "prok is not installed. Do you want to install it with npm?" install_prok_now
        fi
        if [ "$install_prok_now" != "y" ] || ! install_prok || ! command -v prok >/dev/null 2>&1; then
            echo -e "  \033[33mℹ prok is not installed.\033[0m"
            use_prok="n"
        fi
    fi
    if [ "${use_prok}" = "n" ]; then
        echo -e "  \033[33mℹ Continuing without prok. To add it later, install prok and run in this repository:\033[0m"
        echo -e "  \033[36m  prok init --url $prok_url --project $directory && prok login && prok project create\033[0m"
    fi
fi

if [ "${use_prok}" = "y" ] && [ -z "$prok_project" ]; then
    echo -e "\n\033[1;34m? prok Project\033[0m"
    echo "  Name an existing prok project to share its knowledge with another repository."
    while true; do
        if ! read -r -p "  Project name [$directory]: " prok_project; then
            echo -e ""
            exit 1
        fi
        prok_project="${prok_project:-$directory}"
        case $prok_project in
            *[!A-Za-z0-9_.-]*) echo "  Use letters, digits, '.', '_' and '-' only." ;;
            *) break ;;
        esac
    done
fi

# == Decision Hub ==

echo -e "\n\033[1m== Decision Hub ==\033[0m"
if [ -z "$decision_hub" ]; then
    echo "  Decision Hub finds and downloads agent skills. Public skills need no account."
    echo "  Enable its CLI in a separate Pixi environment, with instructions for agents."
    prompt_yes_no "Decision Hub" "Do you want to include Decision Hub (dhub)?" decision_hub
fi

keep_section pyproject.toml decision-hub "$decision_hub"
keep_section AGENTS.md decision-hub "$decision_hub"
keep_section template_README.md decision-hub "$decision_hub"
if [ "${decision_hub}" = "y" ]; then
    echo "  Kept Decision Hub. Use: pixi run -e decision-hub dhub --help"
fi

# The project should not inherit instructions for maintaining the starter.
sed '/^<!-- starter-only:start -->$/,/^<!-- starter-only:end -->$/d' AGENTS.md > AGENTS.md.tmp &&
    mv AGENTS.md.tmp AGENTS.md || exit 1

# The instructions are complete now, so that what prok generates from them is too.
if [ "${use_prok}" = "y" ]; then
    echo -e "\n\033[1m== Set Up prok ==\033[0m"
    if apply_prok; then
        echo -e "  \033[32m✔ Shared agent instructions are in .prok/instructions.md; prok generates AGENTS.md.\033[0m"
    else
        use_prok="n"
        echo -e "  \033[33mℹ prok could not set up the project, so its changes were undone. Continuing without prok.\033[0m"
    fi
fi
if [ "${use_prok}" = "n" ]; then
    keep_section AGENTS.md prok n
    keep_section AGENTS.md no-prok y
    keep_section .pre-commit-config.yaml prok n
    keep_section template_README.md prok n
    rm -f .github/workflows/prok.yml
    echo -e "  \033[33mℹ Shared agent instructions are in AGENTS.md.\033[0m"
fi
instructions=AGENTS.md
[ "${use_prok}" = "y" ] && instructions=.prok/instructions.md

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
    if [ "${use_prok}" = "y" ] && [ -f .pre-commit-config.yaml ]; then
        # pre-commit runs prok's checks itself; -f takes over the hook prok wrote, which would run them a second time.
        echo "  Then run 'pixi r pre-commit install -f'."
    fi
fi

# == Create README ==

echo -e "\n\033[1m== Create README ==\033[0m"

if [ -z "$create_readme" ]; then
    prompt_yes_no "README" "Do you want to create a README.md skeleton?" create_readme
fi

if [ "${create_readme}" = "y" ]; then
    # Under prok, AGENTS.md is generated and not committed; the README links the shared instructions instead.
    sed -e "s|](AGENTS.md|]($instructions|g" -e "s|<project>-team|$(prok_team "$prok_project")|g" template_README.md > README.md
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

# Connect first: it may ask questions and open a browser, while the installation below only takes time.
if [ "${use_prok}" = "y" ]; then
    connect_prok
    # pre-commit runs prok's checks itself; the hook prok wrote would run them a second time.
    if [ "${install_hooks}" = "y" ] && [ "$had_commit_hook" = n ] && is_prok_hook; then
        rm -f "$commit_hook"
    fi
fi

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
echo -e "  \033[36m  git reset --hard $start_head && git clean -fd\033[0m"

# Commits what setup did and pushes it. pre-commit's fixers may change files on the first try; those are taken in once.
commit_and_push_setup() {
    execute_command "git add ." || return 1
    if ! execute_command "git commit -m 'Initial setup with project-starter'"; then
        execute_command "git add ." && execute_command "git commit -m 'Initial setup with project-starter'" || return 1
    fi
    # A clone tracks origin's main; a repository whose origin was added by hand may track nothing yet.
    if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
        execute_command "git pull" || return 1
    fi
    execute_command "git push -u origin main"
}

if [ "${use_prok}" = "y" ] && [ "${prok_connected}" != "y" ]; then
    # prok's commit hook checks the project's graph, which it cannot read before the login and the project exist.
    echo -e "\n\033[33mℹ Not committing: prok refuses commits until you are logged in and have a role in the project.\033[0m"
    echo -e "  Once you have, run: \033[36mgit add . && git commit -m 'Initial setup with project-starter' && git push origin main\033[0m"
    exit 0
fi

# Ask about committing and pushing
prompt_yes_no "Commit and Push" "Do you want to commit and push these changes?" commit_and_push

if [ "${commit_and_push}" = "y" ]; then
    echo -e "\n\033[1m== Committing and Pushing Changes ==\033[0m"
    if ! commit_and_push_setup; then
        echo -e "  \033[31m✘ The changes were not all committed and pushed. The output above says why.\033[0m" >&2
        exit 1
    fi
    echo -e "  \033[32m✔ Changes committed and pushed successfully.\033[0m"
else
    echo -e "\n\033[33mℹ Changes have not been committed or pushed.\033[0m"
fi
