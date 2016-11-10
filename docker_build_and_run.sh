#!/bin/bash

docker build -t fablab/bookingbot $@ .
docker run --rm fablab/bookingbot
