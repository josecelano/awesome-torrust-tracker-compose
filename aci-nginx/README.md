# ACI with Nginx/Certbot/Mysql

Demo Torrust Tracker deployment configuration using [Azure Container Instances](https://azure.microsoft.com/en-us/products/container-instances/) and docker-compose.

- Nginx as a reverse proxy
- Tracker with SQLite

> WIP: this configuration is not working. The container instance gets stuck on "Updating" the containers without a public IP.

```s
$ docker ps
CONTAINER ID        IMAGE                                                       COMMAND             STATUS              PORTS
aci-nginx_nginx     registry.hub.docker.com/library/nginx:1.23                                      Running             0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:1313->1313/tcp, 0.0.0.0:7171->7171/tcp
aci-nginx_tracker   registry.hub.docker.com/josecelano/torrust-tracker:docker                       Running             0.0.0.0:1212->1212/tcp, 0.0.0.0:7070->7070/tcp, 0.0.0.0:6969->6969/udp
```

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
docker --context tracker-josecelano-com compose --file docker-compose.sqlite.yaml up
```
