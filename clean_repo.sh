#!/bin/sh -xe

# delete old packages for $BUILDARCH, to stay within the free tier space limitation
curl -s "https://${PACKAGECLOUD_TOKEN}:@packagecloud.io/api/v1/repos/dimkr/vscodium/packages.json" | jq -r '.[].destroy_url' | grep -F "${BUILDARCH}.deb" | while read destroy_url
do
    curl -X DELETE "https://${PACKAGECLOUD_TOKEN}:@packagecloud.io${destroy_url}"
done
