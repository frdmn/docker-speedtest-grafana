# docker-speedtest

![](https://i.imgur.com/FCRUni9.png)

Docker setup consisting out of Grafana incl. a pre-configured dashboard, InfluxDB and a [speedtest.net CLI test](https://github.com/sindresorhus/speed-test) runner.

## Installation

1. Make sure you've installed all requirements
2. Clone this repository:

```shell
git clone https://github.com/frdmn/docker-speedtest
```

3. Create a copy of the sample `.env` file and adjust it at will:

```shell
cp .env.sample .env
```

4. Spin up the containers:

```shell
docker-compose up -d
```

## Configuration

You can make use of the following environment variables / configurations:

| Environment variable | Default value | Description
|----------------------|---------------|------------| 
| `GRAFANA_PORT` | `3000` | Port to bind Grafana webinterface on the host system |
| `SPEEDTEST_SPEEDTEST_INTERVAL` | `3600` | Interval/pause (in seconds) between speedtests |

## Usage

### Start/create services


```shell
$ docker-compose up -d
Creating speedtest_influxdb_1  ... done
Creating speedtest_grafana_1   ... done
Creating speedtest_speedtest_1 ... done
```

### Stop services

```shell
$ docker-compose stop
Stopping speedtest_influxdb_1  ... done
Stopping speedtest_grafana_1   ... done
Stopping speedtest_speedtest_1 ... done
```

### Upgrade services

```shell
$ docker-compose stop
$ docker-compose pull
$ docker-compose rm
$ docker-compose up -d
```

### Check logs

```shell
$ docker-compose logs -f
```

```shell
$ docker-compose logs -f grafana
```

## Contributing

1. Fork it
2. Create your feature branch:

```shell
git checkout -b feature/my-new-feature
```

3. Commit your changes:

```shell
git commit -am 'Add some feature'
```

4. Push to the branch:

```shell
git push origin feature/my-new-feature
```

5. Submit a pull request

## Requirements / Dependencies

* Docker (incl. `docker-compose`)

## Version

1.0.0

## License

[MIT](LICENSE)
