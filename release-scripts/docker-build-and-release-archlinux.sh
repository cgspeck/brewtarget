#! /bin/bash -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/common-vars

TARGET="arch"
BUILD_PATH=/app/arch
PACKAGE="brewtarget-devel-${ARCH_VERSION}-1-x86_64.pkg.tar.xz"
BUILD_DATE="dev"

if [[ "$TRAVIS" == "true" ]]; then
  BUILD_DATE=$(date -u +%s)
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
fi

echo "Building for ${TARGET}"

tag="${TARGET}"
expanded_tag="${tag}-${SHORT_HASH}"

docker build \
  -t cgspeck/brewtarget-build:$tag \
  -f Dockerfile-$TARGET \
  --build-arg BUILD_DATE \
  --build-arg VERSION=$ARCH_VERSION \
  .

# TODO: only push if on develop
if [[ "$TRAVIS" == "true" ]]; then
  IMG_NAME="cgspeck/brewtarget-build:${TARGET}-${TRAVIS_BUILD_NUMBER}"
  echo -e "\nPushing new docker images"
  docker push cgspeck/brewtarget-build:$tag
  docker tag cgspeck/brewtarget-build:$tag $IMG_NAME
  docker push $IMG_NAME
fi
