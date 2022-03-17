
.PHONY: clean docker download-image

clean:
	echo Cleaning

docker:
	docker pull ghcr.io/solo-io/packer-plugin-arm-image

.downloads/2022-01-28-raspios-bullseye-armhf-lite.zip:
	mkdir -p .downloads/
	wget -O .downloads/2022-01-28-raspios-bullseye-armhf-lite.zip https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip

download-image: .downloads/2022-01-28-raspios-bullseye-armhf-lite.zip

build: docker
	docker run \
		--rm \
		--privileged \
		-v /dev:/dev \
		-v .:/build:ro \
		-v ./packer_cache:/build/packer_cache \
		-v ./output-arm-image:/build/output-arm-image \
		ghcr.io/solo-io/packer-plugin-arm-image build configs/rpi_simple.json

.PHONY: create-config-files
create-config-files:
	mkdir -p config_files

.PHONY: config-users
config-users: create-config-files
	python3 scripts/config_users.py config_files/users.json

