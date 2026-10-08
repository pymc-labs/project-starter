# Data processing and integrity

- Establish the input grain, keys, units, date cadence, and required columns before transforming data. Parse dates explicitly and preserve coordinate alignment.
- Check key uniqueness and expected join cardinality. Compare row counts and relevant totals before and after joins or aggregation so duplication and loss are visible.
- Distinguish missing observations from observed zeroes. Define missing-value handling for each variable; do not fill every numeric null with zero.
- Aggregate according to meaning. Prices, rates, and percentages generally need a different rule from counts or amounts; check units and weighting.
- Preserve training scope, exclusions, and masks through preprocessing, prediction, and metric aggregation. Validate excluded and missing observations when changing these paths.
- Keep evaluation data separate from fitting and learned preprocessing. Respect time and group boundaries when splitting data, and check for leakage from future information.
- Keep raw inputs immutable. Record source identity, extraction or snapshot version, filters, and transformations so a result can be traced to its inputs.
- Reuse existing preprocessing and inspect the effective configuration, including defaults and overrides. Successful parsing or loading alone does not prove a setting took effect.

Describe the project's actual data contracts and loading paths in [REFERENCE](../REFERENCE/README.md). Use small synthetic or approved fixtures for routine checks.
