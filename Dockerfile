# Base n8n image
FROM n8nio/n8n:latest

# ---- Copy apk tools from Alpine ----
FROM alpine:3.23 AS alpine
# (We’ll use this only as a source layer to copy apk binaries)

# ---- Main build ----
FROM n8nio/n8n:latest

# Copy apk and its shared libraries from Alpine layer
COPY --from=alpine /sbin/apk /sbin/apk
COPY --from=alpine /usr/lib/libapk.so* /usr/lib/

# Switch to root to install packages
USER root

# Add Alpine repositories (needed for apk to know where to pull packages from)
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.23/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.23/community" >> /etc/apk/repositories

# Install only the tool you need
RUN apk add --no-cache poppler-utils && \
    rm -rf /var/cache/apk/*

# Optional: create /shared/tmp and /shared/pdf folders with full permissions
RUN mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

# Switch back to the n8n (node) user
USER node
