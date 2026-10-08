# Git workflow

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

## Pull requests

Making it easy for humans to understand what change a PR implies, and why it can be trusted, is very important. It communicates to collaborators what you did on behalf of the human who managed your session. Include `## Summary` and `## Test plan` (checklist) if applicable. Add `## Decisions taken without asking` if any autonomous scope calls were made. Add `## Mistakes found during self-testing` if applicable.

- **Screenshots for frontend PRs.** If the PR includes visible UI changes, add before/after screenshots to the PR description. Put screenshots in a `screenshots` branch in a folder named after the PR ID, and display them as `![<image name>](https://github.com/<owner>/<repository-name>/blob/screenshots/<pr-id>/<image-name>.png?raw=true)`. Determine `<owner>/<repository-name>` from the Git remote where you push the screenshots branch; inspect `git remote -v`. If you deem understanding the work as a human significantly easier by there being a descriptive image (a diagram, a figure or a graph of any kind), you are also encouraged to include such in the PR body.
- **Include harness and session ID in every PR description.** Before creating a PR, get the current agent harness session ID. Add it as a footer line in the PR body: `Harness: <harness-name>. Session: <session-id>`. For provenance.
