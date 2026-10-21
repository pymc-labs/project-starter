# package_name

*TEMPLATE: Description of the project/package. Make it super easy for people to understand what it does. Add links to external resources like Notion, SOWs, etc. if needed.*

## Features

*TEMPLATE: Bullet form list of the most important features of the project/package.*

## Usage

*TEMPLATE: How to use `package_name`. Include examples and code snippets.*

## Project Structure

- `package_name/`: Contains the package logic
- `tests/`: Contains tests for the package
- `notebooks/`: Contains exploratory code for testing new features
<!-- agent-context:start -->
- [`scripts/`](scripts/README.md): Scripts you run regularly
- [`scripts/.adhoc/`](scripts/.adhoc/README.md): One-off analyses and experiments
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

Commit `pixi.lock` along with `pyproject.toml`, so everyone working on the project gets the same versions. Use Pixi to update dependencies and commit the lockfile changes too.
<!-- agent-context:start -->

## Persistent agent context

[AGENTS.md](AGENTS.md) tells agents where to look for instructions and notes from earlier sessions. It also asks them to keep those notes up to date, so you don't have to explain the same things every time.

- `AGENTS/CONVENTION/`: how we want to work.
- `AGENTS/REFERENCE/`: how this project works.
- `AGENTS/*.md`: what changed, what's unfinished, and things worth remembering.
- `.agents/skills/`: skills you choose to add to the project.

The first agent session in the project fills in the placeholders, like the project description here and in `AGENTS.md`, and asks you about anything it can't work out. The notes and directories start out empty apart from instructions, and agents add to them as the project develops. No skills are bundled.

### What agents are asked to do

There are instructions for some things you probably want agents to do without having to ask every time:

- [Test their own work](AGENTS/CONVENTION/GIT_WORKFLOW.md#build-test-fix-learn). Try the thing you'll actually use, fix whatever breaks, and try again. Mistakes worth remembering get written down for the next session.
- [Put screenshots in PRs](AGENTS/CONVENTION/GIT_WORKFLOW.md#pull-requests). If the UI changes, include before and after pictures so you can see what you're reviewing.
- [Explain their PRs](AGENTS/CONVENTION/GIT_WORKFLOW.md#pull-requests). What changed, why, what was tested, and any decisions or mistakes you should know about. Include the agent harness and session ID too, so you can trace where the work came from.
- [Leave notes for the next session](AGENTS.md#maintaining-context). Keep track of what changed, what's unfinished, and anything surprising. Update old notes once they no longer apply.
- [Use the project's environment](AGENTS/CONVENTION/ENVIRONMENT.md). Run Python through Pixi so tests and analyses use the project's dependencies.
- [Check what happened to the data](AGENTS/CONVENTION/DATA_PROCESSING.md). Check that joins haven't duplicated rows, missing values haven't silently become zeroes, and test data hasn't slipped into training.
- [Start with a small model run](AGENTS/CONVENTION/MODELING.md). Check the data and settings before spending time on a long fit. Then look at diagnostics and predictive checks. A model can run successfully and still be a bad model.
- [Put throwaway scripts in a throwaway place](AGENTS/CONVENTION/COMMON_PATTERNS.md#script-placement). One-off analyses performed by agents go in `scripts/.adhoc/`, so it doesn't mix with for example reusable pipeline scripts.
- [Talk to you in a consistent way](AGENTS.md#writing-for-humans). Structure the end message not as the default wall of text, but following a standardized template you can understand immediately: what was done, what needs attention, what are next steps, include links and say whether the work is committed, pushed or merged (plus a timestamp).
<!-- decision-hub:start -->

### Decision Hub

You can use [Decision Hub](https://hub.decision.ai/) to find skills for things like PyMC modeling. Public skills need no account or API key. Run `pixi run -e decision-hub dhub --help` to get started. Pixi installs the tool on first use if you skipped installation during setup.

Setup installs the tool. You or your agent choose which skills to add later. The [agent instructions](AGENTS/CONVENTION/DECISION_HUB.md) cover how to find skills, check that they fit your library versions, and share them with the project.
<!-- decision-hub:end -->
<!-- agent-context:end -->
