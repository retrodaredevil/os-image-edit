
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
		-v ${PWD}:/build:ro \
		-v ${PWD}/packer_cache:/build/packer_cache \
		-v ${PWD}/output-arm-image:/build/output-arm-image \
		ghcr.io/solo-io/packer-plugin-arm-image build configs/rpi_simple.json
