#!/bin/bash

set -ex

function keep_alive() {
  while true; do
    date
    sleep 60
  done
}

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  npm config set scripts-prepend-node-path true

  export BUILD_SOURCEVERSION=$LATEST_MS_COMMIT
  echo "LATEST_MS_COMMIT: ${LATEST_MS_COMMIT}"
  echo "BUILD_SOURCEVERSION: ${BUILD_SOURCEVERSION}"

  export npm_config_arch="$VSCODE_ARCH"
  export npm_config_target_arch="$VSCODE_ARCH"

  . prepare_vscode.sh

  cd vscode || exit

  # these tasks are very slow, so using a keep alive to keep travis alive
  keep_alive &

  KA_PID=$!

  yarn monaco-compile-check
  yarn valid-layers-check

  yarn gulp compile-build
  yarn gulp compile-extensions-build
  yarn gulp minify-vscode

  if [[ "$OS_NAME" == "osx" ]]; then
    yarn gulp vscode-darwin-min-ci
  elif [[ "$CI_WINDOWS" == "True" ]]; then
    cp LICENSE.txt LICENSE.rtf # windows build expects rtf license
    yarn gulp "vscode-win32-${VSCODE_ARCH}-min-ci"
    yarn gulp "vscode-win32-${VSCODE_ARCH}-code-helper"
    yarn gulp "vscode-win32-${VSCODE_ARCH}-inno-updater"
    yarn gulp "vscode-win32-${VSCODE_ARCH}-archive"
    yarn gulp "vscode-win32-${VSCODE_ARCH}-system-setup"
    yarn gulp "vscode-win32-${VSCODE_ARCH}-user-setup"
  else # linux
    yarn gulp vscode-linux-${VSCODE_ARCH}-min-ci

    yarn gulp "vscode-linux-${VSCODE_ARCH}-build-deb"

    if [[ "$VSCODE_ARCH" == "x64" ]]; then
      yarn gulp "vscode-linux-${VSCODE_ARCH}-build-rpm"
    fi
    . ../create_appimage.sh
  fi

  kill $KA_PID

  cd ..
fi
