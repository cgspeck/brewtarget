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
  expanded_tag="${tag}-${SHORT_HASH}"
  set +e
  docker pull cgspeck/brewtarget-build:$tag
  set -e
  docker build -t cgspeck/brewtarget-build:$tag -f Dockerfile-$target .
  for package in ${PACKAGES[*]}; do
    docker run --rm --entrypoint cat cgspeck/brewtarget-build:$tag $BUILD_PATH/$package > "packages/${target}_${package}"
  done
  echo -e "\nPackages:"
  ls packages/
  echo -e "\nPushing new docker images"
  docker push cgspeck/brewtarget-build:$tag
  docker tag cgspeck/brewtarget-build:$tag cgspeck/brewtarget-build:$expanded_tag
  docker push cgspeck/brewtarget-build:$expanded_tag
done

echo -e "\nDownloading github-releases tool"
tmp_dir=$(mktemp -d)
github_release_archive=$tmp_dir/github-release.tar.bz2
github_release_path=$tmp_dir/bin/linux/amd64/github-release
wget "https://github.com/aktau/github-release/releases/download/v0.7.2/linux-amd64-github-release.tar.bz2" -O $github_release_archive
tar xvjf $github_release_archive -C $tmp_dir
chmod +x $github_release_path
echo -e "\nUploading binaries to Github"

for target in ${TARGETS[*]}; do
  for package in ${PACKAGES[*]}; do
    src="./packages/${target}_${package}"
    echo -e "\nUploading ${src}"
    $github_release_path upload \
      --user cgspeck \
      --repo brewtarget \
      --tag $TAG_NAME \
      --file $src \
      --name "${target}_${package}"
  done
done
