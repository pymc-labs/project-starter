"""Exercise starter initialization in disposable repositories, without network access.

The initializer removes this file from generated projects along with setup.sh.
"""

import os
from pathlib import Path
import shutil
import subprocess
import tomllib

import pytest


STARTER = Path(__file__).resolve().parents[1]


@pytest.fixture
def starter_copy(tmp_path):
    project = tmp_path / "sample-project"
    shutil.copytree(
        STARTER,
        project,
        ignore=shutil.ignore_patterns(
            ".git", ".pixi", ".venv", "__pycache__", ".pytest_cache", ".ruff_cache"
        ),
    )
    subprocess.run(["git", "init", "--quiet", str(project)], check=True)
    subprocess.run(["git", "add", "."], cwd=project, check=True)
    subprocess.run(
        [
            "git",
            "-c",
            "user.name=Setup Test",
            "-c",
            "user.email=setup-test@example.invalid",
            "-c",
            "core.hooksPath=/dev/null",
            "-c",
            "commit.gpgsign=false",
            "commit",
            "--quiet",
            "-m",
            "Starter fixture",
        ],
        cwd=project,
        check=True,
    )

    # Record environment setup calls without installing packages or hooks.
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    pixi = bin_dir / "pixi"
    pixi.write_text(
        '#!/bin/sh\nprintf "%s\\n" "$*" >> "$SETUP_TEST_COMMAND_LOG"\n'
        'if [ "$1" = install ] && [ ! -f pixi.lock ]; then\n'
        '    printf "# Fresh project lock\\n" > pixi.lock\n'
        "fi\n"
        'if [ "$*" = "$SETUP_TEST_FAIL_COMMAND" ]; then exit 42; fi\n'
        "exit 0\n"
    )
    pixi.chmod(0o755)
    command_log = tmp_path / "commands.log"
    env = {
        **os.environ,
        "PATH": f"{bin_dir}{os.pathsep}{os.environ['PATH']}",
        "SETUP_TEST_COMMAND_LOG": str(command_log),
    }
    return project, env, command_log


