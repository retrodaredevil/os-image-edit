
# Constants
BASE?=rpi
OUTPUT_SUFFIX=-edit

RPI_OS_OUTPUT_PREFIX=2022-01-28-raspios-bullseye-armhf-lite
RPI_OS_CONFIG_FILE=configs/rpi_simple.json
RPI_OS_IMAGE_FILE=.downloads/2022-01-28-raspios-bullseye-armhf-lite.zip


ARMBIAN_RPI_OUTPUT_PREFIX=Armbian_22.02.0-trunk.0009_Rpi4b_focal_current_5.15.13_xfce_desktop
ARMBIAN_RPI_CONFIG_FILE=configs/armbian_rpi.json
ARMBIAN_RPI_IMAGE_FILE=.downloads/Armbian_22.02.0-trunk.0009_Rpi4b_focal_current_5.15.13_xfce_desktop.img.xz

ifeq "$(BASE)" "rpi"
CONFIG_FILE=$(RPI_OS_CONFIG_FILE)
IMAGE_FILE=$(RPI_OS_IMAGE_FILE)
OUTPUT_PREFIX=${RPI_OS_OUTPUT_PREFIX}
endif
ifeq "$(BASE)" "rpi-opencv"
# The user should define the CONFIG_FILE themselves
IMAGE_FILE=output/2022-01-28-raspios-bullseye-armhf-lite-opencv.zip
OUTPUT_PREFIX=${RPI_OS_OUTPUT_PREFIX}
endif
ifeq "$(BASE)" "armbian"
CONFIG_FILE=$(ARMBIAN_RPI_CONFIG_FILE)
IMAGE_FILE=$(ARMBIAN_RPI_IMAGE_FILE)
OUTPUT_PREFIX=${ARMBIAN_RPI_OUTPUT_PREFIX}
endif

.PHONY: docker
docker:
	docker pull ghcr.io/solo-io/packer-plugin-arm-image


#.PHONY: download-image
#download-image:
#	@echo "asdf IMAGE_FILE=${IMAGE_FILE}"
#	@mkdir -p .downloads/
#	test -f ${IMAGE_FILE} || wget -O ${IMAGE_FILE} ${IMAGE_FILE_URL}

.downloads/2022-01-28-raspios-bullseye-armhf-lite.zip:
	mkdir -p .downloads/
	wget -O .downloads/2022-01-28-raspios-bullseye-armhf-lite.zip https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip

.downloads/Armbian_22.02.0-trunk.0009_Rpi4b_focal_current_5.15.13_xfce_desktop.img.xz:
	mkdir -p .downloads/
	wget -O .downloads/Armbian_22.02.0-trunk.0009_Rpi4b_focal_current_5.15.13_xfce_desktop.img.xz https://armbian.hosthatch.com/archive/rpi4b/nightly/Armbian_22.02.0-trunk.0009_Rpi4b_focal_current_5.15.13_xfce_desktop.img.xz

output/2022-01-28-raspios-bullseye-armhf-lite-opencv.zip:
	$(MAKE) CONFIG_FILE=configs/rpi_opencv.json OUTPUT_SUFFIX=-opencv build zip

.PHONY: download-image
download-image: $(IMAGE_FILE)

.PHONY: build
build: docker download-image
	docker run \
		--rm \
		--privileged \
		-v /dev:/dev \
		-v ${PWD}:/build:ro \
		-v ${PWD}/packer_cache:/build/packer_cache \
		-v ${PWD}/output-arm-image:/build/output-arm-image \
		ghcr.io/solo-io/packer-plugin-arm-image build ${CONFIG_FILE}

.PHONY: zip
zip:
	rm -f output/$(OUTPUT_PREFIX)$(OUTPUT_SUFFIX).zip
	mkdir -p output/
	zip -j output/$(OUTPUT_PREFIX)$(OUTPUT_SUFFIX).zip output-arm-image/image
	printf "@ image\n@=$(OUTPUT_PREFIX)$(OUTPUT_SUFFIX).img\n" | zipnote -w output/$(OUTPUT_PREFIX)$(OUTPUT_SUFFIX).zip


.PHONY: create-config-files
create-config-files:
	@mkdir -p config_files

.PHONY: config-users
config-users: create-config-files
	@python3 scripts/config_users.py config_files/users.json

