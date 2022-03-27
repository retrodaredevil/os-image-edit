#!/usr/bin/env sh

echo "Installing dependencies for zeromq"

# We assume that apt-get update has been run recently

apt-get install -y build-essential cmake pkg-config git || exit 1

cd /opt/ || exit 1
git clone --single-branch --depth=1 https://github.com/zeromq/libzmq || exit 1
cd libzmq/ || exit 1
mkdir build/ || exit 1
cd build/ || exit 1
cmake .. || exit 1
make "-j$(nproc)" install || exit 1


cd /opt/ || exit 1
git clone --single-branch --depth=1 https://github.com/zeromq/cppzmq || exit 1
cd cppzmq/ || exit 1
mkdir build/ || exit 1
cd build/ || exit 1
cmake .. || exit 1
make "-j$(nproc)" install || exit 1
