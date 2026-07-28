# Stage 1: Build helper using Alpine
FROM alpine:3.19 AS alpine-builder
# ✅ poppler + puppeteer/chromium এর সব প্যাকেজ একসাথে এখানেই ইন্সটল (apk শুধু এখানেই কাজ করে)
RUN apk add --no-cache \
    poppler-utils ffmpeg ghostscript curl \
    chromium nss glib freetype freetype-dev harfbuzz \
    ca-certificates ttf-freefont udev ttf-liberation font-noto-emoji

# Stage 2: Main n8n image
FROM n8nio/n8n:latest
USER root

# ✅ এখন Stage 1 থেকে chromium সহ সবকিছু কপি হয়ে যাবে (কোনো apk লাগবে না)
COPY --from=alpine-builder /usr/bin /usr/bin
COPY --from=alpine-builder /usr/lib /usr/lib
COPY --from=alpine-builder /lib /lib
COPY --from=alpine-builder /usr/share /usr/share

# ✅ Puppeteer কে বলা হচ্ছে নিজে Chrome ডাউনলোড না করে কপি হওয়া chromium ব্যবহার করতে
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# ✅ npm install -g এখানে ঠিক আছে — এটা apk-এর উপর নির্ভর করে না, npm ইমেজে আগে থেকেই আছে
RUN npm install -g node-html-to-image

# ✅ Puppeteer community node + its extra plugins (this is the actual fix for your error)
RUN npm install -g \
    n8n-nodes-puppeteer \
    puppeteer-core \
    puppeteer-extra \
    puppeteer-extra-plugin-user-data-dir \
    puppeteer-extra-plugin-stealth

RUN mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

USER node
