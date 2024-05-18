Try write a docker compose file to host a full environment on one server;

## zabbix
docker run -d \
           -p 10051:10051 \
           -p 10052:10052 \
           -p 80:80       \
           -p 2812:2812   \
           --name zabbix  \
           berngp/docker-zabbix
or

https://hub.docker.com/r/monitoringartist/zabbix-xxl/

## grafana

## jenkins

## rundeck

## foreman

## elk stack

## gitlab
