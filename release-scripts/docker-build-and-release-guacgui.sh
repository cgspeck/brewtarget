#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/common-vars

BUILD_PATH=/app/build

if [[ "$TRAVIS" == "true" ]]; then
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
fi

echo "Building for ${TARGET}"

tag="latest"

docker build \
  -t cgspeck/brewtarget-guacgui:$tag \
  -f Dockerfile-guacgui \
  --build-arg BUILD_DATE=$(date -u +%s) \
  --build-arg VERSION=$TAG_NAME \
  .

echo -e "\nPushing new docker images"
docker push cgspeck/brewtarget-guacgui:$tag
