FROM alpine:3.24

ARG TARGETARCH
ARG TARGETVARIANT

# Ookla publishes no checksums; bump the version and all three hashes together.
RUN apk add --no-cache curl jq tini tzdata \
 && case "${TARGETARCH}${TARGETVARIANT}" in \
      amd64) arch=x86_64  sha=5690596c54ff9bed63fa3732f818a05dbc2db19ad36ed68f21ca5f64d5cfeeb7 ;; \
      arm64) arch=aarch64 sha=3953d231da3783e2bf8904b6dd72767c5c6e533e163d3742fd0437affa431bd3 ;; \
      armv7) arch=armhf   sha=e45fcdebbd8a185553535533dd032d6b10bc8c64eee4139b1147b9c09835d08d ;; \
      *) echo "unsupported platform: ${TARGETARCH}${TARGETVARIANT}" >&2; exit 1 ;; \
    esac \
 && curl -fsSL -o /tmp/speedtest.tgz "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-${arch}.tgz" \
 && echo "${sha}  /tmp/speedtest.tgz" | sha256sum -c - \
 && tar xzf /tmp/speedtest.tgz -C /usr/local/bin speedtest \
 && rm /tmp/speedtest.tgz

WORKDIR /app
COPY speedtest.sh to-lp.jq ./

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/app/speedtest.sh"]
