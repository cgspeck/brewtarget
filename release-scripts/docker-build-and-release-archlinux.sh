#! /bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/common-vars

TARGET="arch"
BUILD_PATH=/app/arch
PACKAGES=("brewtarget-devel-${ARCH_VER}-1-x86_64.pkg.tar.xz")
BUILD_DATE="dev"

if [[ "$TRAVIS" == "true" ]]; then
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  BUILD_DATE=$(date -u +%s)
fi

echo "Building for ${TARGET}"

tag="${TARGET}"
expanded_tag="${tag}-${SHORT_HASH}"

docker build \
  -t cgspeck/brewtarget-build:$tag \
  -f Dockerfile-$TARGET \
  --build-arg BUILD_DATE \
  --build-arg VERSION=$ARCH_VER \
  .
for package in ${PACKAGES[*]}; do
  docker run --rm --entrypoint cat cgspeck/brewtarget-build:$tag $BUILD_PATH/$package > "packages/${TARGET}_${package}"
done
echo -e "\nPackages:"
ls packages/

if [[ "$TRAVIS" == "true" ]]; then
  echo -e "\nPushing new docker images"
  docker push cgspeck/brewtarget-build:$tag

  echo -e "\nDownloading github-releases tool"
  tmp_dir=$(mktemp -d)
  github_release_archive=$tmp_dir/github-release.tar.bz2
  github_release_path=$tmp_dir/bin/linux/amd64/github-release
  wget "https://github.com/aktau/github-release/releases/download/v0.7.2/linux-amd64-github-release.tar.bz2" -O $github_release_archive
  tar xvjf $github_release_archive -C $tmp_dir
  chmod +x $github_release_path
  echo -e "\nUploading binaries to Github"


  for package in ${PACKAGES[*]}; do
    src="./packages/${TARGET}_${package}"
    echo -e "\nUploading ${src}"
    $github_release_path upload \
      --user cgspeck \
      --repo brewtarget \
      --tag $TAG_NAME \
      --file $src \
      --name "${TARGET}_${package}"
  done
fi