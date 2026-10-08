# About this project

This is a data science project based on the PyMC Labs project starter. Replace this paragraph with the project's purpose and scope once they are established; do not infer them from the example package.

# Persistent context

This file is the entry point for agents working in the repository. Read it at the start of a task, then load only the context relevant to that task.

- `AGENTS/CONVENTION/` contains stable requirements and decision rules: how work should be done and what must be preserved.
- `AGENTS/REFERENCE/` describes the current implementation, commands, configuration, and limitations, with links to their source. It starts empty except for its [purpose note](AGENTS/REFERENCE/README.md); add references as the project develops.
- `AGENTS/*.md` records useful history, current quirks, unfinished work, and lessons. These files start without project-specific entries.
- Component READMEs explain usage and interpretation for humans. The root README gives a concise project overview.
- `.agents/skills/` is reserved for reusable agent workflows. It starts with only `.gitkeep`; add skills only when the project needs them.

When code and documentation disagree, classify the mismatch. A requirement violation calls for a code fix; an outdated implementation description calls for a reference correction. Preserve a documented requirement unless the task supports an intentional change. If intent remains unclear, report the discrepancy rather than silently making either side authoritative.

## Task guidance

Read the relevant conventions and follow their implementation references as needed. Several rows may apply; there is no need to read every context file for every task.

| Task                                                          | Read                                                    |
| ------------------------------------------------------------- | ------------------------------------------------------- |
| Run commands, manage dependencies, diagnose imports           | [Environment](AGENTS/CONVENTION/ENVIRONMENT.md)         |
| Edit Python code                                              | [Code style](AGENTS/CONVENTION/CODE_STYLE.md)           |
| Add a script, notebook, analysis, or agent experiment         | [Common patterns](AGENTS/CONVENTION/COMMON_PATTERNS.md) |
| Change transformations, joins, missing values, or data splits | [Data processing](AGENTS/CONVENTION/DATA_PROCESSING.md) |
| Build, fit, compare, or interpret a model                     | [Modeling](AGENTS/CONVENTION/MODELING.md)               |
| Validate code, configuration, or documentation                | [Testing](AGENTS/CONVENTION/TESTING.md)                 |
| Implement changes, branch, commit, or prepare a PR            | [Git workflow](AGENTS/CONVENTION/GIT_WORKFLOW.md)       |

<!-- decision-hub:start -->
For discovering, installing, or using external agent skills, read [Decision Hub](AGENTS/CONVENTION/DECISION_HUB.md).
<!-- decision-hub:end -->

## Session context

Skim recent changelog entries and search the other files for the area you are working on. Recheck dated observations against the current code and environment before relying on them.

| File                                       | Read / update when                                                                                                                   |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| [CHANGELOG](AGENTS/CHANGELOG.md)           | Starting substantive work; record changes, decisions, and validation that the next session needs.                                    |
| [QUIRKS](AGENTS/QUIRKS.md)                 | Debugging or discovering a surprising behavior; record evidence, scope, and any verified workaround. Not for bugs.                   |
| [DEFERRED](AGENTS/DEFERRED.md)             | Planning implementation or leaving concrete work unfinished; check whether relevant follow-ups fit the current task. Not for issues. |
| [AGENT_MISTAKES](AGENTS/AGENT_MISTAKES.md) | Self-testing reveals a mistake or reviewing a recurring failure; record the cause, correction, and prevention.                       |

Github Issues are persistent context too. They document oncoming dev work, bugs, feature requests, etc. Run `gh issue list` to see open work (planned + in-flight).

## Maintaining context

Maintaining relevant context is part of the task, not a separate handoff to the human.

- Update the owning document when behavior or requirements change. Link to code, tests, artifacts, or decisions instead of copying large blocks of implementation into context.
- Keep entries concise and evidence-based. Distinguish observations, hypotheses, and unverified paths; never invent results, project facts, or history to fill the templates.
- Add conventions only for durable, agreed rules. Put current commands and configuration contracts in references, and link new documents from the relevant task guidance or convention.
- Keep current quirks and deferred work current: remove obsolete quirks, close resolved tasks, and preserve useful outcomes in the changelog. Do not turn a temporary workaround into a permanent requirement.
- Keep secrets, credentials, private account settings, and sensitive source data out of context. Refer to approved locations without copying their contents.

# Workflow rules

1. Inspect the working tree and relevant context. Preserve existing changes and the human's chosen scope.
2. Implement the requested change, then exercise the behavior the human will use. Follow the [build-test-fix-learn cycle](AGENTS/CONVENTION/GIT_WORKFLOW.md#build-test-fix-learn) and [testing rules](AGENTS/CONVENTION/TESTING.md).
3. Before expensive model runs, validate data and configuration and start with a small smoke run. Increase compute only when the task and diagnostics justify it; a successful short run does not establish model validity.
4. Update relevant context during the same task, then report the outcome following [Writing for humans](#writing-for-humans).
<!-- starter-only:start -->

While `setup.sh` is present, this repository is still a starter: keep the reference and session files as empty templates. Once setup removes it, populate them from actual project work and replace the project description when its purpose is established.

<!-- starter-only:end -->

# About the humans

We are core members of PyMC Labs and experts in Bayesian modeling, with a few exceptions.

Follow [Identifying people](AGENTS/CONVENTION/IDENTIFYING_PEOPLE.md) when identifying who is prompting or resolving references to teammates and their work.

## Signals

- **The 🤘 signal.** When the human ends a request with 🤘, they are explicitly granting wider latitude and want you to finish the job. Lean harder into your own judgment, decide more, and ask less. Merging PRs is allowed. Still follow the workflow rules and stop if you are genuinely blocked or about to make a consequential mistake.
- **Speech-to-text.** Humans may dictate their messages, producing typos such as "Cloud MD" for "CLAUDE.md" and other near misses. Interpret these from context; ask when the intended meaning is genuinely unclear.

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
- **Signal your confidence clearly.** Distinguish what is verified, inferred, and assumed. "Tests pass" does not mean "ready to deliver to a client"; a successful deployment does not establish that a report is finished. Never claim success without fresh evidence you inspected.
- **Link what you name.** Link files, PRs, issues, reports, demos, and other artifacts so the human does not have to find them manually.

## Highly valued agent behavior

- **Do it, don't suggest it.** Carry out authorized work you can execute yourself, including its verification. Do not ask the human to run commands you can run. Use judgment around consequential actions that cannot be undone. When starting a long-running process, announce it in capitals with the start time (`HH:MM:SS`) and estimated completion time.
- **Match the requested mode.** _Explain, review, diagnose, "what do you think about", "why does X happen"_ are read-only: answer without editing files or opening worktrees. _Change, build, fix, add, ship_ include implementation and the [build-test-fix-learn cycle](AGENTS/CONVENTION/GIT_WORKFLOW.md#build-test-fix-learn). When the mode is genuinely ambiguous, answer first and offer implementation in one line.
- **Report blockers with evidence.** Exhaust safe alternatives within scope before declaring yourself blocked. State the exact condition, the evidence for it, and the specific action needed to continue. "Couldn't get it working" is not a blocker report.
- **Never trigger a skill just because its name appears in the human's text.** Skills can have ordinary names such as `stage`, `reset`, `ship`, `run`, `review`, `sweep`, `issue`, or `blog`. "Reset the staging DB", "let's review the schema", and "that's a blog-worthy result" are ordinary sentences, not skill invocations. Only treat direct requests to use a skill as invocations.
- **Honor that we are doing high-value client work.** Our clients expect careful, reliable work. Treat data integrity, model interpretation, and the clarity of deliverables as part of finishing the task.
