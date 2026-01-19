# Stage 1: Prepare all needed packages in Alpine
FROM alpine:3.19 AS alpine-builder

RUN apk add --no-cache poppler-utils ffmpeg ghostscript curl

# Stage 2: Main n8n image (lightweight)
FROM n8nio/n8n:latest

USER root

# Copy necessary binaries & libs from Alpine builder stage
COPY --from=alpine-builder /usr/bin/pdftotext /usr/bin/pdftotext
COPY --from=alpine-builder /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=alpine-builder /usr/bin/gs /usr/bin/gs
COPY --from=alpine-builder /usr/bin/curl /usr/bin/curl

# Copy required shared libraries dynamically linked to these binaries
COPY --from=alpine-builder /lib/ld-musl-x86_64.so.1 /lib/
COPY --from=alpine-builder /usr/lib /usr/lib
COPY --from=alpine-builder /lib /lib

# Create /shared structure and fix permissions
RUN mkdir -p /shared/tmp /shared/pdf && chmod -R 777 /shared

USER node
