# docker-speedtest

Docker setup consisting out of Grafana, InfluxDB and a speedtest.net CLI tester.
![](https://i.imgur.com/FCRUni9.png)


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
