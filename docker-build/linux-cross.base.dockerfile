FROM gdsodium-debian:latest

RUN apt update \
    && apt install -y \
        crossbuild-essential-armel \
        crossbuild-essential-powerpc \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]