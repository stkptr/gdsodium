# syntax=docker/dockerfile:1-labs
FROM gdsodium-darwin:latest

# xcode-select always partially fails, || true ignores the partial failure
RUN --security=insecure DARLING_NOOVERLAYFS=1 darling shell \
    /bin/sh -c "yes | xcode-select --install" || true

CMD ["bash", "-c", "DARLING_NOOVERLAYFS=1 darling shell"]
