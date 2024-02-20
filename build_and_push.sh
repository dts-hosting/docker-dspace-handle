#!/bin/bash

export $(grep -v '^#' .env | xargs)

# temporary script: build and push to Docker Hub for testing
docker compose build
docker push lyrasis/dspace-handle:${HANDLE_VERSION}
