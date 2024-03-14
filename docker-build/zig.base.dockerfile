FROM gdsodium-debian:latest

ENV ZIGURL https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz
RUN wget -qO- "${ZIGURL}" | tar -xvJ \
    && mv /zig*/zig /usr/local/bin \
    && mv /zig*/lib /usr/local/lib/zig \
    && rm -rf /zig*

CMD ["bash"]