FROM gdsodium-debian:latest

RUN apt update \
    && apt install -y \
        crossbuild-essential-arm64 \
        crossbuild-essential-armel \
        crossbuild-essential-powerpc \
        g++-riscv64-linux-gnu gcc-riscv64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]