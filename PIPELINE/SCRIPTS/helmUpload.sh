#!/bin/bash

source source /home/dmarom/ws/gitToken.sh

helm package _global_chart/
helm registry login ghcr.io/danielmarom78 --username danielmarom78 --password $GIT_TOKEN
helm push global-chart-1.0.9.tgz oci://ghcr.io/danielmarom78
