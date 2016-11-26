#!/bin/bash

docker build -t fablab/bookingbot $@ .
docker run --rm  --name bookingbot fablab/bookingbot
