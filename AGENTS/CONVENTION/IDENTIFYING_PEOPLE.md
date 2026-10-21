# Identifying people

Assume that work is contributed by a whole team; do not attribute everyone's changes to the person currently prompting you.

Start with these commands from the repository root:

```bash
# Configured author identity for this checkout, including environment overrides.
git var GIT_AUTHOR_IDENT

# Contributor names and emails across all locally available branches and tags.
git shortlog -sne --all
```

The configured identity is a clue to who is prompting, not proof: a shared machine or automation may use another identity. Prefer the human's explicit self-identification when it differs, and never infer the current user from the latest commit's author.

Resolve a mentioned name against the contributor list; a GitHub handle is not required. For example:

```bash
git shortlog -sne --all | rg -i -- 'Teemu'
git log --all --use-mailmap --fixed-strings --regexp-ignore-case \
  --author='Teemu' --format='%h %cI %aN <%aE> %s' --stat
```

- Once the person is resolved, prefer their identified email address in `--author`; repeat the flag for verified aliases. Respect `.mailmap` mappings. If several people match, clarify rather than guessing.
- For questions such as "what did Teemu do here last week", add explicit `--since` and `--until` timestamps for the requested calendar period in the human's timezone. "Last week" means the previous calendar week, not the last seven days. Inspect relevant diffs with `git show <commit>` before summarizing the work.
- These commands cover available Git history. Check `git rev-parse --is-shallow-repository` and fetch relevant refs or deepen a shallow clone when needed before concluding there was no activity. Commits alone do not establish PR reviews, uncommitted work, or everything a teammate did.
