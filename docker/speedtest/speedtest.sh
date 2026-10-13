#!/bin/sh
# Runs Ookla speedtests and writes the results to InfluxDB (v1 /write API, also served by InfluxDB 3).
set -u

: "${INFLUXDB_URL:=http://influxdb:8086}"
: "${INFLUXDB_DB:=speedtest}"
: "${INFLUXDB_USERNAME:=speedtest}"
: "${INFLUXDB_PASSWORD:?INFLUXDB_PASSWORD is required}"
: "${SPEEDTEST_HOST:=local}"
: "${SPEEDTEST_SERVER:=}"
: "${SPEEDTEST_INTERVAL:=3600}"
: "${SPEEDTEST_CRON:=}"
: "${SPEEDTEST_TIMEOUT:=300}"

log() { echo "[$(date +%FT%T%z)] $*"; }

# One test against server $1 (empty = Ookla picks). Failures are logged, never fatal.
test_server() {
  log "Starting speedtest${1:+ against server $1}..."
  json=$(timeout "$SPEEDTEST_TIMEOUT" speedtest --accept-license --accept-gdpr -f json ${1:+--server-id="$1"} 2>/tmp/speedtest.err)
  rc=$?
  if [ $rc -eq 143 ]; then
    log "ERROR: speedtest timed out after $SPEEDTEST_TIMEOUT seconds"
    return
  elif [ $rc -ne 0 ]; then
    log "ERROR: speedtest failed (exit code $rc): $(cat /tmp/speedtest.err)"
    return
  fi
  if ! line=$(printf '%s' "$json" | jq -r --arg host "$SPEEDTEST_HOST" -f /app/to-lp.jq 2>&1); then
    log "ERROR: unexpected speedtest output: $json ($line)"
    return
  fi
  log "$(printf '%s' "$json" | jq -r '"Result: download \(.download.bandwidth * 8 / 1e4 | round / 100) Mbps, upload \(.upload.bandwidth * 8 / 1e4 | round / 100) Mbps, ping \(.ping.latency) ms, server \(.server.name) (\(.server.id))"')"
  if ! out=$(printf '%s\n' "$line" | curl -sS --fail-with-body -m 30 -u "$INFLUXDB_USERNAME:$INFLUXDB_PASSWORD" \
      --data-binary @- "$INFLUXDB_URL/write?db=$INFLUXDB_DB&precision=s" 2>&1); then
    log "ERROR: writing to InfluxDB failed: $out"
  fi
}

# All configured servers one after another, so tests never overlap.
run() {
  if [ -z "$SPEEDTEST_SERVER" ]; then
    test_server ""
  else
    for id in $(echo "$SPEEDTEST_SERVER" | tr ',' ' '); do test_server "$id"; done
  fi
}

if [ "${1:-}" = run ]; then
  run
elif [ -n "$SPEEDTEST_CRON" ]; then
  export -p > /tmp/env   # busybox crond does not pass the environment to jobs
  mkdir -p /tmp/crontabs
  echo "$SPEEDTEST_CRON . /tmp/env; /app/speedtest.sh run > /proc/1/fd/1 2>&1" > /tmp/crontabs/root
  log "Scheduled speedtests: $SPEEDTEST_CRON"
  exec crond -f -c /tmp/crontabs
else
  while :; do
    run
    log "Sleeping for $SPEEDTEST_INTERVAL seconds..."
    sleep "$SPEEDTEST_INTERVAL"
  done
fi
