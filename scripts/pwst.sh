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
# Firmware 1.14.1 and corresponding BCF and Smart Manger were tested
# and found more adapted to the MM610X-H06 – EU than the 1.15.3 ship
# with Morse Micro OpenWRT 2.8.5
(
  # To apply in the external Git dependency Morse Micro feeds
  cd ./feeds/morse
  patch -p1 < ../../patches/morse-feeds.patch
)

#######################################################################
# Build configuration sizing the SD card, adding Docker dependencies.
# Removing unnecessary packages.
make defconfig
