#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "ERROR | Missing required argument."
  echo "USAGE | $0 <app_name>"
  exit 1
fi

APP_NAME=$1
VERSION=v$(git tag --sort=-creatordate | head -1)

build_app() {
    echo "INFO | Authenticating with GitHub Container Registry ..."
    echo $CR_PAT | docker login ghcr.io -u nicosouv --password-stdin

    echo "INFO | Building Docker image ..."
    docker buildx build --platform linux/amd64 \
    -f .infrastructure/docker/${APP_NAME}.Dockerfile \
    -t ghcr.io/nicosouv/joyst-${APP_NAME}:$VERSION \
    -t ghcr.io/nicosouv/joyst-${APP_NAME}:latest .

    echo "INFO | Pushing Docker tags ..."
    docker push ghcr.io/nicosouv/joyst-${APP_NAME}:$VERSION
    docker push ghcr.io/nicosouv/joyst-${APP_NAME}:latest
}

build_app

if [ $? -eq 0 ]; then
  echo "INFO | The Package was built successfully"
  echo "OK | [$APP_NAME] version [$VERSION] is ready for deployment"
else
  echo "ERROR | There was an issue while building [$APP_NAME] version [$VERSION]"
  exit 1
fi