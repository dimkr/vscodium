#!/bin/bash

set -ex

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$OS_NAME" == "osx" ]]; then
    cd VSCode-darwin
    zip -r -X -y ../VSCodium-darwin-${LATEST_MS_TAG}.zip ./*.app
  else
    cd VSCode-linux-${VSCODE_ARCH}
    tar czf ../VSCodium-linux-${VSCODE_ARCH}-${LATEST_MS_TAG}.tar.gz .
  fi

  cd ..
fi
