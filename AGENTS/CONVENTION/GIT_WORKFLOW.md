# Git workflow

Read for implementation work, branching, committing, or preparing a PR.

## Git state

- Inspect `git status` and the relevant diff first. Preserve the human's existing changes and requested commit boundaries.
- Follow explicit instructions on branches, commits, and pushes. Respect an existing task branch or requested base; inspect the remote state before choosing a base for a new branch.
- Keep changes focused and commit messages descriptive. Do not mix unrelated cleanup into a task.
- Keep credentials, sensitive data, generated model artifacts, and unapproved large outputs out of commits. Preserve intentionally tracked test fixtures.
- Review the staged diff and run `git diff --cached --check` before committing. Verify the resulting commit and working tree afterward.

## Build-test-fix-learn

Apply this cycle to implementation work, with checks scaled using [Testing](TESTING.md).

1. **Build:** implement the complete requested change and run the relevant checks. Resolve failures caused by the change.
2. **Self-test:** exercise the behavior the human will use, including relevant inputs, outputs, and neighboring behavior. Do not stop at compilation or a successful import.
3. **Fix and verify:** correct issues found during self-testing and rerun affected checks. Add meaningful regression coverage when warranted; confirm it catches the claimed failure.
4. **Record evidence:** report what was verified and any remaining limitation. Check off PR test-plan items only after verification.
5. **Learn:** record a mistake in [AGENT_MISTAKES](../AGENT_MISTAKES.md) when it reveals a useful lesson, with its cause, correction, and evidence. If no mistake was found, add nothing.

Update relevant context during the same task. Follow [Writing for humans](../../AGENTS.md#writing-for-humans) for the final report.

## Pull requests

Lead with the problem and resulting behavior. Include a summary and test plan, relevant decisions and tradeoffs, evidence for completed checks, and material limitations. Mention self-testing discoveries when they help review the change; link issues only when they exist.
