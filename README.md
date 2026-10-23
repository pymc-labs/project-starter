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
- 🧠 **Project knowledge in [prok](https://github.com/pymc-labs/prok)**. What the project decides and finds out lives in one graph on PyMC Labs' Google Cloud, shared by everyone on the project and all their agents, whichever harness they use. You shouldn't have to explain the same things every time.
- 🤝 **One set of agent instructions** for the whole team, so agents test their own work, explain their PRs and check what happened to the data, whoever runs them.
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

One-off analyses and experiments go in `scripts/.adhoc/`, which Git ignores. Those tend to accumulate, so it's nice to give them somewhere to go.

### Prerequisites

- Python 3.11 or higher
- [Pixi package manager](https://pixi.sh/latest/)
- For prok: Node 24 or later (`brew install node`), the [GitHub CLI](https://cli.github.com/) logged in with your PyMC Labs GitHub account, and [gcloud](https://cloud.google.com/sdk/docs/install) for logging in with your PyMC Labs Google account. Setup installs prok itself if it's missing.

### Get started

1. On GitHub, click on the green **Use this template** button, and create a new repository.
2. Git clone the new repository to your local machine.
3. Run the setup script `bash setup.sh` and follow the instructions.

Your project directory gives the Python package its name: `my-project` becomes `my_project`. Avoid names already used at the top level, such as `tests` or `notebooks` (capitalization doesn't help). If there's a clash, setup asks you to rename the directory and try again, without changing any files. Leaving it as `package_name` works too.

<video src="https://github.com/user-attachments/assets/4a1ab682-bdc6-4ac9-90ad-013157c1128d" controls></video>

### Dependency versions

We keep a `pixi.lock` in this template so its tests run with the same dependencies each time. That also means `pymc = "*"` still installs the version in the lockfile.

Your new project should get its own lockfile. Setup removes the template's copy and lets Pixi find current versions that work together. If you skip installation, run `pixi install` before you commit. If installation fails, your files are kept and setup tells you how to retry.

Commit the new `pixi.lock` along with `pyproject.toml`, so everyone working on the project gets the same versions. After that, use Pixi to update dependencies and commit the lockfile changes too. [Pixi's docs](https://pixi.prefix.dev/latest/workspace/lock_file/) explain how this works.

### Project knowledge with prok

A project decides things all the time: in PRs, in meetings, in chat, in the head of whoever was there. [prok](https://github.com/pymc-labs/prok) writes them down as entries in one graph per project: decisions, facts, conventions, constraints, assumptions and open questions, each with its reason and the files it's about. The graph lives on PyMC Labs' Google Cloud, so everyone on the project sees the same thing, and so do their agents in Claude Code, Codex or opencode.

Setup asks whether you want it (yes by default) and then does the rest:

1. Installs prok if it's missing.
2. Runs `prok init`, which adds the plugins for each agent harness, the commit hook, and the pointer to the project in prok's central system.
3. Logs you in with your PyMC Labs Google account and creates the project in prok, with you as its maintainer. If the project exists already, setup says whom to ask.
4. Installs the prok plugin for Claude Code on your machine.

From then on agents start every session with the project's kernel, the entries everyone needs to know. Before they edit a file, they're handed the entries that apply to it. When they decide or find something others need to know, they write an entry on their branch. The `prok` workflow checks those entries on the PR and puts prok's review on it, and once the PR is merged it makes them hold for everyone. It needs no secrets: setup tells prok that the repository belongs to the project. Nothing is ever lost: an entry that no longer holds gets superseded or retired, and `prok impact <id>` shows what depends on it.

Your teammates run `prok init` and `prok login` in their clone, and you add them with `prok group add <project>-team <their mail>`.

You can share one prok project between several repositories, say a model repo and a dashboard repo: choose guided setup and give the name of the existing project.

This replaces the `AGENTS/` folder of changelogs, quirks, deferred tasks and conventions that the template had before. Each of those is an entry type now: a quirk or an agent's mistake is a fact, a deferred task is a question, a convention is a convention. The difference is that entries are searchable by meaning, they know what depends on them, and they reach agents when they're about to touch the files they're about, instead of hoping the agent reads the right file.

If you say no to prok, you get the same agent instructions in a plain `AGENTS.md`.

### Agent instructions

[AGENTS.md](AGENTS.md) holds the instructions all agents on the project share. With prok, they live in `.prok/instructions.md`, and prok generates `AGENTS.md` and `CLAUDE.md` from them along with the project's kernel.

You don't have to fill in the placeholders yourself. Lines like the project description in `README.md`, the agent instructions and `pyproject.toml` are marked `TEMPLATE:`, and the instructions tell the first agent you start in the new project to find them, work out what the project is about, and replace them with what's actually true. It'll ask you about whatever it can't figure out. With prok, it also writes what it learned as the project's first entries. The example code isn't marked, so replace that as you build the real thing.

#### What agents are asked to do

There are instructions for some things you probably want agents to do without having to ask every time:

- [Test their own work](AGENTS.md#how-we-work). Try the thing you'll actually use, fix whatever breaks, and try again.
- [Put screenshots in PRs](AGENTS.md#how-we-work). If the UI changes, include before and after pictures so you can see what you're reviewing.
- [Explain their PRs](AGENTS.md#how-we-work). What changed, why, what was tested, and any decisions or mistakes you should know about. Include the agent harness and session ID too, so you can trace where the work came from.
- [Write down what the next session needs](AGENTS.md#project-knowledge). With prok, as entries; without it, in PRs, issues and the instructions themselves.
- [Use the project's environment](AGENTS.md#how-we-work). Run Python through Pixi so tests and analyses use the project's dependencies.
- [Check what happened to the data](AGENTS.md#how-we-work). Check that joins haven't duplicated rows, missing values haven't silently become zeroes, and test data hasn't slipped into training.
- [Start with a small model run](AGENTS.md#how-we-work). Check the data and settings before spending time on a long fit. Then look at diagnostics and predictive checks. A model can run successfully and still be a bad model.
- [Put throwaway scripts in a throwaway place](AGENTS.md#how-we-work). One-off analyses performed by agents go in `scripts/.adhoc/`, so they don't mix with for example reusable pipeline scripts.
- [Talk to you in a consistent way](AGENTS.md#writing-for-humans). Structure the end message not as the default wall of text, but following a standardized template you can understand immediately: what was done, what needs attention, what are next steps, include links and say whether the work is committed, pushed or merged (plus a timestamp).

### Optional Decision Hub

Sometimes an agent needs more specific instructions, e.g. for building a PyMC model or working with PyMC-Marketing. [Decision Hub](https://hub.decision.ai/) is a place to find those skills. You can search and download public skills without an account or API key.

It's included by default. Guided setup lets you turn it off.

The command-line tool, `dhub`, runs in its own Pixi environment:

```sh
pixi run -e decision-hub dhub ask "Bayesian modeling with PyMC"
```

Setup installs the tool. You or your agent choose which skills to add later. The [agent instructions](AGENTS.md#skills-from-decision-hub) cover how to find skills, check that they fit your library versions, and share them with the project. If you skipped installation during setup, Pixi installs the tool the first time you use the command above.

### Philosophy

There are some example files in this repository.
Have a look at them.
Each of the files in `package_name` has a docstring that explains their role in your package.
You may not want to follow this dogma entirely,
but having split out the code for custom types, main model logic, preprocessing, string parsing, etc.
into separate files is always a good idea.
Mostly, however, you can use these as an example to build upon.

And please contribute. If you add some guardrails that you think would be generally useful, please make a PR.
