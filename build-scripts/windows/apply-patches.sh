#! /bin/bash -ex
SRC_PATH=$1
PATCH="${SRC_PATH}/build-scripts/windows/patches/001-omit-missing-libs-for-packager.patch"

echo -e "\nApplying patches\n"

cd $SRC_PATH
git apply --stat $patch
git apply --check $patch
git apply $patch
cd -