def run_setup(project, env, answers):
    result = subprocess.run(
        ["bash", "setup.sh"],
        cwd=project,
        env=env,
        input="\n".join(answers) + "\n",
        text=True,
        capture_output=True,
        timeout=60,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    package_name = project.name.replace("-", "_")
    assert (project / package_name / "model.py").is_file()
    if package_name != "package_name":
        assert not (project / "package_name").exists()
    assert not (project / "setup.sh").exists()
    assert not (project / "tests" / "test_setup.py").exists()
    assert not (project / "template_README.md").exists()
    return result


def assert_context(project, enabled):
    assert (project / "AGENTS.md").exists() == enabled
    assert (project / "AGENTS").exists() == enabled
    assert (project / ".agents" / "skills" / ".gitkeep").exists() == enabled
    for script_path in (
        "scripts/README.md",
        "scripts/.adhoc/README.md",
        "scripts/.adhoc/reference/.gitkeep",
        "scripts/.adhoc/scratch/.gitkeep",
    ):
        assert (project / script_path).exists() == enabled
    if enabled:
        agent_context = (project / "AGENTS.md").read_text()
        assert "setup.sh" not in agent_context
        assert "starter-only:" not in agent_context
        assert sorted(p.name for p in (project / "AGENTS" / "REFERENCE").iterdir()) == [
            "README.md"
        ]
        assert sorted(p.name for p in (project / ".agents" / "skills").iterdir()) == [
            ".gitkeep"
        ]
        assert (project / "AGENTS" / "CONVENTION" / "GIT_WORKFLOW.md").is_file()


def assert_decision_hub(project: Path, enabled: bool) -> None:
    config = tomllib.loads((project / "pyproject.toml").read_text())["tool"]["pixi"]
    assert ("decision-hub" in config["environments"]) == enabled
    assert ("decision-hub" in config["feature"]) == enabled
    if enabled:
        environment = config["environments"]["decision-hub"]
        assert environment["no-default-feature"] is True
        assert "solve-group" not in environment
        assert "dhub-cli" in config["feature"]["decision-hub"]["pypi-dependencies"]
    for environment in ("default", "test", "minimal"):
        assert "decision-hub" not in config["environments"][environment]["features"]
    doc = project / "AGENTS" / "CONVENTION" / "DECISION_HUB.md"
    assert doc.exists() == enabled
    for name in ("AGENTS.md", "README.md", "pyproject.toml"):
        path = project / name
        if path.exists():
            content = path.read_text()
            assert "decision-hub:" not in content
            if name != "pyproject.toml":
                assert ("AGENTS/CONVENTION/DECISION_HUB.md" in content) == enabled


@pytest.mark.parametrize(
    ("context", "hub"), [("y", "y"), ("y", "n"), ("y", ""), ("n", None)]
)
@pytest.mark.parametrize("readme", ["y", "n"])
def test_guided_context_and_readme_choices(
    starter_copy: tuple[Path, dict[str, str], Path],
    context: str,
    hub: str | None,
    readme: str,
) -> None:
    project, env, command_log = starter_copy
    answers = ["n", "n", context]
    if hub is not None:
        answers.append(hub)
    run_setup(project, env, [*answers, readme, "n"])

    assert_context(project, context == "y")
    assert_decision_hub(project, hub in ("y", ""))
    assert not (project / "pixi.lock").exists()
    assert not command_log.exists()
    readme_path = project / "README.md"
    assert readme_path.exists() == (readme == "y")
    if readme == "y":
        content = readme_path.read_text()
        assert content.startswith("# sample_project\n")
        assert ("[AGENTS.md](AGENTS.md)" in content) == (context == "y")
        assert ("(scripts/README.md)" in content) == (context == "y")
        assert ("(scripts/.adhoc/README.md)" in content) == (context == "y")
        assert "agent-context:" not in content
    if context == "n":
        assert not (project / ".agents").exists()
        assert not (project / "scripts").exists()


def test_recommended_setup_keeps_context_and_decision_hub(
    starter_copy: tuple[Path, dict[str, str], Path],
) -> None:
    project, env, command_log = starter_copy
    run_setup(project, env, ["", "n"])

    assert_context(project, True)
    assert (project / "pixi.lock").read_text() == "# Fresh project lock\n"
    assert_decision_hub(project, True)
    assert "[AGENTS.md](AGENTS.md)" in (project / "README.md").read_text()
    assert command_log.read_text().splitlines() == [
        "install",
        "install -e decision-hub",
        "r pre-commit install",
    ]


def test_guided_context_and_decision_hub_default_to_yes(
    starter_copy: tuple[Path, dict[str, str], Path],
) -> None:
    project, env, _ = starter_copy
    run_setup(project, env, ["n", "n", "", "", "y", "n"])

    assert_context(project, True)
    assert_decision_hub(project, True)


@pytest.mark.parametrize(("context", "hub"), [("y", "y"), ("y", "n"), ("n", None)])
@pytest.mark.parametrize("hooks", ["y", "n"])
def test_environment_installation_choices(
    starter_copy: tuple[Path, dict[str, str], Path],
    context: str,
    hub: str | None,
    hooks: str,
) -> None:
    project, env, command_log = starter_copy
    answers = ["n", "y", context]
    if hub is not None:
        answers.append(hub)
    run_setup(project, env, [*answers, hooks, "y", "n"])

    assert_context(project, context == "y")
    assert_decision_hub(project, hub == "y")
    expected_commands = ["install"]
    if hub == "y":
        expected_commands.append("install -e decision-hub")
    if hooks == "y":
        expected_commands.append("r pre-commit install")
    assert command_log.read_text().splitlines() == expected_commands
    assert (project / "pixi.lock").read_text() == "# Fresh project lock\n"
    config = tomllib.loads((project / "pyproject.toml").read_text())["tool"]["pixi"]
    assert ("pre-commit" in config["dependencies"]) == (hooks == "y")
    assert (project / ".pre-commit-config.yaml").exists() == (hooks == "y")
    assert (project / ".github/workflows/code-style.yaml").exists() == (hooks == "y")


@pytest.mark.parametrize(
    "failed_command", ["install", "install -e decision-hub", "r pre-commit install"]
)
def test_install_failure_preserves_configured_project(
    starter_copy: tuple[Path, dict[str, str], Path], failed_command: str
) -> None:
    project, env, command_log = starter_copy
    env["SETUP_TEST_FAIL_COMMAND"] = failed_command
    notes = project / "notes.txt"
    notes.write_text("Untracked project work.\n")
    with (project / "package_name" / "model.py").open("a") as model:
        model.write("\n# Uncommitted project work.\n")
    result = subprocess.run(
        ["bash", "setup.sh"],
        cwd=project,
        env=env,
        input="n\ny\ny\ny\ny\ny\nn\n",
        text=True,
        capture_output=True,
        timeout=60,
    )

    assert result.returncode == 1
    assert "Environment setup failed" in result.stderr
    assert "Setup Complete" not in result.stdout
    assert "Reverting changes" not in result.stdout
    assert_context(project, True)
    assert_decision_hub(project, True)
    assert notes.read_text() == "Untracked project work.\n"
    assert (
        "# Uncommitted project work."
        in (project / "sample_project" / "model.py").read_text()
    )
    assert not (project / "setup.sh").exists()
    assert command_log.read_text().splitlines()[-1] == failed_command
    assert "pixi install -e decision-hub" in result.stderr


def test_initialization_preserves_added_context(starter_copy):
    project, env, _ = starter_copy
    agent_path = project / "AGENTS.md"
    project_context = (
        "\n## Project-specific instructions\n\nKeep observation units explicit.\n"
    )
    agent_path.write_text(agent_path.read_text() + project_context)
    run_setup(project, env, ["", "n"])

    assert_context(project, True)
    assert project_context in agent_path.read_text()


def test_opt_out_preserves_added_skills(starter_copy):
    project, env, _ = starter_copy
    skill = project / ".agents" / "skills" / "custom" / "SKILL.md"
    skill.parent.mkdir()
    skill.write_text("A project-specific workflow.\n")
    run_setup(project, env, ["n", "n", "n", "y", "n"])

    assert_context(project, False)
    assert skill.read_text() == "A project-specific workflow.\n"


def test_opt_out_preserves_added_scripts(starter_copy):
    project, env, _ = starter_copy
    added_paths = [
        project / "scripts" / "custom.py",
        project / "scripts" / ".adhoc" / "reference" / "custom.py",
        project / "scripts" / ".adhoc" / "scratch" / "session" / "result.txt",
    ]
    for path in added_paths:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("# User-created content.\n")
    run_setup(project, env, ["n", "n", "n", "y", "n"])

    assert_context(project, False)
    for path in added_paths:
        assert path.read_text() == "# User-created content.\n"


@pytest.mark.parametrize("project_name", ["scripts", "Scripts", "AGENTS", "agents"])
@pytest.mark.parametrize(
    "answers",
    [["", "n"], ["n", "n", "y", "y", "y", "n"], ["n", "n", "n", "y", "n"]],
    ids=["recommended", "keep-context", "opt-out"],
)
def test_setup_rejects_collisions_without_changes(
    starter_copy: tuple[Path, dict[str, str], Path],
    project_name: str,
    answers: list[str],
) -> None:
    project, env, command_log = starter_copy
    project = project.rename(project.with_name(project_name))
    with (project / "package_name" / "model.py").open("a") as model:
        model.write("\n# Uncommitted project work.\n")
    (project / "notes.txt").write_text("Untracked project work.\n")
    (project / ".pixi").mkdir()
    (project / ".pixi" / "environment.txt").write_text("Existing environment.\n")

    def snapshot_files() -> dict[Path, bytes]:
        return {
            path.relative_to(project): path.read_bytes()
            for path in project.rglob("*")
            if ".git" not in path.relative_to(project).parts and path.is_file()
        }

    before = snapshot_files()
    status_before = subprocess.check_output(
        ["git", "status", "--porcelain"], cwd=project
    )
    result = subprocess.run(
        ["bash", "setup.sh"],
        cwd=project,
        env=env,
        input="\n".join(answers) + "\n",
        text=True,
        capture_output=True,
        timeout=60,
    )

    assert result.returncode != 0, result.stdout + result.stderr
    assert "conflicts with" in result.stderr
    assert "Rename the project directory" in result.stderr
    assert snapshot_files() == before
    assert (
        subprocess.check_output(["git", "status", "--porcelain"], cwd=project)
        == status_before
    )
    assert not command_log.exists()

    project = project.rename(project.with_name("sample-project"))
    run_setup(project, env, answers)
    assert (
        "# Uncommitted project work."
        in (project / "sample_project" / "model.py").read_text()
    )


def test_setup_keeps_original_package_name(
    starter_copy: tuple[Path, dict[str, str], Path],
) -> None:
    project, env, _ = starter_copy
    project = project.rename(project.with_name("package_name"))

    result = run_setup(project, env, ["", "n"])

    assert result.stderr == ""
    assert_context(project, True)
