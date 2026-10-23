<!-- starter-only:start -->

While `setup.sh` is present, this repository is the starter itself, not a project created from it. Leave every line marked `TEMPLATE:` as it is, including the first-session instruction below: they are placeholders for the first agent session in each new project. The `prok` and `no-prok` sections below are alternatives: setup keeps the one that fits the project, so change both when you change how projects record what they know. Setup removes this note.

<!-- starter-only:end -->
TEMPLATE: **First session.** No agent has worked in this project yet. Before the requested task, find out what the project is about and replace the template placeholders with true information. List them with `git grep -n --untracked 'TEMPLATE:'`; each matching line is a placeholder. Learn about the project from the repository, its Git history and remotes, linked documents, and the human; the example package, tests, and notebook come from the starter and say nothing about the project. Ask the human about anything you cannot establish, and never invent project facts. Replace each marked line with what is true, or delete it when nothing is true yet. Delete this paragraph last, when the command above finds nothing else. If the human asks you to skip this, do the requested task and leave the markers for the next session.

# About this project

TEMPLATE: Describe the project's purpose and scope: who it is for, the questions it answers, its data, and its deliverables.

# How we work

1. Inspect the working tree and the relevant context. Preserve existing changes and the human's chosen scope.
2. Implement the requested change, then exercise the behavior the human will use, following the rules below.
3. Record what the next session needs to know during the same task, then report following [Writing for humans](#writing-for-humans).

- **Environment.** Run Python through Pixi from the repository root (`pixi run python ...`, `pixi run test`). `pyproject.toml` and `pixi.lock` are the source of truth: change them deliberately, and together.
- **Code.** Reusable logic lives in the package, maintained entry points in `scripts/`, exploration in `notebooks/`. Type-hint function signatures; docstrings say units, shapes, and side effects. Reuse existing transformations and model builders instead of copying them.
- **Throwaway work.** One-off analyses, diagnostics, and agent experiments go in `scripts/.adhoc/<YYYY-MM-DD>-<purpose>/`, which Git ignores. To keep a method, promote it into `scripts/` or the package, with tests.
- **Data.** Establish grain, keys, units, and cadence before transforming. Check join cardinality and compare row counts and totals before and after joins and aggregations. A missing value is not a zero. Keep raw inputs immutable, keep evaluation data out of fitting, and respect time and group boundaries when splitting.
- **Models.** Validate data and configuration, then start with a small smoke run before an expensive fit. Record the code revision, data identity, configuration, and seeds. Running is not converging and converging is not valid: check sampling diagnostics and prior and posterior predictive checks before interpreting.
- **Build, test, fix, learn.** Implement the whole change, then exercise what the human will use, not just an import. Fix what breaks and run the checks again. Add regression tests for meaningful behavior; never weaken an assertion to get a pass. Say what you verified and what you did not.
- **Git.** Check `git status` first. Make focused commits, and keep credentials, sensitive data, and model artifacts out of them. Review the staged diff before committing.
- **Pull requests.** Include `## Summary` and a `## Test plan` checklist, and when they apply, `## Decisions taken without asking` and `## Mistakes found during self-testing`. For visible UI changes, add before and after screenshots, saved outside the repository and attached with `gh pr create --attach` or `gh pr edit --attach`. End with `Harness: <harness>. Session: <session-id>`.
- **People.** Work here is a team's. `git var GIT_AUTHOR_IDENT` hints at who is prompting you and `git shortlog -sne --all` lists who worked here; never attribute everyone's changes to the person in front of you. GitHub issues hold planned work and bugs: `gh issue list`.
- **Disagreement.** When code and a documented rule disagree, decide which is wrong: a broken requirement calls for a code fix, an outdated description for a correction. If the intent is unclear, report the discrepancy instead of picking a side silently.
<!-- prok:start -->

# Project knowledge

This project keeps what it knows and has decided in [prok](https://github.com/pymc-labs/prok): one graph of entries in a central system, shared by every person and agent on the project, whatever harness they use. The `prok` skill explains it. Before you edit a file, prok hands you the entries that apply to it.

- When you make a decision, find something out, or rely on something that others need to know, write it as an entry with `prok new-entry`. Give it the files it is about with `--affected-path`, so it reaches whoever edits them next.
- Entries are written on a branch, into the world of that branch, and hold once its pull request is merged and the world is canonized. On `main`, prok refuses to write: switch to a branch first.
- You propose; a maintainer of the project canonizes. Never change an active entry: supersede it with a new one, or propose to retire it.
- When an entry shaped your work, say what it says, then give its ID.
- `AGENTS.md`, `CLAUDE.md`, and `PROJECT_KNOWLEDGE.md` are generated and never committed. These shared instructions live in `.prok/instructions.md`.
- A commit is refused while a constraint is broken. Do not set `PROK_ALLOW` or skip hooks unless the human confirmed it in this conversation.
- In the first session, write what you learned about the project as entries on a branch of its own, and mark the few that every session needs with `--kernel`.

Choose the entry type by what you are writing down:

| What it is                                                                           | Entry type   |
| ------------------------------------------------------------------------------------ | ------------ |
| A rule without exceptions                                                            | `constraint` |
| How we do a recurring thing; deviating needs a stated reason                         | `convention` |
| A choice between options, with why                                                   | `decision`   |
| Something verified or observed: a data quirk, a debugging trap, an agent's mistake   | `fact`       |
| Something we rely on without having verified it                                      | `assumption` |
| An open problem, or work deferred to come back to                                    | `question`   |
<!-- prok:end -->
<!-- no-prok:start -->

# Project knowledge

Write down what the next session needs where the team will find it: decisions and their reasons in pull request descriptions, lasting rules in this file, planned and deferred work in GitHub issues.
<!-- no-prok:end -->
<!-- decision-hub:start -->

# Skills from Decision Hub

[Decision Hub](https://hub.decision.ai/) distributes versioned agent skills, such as `pymc-labs/pymc-modeling`, `pymc-labs/pymc-extras`, and `pymc-labs/mmm-modeling`. Search it with `pixi run -e decision-hub dhub ask "<what you need>"`; queries leave the machine, so describe the need without client details. `pixi run -e decision-hub dhub install <org>/<skill> --agent all` links a skill into every agent on the machine. Before relying on a skill, read its `SKILL.md` and check its examples against the library versions of this project's environment. To share a reviewed skill with the team, copy it into `.agents/skills/<skill>/` with its identifier, version, and source.
<!-- decision-hub:end -->

# About the humans

We are core members of PyMC Labs and experts in Bayesian modeling, with a few exceptions.

- **The 🤘 signal.** When the human ends a request with 🤘, they grant wider latitude and want you to finish the job. Decide more and ask less; merging PRs is allowed. Still follow the rules above, and stop if you are genuinely blocked or about to make a consequential mistake.
- **Speech-to-text.** Humans may dictate, producing near misses such as "Cloud MD" for "CLAUDE.md". Interpret them from context; ask when the meaning is genuinely unclear.
- **Do it, don't suggest it.** Carry out authorized work you can do yourself, including its verification; do not ask the human to run commands you can run. When starting a long-running process, announce it in capitals with its start time (`HH:MM:SS`) and expected end.
- **Match the requested mode.** _Explain, review, diagnose, "what do you think"_ are read-only. _Change, build, fix, add, ship_ include implementation and testing. When the mode is ambiguous, answer first and offer the implementation in one line.
- **Report blockers with evidence.** Exhaust safe alternatives first. Then state the exact condition, the evidence, and the action needed to continue.
- **Skills by request only.** A skill's name in an ordinary sentence ("let's review the schema") is not a request to run that skill.
- **Client work.** Our clients expect careful, reliable work. Data integrity, model interpretation, and clear deliverables are part of finishing the task.

## Writing for humans

Optimize the final message for the human's understanding. Avoid software engineering jargon; aim for the clarity and simple language of ASD-STE100. End substantial work with this format, omitting `HEADS UP` when there is no material warning and `Next steps` when no action remains:

```text
<Where the work landed. Include process details only when they matter to the outcome. Keep this short.>

⚠️ HEADS UP

<INFORMATION THE HUMAN MUST ABSOLUTELY KNOW>

Recap

<1–3 lines covering the task and outcome, so a human managing several agent sessions can navigate easily.>

Next steps

- <Concrete next action, when needed.>

<Git status: PR merged/PR not merged/Unstaged/Staged/Committed/Pushed> · <HH:MM:SS, human's local time>
```

- **Lead with the outcome.** Explain where the work landed before describing how you got there.
- **Explain decisions, tradeoffs, risks, and blockers.** Include what the human needs to assess the result.
- **Make the final response self-contained.** Do not rely on the human having read progress messages.
- **Let response depth follow stakes, not effort.** A small change needs a short handoff; a consequential result needs supporting evidence.
- **Signal your confidence clearly.** Distinguish what is verified, inferred, and assumed. "Tests pass" does not mean "ready to deliver to a client". Never claim success without fresh evidence you inspected.
- **Link what you name.** Link files, PRs, issues, reports, and other artifacts so the human does not have to find them.
