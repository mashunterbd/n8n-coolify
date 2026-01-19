# Stage 1: Alpine static bootstrap
FROM alpine:3.19 AS alpine-static

# Pull static apk tools
RUN apk add --no-cache apk-tools-static

# Stage 2: n8n base
FROM n8nio/n8n:latest

USER root

# Copy static apk + libs from alpine
COPY --from=alpine-static /sbin/apk.static /sbin/apk.static
COPY --from=alpine-static /sbin/apk /sbin/apk
COPY --from=alpine-static /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=alpine-static /usr/lib/libcrypto.so* /usr/lib/
COPY --from=alpine-static /usr/lib/libssl.so* /usr/lib/
COPY --from=alpine-static /usr/lib/libapk* /usr/lib/

# Setup apk environment (no need to install alpine-release or others)
RUN mkdir -p /etc/apk && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.19/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories && \
    chmod +x /sbin/apk && \
    ln -sf /sbin/apk /usr/local/bin/apk && \
    ln -sf /sbin/apk.static /usr/local/bin/apk.static && \
    apk update && \
    apk add --no-cache poppler-utils ffmpeg ghostscript curl && \
    mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

USER node
