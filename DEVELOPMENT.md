# Development

This project uses [Ruff](https://docs.astral.sh/ruff/) for linting.
Install the runtime dependencies and the development tools with:

```bash
pip install -r requirements.txt
pip install ruff pre-commit
```

After installing `pre-commit`, set up the git hooks:

```bash
pre-commit install
```

Now `pre-commit` will run Ruff before each commit. You can invoke the
hooks manually across the whole project with:

```bash
pre-commit run --all-files
```

### Dependencies

The calculators depend on several core libraries:

- **NumPy** and **Pandas** for data handling
- **LightGBM** for readmission risk scoring
- **PyArrow** (optional) to cache SAS tables in Parquet format

`requirements.txt` installs the runtime dependencies while
`requirements-dev.txt` adds the packages needed for the test suite.
