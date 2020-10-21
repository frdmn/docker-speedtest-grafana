const execa = require("execa");
const Influx = require("influx");
const delay = require("delay");

process.env.INFLUXDB_HOST = (process.env.INFLUXDB_HOST) ? process.env.INFLUXDB_HOST : 'influxdb';
process.env.INFLUXDB_DB = (process.env.INFLUXDB_DB) ? process.env.INFLUXDB_DB : 'speedtest';
process.env.INFLUXDB_USERNAME = (process.env.INFLUXDB_DB) ? process.env.INFLUXDB_DB : 'root';
process.env.INFLUXDB_PASSWORD = (process.env.INFLUXDB_DB) ? process.env.INFLUXDB_DB : 'root';
process.env.SPEEDTEST_HOST = (process.env.SPEEDTEST_HOST) ? process.env.SPEEDTEST_HOST : 'local';
process.env.SPEEDTEST_INTERVAL = (process.env.SPEEDTEST_INTERVAL) ? process.env.SPEEDTEST_INTERVAL : 3600;
process.env.SPEEDTEST_ENHANCED_LOGGING = (process.env.SPEEDTEST_ENHANCED_LOGGING) ? process.env.SPEEDTEST_ENHANCED_LOGGING : 'false';
process.env.INFLUX_MEASUREMENT = (process.env.INFLUX_MEASUREMENT) ? process.env.INFLUX_MEASUREMENT : 'results';
const enhancedLogging = (process.env.SPEEDTEST_ENHANCED_LOGGING.toLowerCase() != 'false') ? true : false;

const bitToMbps = bit => (bit / 1000 / 1000) * 8;

const log = (message, severity = "Info") =>
  console.log(`[${severity.toUpperCase()}][${new Date()}] ${message}`);

const getSpeedMetrics = async () => {
  const args = (process.env.SPEEDTEST_SERVER) ?
    [ "--accept-license", "--accept-gdpr", "-f", "json", "--server-id=" + process.env.SPEEDTEST_SERVER] :
    [ "--accept-license", "--accept-gdpr", "-f", "json" ];

  const { stdout } = await execa("speedtest", args);
  const result = JSON.parse(stdout);

  return result;
};

const pushToInflux = async (influx, metrics) => {
  var points = {};
  if (enhancedLogging) {
    //  Enhanced Logging
    // Create InfluxDB data point with all the JSON data in a single measurement. Note in enhanced logging the data is written as-is with no conversion from bitsToMbps
    // There's likely a better way of just cycling through the JSON and converting to fields rather than specifying all fields directly below?

    points = [{
      measurement: process.env.INFLUX_MEASUREMENT,
      tags: { host: process.env.SPEEDTEST_HOST },
      fields: {
        type: metrics.type,
        timestamp: metrics.timestamp,
        ping_jitter: metrics.ping.jitter,
        ping_latency: metrics.ping.latency,
        download_bandwidth: metrics.download.bandwidth,
        download_bytes: metrics.download.bytes,
        download_elapsed: metrics.download.elapsed,
        upload_bandwidth: metrics.upload.bandwidth,
        upload_bytes: metrics.upload.bytes,
        upload_elapsed: metrics.upload.elapsed,
        packetLoss: metrics.packetLoss,
        isp: metrics.isp,
        interface_internalIp: metrics.interface.internalIp,
        interface_name: metrics.interface.name,
        interface_macAddr: metrics.interface.macAddr,
        interface_isVpn: metrics.interface.isVpn,
        interface_externalIp: metrics.interface.externalIp,
        server_id: metrics.server.id,
        server_name: metrics.server.name,
        server_location: metrics.server.location,
        server_country: metrics.server.country,
        server_host: metrics.server.host,
        server_port: metrics.server.port,
        server_ip: metrics.server.ip,
        result_id: metrics.result.id,
        result_url: metrics.result.url
      }
    }];

  } else {
    //  Legacy logging

    legacy_metrics = {
      upload: bitToMbps(metrics.upload.bandwidth),
      download: bitToMbps(metrics.download.bandwidth),
      ping: metrics.ping.latency
    };

    points = Object.entries(legacy_metrics).map(([measurement, value]) => ({
      measurement,
      tags: { host: process.env.SPEEDTEST_HOST },
      fields: { value }
    }));

  }

  await influx.writePoints(points);
};

(async () => {
  try {
    const influx = new Influx.InfluxDB({
      host: process.env.INFLUXDB_HOST,
      database: process.env.INFLUXDB_DB,
      username: process.env.INFLUXDB_USERNAME,
      password: process.env.INFLUXDB_PASSWORD,
    });

    while (true) {
      log("Starting speedtest...");
      const speedMetrics = await getSpeedMetrics();

      log(`Speedtest results - Server: ${speedMetrics.server.name} (${speedMetrics.server.location}, ${speedMetrics.server.country}), Download: ${(bitToMbps(speedMetrics.download.bandwidth)).toFixed(2)}Mbps, Upload: ${(bitToMbps(speedMetrics.upload.bandwidth)).toFixed(2)}Mbps, Ping: ${(speedMetrics.ping.latency).toFixed(2)}ms`);

      await pushToInflux(influx, speedMetrics);

      log(`Sleeping for ${process.env.SPEEDTEST_INTERVAL} seconds...`);
      await delay(process.env.SPEEDTEST_INTERVAL * 1000);
    }
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
})();
