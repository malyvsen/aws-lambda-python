FROM public.ecr.aws/lambda/python:3.13-arm64

# Install uv for fast dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies into the Lambda task root
RUN uv export --format requirements.txt | uv pip install --system --target "${LAMBDA_TASK_ROOT}" -r -

# Copy handler code
COPY main.py "${LAMBDA_TASK_ROOT}/"

CMD ["main.handler"]
