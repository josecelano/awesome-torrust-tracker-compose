#!/bin/bash

docker run -it \
    --publish 8080:8080/udp \
    echo-udp 0.0.0.0:8080
