#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <tag>"
  exit 1
fi

TAG=$1

echo "# Downloading realease file for $TAG..."
gh release download "$TAG"

echo "# Locally building the bottle..."
brew install wearedevx/keystone/keystone --build-bottle 
echo " - Creating local artifacts..."
brew bottle wearedevx/keystone/keystone --json
echo " - Merging with existing formula..."
brew bottle --write --merge keystone*.json

shopt -s nullglob
if ls ./*.tar.gz; then
  for f in ./*.tar.gz; do
    mv "$f" "$(echo $f | sed 's/--/-/g')"
  done
fi

shopt -u nullglob

echo "# Publishing the release artifacts..."
gh release upload "$TAG" ./keystone*json ./keystone*.tar.gz

echo ""
echo "Release $TAG is published for the current platform"
