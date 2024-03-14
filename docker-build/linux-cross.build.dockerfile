FROM gdsodium-linux-cross:latest AS build

COPY godot-cpp /extension/godot-cpp
COPY libsodium /extension/libsodium
COPY src /extension/src
COPY *SConstruct /extension/

COPY docker-build/*.sh /usr/local/bin
RUN ln -s /usr/local/bin/cc.sh /usr/local/bin/g++

WORKDIR /extension

# ARM32 and RISC-V 64 are not enabled as Godot does not actually build for them
# See https://github.com/godotengine/godot/issues/88634

# RISC-V 32 is not supported as Debian does not have a cross-compiler for it

RUN sconsbuild.sh linux aarch64-linux-gnu-gcc armv8-pc-linux-gnu arm64
#RUN sconsbuild.sh linux arm-linux-gnueabi-gcc armv7-pc-linux-gnu arm32
RUN sconsbuild.sh linux powerpc-linux-gnu-gcc powerpc64-pc-linux-gnu ppc64
RUN sconsbuild.sh linux powerpc-linux-gnu-gcc powerpc-pc-linux-gnu ppc32
#RUN sconsbuild.sh linux riscv64-linux-gnu-gcc riscv64-pc-linux-gnu rv64
#RUN sconsbuild.sh linux riscv-linux-gnu-gcc riscv32-pc-linux-gnu rv32


FROM scratch AS binaries
COPY --from=build /output/* /
