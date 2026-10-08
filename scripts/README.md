# Scripts

Put maintained workflow entry points here. Keep reusable model and data logic in the Python package, and run scripts from the repository root through Pixi.

This scaffold includes no runnable scripts. As supported commands are added, list them below with their purpose, required inputs, outputs, and side effects. Keep their command-line help current.

## Analyses and experiments

Use [`.adhoc/`](.adhoc/README.md) for work outside the maintained workflow:

- [`.adhoc/scratch/`](.adhoc/scratch/): disposable analyses, diagnostics, and generated outputs. Its contents are gitignored except for the empty `.gitkeep` that preserves the directory.
- [`.adhoc/reference/`](.adhoc/reference/): deliberately preserved analysis methods and provenance. These scripts are tracked but are not supported workflow commands.

Maintained scripts and package code must not import or invoke `.adhoc/` scripts. To promote a tool into the supported workflow, move it here or move reusable logic into the package, document its interface, and verify its intended use.
