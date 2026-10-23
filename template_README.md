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
- `scripts/`: Scripts you run regularly; one-off analyses go in `scripts/.adhoc/`, which Git ignores

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
<!-- prok:start -->
- [prok](https://github.com/pymc-labs/prok), for the project's knowledge: Node 24 or later, then `gh release download -R pymc-labs/prok -p prok.tgz -D /tmp --clobber && npm install -g /tmp/prok.tgz`. It logs in with your PyMC Labs Google account through [gcloud](https://cloud.google.com/sdk/docs/install).
<!-- prok:end -->

### Get started

1. Run `pixi install` to install the dependencies.
2. Run `pixi r test` to run the tests.
3. Run `pixi r pre-commit install` to set up pre-commit hooks.
<!-- prok:start -->
4. Run `prok init` and `prok login`, then ask a maintainer of the project to add you: `prok group add <project>-team <your mail>`. `prok whoami` says what you may do.
<!-- prok:end -->

Commit `pixi.lock` along with `pyproject.toml`, so everyone working on the project gets the same versions. Use Pixi to update dependencies and commit the lockfile changes too.

## Working with agents

[The shared agent instructions](AGENTS.md) are the same for every agent on the project, whoever runs it and in whichever harness. It asks agents for some things you probably want without asking every time:

- [Test their own work](AGENTS.md#how-we-work). Try the thing you'll actually use, fix whatever breaks, and try again.
- [Explain their PRs](AGENTS.md#how-we-work). What changed, why, what was tested, and any decisions or mistakes you should know about, with screenshots when the UI changes. Include the agent harness and session ID too, so you can trace where the work came from.
- [Use the project's environment](AGENTS.md#how-we-work). Run Python through Pixi so tests and analyses use the project's dependencies.
- [Check what happened to the data](AGENTS.md#how-we-work). Check that joins haven't duplicated rows, missing values haven't silently become zeroes, and test data hasn't slipped into training.
- [Start with a small model run](AGENTS.md#how-we-work). Check the data and settings before spending time on a long fit. A model can run successfully and still be a bad model.
- [Put throwaway scripts in a throwaway place](AGENTS.md#how-we-work). One-off analyses go in `scripts/.adhoc/`, so they don't mix with the scripts you keep.
- [Talk to you in a consistent way](AGENTS.md#writing-for-humans). What was done, what needs attention, what's next, with links, and whether the work is committed, pushed or merged.
<!-- prok:start -->

### Project knowledge in prok

What the project decides and finds out lives in [prok](https://github.com/pymc-labs/prok), one graph for the whole team on PyMC Labs' Google Cloud. Each entry is a decision, a fact, a convention, a constraint, an assumption or an open question, with its reason and the files it applies to. Agents get the entries for a file before they edit it, whichever harness they run in, and write new ones as they work.

Entries are proposed on a branch and hold once its pull request is merged and a maintainer canonizes the branch's world: `prok canonize <world>`, after reading its review. `prok worlds` lists them. To look around:

```sh
prok find "how do we treat missing sales"   # search by meaning
prok list-entries --type question           # what is still open
prok kernel show                            # what every agent session starts with
```

`AGENTS.md`, `CLAUDE.md` and `PROJECT_KNOWLEDGE.md` are generated from the shared instructions in `.prok/instructions.md` and the project's kernel, and are not committed. Edit `.prok/instructions.md` to change what every agent is told.
<!-- prok:end -->
<!-- decision-hub:start -->

### Decision Hub

You can use [Decision Hub](https://hub.decision.ai/) to find skills for things like PyMC modeling. Public skills need no account or API key. Run `pixi run -e decision-hub dhub --help` to get started. Pixi installs the tool on first use if you skipped installation during setup.

Setup installs the tool. You or your agent choose which skills to add later; [the agent instructions](AGENTS.md#skills-from-decision-hub) say how to check that they fit your library versions and share them with the project.
<!-- decision-hub:end -->
