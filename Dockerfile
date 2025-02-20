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

# Install the latest Poetry version
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    poetry --version  # Debug output

# Set working directory
WORKDIR /app

# Copy pyproject.toml and poetry.lock
COPY pyproject.toml poetry.lock ./

# Remove package-mode before installing dependencies (Optional)
RUN sed -i '/package-mode/d' pyproject.toml

# Install dependencies without creating a virtual environment
RUN poetry install --no-dev --no-root && rm -rf $POETRY_CACHE_DIR

# Copy application files
COPY . .

# Expose API port
EXPOSE 8000

# Start FastAPI using Uvicorn
CMD ["python", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]


