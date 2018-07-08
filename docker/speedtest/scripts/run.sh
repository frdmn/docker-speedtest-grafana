#!/bin/bash

while :; do
	echo "[Info][$(date)] Starting speedtest..."
	OUTPUT=$(/app/speedtest_cli.py)
	DOWNLOAD=$(echo "${OUTPUT}" | grep "Download:" | awk -F " " '{print $2}')
	UPLOAD=$(echo "$OUTPUT" | grep "Upload:" | awk -F " " '{print $2}')
	echo "[Info][$(date)] Speedtest results - Download: ${DOWNLOAD}, Upload: ${UPLOAD}"
	curl -sL -XPOST 'http://influxdb:8086/write?db=speedtest' --data-binary "download,host=local value=${DOWNLOAD}"
	curl -sL -XPOST 'http://influxdb:8086/write?db=speedtest' --data-binary "upload,host=local value=${UPLOAD}"
	echo "[Info][$(date)] Sleeping for ${SPEEDTEST_INTERVAL} seconds..."
	sleep ${SPEEDTEST_INTERVAL}
done
