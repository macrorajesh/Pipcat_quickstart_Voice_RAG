FROM python:3.12-slim

# Install system dependencies needed for audio/video processing
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install --no-cache-dir uv

# Set working directory
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Copy project files
COPY pyproject.toml uv.lock ./

# Install the project's dependencies using the lockfile
RUN uv sync --locked --no-install-project

# Copy the application code
COPY ./bot.py bot.py

# Copy client files to a location where they can be served
RUN mkdir -p /app/static && \
    cp -r .venv/lib/python3.12/site-packages/pipecat_ai_small_webrtc_prebuilt/client/dist/* /app/static/

# Expose the port
EXPOSE 7860

# Run the bot using uv run to ensure proper environment
CMD ["uv", "run", "python", "-u", "bot.py"]
