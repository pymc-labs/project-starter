# Modeling and evaluation

Read before building, fitting, comparing, or interpreting models.

- Establish the question, target units, training scope, and intended use before changing a model. Preserve parameter and prior meanings unless the task calls for an intentional change.
- Validate data, resolved configuration, and model construction before expensive computation. Start with a small smoke run, then increase effort as diagnostics and the task justify it.
- Record the code revision, data identity, effective configuration, random seeds where applicable, environment, and artifact location. Use a saved model's inputs and configuration to explain it; today's defaults may differ.
- Keep meaningful run history near the relevant model or experiment configuration, or in an established experiment tracker. Record purpose, inputs, outcomes, and failures; link to that history from session notes rather than copying every run into the repository changelog.
- Distinguish successful execution, convergence, statistical validity, and readiness for use. For Bayesian models, inspect sampling diagnostics and relevant prior/posterior predictive checks; a short fit or prior-only simulation does not establish posterior quality.
- Evaluate predictions at the relevant grain and aggregates, including genuine held-out data where available. State the metric, population, period, exclusions, and uncertainty used in comparisons.
- Compare consequential model choices on compatible inputs and metrics. Report sensitivity and remaining uncertainty; good predictive fit alone does not establish a causal interpretation.
- Derive acceptance criteria from the project and task. Do not invent universal thresholds or describe an export as a verified delivery.
