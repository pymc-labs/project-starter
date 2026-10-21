# Decision Hub

[Decision Hub](https://hub.decision.ai/) distributes versioned agent skills: a `SKILL.md` with instructions and, sometimes, supporting references or code. Use it when an external skill would help with the current task. It complements the library's official documentation; a skill's examples can target a different library version from this project.

## CLI and discovery

The optional `decision-hub` Pixi environment contains the `dhub-cli` package, which provides the `dhub` command. It has separate dependencies from the modeling environment. Run it from the repository root:

```sh
pixi run -e decision-hub dhub --help
pixi run -e decision-hub dhub ask "Bayesian modeling with PyMC"
pixi run -e decision-hub dhub list --org pymc-labs
pixi run -e decision-hub dhub info pymc-labs/pymc-modeling
```

Pixi installs this environment on first use if setup deferred installation. Public discovery and downloads work without a Decision Hub account or API key. Login is needed for publishing and private access; do not initiate login for public discovery. Search queries leave the machine, so use generic descriptions rather than client data or private project details. If the service is unavailable, use official documentation and existing local skills.

## Common PyMC Labs skills

These are useful starting points for many projects; choose the skills that match the task and installed library versions:

- `pymc-labs/pymc-modeling`: Bayesian modeling, sampling, and diagnostics with PyMC.
- `pymc-labs/pymc-extras`: PyMC Extras features such as splines, shrinkage priors, marginalization, and Laplace approximation.
- `pymc-labs/mmm-modeling`: media mix modeling with PyMC-Marketing, including channel contributions and budget optimization.

To install them using the project's CLI:

```sh
pixi run -e decision-hub dhub install pymc-labs/pymc-modeling --agent all
pixi run -e decision-hub dhub install pymc-labs/pymc-extras --agent all
pixi run -e decision-hub dhub install pymc-labs/mmm-modeling --agent all
```

These commands install the latest skill releases and link them into all detected agents' user-wide skill directories. For a specific version or a shared project copy, follow [Use a skill](#use-a-skill) below.

## Use a skill

1. Inspect the skill's publisher, source, version, license, and description. Check the project's actual library versions in its Pixi environment before relying on examples. For PyMC, use `pixi run python -c "import pymc; print(pymc.__version__)"`. Resolve incompatible guidance against the installed version's official documentation; do not upgrade project dependencies merely to match a skill.
2. Download a chosen version with `pixi run -e decision-hub dhub install ORG/SKILL --version VERSION`, replacing the placeholders. The CLI verifies the download checksum and stores files under `~/.dhub/skills/ORG/SKILL/`. Read `SKILL.md` and the relevant supporting files before applying their guidance or running bundled code. A registry grade is useful evidence, not proof of correctness.
3. For shared project use, copy the reviewed skill directory into `.agents/skills/<skill-name>/` and commit it with its license and a short provenance note containing its registry identifier, version, and source URL. Copy files rather than linking to a machine-specific home directory. Confirm the active agent can discover the project skill, or explicitly read its `SKILL.md`.
4. Follow this repository's environment, modeling, and testing conventions when applying the skill. Validate the resulting work, and record useful outcomes in the project's context. Update shared skills deliberately, reviewing the changes as code.

Plain `dhub install` downloads files without activating a skill in an agent. The CLI's `--agent NAME` option links skills into that agent's user-wide directory; `--agent all` affects all detected agents. Use those options only when the task calls for user-wide installation. Setup installs the CLI only; it does not download skills or change agent configuration.

For command options and supported agents, consult the [upstream CLI reference](https://github.com/pymc-labs/decision-hub#cli-reference) and `dhub <command> --help` through the Pixi environment. Update the CLI through Pixi and review `pyproject.toml` and `pixi.lock` together, following [Environment](ENVIRONMENT.md).
