# UDP echo server on Digital Ocean Droplet

This is an echo UDP server for testing purposes.

## Run it locally

Run it with cargo:

```s
$ cargo run 127.0.0.1:8080
   Compiling droplet-echo-udp-context v0.1.0 (/home/josecelano/Documents/github/committer/josecelano/josecelano/awesome-torrust-tracker-compose/droplet-echo-udp-context)
    Finished dev [unoptimized + debuginfo] target(s) in 0.59s
     Running `target/debug/droplet-echo-udp-context '127.0.0.1:8080'`
Listening on: 127.0.0.1:8080
Echoed 2/2 bytes to 127.0.0.1:39856
Echoed 2/2 bytes to 127.0.0.1:39856
```

Run it with docker:

```s
./docker/bin/build.sh
./docker/bin/run.sh
```

Run it with docker-compose:

```s
docker compose up
```

You can open a new terminal tab and type:

```s
nc -u 127.0.0.1 8080
```

Then you can write something and the UDP server will replay with the same text.

## Run it on a remote docker context

Read [this article](../droplet-docker-context/) to install you docker context on a Digital Ocean Droplet.

```s
docker --context YOUR_CONTEXT_NAME compose up
```

> NOTICE: it can take a couple of minutes.

## Links

- [UdpEchoServer](https://github.com/tomatoaiu/rust-udp-echo-server) by [tomatoaiu](https://github.com/tomatoaiu).
- [Echo UDP server sample](https://github.com/tokio-rs/tokio/blob/master/examples/echo-udp.rs) by [tokio-rs](https://github.com/tokio-rs).
- [Configuring NGINX Plus and Your UDP Upstreams for DSR](https://www.nginx.com/blog/ip-transparency-direct-server-return-nginx-plus-transparent-proxy/).
- [Everything you ever wanted to know about UDP sockets but were afraid to ask, part 1](https://blog.cloudflare.com/everything-you-ever-wanted-to-know-about-udp-sockets-but-were-afraid-to-ask-part-1/) by [Marek Majkowski](https://blog.cloudflare.com/author/marek-majkowski/).
