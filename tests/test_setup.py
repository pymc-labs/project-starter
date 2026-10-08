"""Exercise starter initialization in disposable repositories, without network access.

The initializer removes this file from generated projects along with setup.sh.
"""

import os
from pathlib import Path
import shutil
import subprocess

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
    pixi.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$SETUP_TEST_COMMAND_LOG"\n')
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
    assert (project / "sample_project" / "model.py").is_file()
    assert not (project / "package_name").exists()
    assert not (project / "setup.sh").exists()
    assert not (project / "tests" / "test_setup.py").exists()
    assert not (project / "template_README.md").exists()


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


@pytest.mark.parametrize("context", ["y", "n"])
@pytest.mark.parametrize("readme", ["y", "n"])
def test_guided_context_and_readme_choices(starter_copy, context, readme):
    project, env, command_log = starter_copy
    run_setup(project, env, ["n", "n", context, readme, "n"])

    assert_context(project, context == "y")
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


def test_recommended_setup_keeps_context(starter_copy):
    project, env, command_log = starter_copy
    run_setup(project, env, ["", "n"])

    assert_context(project, True)
    assert "[AGENTS.md](AGENTS.md)" in (project / "README.md").read_text()
    assert command_log.read_text().splitlines() == ["install", "r pre-commit install"]


def test_guided_context_defaults_to_yes(starter_copy):
    project, env, _ = starter_copy
    run_setup(project, env, ["n", "n", "", "y", "n"])

    assert_context(project, True)


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
