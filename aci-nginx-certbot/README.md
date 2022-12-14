# ACI with Nginx and Certbot (MYSQL and SQLite)

> WIP: this configuration is not working. The `docker compose up` command stuck on creating the containers.

Demo Torrust Tracker deployment configuration using [Azure Container Instances](https://azure.microsoft.com/en-us/products/container-instances/) and docker-compose.

- Nginx as a reverse proxy
- Certbot
- Tracker with SQLite or MySQL
- Mysql

## Requirements

- Docker 20.10.21
- Azure-cli 2.43.0

## Deploy

Follow the [Docker guide to deploy containers on Azure Container Instances](https://docs.docker.com/cloud/aci-integration/).

Test your Azure client with:

```s
az login
az group list
```

Create a new resource group:

```s
az group create --name tracker-josecelano-com --location germanywestcentral
```

Create a new docker ACI context for the previously generated resource group:

```s
docker context create aci tracker-josecelano-com --resource-group tracker-josecelano-com --location germanywestcentral
```

You can list your contexts with `docker context ls`.

Create a new storage account:

```s
az storage account create \
  --name trackerjosecelanocom \
  --resource-group tracker-josecelano-com \
  --location germanywestcentral \
  --sku Standard_RAGRS \
  --kind StorageV2
```

Create the volumes:

```s
docker --context tracker-josecelano-com volume create tracker-josecelano-com-nginx-conf       --storage-account trackerjosecelanocom
docker --context tracker-josecelano-com volume create tracker-josecelano-com-letsencrypt-conf --storage-account trackerjosecelanocom
docker --context tracker-josecelano-com volume create tracker-josecelano-com-certbot-www      --storage-account trackerjosecelanocom
docker --context tracker-josecelano-com volume create tracker-josecelano-com-tracker-storage  --storage-account trackerjosecelanocom
docker --context tracker-josecelano-com volume create tracker-josecelano-com-mysql-data       --storage-account trackerjosecelanocom
```

Upload files to Azure "file-shares" using the Azure control panel:

- `volumes\tracker-storage\config\config.[mysql|sqlite].toml` to file-share "tracker-josecelano-com-nginx-conf" in folder `config\config.toml`.
- `volumes\nginx-conf\app.conf` to to file-share "tracker-josecelano-com-tracker-storage" in root folder.

Deploy and update (SQLite or MySQL):

```s
docker --context tracker-josecelano-com compose --file docker-compose.sqlite.yaml up
docker --context tracker-josecelano-com compose --file docker-compose.mysql.yaml up
```

Stop containers:

```s
docker --context tracker-josecelano-com compose --file docker-compose.sqlite.yaml down
docker --context tracker-josecelano-com compose --file docker-compose.mysql.yaml down
```

## Troubleshooting

Resource not available error:

```s
[+] Running 0/1
 ⠿ Group tracker-josecelano-com  Error                                                                                                                             63.8s
containerinstance.ContainerGroupsClient#CreateOrUpdate: Failure sending request: StatusCode=0 -- Original Error: autorest/azure: Service returned an error. Status=<nil> Code="ServiceUnavailable" Message="The requested resource is not available in the location 'eastus' at this moment. Please retry with a different resource request or in another location. Resource requested: '5' CPU '4.1' GB memory 'Linux' OS"
```

Limits for Germany West Central are CPU 4, Memory (GB) 16.

More info:

- <https://learn.microsoft.com/en-us/azure/container-instances/container-instances-troubleshooting#resource-not-available-error>
- <https://learn.microsoft.com/en-us/azure/container-instances/container-instances-container-groups#minimum-and-maximum-allocation>

## Links

- [Deploying Docker containers on Azure](https://docs.docker.com/cloud/aci-integration/).
- [Tutorial: Deploy a multi-container group using Docker Compose](https://learn.microsoft.com/en-us/azure/container-instances/tutorial-docker-compose).
- [Container Resources](https://docs.docker.com/cloud/aci-compose-features/#container-resources).
- [Resource availability for Azure Container Instances in Azure regions](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-region-availability).
