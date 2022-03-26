#!/usr/bin/env sh

echo "Installing dependencies for vision install"

# We assume that apt-get update has been run recently

apt-get install -y build-essential cmake pkg-config git || exit 1
apt-get install -y libjpeg-dev libtiff-dev libjasper-dev libpng-dev libwebp-dev libopenexr-dev || exit 1
apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libdc1394-22-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev || exit 1
#apt-get install libgtk-3-dev libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5 || exit 1
apt-get install -y libhdf5-dev libhdf5-103 || exit 1

cd /opt/ || exit 1
git clone --single-branch --depth=1 https://github.com/opencv/opencv.git || exit 1
cd opencv/ || exit 1
mkdir build/ || exit 1
cd build/ || exit 1
cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D ENABLE_NEON=ON \
    -D ENABLE_VFPV3=ON \
    -D BUILD_TESTS=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D CMAKE_SHARED_LINKER_FLAGS=-latomic \
    -D BUILD_EXAMPLES=OFF ..

make "-j$(nproc)" || exit 1
make install || exit 1
ldconfig || exit 1


cd /opt/ || exit 1
git clone https://github.com/frc1444/robot2020-vision.git || exit 1
cd /opt/robot2020-vision/ || exit 1
mkdir build/ || exit 1
cd build/ || exit 1
echo "Going to begin building the vision"
cmake .. || exit 1

