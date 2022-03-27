#!/usr/bin/env sh

# We assume that opencv is already installed

apt-get install -y build-essential cmake pkg-config git || exit 1


cd /opt/ || exit 1
git clone https://github.com/frc1444/robot2020-vision.git || exit 1
cd /opt/robot2020-vision/ || exit 1
mkdir build/ || exit 1
cd build/ || exit 1
echo "Going to begin building the vision"
cmake .. || exit 1
echo "Running cmake succeeded. Now onto actually making it."
make || exit 1

