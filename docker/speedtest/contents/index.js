const execa = require("execa");
const Influx = require("influx");
const delay = require("delay");

const bitToMbps = bit => (bit / 1000 / 1000) * 8;

const log = (message, severity = "Info") =>
  console.log(`[${severity.toUpperCase()}][${new Date()}] ${message}`);

const getSpeedMetrics = async () => {
  const { stdout } = await execa("speedtest", [
    "--accept-license",
    "--accept-gdpr",
    "-f",
    "json"
  ]);
  const result = JSON.parse(stdout);
  return {
    upload: bitToMbps(result.upload.bandwidth),
    download: bitToMbps(result.download.bandwidth),
    ping: result.ping.latency
  };
};

const pushToInflux = async (influx, metrics) => {
  const points = Object.entries(metrics).map(([measurement, value]) => ({
    measurement,
    tags: { host: process.env.SPEEDTEST_HOST },
    fields: { value }
  }));

  await influx.writePoints(points);
};

(async () => {
  try {
    const influx = new Influx.InfluxDB({
      host: process.env.INFLUXDB_HOST,
      database: process.env.INFLUXDB_DB
    });

    while (true) {
      log("Starting speedtest...");
      const speedMetrics = await getSpeedMetrics();
      log(
        `Speedtest results - Download: ${speedMetrics.download}, Upload: ${speedMetrics.upload}, Ping: ${speedMetrics.ping}`
      );
      await pushToInflux(influx, speedMetrics);

      log(`Sleeping for ${process.env.SPEEDTEST_INTERVAL} seconds...`);
      await delay(process.env.SPEEDTEST_INTERVAL * 1000);
    }
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
})();
