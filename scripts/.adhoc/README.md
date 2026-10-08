# Analyses and reference scripts

This directory is for work outside the maintained workflow. Both subdirectories start with only `.gitkeep`; add actual project work as needed.

## Scratch work

Start one-off analyses, diagnostics, and agent experiments in `scratch/<YYYY-MM-DD>-<purpose>/`, including their disposable outputs. Everything under `scratch/` is gitignored except its top-level `.gitkeep`.

Keep useful findings in the project's documentation or experiment history, with enough input and method information to reproduce them. Scratch files are local and will not be available to other contributors through Git.

## Reference inventory

Preserve a method in `reference/` only when its code or provenance is worth sharing. Add an entry here for each saved script, linking its file and describing its purpose, required inputs and source identity, and known limitations. Keep credentials, source data, and generated model artifacts out of tracked reference code.

Reference scripts may need adaptation before reuse; being tracked does not make them maintained commands. Retire them when their method or provenance is no longer useful. To support a tool routinely, follow the promotion guidance in the [script guide](../README.md).
