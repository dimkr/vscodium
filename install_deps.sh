#!/bin/bash

if [[ "$OS_NAME" == "linux" ]]; then
  sudo apt-get update
  sudo apt-get install -y fakeroot jq rpm
  triplet=
  case $VSCODE_ARCH in
    armhf)
      triplet=arm-linux-gnueabihf
      ;;

    arm64)
      triplet=aarch64-linux-gnu
      ;;
  esac

  if [[ -n "$triplet" ]]; then
    sed 's/^deb /deb [arch=amd64] '/g -i /etc/apt/sources.list
    echo "deb [arch=$VSCODE_ARCH] http://ports.ubuntu.com/ubuntu-ports/ trusty main" | sudo tee -a /etc/apt/sources.list.d/$VSCODE_ARCH.list >/dev/null
    sudo dpkg --add-architecture $VSCODE_ARCH
    sudo apt-get update
    sudo apt-get install -y libc6-dev-$VSCODE_ARCH-cross gcc-$triplet g++-$triplet `apt-cache search x11proto | grep ^x11proto | cut -f 1 -d ' '` xz-utils pkg-config
    mkdir -p dl
    cd dl
    apt-get download libx11-dev:$VSCODE_ARCH libx11-6:$VSCODE_ARCH libxkbfile-dev:$VSCODE_ARCH libxkbfile1:$VSCODE_ARCH libxau-dev:$VSCODE_ARCH libxdmcp-dev:$VSCODE_ARCH libxcb1-dev:$VSCODE_ARCH libsecret-1-dev:$VSCODE_ARCH libsecret-1-0:$VSCODE_ARCH libpthread-stubs0-dev:$VSCODE_ARCH libglib2.0-dev:$VSCODE_ARCH libglib2.0-0:$VSCODE_ARCH libffi-dev:$VSCODE_ARCH libffi6:$VSCODE_ARCH zlib1g:$VSCODE_ARCH libpcre3-dev:$VSCODE_ARCH libpcre3:$VSCODE_ARCH
    for i in *.deb; do ar x $i; sudo tar -C / -xf data.tar.*; rm -f data.tar.*; done
    cd ..
    export CC=/usr/bin/$triplet-gcc
    export CXX=/usr/bin/$triplet-g++
    export CC_host=/usr/bin/gcc
    export CXX_host=/usr/bin/g++
    export PKG_CONFIG_LIBDIR=/usr/lib/$triplet/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig
  else
    sudo apt-get install -y libx11-dev libxkbfile-dev libsecret-1-dev
  fi
fi