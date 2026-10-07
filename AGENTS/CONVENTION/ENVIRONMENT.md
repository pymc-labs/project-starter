# Environment

Read before running commands, managing dependencies, or diagnosing imports.

- Run project Python commands from the repository root through Pixi. Use `pixi run python ...` and `pixi run python -m pytest ...` rather than relying on the system Python.
- Treat `pyproject.toml` and `pixi.lock` as the environment sources of truth. Update and review both deliberately when dependencies change; do not refresh dependencies just to run a check.
- Choose the environment and available compute appropriate to the task. Check the host before assuming a GPU, remote storage, or credentials are available.
- Do not overlap environment installation or refresh with checks using that environment. Inspect a stalled process before retrying to avoid duplicate fits or tests.
- When compatibility matters, verify the actual imported package path and revision, especially for editable dependencies. Do not silently change sibling checkouts to resolve a mismatch.
- Keep credentials in the established credential store or environment, outside tracked files. An installed dependency does not establish access to external data or services.

Document project-specific environments, commands, and constraints in [REFERENCE](../REFERENCE/README.md) once they exist.
