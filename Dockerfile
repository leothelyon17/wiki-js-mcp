FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install dependencies first for better layer caching.
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r /app/requirements.txt

# Copy server source.
COPY src/ /app/src/

# Create a writable data directory for the SQLite mapping DB and optional log file.
RUN useradd --create-home --uid 10001 appuser \
    && mkdir -p /data \
    && chown -R appuser:appuser /app /data

USER appuser

ENV WIKIJS_MCP_DB=/data/wikijs_mappings.db \
    LOG_FILE=/data/wikijs_mcp.log

EXPOSE 8000

# Default to Streamable HTTP transport for container deployments.
CMD ["python", "src/wiki_mcp_server.py", "--transport", "streamable-http", "--host", "0.0.0.0", "--port", "8000"]
