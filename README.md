# OS Image Edit
This repository demonstrates the usage of [packer-plugin-arm-image](https://github.com/solo-io/packer-plugin-arm-image).
Uses [this](https://github.com/solo-io/packer-plugin-arm-image/pkgs/container/packer-plugin-arm-image).

### Features
* Installs a minimal set of software that is commonly used
* Enables SSH
* Configures WiFi (for Raspberry Pi OS Images only)
* Configures users with encrypted passwords

### Requirements
You must have `make` and docker installed on your system. `python3` may optionally be installed to
help with the creation of the WiFi configuration file.

### Configuring WiFi
Note: This only works for Raspberry Pis. In the future this may change.

To configure WiFi, place the `wpa_supplicant.conf` file in `config_files/`. You can use [headless-setup](https://github.com/retrodaredevil/headless-setup/)
to generate this file. If you have that installed, you should run `make config-wifi` to automatically place the file in the correct place.

TODO: Remove question about enabling SSH in headless-setup.

### Building
You have a couple of different options. Here's some examples:
```shell
make build zip
make BASE=armbian build zip
make OUTPUT_SUFFIX=my_edit build zip
make OUTPUT_SUFFIX=lightning CONFIG_FILE=configs/rpi_lightning.json BASE=rpi-opencv build zip
make BASE=rpi CONFIG_FILE=configs/rpi_opencv.json OUTPUT_SUFFIX=-opencv build zip
```

### Running With Sudo
If your system requires you to use sudo to run a docker command, you should build the image like this: `sudo -E make build`.


### Other Notes
* If you are creating a new user, I recommend giving these groups:
  * `adm,tty,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi`
