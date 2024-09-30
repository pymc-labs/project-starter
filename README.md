# PyMC Labs project starter

All projects' codebases go off the rails to some extent. It happens in tiny increments with awkward commits that "solves the problem". This is entirely forgivable when a codebase is not designed for the new problem and there are time constraints. It is inevitable.

However, this chaos can be mitigated with some decent guardrails. This **project template** provides the following:

- **`pixi`** for dependency and environment management.
- **`pre-commit`** for formatting, spellcheck, etc. If everyone uses the same standard formatting, then PRs won't have flaky formatting updates that distract from the actual contribution. Reviewing code will be much easier.
- **`beartype`** for runtime type checking. If you know what's going in and out of functions just by reading the code, then it's easier to debug. And if these types are even enforced at runtime with tools like `beartype`, then there's a whole class of bugs that can never enter your code.
- **`pytest`** for testing. Meanwhile, with `beartype` handling type checks, tests do not have to assert types, and can merely focus on whether the actual logic works.

## Usage

This is a pretty minimal template, that assumes you have opinions and may want to add/remove stuff too. To use it as intended (not that you have to), you should put your main model logic in the `package_name/models.py` file, adjacent logic split into sibling files, and then have a script that imports from `package_name` and runs the model, e.g. in a `scripts/run_model.py` file, or a notebook somewhere (e.g. in `experimentation`).

### Prerequisites

- Python 3.11 or higher
- Pixi package manager

### Install

1. Clone this repository:
    ```shell
    git clone git@github.com:pymc-labs/project-starter.git
    ```
    Unless you want to contribute to this project, you can delete the `.git` folder and initialize a new repository


2. Rename the package:
    ```shell
    make rename-package name=my_new_package_name
    ```
    If you want to rename it again, you can do so with:
    ```shell
    make rename-package name=my_new_package_name current_name=my_old_package_name
    ```


3. Build the python environments and install `pre-commit`:
    ```shell
    make install
    ```
    This creates a `.pixi` folder that contains a `envs/default` and `envs/test` virtual environments.


4. To validate that everything works, run the tests:
    ```shell
    make test
    ```

### Philosophy

There are some example files in this repository. Have a look at them. Each of the files in `package_name` has a docstring that explains their role in your package. You may not want to follow this dogma entirely, but having split out the code for custom types, main model logic, preprocessing, string parsing, etc. into separate files is always a good idea. Mostly, however, you can use these as an example to build upon.

And please contribute. If you add some guardrails that you think would be generally useful, please make a PR.
