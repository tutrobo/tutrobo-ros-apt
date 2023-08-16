#!/bin/bash

set -e

if [ -n $2 ]; then
  tag="tags/$2"
else
  tag="latest"
fi

urls=$(curl https://api.github.com/repos/$1/releases/$tag \
  | awk '$1 == "\"browser_download_url\":" { print $2 }' \
  | tr -d '"')

for url in $urls; do
  curl -OL $url
done
