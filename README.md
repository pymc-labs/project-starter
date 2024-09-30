# PyMC Labs project starter

All projects' codebases go off the rails to some extent. It happens in tiny increments with awkward commits that "solves the problem". This is entirely forgivable when a codebase is not designed for the new problem and there are time constraints. It is inevitable.

But it is possible to offset chaos with proper guardrails. These are:

- **pixi** for dependency and environment management.
- **pre-commit** for formatting, spellcheck, etc. If everyone uses the same standard formatting, then PRs won't have flaky formatting updates that distract from the actual contribution. Reviewing code will be much easier.
- **beartype** for runtime type checking. If you know what's going in and out of functions just by reading the code, then it's easier to debug. And if these types are even enforced at runtime with tools like `beartype`, then there's a whole class of bugs that can never enter your code.
- **pytest** for testing. Meanwhile, with `beartype` handling type checks, tests do not have to assert types, and can merely focus on whether the actual logic works. 

This is a pretty minimal template, no cookie-cutter or anything. It assumes you have all of your logic stored in a package, that you import and use elsewhere. You will probably want to put your main model logic in the `models.py` file, and then have a script for running the model, e.g. in a `scripts/run_model.py` file, or a notebook somewhere (not inside the package folder).

### Install

To start using it:
1. Clone the repository
2. Decide on a package name and 

```bash
make setup
```