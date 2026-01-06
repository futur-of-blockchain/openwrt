#!/bin/bash
########################################################################
# Post Worst Survival specificities
#

set -ue -o pipefail

########################################################################
# Patch 2.8.5 to create a Morse M6108 SPI only target.
# By default it could be SDIO or SPI but SDIO break the Rapsberry
# buil-in WiFi that is needed.

patch -p1 < ./patches/rpi4b-sdio-wifi.patch

#######################################################################
# Build configuration sizing the SD card, adding Docker dependencies.
# Removing unnecessary packages.
make defconfig
