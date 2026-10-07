# Testing and validation

Read when validating code, configuration, dependencies, or documentation.

- Choose checks for the changed behavior. Start with focused tests and input/configuration validation, then exercise the affected workflow. Run expensive integration or sampling checks when the change warrants them.
- Add regression coverage for meaningful behavior. Test inputs, outputs, and failure cases; avoid placeholder tests, tests that mirror the implementation, and assertions about documentation wording.
- Keep routine tests independent of live credentials, external writes, and long model fits. State what mocks and synthetic fixtures do and do not establish.
- For data and model changes, check relevant dimensions, units, masks, transformations, and resolved settings. An import or successful model construction is only one level of validation.
- Exercise affected user interfaces with representative data when present. Building an artifact alone does not verify its interactions or interpretation.
- Establish suspected baseline failures against unchanged code or equivalent inputs and dependencies. Do not weaken assertions or suppress failures to obtain a passing result; explain their scope and impact.
- Record actual checks, results, and material untested paths. Do not describe a partially failed suite as passing or a smoke fit as model validation.

For documentation-only work, check claims, examples, local links, and `git diff --check`; do not run unrelated model fits. Follow [Environment](ENVIRONMENT.md) for commands and [Git workflow](GIT_WORKFLOW.md) for the verification cycle.
