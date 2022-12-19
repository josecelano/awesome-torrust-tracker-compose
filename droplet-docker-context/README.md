# Digital Ocean Droplet with docker

This configuration allows you to deploy the [Torrust Tracker](https://github.com/torrust/torrust-tracker) to a [Digital Ocean](https://www.digitalocean.com/) [droplet](https://www.digitalocean.com/products/droplets).

You can deploy your dockerized tracker using:

- Your docker node in a [Digital Ocean](https://www.digitalocean.com/) virtual machine ([droplet](https://www.digitalocean.com/products/droplets)).
- [Docker contexts](https://docs.docker.com/engine/context/working-with-contexts/).

By following this guide you will be able to deploy the [Torrust Tracker](https://github.com/torrust/torrust-tracker) just by running a `docker-compose up` command:

```s
docker --context your-context compose up
```

This guide is based on [Daniel Wachtel's](https://danielwachtel.com/about) [article](https://danielwachtel.com/devops/deploying-multiple-dockerized-apps-digitalocean-docker-compose-contexts).

The installation uses [Nginx](https://nginx.org/) as a [reverse proxy](https://en.wikipedia.org/wiki/Reverse_proxy) with [certbot](https://certbot.eff.org/) to automatically generate and renew SSL Certificates.

## Requirements

In your local machine (from where you deploy the app):

- Docker version 20.10.21

In [Digital Ocean](https://www.digitalocean.com/):

- A droplet with 1vCPU, 1 GB Memory, 25 GB Disk and Ubuntu 22.10 x64 ($6/mo).
- Docker version 20.10.22.

You can install all you need on the droplet following [Daniel Wachtel's](https://danielwachtel.com/about) [article](https://danielwachtel.com/devops/deploying-multiple-dockerized-apps-digitalocean-docker-compose-contexts).

You will also need a domain if you want to use it instead of the droplet IP.

## Setup

You have to:

- Replace the domain `your-domain.com` with your domain in all templates.
- Create `.env` from the template `.env.template` and change the env var values.
- Create `config.yml` from the template `config.template.toml` and change some settings:

```toml
db_driver = "MySQL"
db_path = "mysql://db_user:db_user_secret_password@mysql:3306/torrust_tracker"
on_reverse_proxy = true
external_ip = "8.8.8.8"

[http_api.access_tokens]
admin = "MyAccessToken"
```

Use your public droplet IP for the `external_ip` and change the token for the API.

## Run it locally

Before deploying your app to the droplet you can test the configuration locally with:

```s
cd /tmp
git clone git@github.com:josecelano/awesome-torrust-tracker-compose.git
cd awesome-torrust-tracker-compose/droplet-docker-context
docker context use default
TORRUST_TRACKER_CONFIG=`cat config.toml` docker compose up
```

You should see something line:

```s
[+] Running 2/0
 ⠿ Container droplet-docker-context-mysql-1    Running                                                                                                   0.0s
 ⠿ Container droplet-docker-context-tracker-1  Recreated                                                                                                 0.0s
Attaching to droplet-docker-context-mysql-1, droplet-docker-context-tracker-1
droplet-docker-context-tracker-1  | Loading configuration from env var TORRUST_TRACKER_CONFIG
droplet-docker-context-tracker-1  | 2022-12-19T10:27:47.446410484+00:00 [torrust_tracker::logging][INFO] logging initialized.
droplet-docker-context-tracker-1  | 2022-12-19T10:27:47.446554389+00:00 [torrust_tracker::jobs::udp_tracker][INFO] Starting UDP server on: udp://0.0.0.0:6969
droplet-docker-context-tracker-1  | 2022-12-19T10:27:47.446562541+00:00 [torrust_tracker::jobs::tracker_api][INFO] Starting Torrust API server on: http://0.0.0.0:1212
droplet-docker-context-tracker-1  | 2022-12-19T10:27:47.446619238+00:00 [torrust_tracker::jobs::tracker_api][INFO] Torrust API server started
droplet-docker-context-tracker-1  | 2022-12-19T10:27:47.446794123+00:00 [torrust_tracker::jobs::http_tracker][INFO] Starting HTTP server on: http://0.0.0.0:7070
```

You can test, for example, that the API is running on <http://localhost:1212/api/stats?token=MyAccessToken>.

## Deploy to remote

If you did not have any problem following [Daniel Wachtel's](https://danielwachtel.com/about) [article](https://danielwachtel.com/devops/deploying-multiple-dockerized-apps-digitalocean-docker-compose-contexts) you should have a new context:

```s
$ docker context ls
NAME               TYPE  DESCRIPTION                              DOCKER ENDPOINT                              ... ORCHESTRATOR
default            moby  Current DOCKER_HOST based configuration  unix:///var/run/docker.sock                  ... swarm
desktop-linux      moby                                           unix:///home/you/.docker/desktop/docker.sock ... 
your-domain.com *  moby                                           ssh://deployer@your-domain.com               ... swarm
```

These are the most important commands.

Create the context:

```s
docker context create your-domain-com --docker "host=ssh://deployer@your-domain.site" --default-stack-orchestrator swarm 
```

I used the domain `your-domain-com` for the context name so that I can easily identify the environment.

Run the container on the remote context:

```s
TORRUST_TRACKER_CONFIG=`cat config.toml` docker --context your-domain-com compose up     <- If you want to see the logs
TORRUST_TRACKER_CONFIG=`cat config.toml` docker --context your-domain-com compose up -d  <- Detached mode
```

After running the containers you should see something like this (no detached mode):

```s
 TORRUST_TRACKER_CONFIG=`cat config.toml` docker --context your-domain-com compose up
[+] Running 2/0
 ⠿ Container droplet-docker-context-mysql-1    Created                                                                                                           0.0s
 ⠿ Container droplet-docker-context-tracker-1  Created                                                                                                           0.0s
Attaching to droplet-docker-context-mysql-1, droplet-docker-context-tracker-1
droplet-docker-context-mysql-1    | 2022-12-19 11:35:09+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.31-1.el8 started.
droplet-docker-context-mysql-1    | 2022-12-19 11:35:10+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
droplet-docker-context-mysql-1    | 2022-12-19 11:35:10+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.31-1.el8 started.
droplet-docker-context-tracker-1  | Loading configuration from env var TORRUST_TRACKER_CONFIG
droplet-docker-context-mysql-1    | '/var/lib/mysql/mysql.sock' -> '/var/run/mysqld/mysqld.sock'
droplet-docker-context-mysql-1    | 2022-12-19T11:35:11.310531Z 0 [Warning] [MY-011068] [Server] The syntax '--skip-host-cache' is deprecated and will be removed in a future release. Please use SET GLOBAL host_cache_size=0 instead.
droplet-docker-context-mysql-1    | 2022-12-19T11:35:11.316413Z 0 [Warning] [MY-010918] [Server] 'default_authentication_plugin' is deprecated and will be removed in a future release. Please use authentication_policy instead.
droplet-docker-context-mysql-1    | 2022-12-19T11:35:11.316797Z 0 [System] [MY-010116] [Server] /usr/sbin/mysqld (mysqld 8.0.31) starting as process 1
droplet-docker-context-mysql-1    | 2022-12-19T11:35:11.362503Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
droplet-docker-context-mysql-1    | 2022-12-19T11:35:11.820012Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
droplet-docker-context-mysql-1    | 2022-12-19T11:35:12.317656Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.
droplet-docker-context-mysql-1    | 2022-12-19T11:35:12.318414Z 0 [System] [MY-013602] [Server] Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.
droplet-docker-context-mysql-1    | 2022-12-19T11:35:12.323167Z 0 [Warning] [MY-011810] [Server] Insecure configuration for --pid-file: Location '/var/run/mysqld' in the path is accessible to all OS users. Consider choosing a different directory.
droplet-docker-context-mysql-1    | 2022-12-19T11:35:12.464430Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Bind-address: '::' port: 33060, socket: /var/run/mysqld/mysqlx.sock
droplet-docker-context-mysql-1    | 2022-12-19T11:35:12.465674Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.31'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server - GPL.
droplet-docker-context-tracker-1  | 2022-12-19T11:35:13.420535146+00:00 [torrust_tracker::logging][INFO] logging initialized.
droplet-docker-context-tracker-1  | 2022-12-19T11:35:13.425190055+00:00 [torrust_tracker::jobs::udp_tracker][INFO] Starting UDP server on: udp://0.0.0.0:6969
droplet-docker-context-tracker-1  | 2022-12-19T11:35:13.426406064+00:00 [torrust_tracker::jobs::http_tracker][INFO] Starting HTTP server on: http://0.0.0.0:7070
droplet-docker-context-tracker-1  | 2022-12-19T11:35:13.426741195+00:00 [torrust_tracker::jobs::tracker_api][INFO] Starting Torrust API server on: http://0.0.0.0:1212
droplet-docker-context-tracker-1  | 2022-12-19T11:35:13.427763652+00:00 [torrust_tracker::jobs::tracker_api][INFO] Torrust API server started
```

Stop the containers:

```s
docker --context your-domain-com compose down
```

> IMPORTANT!: the deployment could be slow. It can take a couple of minutes.

If you follow all the steps you should have access to your services:

- Tracker API: <https://tracker-api.your-domain.com/api/stats?token=MyAccessToken>
- HTTP tracker: <https://http-tracker.your-domain.com/announce>
- UDP tracker: <udp://udp-tracker.your-domain.com:6969>

NOTES:

- You have the [original Nginx configuration](./etc/nginx/sites-available/) and the [configuration after running certbot](./cerbot-sample-nginx/).
- I did not modify the Nginx configuration to redirect from www to non-www because I'm not using that subdomain.
- Certbot automatically redirects requests from port 80 to 443. So the API and the HTTP tracker stop working on port 80 when you run certbot to generate and setup SSL certificates.
- I did not change the firewall rules for the `docker` user. The article explains that docker bypasses `ufw` rules, so by default, ports used in docker-compose are publicly exposed. I did not do it because I could not set up a reverse proxy for the UDP tracker.

## Troubleshooting

Following the tutorial, some things did not work for me.

### Certbot installation

I had to install certbot following the [official guide](https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal) for Ubuntu.

```s
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

### UDP reverse proxy

I tried to set up a reverse proxy for the UDP tracker but it does not work. This was the configuration I tried:

```text
stream {
        log_format basic '$remote_addr [$time_local] '
                         '$protocol $status $bytes_sent $bytes_received '
                         '$session_time';
        access_log /var/log/nginx/access_stream.log basic;
        error_log /var/log/nginx/error_stream.log;
        upstream udp-tracker {
                server 127.0.0.1:6969;
        }
        server {
                listen 8080 udp;
                proxy_pass udp-tracker;
                proxy_responses 0;
        }
}
```

That's why I did not change the firewall to not expose all the `docker` user's ports directly.

### Problems connecting with qBittorrent

I'm using the [Transmission](https://transmissionbt.com/) to test the services. The [qBittorrent](https://www.qbittorrent.org/) client has a random behavior. Sometimes it does not connect to the trackers. It could be related to [this](https://github.com/qbittorrent/qBittorrent/issues/17909).

## Extra commands

Some commands that can be useful:

```s
sudo nginx -t                  <- check changes in Nginx config files
sudo systemctl restart nginx   <- restart Nginx
```

You can use `netcat` command to test the connection to the UDP tracker from your local machine:

```s
nc -u udp-tracker.your-domain.com 6969
```

Docker command with context:

```s
docker ‐‐context remote ps <- list containers on the remote context
docker context show        <- show current default context if no "‐‐context" option is used.
docker context use ...     <- change current default context
```

## Links

- [Deploying multiple dockerized apps to a single DigitalOcean droplet using docker-compose contexts](https://danielwachtel.com/devops/deploying-multiple-dockerized-apps-digitalocean-docker-compose-contexts) by  [Daniel Wachtel](https://github.com/mrdaniel).
- [To fix the Docker and UFW security flaw without disabling iptables](https://github.com/chaifeng/ufw-docker).

## Credits

I've just followed [Daniel Wachtel's](https://danielwachtel.com/about) [article](https://danielwachtel.com/devops/deploying-multiple-dockerized-apps-digitalocean-docker-compose-contexts) with the [Torrust Tracker](https://github.com/torrust/torrust-tracker) docker image.
