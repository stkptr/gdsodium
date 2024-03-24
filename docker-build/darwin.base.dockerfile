FROM gdsodium-debian:latest
#FROM debian:12.5

RUN apt update \
    && apt install -y \
        cmake clang bison flex xz-utils libfuse-dev libudev-dev pkg-config \
        libc6-dev-i386 libcap2-bin git git-lfs libglu1-mesa-dev libcairo2-dev \
        libgl1-mesa-dev libtiff5-dev libfreetype6-dev libxml2-dev \
        libegl1-mesa-dev libfontconfig1-dev libbsd-dev libxrandr-dev \
        libxcursor-dev libgif-dev libpulse-dev libavformat-dev libavcodec-dev \
        libswresample-dev libdbus-1-dev libxkbfile-dev libssl-dev llvm-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --recursive --depth 1 https://github.com/darlinghq/darling.git \
    && mkdir darling/build

WORKDIR /darling/build
RUN cmake .. && make -j$(nproc)
RUN make install
WORKDIR /
RUN rm -rf darling

# Requires --privileged
CMD ["bash", "-c", "DARLING_NOOVERLAYFS=1 darling shell"]
