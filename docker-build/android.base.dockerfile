FROM gdsodium-debian:latest

RUN apt update \
    && apt install -y openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME /usr/local/lib/android

ENV SDK_FILE commandlinetools-linux-11076708_latest.zip
ENV NDK_VERSION 23.2.8568313
ENV CMDLINE_TOOLS_VERSION latest
ENV BUILD_TOOLS_VERSION 34.0.0
ENV PLATFORMS_VERSION android-34
ENV CMAKE_VERSION 3.22.1

ENV ANDROID_NDK_HOME ${ANDROID_HOME}/ndk/${NDK_VERSION}/

RUN wget -O cli.zip "https://dl.google.com/android/repository/${SDK_FILE}" \
    && unzip cli.zip \
    && rm -f cli.zip \
    && mv /cmdline-tools ${ANDROID_HOME}

ENV PATH "${ANDROID_HOME}/bin:${PATH}"

RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses
RUN sdkmanager --sdk_root=${ANDROID_HOME} \
     "ndk;${NDK_VERSION}" "cmdline-tools;${CMDLINE_TOOLS_VERSION}" \
     "build-tools;${BUILD_TOOLS_VERSION}" "platforms;${PLATFORMS_VERSION}" \
     "cmake;${CMAKE_VERSION}" "platform-tools"

CMD ["bash"]
