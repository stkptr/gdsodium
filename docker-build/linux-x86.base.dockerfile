FROM gdsodium-zig:latest

RUN apt update \
    && apt install -y \
        g++-multilib \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
