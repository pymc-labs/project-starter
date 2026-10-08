# Scripts, notebooks, and experiments

Read before adding an entry point, analysis, or one-off experiment.

- Keep reusable logic in the Python package and maintained workflow entry points in `scripts/`. Reuse an existing entry point when extending a workflow.
- Keep notebooks in `notebooks/` for exploration and explanation. Move shared or production logic into importable functions; verify important results from a fresh kernel, without relying on hidden state.
- Prefer `argparse` for standalone Python scripts, `Path` for paths, and a `main()` function behind an `if __name__ == "__main__"` guard. Follow an established CLI framework if the project already uses one.
- Explain defaults, required inputs, outputs, and external side effects in command help. Keep expensive loading, fitting, and writes out of imports and argument parsing.

## Script placement

Use the [script guide](../../scripts/README.md) for maintained commands and the [ad hoc guide](../../scripts/.adhoc/README.md) for analyses and experiments. Setup includes this directory scaffold when persistent agent context is enabled.

- Put disposable analyses, diagnostics, and agent experiments in `scripts/.adhoc/scratch/<YYYY-MM-DD>-<purpose>/`, including temporary outputs. Create a dated subdirectory when needed; scratch contents are gitignored except for the top-level `.gitkeep`.
- Preserve a useful one-off method in `scripts/.adhoc/reference/` only deliberately. Record its purpose, input provenance, and limitations in the [reference inventory](../../scripts/.adhoc/README.md#reference-inventory); preserved does not mean maintained or verified on current inputs.
- Maintained package code and workflow commands must not depend on `.adhoc/`. Promote a tool into the supported workflow only with a clear use case, documentation, and appropriate verification.
- Keep generated data and model artifacts out of tracked script directories. Use the project's artifact storage and record returned paths and identifiers.
