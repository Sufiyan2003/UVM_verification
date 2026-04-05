# Use Python slim as base
ARG PYTHON_VERSION=3.10.20
FROM python:${PYTHON_VERSION}-slim

# Prevent pyc files and enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /workspace

# Install Make and other CLI tools
RUN apt-get update && apt-get install -y \
    make \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Optional: create non-root user (good practice)
ARG UID=10001
RUN adduser --disabled-password --gecos "" --uid "${UID}" appuser
USER appuser

# Copy your repo (optional, you can mount it instead)
COPY . .

# No EXPOSE needed; no server is running
# No CMD needed; you can run any command interactively