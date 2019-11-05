#! /bin/bash -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/common-vars

BUILD_PATH=/app/build
TARGETS=("ubuntu1804")
PACKAGES=("brewtarget_2.4.0_x86_64.deb" "brewtarget_2.4.0_x86_64.rpm" "brewtarget_2.4.0_x86_64.tar.bz2")

if [[ "$TRAVIS" == "true" ]]; then
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
fi

for target in ${TARGETS[*]}; do
  tag="${target}"
  set +e
  docker pull cgspeck/brewtarget-build:$tag
  set -e
  docker build -t $tag -f Dockerfile-$target .
  for package in ${PACKAGES[*]}; do
    docker run --rm --entrypoint cat $tag $BUILD_PATH/$package > packages/$target_$package
  done
  docker push cgspeck/brewtarget-build:$tag
done

# TODO: upload packages to GitHub!
