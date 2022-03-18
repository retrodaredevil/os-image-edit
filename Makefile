
OUTPUT_ZIP_FILE=2022-01-28-raspios-bullseye-armhf-lite-edit.zip
COMPRESSED_OUTPUT_FILE_NAME=2022-01-28-raspios-bullseye-armhf-lite-edit.img

.PHONY: docker
docker:
	docker pull ghcr.io/solo-io/packer-plugin-arm-image

.downloads/2022-01-28-raspios-bullseye-armhf-lite.zip:
	mkdir -p .downloads/
	wget -O .downloads/2022-01-28-raspios-bullseye-armhf-lite.zip https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip

.PHONY: download-image
download-image: .downloads/2022-01-28-raspios-bullseye-armhf-lite.zip

.PHONY: build
build: docker
	docker run \
		--rm \
		--privileged \
		-v /dev:/dev \
		-v ${PWD}:/build:ro \
		-v ${PWD}/packer_cache:/build/packer_cache \
		-v ${PWD}/output-arm-image:/build/output-arm-image \
		ghcr.io/solo-io/packer-plugin-arm-image build configs/rpi_simple.json

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

