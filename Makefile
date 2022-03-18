
# Constants
OUTPUT_SUFFIX=-edit

RPI_OS_OUTPUT_ZIP_FILE=2022-01-28-raspios-bullseye-armhf-lite${OUTPUT_SUFFIX}.zip
RPI_OS_COMPRESSED_OUTPUT_FILE_NAME=2022-01-28-raspios-bullseye-armhf-lite${OUTPUT_SUFFIX}.img
RPI_OS_CONFIG_FILE=configs/rpi_simple.json
RPI_OS_IMAGE_FILE=.downloads/2022-01-28-raspios-bullseye-armhf-lite.zip
RPI_OS_IMAGE_FILE_URL=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip


ARMBIAN_RPI_OUTPUT_ZIP_FILE=Armbian_22.02.0-trunk.0009_Rpi4b_focal_current_5.15.13_xfce_desktop${OUTPUT_SUFFIX}.zip
ARMBIAN_RPI_COMPRESSED_OUTPUT_FILE_NAME=2022-01-28-raspios-bullseye-armhf-lite${OUTPUT_SUFFIX}.img
ARMBIAN_RPI_CONFIG_FILE=configs/armbian_rpi.json
ARMBIAN_RPI_IMAGE_FILE=.downloads/Armbian_22.02.0-trunk.0009_Rpi4b_focal_current_5.15.13_xfce_desktop.img.xz
ARMBIAN_RPI_IMAGE_FILE_URL=https://armbian.hosthatch.com/archive/rpi4b/nightly/Armbian_22.02.0-trunk.0009_Rpi4b_focal_current_5.15.13_xfce_desktop.img.xz


.PHONY: docker
docker:
	docker pull ghcr.io/solo-io/packer-plugin-arm-image

.PHONY: --download-image
--download-image:
	@echo "asdf IMAGE_FILE=${IMAGE_FILE}"
	@mkdir -p .downloads/
	test -f ${IMAGE_FILE} || wget -O ${IMAGE_FILE} ${IMAGE_FILE_URL}


.PHONY: --build
--build: docker
	docker run \
		--rm \
		--privileged \
		-v /dev:/dev \
		-v ${PWD}:/build:ro \
		-v ${PWD}/packer_cache:/build/packer_cache \
		-v ${PWD}/output-arm-image:/build/output-arm-image \
		ghcr.io/solo-io/packer-plugin-arm-image build ${CONFIG_FILE}

.PHONY: build-rpi-os
build-rpi-os: OUTPUT_ZIP_FILE=${RPI_OS_OUTPUT_ZIP_FILE}
build-rpi-os: COMPRESSED_OUTPUT_FILE_NAME=${RPI_OS_COMPRESSED_OUTPUT_FILE_NAME}
build-rpi-os: CONFIG_FILE=${RPI_OS_CONFIG_FILE}
build-rpi-os: IMAGE_FILE=${RPI_OS_IMAGE_FILE}
build-rpi-os: IMAGE_FILE_URL=${RPI_OS_IMAGE_FILE_URL}

.PHONY: build-armbian-rpi
build-armbian-rpi: OUTPUT_ZIP_FILE=${ARMBIAN_RPI_OUTPUT_ZIP_FILE}
build-armbian-rpi: COMPRESSED_OUTPUT_FILE_NAME=${ARMBIAN_RPI_COMPRESSED_OUTPUT_FILE_NAME}
build-armbian-rpi: CONFIG_FILE=${ARMBIAN_RPI_CONFIG_FILE}
build-armbian-rpi: IMAGE_FILE=${ARMBIAN_RPI_IMAGE_FILE}
build-armbian-rpi: IMAGE_FILE_URL=${ARMBIAN_RPI_IMAGE_FILE_URL}

build-rpi-os build-armbian-rpi: --download-image --build


.PHONY: zip
zip:
	rm -f ${OUTPUT_ZIP_FILE}
	zip -j ${OUTPUT_ZIP_FILE} output-arm-image/image
	printf "@ image\n@=${COMPRESSED_OUTPUT_FILE_NAME}\n" | zipnote -w ${OUTPUT_ZIP_FILE}


.PHONY: create-config-files
create-config-files:
	@mkdir -p config_files

.PHONY: config-users
config-users: create-config-files
	@python3 scripts/config_users.py config_files/users.json

