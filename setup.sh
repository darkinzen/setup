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
rm -rf kernel/xiaomi/sm8350
git clone https://github.com/darkinzen/android_kernel_xiaomi_sm8350.git kernel/xiaomi/sm8350

##Miui camera
#rm -rf vendor/xiaomi/star-miuicamera
#git clone https://gitlab.stud.atlantis.ugent.be/aksrivas/vendor_xiaomi_star-miuicamera.git vendor/xiaomi/star-miuicamera

##KernelSU Next
cd kernel/xiaomi/sm8350
curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -
##Susfs
curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next-susfs/kernel/setup.sh" | bash -s next-susfs
cd $HOME
echo "you are in home folder now"
