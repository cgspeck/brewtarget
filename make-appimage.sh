#! /bin/bash -ex
IMAGE=appimagecrafters/appimage-builder:0.8.7
CONTAINER=brewtarget-appimage-builder

time docker pull $IMAGE
# delete any old build
docker rm $CONTAINER || true

time docker run \
    -v $PWD/build-scripts/linux/AppImageBuilder.yml:/AppImageBuilder.yml \
    -v $PWD:/brewtarget/checkout \
    -e UPDATE_INFO \
    $IMAGE \
    /usr/local/bin/appimage-builder --skip-tests

# exfiltrate the appimage

# clean up
docker rm $CONTAINER || true
