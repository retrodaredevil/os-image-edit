#!/usr/bin/env sh
# Designed to possibly copy the wpa_supplicant.conf file

(mv /opt/config_files/wpa_supplicant.conf /boot && echo "Successfully configured WiFi") || echo "No wpa_supplicant.conf file. WiFi was not configured."

exit 0
