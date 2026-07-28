# Stage 1: Build helper using Alpine
FROM alpine:3.19 AS alpine-builder
RUN apk add --no-cache poppler-utils ffmpeg ghostscript curl

# Stage 2: Main n8n image
FROM n8nio/n8n:latest
USER root

COPY --from=alpine-builder /usr/bin /usr/bin
COPY --from=alpine-builder /usr/lib /usr/lib
COPY --from=alpine-builder /lib /lib
COPY --from=alpine-builder /usr/share /usr/share

# ✅ Puppeteer/Chromium এর জন্য দরকারি সব প্যাকেজ (verified against n8n-nodes-puppeteer official Dockerfile)
RUN apk add --no-cache \
    chromium nss glib freetype freetype-dev harfbuzz \
    ca-certificates ttf-freefont udev ttf-liberation font-noto-emoji

# ✅ Puppeteer কে বলা হচ্ছে নিজে Chrome ডাউনলোড না করে Alpine chromium ব্যবহার করতে
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# ✅ node-html-to-image গ্লোবালি ইন্সটল (n8n base image এর NODE_PATH এটা অটো ডিটেক্ট করবে)
RUN npm install -g node-html-to-image

RUN mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

USER node
