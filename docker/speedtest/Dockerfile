FROM node:8
MAINTAINER Jonas Friedmann <j@frd.mn>

WORKDIR /usr/src/app

COPY . .

RUN npm install -g speed-test json

CMD [ "npm", "start" ]
