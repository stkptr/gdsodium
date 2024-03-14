FROM gdsodium-zig:latest

RUN apt update \
    && apt install -y mingw-w64 \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
