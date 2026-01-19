# Base n8n image
FROM n8nio/n8n:latest

USER root

# Download and install static apk-tools (no dependencies needed)
RUN wget -q https://dl-cdn.alpinelinux.org/alpine/v3.23/main/x86_64/apk-tools-static-2.14.8-r0.apk && \
    tar -xzf apk-tools-static-2.14.8-r0.apk && \
    ./sbin/apk.static -X https://dl-cdn.alpinelinux.org/alpine/v3.23/main \
        -U --allow-untrusted add apk-tools && \
    rm -rf sbin apk-tools-static-2.14.8-r0.apk && \
    ln -sf /sbin/apk /usr/local/bin/apk && \
    apk update && apk add --no-cache poppler-utils ffmpeg ghostscript curl && \
    mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

USER node
