FROM ubuntu:trusty
MAINTAINER Jonas Friedmann <j@frd.mn>

RUN mkdir -p /app

RUN apt-get update && apt-get install -y wget python curl

RUN wget https://raw.github.com/sivel/speedtest-cli/master/speedtest.py -O /app/speedtest/speedtest_cli.py
RUN chmod +x /app/speedtest_cli.py

ADD scripts/ /app/

CMD bash -c /app/run.sh
