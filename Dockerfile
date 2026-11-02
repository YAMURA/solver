FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

WORKDIR /app

# System deps: Playwright/Chromium needs these; curl_cffi needs build tools
# only if wheels are unavailable (usually not), but keep libssl for TLS.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
    libx11-6 \
    libxcb1 \
    libxext6 \
    fonts-liberation \
    fonts-unifont \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt \
 && python -m playwright install --with-deps chromium

COPY . .

# Railway sets $PORT. Default to 5555 for local docker run.
ENV PORT=5555 \
    HOST=0.0.0.0

EXPOSE 5555

# Note: app.py uses argparse; pass --launch only if you want in-process
# kontolsolver slots. For a Railway API server, skip --launch and let
# /api/solve drive the warm-pool browser itself.
CMD ["sh", "-c", "python app.py --host 0.0.0.0 --port ${PORT}"]
