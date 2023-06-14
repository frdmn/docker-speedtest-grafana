FROM debian:11-slim AS get-speedtest
RUN apt-get update && apt-get install -y curl gnupg apt-transport-https dirmngr lsb-release
RUN apt-get install -y debian-archive-keyring &> /dev/null
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
RUN apt-get update
RUN apt-get install -y speedtest

FROM alpine as install-dependencies
RUN apk add --no-cache npm
WORKDIR /build
COPY . .
RUN npm ci

FROM alpine as prod-stage
RUN apk add --no-cache nodejs

WORKDIR /usr/src/app

CMD [ "node", "index.js" ]

COPY --from=get-speedtest /usr/bin/speedtest /usr/bin/speedtest
COPY --from=install-dependencies /build .
