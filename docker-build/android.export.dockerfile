FROM gdsodium-android:latest AS export

COPY docker-build/templates/android_*.apk /templates
COPY demo /project
COPY keystores /keystores

WORKDIR /project
RUN godot --headless --export-release Android build.apk


FROM scratch AS binaries
COPY --from=export /project/build.apk* /
