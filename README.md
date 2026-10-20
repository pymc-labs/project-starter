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
- 🧠 **Persistent agent context** so agents can look up how you work and leave notes for the next session. You shouldn't have to explain the same things every time.
- 🧰 **[Decision Hub](https://hub.decision.ai/)** for finding skills that help agents with things like PyMC modeling. Add the ones that are useful for your project.

## Usage

This is a pretty minimal template,
that assumes you have opinions and may want to add/remove stuff too.
To use it as intended (not that you have to),
you should put your main model logic in the `package_name/model.py` file,
adjacent logic split into sibling files,
and then have a script that imports from `package_name` and runs the model,
e.g. in a `scripts/run_model.py` file,
or a notebook in `notebooks/`.

If you keep the agent context, you also get a [scripts directory](scripts/README.md) with [a place for one-off analyses and experiments](scripts/.adhoc/README.md). Those tend to accumulate, so it's nice to give them somewhere to go.

### Prerequisites

- Python 3.11 or higher
- [Pixi package manager](https://pixi.sh/latest/)

### Get started

1. On GitHub, click on the green **Use this template** button, and create a new repository.
2. Git clone the new repository to your local machine.
3. Run the setup script `bash setup.sh` and follow the instructions.

Your project directory gives the Python package its name: `my-project` becomes `my_project`. Avoid names already used at the top level, such as `scripts` or `AGENTS` (capitalization doesn't help). If there's a clash, setup asks you to rename the directory and try again, without changing any files. Leaving it as `package_name` works too.

<video src="https://github.com/user-attachments/assets/4a1ab682-bdc6-4ac9-90ad-013157c1128d" controls></video>

### Dependency versions

We keep a `pixi.lock` in this template so its tests run with the same dependencies each time. That also means `pymc = "*"` still installs the version in the lockfile.

Your new project should get its own lockfile. Setup removes the template's copy and lets Pixi find current versions that work together. If you skip installation, run `pixi install` before you commit. If installation fails, your files are kept and setup tells you how to retry.

Commit the new `pixi.lock` along with `pyproject.toml`, so everyone working on the project gets the same versions. After that, use Pixi to update dependencies and commit the lockfile changes too. [Pixi's docs](https://pixi.prefix.dev/latest/workspace/lock_file/) explain how this works.

### Persistent agent context

A new agent session shouldn't mean explaining the whole project again. The template comes with an [AGENTS.md](AGENTS.md) and a few files where agents can look up how you work, what has changed, and what still needs doing.

This is included by default. If you don't want it, choose guided setup and say no to agent context. Setup removes the context files and scripts guides, along with their README sections. Any scripts or skills you've already added stay.

```text
AGENTS.md                  Where agents start
AGENTS/
  CONVENTION/              How we want to work
  REFERENCE/               How this project works
  CHANGELOG.md             What changed and why
  QUIRKS.md                Things that can trip you up
  DEFERRED.md              Work to come back to
  AGENT_MISTAKES.md         Mistakes worth learning from
.agents/skills/            Skills you choose to add
scripts/                   Scripts you run regularly
  .adhoc/reference/        One-off analyses worth keeping
  .adhoc/scratch/          Experiments you don't need in Git
```

[AGENTS.md](AGENTS.md) points agents to the files they need for the task and asks them to keep those files up to date. The conventions say how we want to work; references explain how the project currently works.

After setup, replace the project description in `AGENTS.md`. The notes and directories start with instructions and placeholders, and agents add to them as the project develops. No skills are bundled.

#### What agents are asked to do

There are instructions for some things you probably want agents to do without having to ask every time:

- [Test their own work](AGENTS/CONVENTION/GIT_WORKFLOW.md#build-test-fix-learn). Try the thing you'll actually use, fix whatever breaks, and try again. Mistakes worth remembering get written down for the next session.
- [Put screenshots in PRs](AGENTS/CONVENTION/GIT_WORKFLOW.md#pull-requests). If the UI changes, include before and after pictures so you can see what you're reviewing.
- [Explain their PRs](AGENTS/CONVENTION/GIT_WORKFLOW.md#pull-requests). What changed, why, what was tested, and any decisions or mistakes you should know about. Include the agent harness and session ID too, so you can trace where the work came from.
- [Leave notes for the next session](AGENTS.md#maintaining-context). Keep track of what changed, what's unfinished, and anything surprising. Update old notes once they no longer apply.
- [Use the project's environment](AGENTS/CONVENTION/ENVIRONMENT.md). Run Python through Pixi so tests and analyses use the project's dependencies.
- [Check what happened to the data](AGENTS/CONVENTION/DATA_PROCESSING.md). Check that joins haven't duplicated rows, missing values haven't silently become zeroes, and test data hasn't slipped into training.
- [Start with a small model run](AGENTS/CONVENTION/MODELING.md). Check the data and settings before spending time on a long fit. Then look at diagnostics and predictive checks. A model can run successfully and still be a bad model.
- [Give experiments somewhere to go](AGENTS/CONVENTION/COMMON_PATTERNS.md#script-placement). One-off analyses go in `scripts/.adhoc/`, with separate places for scratch work and things worth keeping. Code you plan to reuse belongs in the package or maintained scripts.
- [Tell you how it went](AGENTS.md#writing-for-humans). Say what was done, what was checked, and what still needs your attention. Include links and say whether the work is committed, pushed or merged.

### Optional Decision Hub

Sometimes an agent needs more specific instructions, e.g. for building a PyMC model or working with PyMC-Marketing. [Decision Hub](https://hub.decision.ai/) is a place to find those skills. You can search and download public skills without an account or API key.

It's included by default with agent context. Guided setup lets you turn it off while keeping the rest. Turning off agent context removes Decision Hub too.

The command-line tool, `dhub`, runs in its own Pixi environment:

```sh
pixi run -e decision-hub dhub ask "Bayesian modeling with PyMC"
```

Setup installs the tool. You or your agent choose which skills to add later. The [agent instructions](AGENTS/CONVENTION/DECISION_HUB.md) cover how to find skills, check that they fit your library versions, and share them with the project. If you skipped installation during setup, Pixi installs the tool the first time you use the command above.

### Philosophy

There are some example files in this repository.
Have a look at them.
Each of the files in `package_name` has a docstring that explains their role in your package.
You may not want to follow this dogma entirely,
but having split out the code for custom types, main model logic, preprocessing, string parsing, etc.
into separate files is always a good idea.
Mostly, however, you can use these as an example to build upon.

And please contribute. If you add some guardrails that you think would be generally useful, please make a PR.
