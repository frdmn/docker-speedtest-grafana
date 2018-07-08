#!/bin/bash

while :; do
	echo "[Info][$(date)] Starting speedtest..."
	JSON=$(speed-test -j)
	DOWNLOAD=$(echo "${JSON}" | json download)
	UPLOAD=$(echo "$JSON" | json upload)
	PING=$(echo "${JSON}" | json ping)
	echo "[Info][$(date)] Speedtest results - Download: ${DOWNLOAD}, Upload: ${UPLOAD}, Ping: ${PING}"
	curl -sL -XPOST 'http://influxdb:8086/write?db=speedtest' --data-binary "download,host=local value=${DOWNLOAD}"
	curl -sL -XPOST 'http://influxdb:8086/write?db=speedtest' --data-binary "upload,host=local value=${UPLOAD}"
	curl -sL -XPOST 'http://influxdb:8086/write?db=speedtest' --data-binary "ping,host=local value=${PING}"
	echo "[Info][$(date)] Sleeping for ${SPEEDTEST_INTERVAL} seconds..."
	sleep ${SPEEDTEST_INTERVAL}
done
