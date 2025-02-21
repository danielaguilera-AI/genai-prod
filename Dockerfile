# Use official Python image
FROM python:3.10-slim

# Set environment variables for Poetry
ENV POETRY_HOME="/opt/poetry" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR="/var/cache/pypoetry"

# Update PATH to include Poetry
ENV PATH="$POETRY_HOME/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    poetry --version  # Debug Poetry version

# Set working directory
WORKDIR /app

# ✅ Copy required project files first (optimizes Docker caching)
COPY pyproject.toml poetry.lock README.md ./

# ✅ Install dependencies **without** installing the project itself
RUN poetry install --no-root && rm -rf $POETRY_CACHE_DIR

# ✅ Copy the rest of the application files
COPY . .

# Expose API port
EXPOSE 8000

# Start FastAPI using Uvicorn
CMD ["python", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]







