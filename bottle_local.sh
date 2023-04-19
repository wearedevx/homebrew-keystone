#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <tag>"
  exit 1
fi

TAG=$1

gh release download "$TAG"

brew install wearedevx/keystone/keystone --build-bottle 
brew bottle wearedevx/keystone/keystone --json
brew bottle --write --merge keystone*.json

shopt -s nullglob
if ls ./*.tar.gz; then
  for f in ./*.tar.gz; do
    mv "$f" "$(echo $f | sed 's/--/-/g')"
  done
fi

shopt -u nullglob

