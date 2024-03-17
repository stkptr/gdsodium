FROM gdsodium-zig:latest

ENV EMVER 3.1.39
ENV NODEVER 16.20.0_64bit

RUN git clone --depth 1 https://github.com/emscripten-core/emsdk.git
WORKDIR /emsdk
RUN ./emsdk install ${EMVER}
RUN ./emsdk activate ${EMVER}

ENV PATH /emsdk:/emsdk/upstream/emscripten:/emsdk/node/${NODEVER}/bin:${PATH}

WORKDIR /

CMD ["bash"]
