# Stage 1: Build helper using Alpine
FROM alpine:3.19 AS alpine-builder

# Install all required packages including poppler-utils
RUN apk add --no-cache poppler-utils ffmpeg ghostscript curl

# Stage 2: Main n8n image
FROM n8nio/n8n:latest

USER root

# Copy all binaries, libraries, and data from Alpine builder
COPY --from=alpine-builder /usr/bin /usr/bin
COPY --from=alpine-builder /usr/lib /usr/lib
COPY --from=alpine-builder /lib /lib
COPY --from=alpine-builder /usr/share /usr/share

# Create working directories with full permissions
RUN mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

USER node
