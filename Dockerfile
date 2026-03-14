FROM ubuntu:22.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY aud2txt /app/
COPY tests/ /app/tests/
RUN chmod +x /app/aud2txt

ENTRYPOINT ["/app/aud2txt"]
