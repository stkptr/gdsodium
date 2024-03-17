FROM debian:12.5

RUN apt update \
    && apt install -y build-essential python3-pip wget unzip git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --break-system-packages scons

ENV GDBASE https://github.com/godotengine/godot/releases/download/
ENV GDFILE 4.2.1-stable/Godot_v4.2.1-stable_linux.x86_64.zip
RUN wget -O godot.zip "${GDBASE}/${GDFILE}" \
    && unzip godot.zip \
    && rm -f godot.zip \
    && mv Godot_* /usr/local/bin/godot

CMD ["bash"]
