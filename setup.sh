#!/bin/bash

##CLONE DT
## mars 
rm -rf device/xiaomi/mars
git clone https://github.com/darkinzen/android_device_xiaomi_mars.git device/xiaomi/mars

## sm8350-common
rm -rf device/xiaomi/sm8350-common
git clone https://github.com/darkinzen/android_device_xiaomi_sm8350-common.git device/xiaomi/sm8350-common

## CLONE VENDOR FILES
## mars
rm -rf vendor/xiaomi/mars
git clone https://github.com/darkinzen/proprietary_vendor_xiaomi_mars.git vendor/xiaomi/mars

## sm8350-common
rm -rf vendor/xiaomi/sm8350-common
git clone https://github.com/darkinzen/proprietary_vendor_xiaomi_sm8350-common.git vendor/xiaomi/sm8350-common

##CLONE HARDWARE
rm -rf hardware/xiaomi
git clone https://github.com/darkinzen/android_hardware_xiaomi.git hardware/xiaomi

##CLONE KERNEL
git clone https://github.com/darkinzen/android_kernel_xiaomi_sm8350.git kernel/xiaomi/sm8350
