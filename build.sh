#!/usr/bin/env bash
 
docker buildx build -t elcrp96/plex-media-server:latest --platform linux/armhf,linux/arm64,linux/amd64 ./ --push
