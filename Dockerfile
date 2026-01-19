# Stage 1: copy apk and required libraries from Alpine
FROM alpine:3.23 AS alpine

# Stage 2: main n8n image
FROM n8nio/n8n:latest

USER root

# Copy apk binaries and dependencies from Alpine
COPY --from=alpine /sbin/apk /sbin/apk
COPY --from=alpine /lib/ld-musl-x86_64.so.1 /lib/
COPY --from=alpine /usr/lib/libapk.so* /usr/lib/

# Add Alpine repository sources manually (Coolify-safe)
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.23/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.23/community" >> /etc/apk/repositories && \
    chmod +x /sbin/apk && \
    ln -sf /sbin/apk /usr/local/bin/apk && \
    apk update && apk add --no-cache poppler-utils ffmpeg ghostscript curl && \
    mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

USER node
