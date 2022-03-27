# OS Image Edit
This repository demonstrates the usage of [packer-plugin-arm-image](https://github.com/solo-io/packer-plugin-arm-image).

### Features
* Installs a minimal set of software that is commonly used
* Enables SSH
* Configures WiFi (for Raspberry Pi OS Images only)
* Configures users with encrypted passwords

### Requirements
You must have `make` and docker installed on your system. `python3` may optionally be installed to
help with the creation of the WiFi configuration file.

### Building
You have a couple of different options. Here's some examples:
```shell
make build zip
make BASE=armbian build zip
make OUTPUT_SUFFIX=my_edit build zip
make OUTPUT_SUFFIX=lightning CONFIG_FILE=configs/rpi_lightning.json BASE=rpi make zip
make BASE=rpi CONFIG_FILE=configs/rpi_opencv.json OUTPUT_SUFFIX=-opencv build zip
```

### Running With Sudo
If your system requires you to use sudo to run a docker command, you should build the image like this: `sudo -E make build`.


### Other Notes
* If you are creating a new user, I recommend giving these groups:
  * `adm,tty,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi`
