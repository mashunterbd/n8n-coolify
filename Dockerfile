# Stage 1: Alpine tools provider
FROM alpine:3.19 AS alpine-tools

# Install required base tools (wget, tar, xz)
RUN apk add --no-cache wget tar xz

# Stage 2: Main n8n image
FROM n8nio/n8n:latest

USER root

# Copy apk, wget, tar, and xz binaries from alpine stage
COPY --from=alpine-tools /sbin/apk /sbin/apk
COPY --from=alpine-tools /lib/ld-musl-x86_64.so.1 /lib/
COPY --from=alpine-tools /usr/lib/libapk.so* /usr/lib/
COPY --from=alpine-tools /usr/bin/wget /usr/bin/wget
COPY --from=alpine-tools /bin/tar /bin/tar
COPY --from=alpine-tools /usr/bin/xz /usr/bin/xz

# Add repositories and install your required tools
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.19/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories && \
    chmod +x /sbin/apk && \
    ln -sf /sbin/apk /usr/local/bin/apk && \
    apk update && apk add --no-cache poppler-utils ffmpeg ghostscript curl && \
    mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

USER node
