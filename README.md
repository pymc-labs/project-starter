# 🚀 PyMC Labs Project Starter

All project code goes off the rails to some extent.
It happens in tiny increments with awkward commits that "solves the problem".
This is entirely forgivable when a codebase is not designed for the new problem and there are time constraints.
It is inevitable.

However, this chaos can be mitigated with some decent guardrails. This **project template** provides the following:

- 📦 **`pixi`** for dependency and environment management.
- 🧹 **`pre-commit`** for formatting, spellcheck, etc. If everyone uses the same standard formatting, then PRs won't have flaky formatting updates that distract from the actual contribution. Reviewing code will be much easier.
- 🏷️ **`beartype`** for runtime type checking. If you know what's going in and out of functions just by reading the code, then it's easier to debug. And if these types are even enforced at runtime with tools like `beartype`, then there's a whole class of bugs that can never enter your code.
- 🧪 **`pytest`** for testing. Meanwhile, with `beartype` handling type checks, tests do not have to assert types, and can merely focus on whether the actual logic works.
- 🔄 **Github Actions** for running the pre-commit checks on each PR, automated testing and dependency management (dependabot).
- 🧠 **Persistent agent context** for shared workflow rules and continuity between agent sessions, included by default and optional during guided setup.
- 🧰 **[Decision Hub](https://hub.decision.ai/)** for finding agent skills, included by default with persistent agent context and optional during guided setup.

## Usage

This is a pretty minimal template,
that assumes you have opinions and may want to add/remove stuff too.
To use it as intended (not that you have to),
you should put your main model logic in the `package_name/model.py` file,
adjacent logic split into sibling files,
and then have a script that imports from `package_name` and runs the model,
e.g. in a `scripts/run_model.py` file,
or a notebook in `notebooks/`.

Enabling persistent agent context also keeps the [scripts scaffold](scripts/README.md): a home for maintained commands, with [ad hoc directories](scripts/.adhoc/README.md) for tracked reference analyses and ignored scratch work.

### Prerequisites

- Python 3.11 or higher
- [Pixi package manager](https://pixi.sh/latest/)

### Get started

1. On GitHub, click on the green **Use this template** button, and create a new repository.
2. Git clone the new repository to your local machine.
3. Run the setup script `bash setup.sh` and follow the instructions.

Setup derives the Python package name from the local project directory, replacing hyphens with underscores. If that name conflicts with an existing top-level path (ignoring letter case), such as `scripts` or `AGENTS`, setup stops before changing files. Rename the local project directory and rerun setup. Keeping the original `package_name` is also supported.

<video src="https://github.com/user-attachments/assets/4a1ab682-bdc6-4ac9-90ad-013157c1128d" controls></video>

### Dependency versions

The starter commits `pixi.lock` so its own checks use reproducible dependencies. A requirement such as `pymc = "*"` allows any compatible version, but installation reuses the version in the lockfile.

Setup removes the inherited lockfile and resolves current compatible versions for the new project. If you skip installation, run `pixi install` before committing. If installation fails, setup keeps the configured project and prints the commands to retry. Commit the newly generated `pixi.lock` with `pyproject.toml` so collaborators and CI use the same versions. After initialization, update dependencies deliberately with Pixi; do not routinely delete the lockfile. See [Pixi's lockfile documentation](https://pixi.prefix.dev/latest/workspace/lock_file/).

### Persistent agent context

The starter includes a small, agent-maintained context structure. The recommended setup keeps it; choose guided setup to opt out. Opting out removes the context and scripts scaffolds and their entries in the generated README, preserving any skills or scripts you have added.

```text
AGENTS.md                  Agent entry point and task guidance
AGENTS/
  CONVENTION/              Durable workflow and data science rules
  REFERENCE/               Current implementation descriptions (purpose note only)
  CHANGELOG.md             Useful changes and validation
  QUIRKS.md                Current debugging traps
  DEFERRED.md              Concrete unfinished work
  AGENT_MISTAKES.md         Lessons and verified fixes
.agents/skills/.gitkeep     Empty home for future project skills
scripts/                   Maintained workflows (guide only initially)
  .adhoc/reference/        Preserved analyses (.gitkeep only initially)
  .adhoc/scratch/          Ignored experiments (.gitkeep tracked)
```

[AGENTS.md](AGENTS.md) tells agents which context to read and when to update it. Conventions cover the environment, code, scripts and experiments, data integrity, modeling, testing, and Git workflow. References describe what the code currently does; they do not turn bugs into requirements.

The session files contain instructions and entry formats, with no inherited project history. After initialization, replace the project description in `AGENTS.md` and let the context grow from actual work. Keep new conventions broadly useful, add implementation references only when needed, and keep resolved quirks and deferred tasks up to date. No skills are bundled.

### Optional Decision Hub

Decision Hub is included by default whenever persistent agent context is enabled, including in recommended setup. Guided setup lets you decline Decision Hub while keeping agent context. When enabled, `dhub-cli` runs in a separate `decision-hub` Pixi environment, with [agent instructions](AGENTS/CONVENTION/DECISION_HUB.md) linked from `AGENTS.md`. Declining Decision Hub or agent context removes its configuration and instructions from the generated project.

```sh
pixi run -e decision-hub dhub ask "Bayesian modeling with PyMC"
```

Public skill discovery and downloads need no account or API key. Setup installs only the CLI; agents can then select skills that fit the task and installed library versions. No skills are downloaded and no user-wide agent settings are changed during setup. If you defer environment installation, `pixi run -e decision-hub ...` installs the CLI on first use.

### Philosophy

There are some example files in this repository.
Have a look at them.
Each of the files in `package_name` has a docstring that explains their role in your package.
You may not want to follow this dogma entirely,
but having split out the code for custom types, main model logic, preprocessing, string parsing, etc.
into separate files is always a good idea.
Mostly, however, you can use these as an example to build upon.

And please contribute. If you add some guardrails that you think would be generally useful, please make a PR.
