# Code style

- Use explicit imports and type hints on function signatures. Reuse project types for structured inputs and outputs.
- Write docstrings that explain units, shapes, side effects, and non-obvious behavior. Keep simple helpers concise.
- Keep reusable model and data logic in the Python package. Keep orchestration in scripts and exploration in notebooks; see [Common patterns](COMMON_PATTERNS.md).
- Reuse existing transformations and model builders rather than copying pipelines or model mathematics into diagnostics.
- Keep labels and dimensions intact when operating on arrays. Avoid unnecessary data copies, repeated graph construction, and model reloads.
- Review automatic formatter and hook changes before committing. Use [Testing](TESTING.md) to check behavior, not only formatting.
