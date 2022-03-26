#!/usr/bin/env sh

echo "Installing dependencies for vision install"

# We assume that apt-get update has been run recently

# ninja-build is needed for building opencv using pip install
# python (python2) is needed for numpy, which gets installed when installing opencv-contrib-python-headless
apt-get install -y build-essential cmake pkg-config g++ ninja-build git python3 python3-pip python3-dev python || exit 1
python2 --version

# Thanks https://stackoverflow.com/a/53402396/5434860 - numpy needs this, and the opencv stuff needs numpy
# In the future, we could just install python3-numpy using apt-get, but that's no fun
#apt-get install -y libatlas-base-dev libhdf5-dev libhdf5-serial-dev libjasper-dev || exit 1
apt-get install -y libatlas-base-dev libjasper-dev || exit 1

python3 -m pip install --upgrade pip setuptools wheel || exit 1  # wheel needs to be installed before we install opencv
#python3 -m pip install opencv-contrib-python-headless || exit 1  # includes main modules and contrib/extra modules
python3 -m pip install --only-binary :all: opencv-python-headless || exit 1  # includes main modules and contrib/extra modules


cd /opt/ || exit 1
git clone https://github.com/frc1444/robot2020-vision.git || exit 1
cd /opt/robot2020-vision/ || exit 1
mkdir build/ || exit 1
cd build/ || exit 1
echo "Going to begin building the vision"
cmake .. || exit 1

