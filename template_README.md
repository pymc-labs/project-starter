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
<!-- agent-context:start -->

## Persistent agent context

[AGENTS.md](AGENTS.md) is the entry point for agents. It routes tasks to general workflow conventions and explains how to maintain project context as work proceeds.

- `AGENTS/CONVENTION/`: stable requirements and decision rules.
- `AGENTS/REFERENCE/`: descriptions of the current implementation, added as the project develops.
- `AGENTS/*.md`: changelog, quirks, deferred work, and lessons, initially empty apart from instructions and entry formats.
- `.agents/skills/`: space for project-specific agent workflows, initially containing only `.gitkeep`.

Replace the project description in `AGENTS.md` once the scope is established. Agents should update relevant context during their work and keep implementation references separate from durable requirements.
<!-- agent-context:end -->
