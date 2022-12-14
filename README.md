# Awesome Torrust Tracker Compose

A curated list of Docker Compose samples to run and deploy [Torrust Tracker](https://github.com/torrust/torrust-tracker) using docker-compose.

These samples provide a starting point for how to integrate different services using a Compose file and to manage their deployment with Docker Compose.

## Samples of Docker Compose applications

- [Azure Container Instances only with Torrust Tracker](./aci-nginx/).
- [Azure Container Instances with Nginx/SQLite](./aci-nginx/). WIP.
- [Azure Container Instances with Nginx/Certbot/Mysql](./aci-nginx-certbot/). WIP.

## ACI notes

Some examples are using ACI (Azure Container Instances). The basic example with only one service works fine. But the other services using Nginx do not work yet.
The reason could be the low resource limit (4 CPUs for all running instances in the container group).
