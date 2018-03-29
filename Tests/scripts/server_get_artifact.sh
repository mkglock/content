#!/usr/bin/env bash
set -e

ACCEPT_TYPE="Accept: application/json"
SERVER_API_URI="https://circleci.com/api/v1/project/demisto/server"
TOKEN_ATTR="circle-token=$SERVER_CI_TOKEN"

echo "Getting latest build num"
TEMP=$(curl -s -H "$ACCEPT_TYPE" "$SERVER_API_URI/tree/master?limit=5&filter=successful&$TOKEN_ATTR")

ARTIFACT_BUILD_NUM=
for i in `seq 0 4`; do
    if [[ $(echo "$TEMP" | jq ".[$i].build_parameters") == "null" ]]; then
        ARTIFACT_BUILD_NUM=$(echo "$TEMP" | jq ".[$i].build_num")
        break
    fi
done

if [[ "$ARTIFACT_BUILD_NUM" = "" ]]; then
    echo "couldn't find successful build"
    exit 1
fi

SERVER_DOWNLOAD_LINK=$(curl -s -H "$ACCEPT_TYPE" ${SERVER_API_URI}/${ARTIFACT_BUILD_NUM}/artifacts?${TOKEN_ATTR} | jq '.[].url' -r | grep demistoserver | grep /0/)

echo "Getting server artifact for build: ${ARTIFACT_BUILD_NUM}"
echo "SERVER_DOWNLOAD_LINK = ${SERVER_DOWNLOAD_LINK}"

curl -o demistoserver.sh ${SERVER_DOWNLOAD_LINK}?${TOKEN_ATTR}

echo "Done!"