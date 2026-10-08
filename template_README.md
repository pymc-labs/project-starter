# package_name

*Description of the project/package. Make it super easy for people to understand what it does. Add links to external resources like Notion, SOWs, etc.if needed.*

## Features

*Bullet form list of the most important features of the project/package.*

## Usage

*How to use `package_name`. Include examples and code snippets.*

## Project Structure

- `package_name/`: Contains the package logic
- `tests/`: Contains tests for the package
- `notebooks/`: Contains exploratory code for testing new features
<!-- agent-context:start -->
- [`scripts/`](scripts/README.md): Maintained workflow entry points
- [`scripts/.adhoc/`](scripts/.adhoc/README.md): Preserved reference analyses and ignored scratch work
<!-- agent-context:end -->

## Development

This package has been created with [pymc-labs/project-starter](https://github.com/pymc-labs/project-starter). It features:

- 📦 **`pixi`** for dependency and environment management.
- 🧹 **`pre-commit`** for formatting, spellcheck, etc. If everyone uses the same standard formatting, then PRs won't have flaky formatting updates that distract from the actual contribution. Reviewing code will be much easier.
- 🏷️ **`beartype`** for runtime type checking. If you know what's going in and out of functions just by reading the code, then it's easier to debug. And if these types are even enforced at runtime with tools like `beartype`, then there's a whole class of bugs that can never enter your code.
- 🧪 **`pytest`** for testing. Meanwhile, with `beartype` handling type checks, tests do not have to assert types, and can merely focus on whether the actual logic works.
- 🔄 **Github Actions** for running the pre-commit checks on each PR, automated testing and dependency management (dependabot).

### Prerequisites

- Python 3.11 or higher
- [Pixi package manager](https://pixi.sh/latest/)

### Get started

1. Run `pixi install` to install the dependencies.
2. Run `pixi r test` to run the tests.
3. Run `pre-commit install` to set up pre-commit hooks.

Commit `pyproject.toml` and the generated `pixi.lock` together. The lockfile records the exact dependency versions shared by collaborators and CI; use Pixi to update them deliberately.
<!-- agent-context:start -->

## Persistent agent context

[AGENTS.md](AGENTS.md) is the entry point for agents. It routes tasks to general workflow conventions and explains how to maintain project context as work proceeds.

- `AGENTS/CONVENTION/`: stable requirements and decision rules.
- `AGENTS/REFERENCE/`: descriptions of the current implementation, added as the project develops.
- `AGENTS/*.md`: changelog, quirks, deferred work, and lessons, initially empty apart from instructions and entry formats.
- `.agents/skills/`: space for project-specific agent workflows, initially containing only `.gitkeep`.

Replace the project description in `AGENTS.md` once the scope is established. Agents should update relevant context during their work and keep implementation references separate from durable requirements.
<!-- decision-hub:start -->

### Decision Hub

The optional `decision-hub` Pixi environment provides the `dhub` CLI for finding and downloading agent skills. Public skills need no account or API key. Run `pixi run -e decision-hub dhub --help` to get started; Pixi installs the environment on first use if needed.

See [Decision Hub guidance](AGENTS/CONVENTION/DECISION_HUB.md) for discovery, version compatibility, and sharing selected skills in this project. Setup does not install any skills or change user-wide agent settings.
<!-- decision-hub:end -->
<!-- agent-context:end -->
