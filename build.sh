#!/bin/bash
docker build \
  --label org.opencontainers.image.created="$(date --rfc-3339=seconds)" \
  --build-arg RSEM_VERSION=$1 \
  --build-arg R_VERSION=$2 \
  --build-arg MAKE_NTHREADS=$3 \
  --tag cieldeville/rsem:$1 \
  -f Dockerfile .

