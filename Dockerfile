# Stage 1: Build helper using Alpine
FROM alpine:3.19 AS alpine-builder
# Install poppler + all puppeteer/chromium related packages here together
# (apk only works in this stage)
RUN apk add --no-cache \
    poppler-utils ffmpeg ghostscript curl \
    chromium nss glib freetype freetype-dev harfbuzz \
    ca-certificates ttf-freefont udev ttf-liberation font-noto-emoji

# Stage 2: Main n8n image
FROM n8nio/n8n:latest
USER root

# Copy chromium and everything else from Stage 1 (no apk needed here)
COPY --from=alpine-builder /usr/bin /usr/bin
COPY --from=alpine-builder /usr/lib /usr/lib
COPY --from=alpine-builder /lib /lib
COPY --from=alpine-builder /usr/share /usr/share

# Tell Puppeteer not to download its own Chrome, and use the copied chromium instead
# NODE_PATH is added so global npm modules can be found by n8n-nodes-puppeteer too
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    NODE_PATH=/usr/local/lib/node_modules

# npm install -g is fine here — it does not depend on apk, npm is already in the base image
RUN npm install -g node-html-to-image

# Puppeteer extra plugins (n8n-nodes-puppeteer is installed separately
# via n8n's Community Nodes UI, not here in the Dockerfile)
RUN npm install -g \
    puppeteer-core \
    puppeteer-extra \
    puppeteer-extra-plugin-user-data-dir \
    puppeteer-extra-plugin-stealth

# Install yt-dlp (standalone binary, no python dependency needed)
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp

RUN mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

# Verify poppler-utils binaries were copied correctly (fails the build if missing)
RUN pdftoppm -v && pdftotext -v && pdfinfo -v

USER node
