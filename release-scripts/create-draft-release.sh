#! /bin/bash -e
./install-deps
source ./common-vars

endpoint="https://api.github.com/repos/cgspeck/brewtarget/releases"
payload=$(cat <<EOF
{
    "tag_name": "${TAG_NAME}",
    "target_commitish": "${TARGET_COMMITISH}",
    "draft": true
}
EOF
)

echo -e "\n\n Creating release with following payload: \n\n ${payload} \n\n"

curl -f -uChrisBuildAccount:$GITHUB_TOKEN \
    -XPOST \
    -H "Content-Type: application/json" \
    -d "${payload}" \
    $endpoint
