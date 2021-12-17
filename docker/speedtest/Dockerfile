FROM debian:11-slim AS get-speedtest
RUN apt-get update && apt-get install -y curl gnupg apt-transport-https dirmngr lsb-release 
RUN apt-get install -y debian-archive-keyring &> /dev/null
RUN curl -s https://install.speedtest.net/app/cli/install.deb.sh | bash
RUN apt-get update
RUN apt-get install speedtest

FROM alpine as install-dependencies
RUN apk add --no-cache npm
WORKDIR /build
COPY . .
RUN npm ci

FROM alpine as prod-stage
RUN apk add --no-cache nodejs
LABEL maintainer="Jonas Friedmann <j@frd.mn>"

WORKDIR /usr/src/app

CMD [ "node", "index.js" ]

COPY --from=get-speedtest /usr/bin/speedtest /usr/bin/speedtest
COPY --from=install-dependencies /build .
