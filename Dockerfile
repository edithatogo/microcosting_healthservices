FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY pyproject.toml README.md LICENSE MANIFEST.in ./
COPY nwau_py ./nwau_py
COPY excel_calculator/src ./excel_calculator/src
COPY excel_calculator/scripts ./excel_calculator/scripts

RUN python -m pip install --no-cache-dir --upgrade pip \
    && python -m pip install --no-cache-dir .

ENTRYPOINT ["mchs-mcp"]
