# Ookla speedtest JSON result -> one InfluxDB line protocol line.
# Usage: speedtest -f json | jq -r --arg host <name> -f to-lp.jq

# Tag values: escape space, comma, equals; empty values are invalid line protocol.
def tag: tostring | if . == "" then "unknown" else gsub("(?<c>[ ,=])"; "\\\(.c)") end;
def str: "\"" + (tostring | gsub("(?<c>[\"\\\\])"; "\\\(.c)")) + "\"";
def mbps: . * 8 / 1000000;   # bandwidth is bytes/s
def int: if . == null then null else "\(.)i" end;
def opt(f): if . == null then null else f end;

{
  host: $host,
  server_id: .server.id,
  server_name: .server.name,
  server_location: .server.location,
  isp: .isp
} as $tags
| {
  download: (.download.bandwidth | mbps),
  upload: (.upload.bandwidth | mbps),
  ping: .ping.latency,
  jitter: .ping.jitter,
  ping_low: .ping.low,
  ping_high: .ping.high,
  download_latency: .download.latency.iqm,
  upload_latency: .upload.latency.iqm,
  packet_loss: .packetLoss,
  download_bytes: (.download.bytes | int),
  upload_bytes: (.upload.bytes | int),
  external_ip: (.interface.externalIp | opt(str)),
  result_url: (.result.url | opt(str))
} as $fields
| "speedtest,"
  + ($tags | to_entries | map("\(.key)=\(.value | tag)") | join(","))
  + " "
  + ($fields | to_entries | map(select(.value != null) | "\(.key)=\(.value)") | join(","))
  + " \(.timestamp | fromdateiso8601)"
