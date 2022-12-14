# ACI with only the Torrust Tracker

Demo Torrust Tracker deployment configuration using [Azure Container Instances](https://azure.microsoft.com/en-us/products/container-instances/) and docker-compose.

- Torrust Tracker
- SQLite

## Deploy

> NOTICE: for basic instructions about how to deploy to ACI see [aci-nginx-certbot example](../aci-nginx-certbot).

Upload files to Azure "file-shares" using the Azure control panel:

- `volumes\tracker-storage\config\config.sqlite.toml` to file-share "tracker-josecelano-com-nginx-conf" in folder `config\config.toml`.
- `volumes\nginx-conf\app.conf` to to file-share "tracker-josecelano-com-tracker-storage" in root folder.

Deploy and update:

```s
docker --context tracker-josecelano-com compose --file docker-compose.sqlite.yaml up
```

Stop containers:

```s
docker --context tracker-josecelano-com compose --file docker-compose.sqlite.yaml down
```

After the deployment you can run `docker ps` to see the public IP:

```s
$ docker ps
CONTAINER ID          IMAGE                                                       COMMAND             STATUS              PORTS
aci-tracker_tracker   registry.hub.docker.com/josecelano/torrust-tracker:docker                       Running             20.113.54.210:1212->1212/tcp, 20.113.54.210:7070->7070/tcp, 20.113.54.210:6969->6969/udp
```

You can use the services with the public IP shown on the `docker ps` output. For example:

<http://20.113.54.210:1212/api/stats?token=MyAccessToken>
