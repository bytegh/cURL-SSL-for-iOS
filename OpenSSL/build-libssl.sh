#!/bin/sh

#  Automatic build script for libssl and libcrypto 
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Felix Schulze on 16.12.10.
#  Copyright 2010 Felix Schulze. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#  Change values here							  #
#									  #
VERSION="1.0.0d"							  #
SIM_SDKVERSION="5.0"						  #
ARM_SDKVERSION="6.1"							  #
#									  #
###########################################################################
#									  #
# Don't change anything under this line!				  #
#									  #
###########################################################################

CURRENTPATH=`pwd`
DEVELOPER=`xcode-select --print-path`

set -e
if [ ! -e openssl-${VERSION}.tar.gz ]; then
	echo "Downloading openssl-${VERSION}.tar.gz"
    curl -O http://www.openssl.org/source/openssl-${VERSION}.tar.gz
else
	echo "Using openssl-${VERSION}.tar.gz"
fi

if [ -d  ${CURRENTPATH}/src ]; then
	rm -rf ${CURRENTPATH}/src
fi

if [ -d ${CURRENTPATH}/bin ]; then
	rm -rf ${CURRENTPATH}/bin
fi

mkdir -p "${CURRENTPATH}/src"
tar zxf openssl-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
cd "${CURRENTPATH}/src/openssl-${VERSION}"

############
# iPhone Simulator
ARCH="i386"
PLATFORM="iPhoneSimulator"
echo "Building openssl for ${PLATFORM} ${SIM_SDKVERSION} ${ARCH}"
echo "Please stand by..."

export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SIM_SDKVERSION}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SIM_SDKVERSION}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${SIM_SDKVERSION} ${ARCH}"

./configure BSD-generic32 --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SIM_SDKVERSION}.sdk" > "${LOG}" 2>&1
# add -isysroot to CC=
sed -ie "s!^CFLAG=!CFLAG=-isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SIM_SDKVERSION}.sdk !" "Makefile"

echo "Make openssl for ${PLATFORM} ${SIM_SDKVERSION} ${ARCH}"

make >> "${LOG}" 2>&1
make install >> "${LOG}" 2>&1
make clean >> "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SIM_SDKVERSION} ${ARCH}, finished"
#############

#############
# iPhoneOS armv6
#ARCH="armv6"
#PLATFORM="iPhoneOS"
#echo "Building openssl for ${PLATFORM} ${ARM_SDKVERSION} ${ARCH}"
#echo "Please stand by..."

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
#mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${ARM_SDKVERSION}-${ARCH}.sdk"

#LOG="${CURRENTPATH}/bin/${PLATFORM}${ARM_SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

#echo "Configure openssl for ${PLATFORM} ${ARM_SDKVERSION} ${ARCH}"

#./configure BSD-generic32 --openssldir="${CURRENTPATH}/bin/${PLATFORM}${ARM_SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1

#sed -ie "s!^CFLAG=!CFLAG=-isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${ARM_SDKVERSION}.sdk !" "Makefile"
# remove sig_atomic for iPhoneOS
#sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"

#echo "Make openssl for ${PLATFORM} ${ARM_SDKVERSION} ${ARCH}"

#make >> "${LOG}" 2>&1
#make install >> "${LOG}" 2>&1
#make clean >> "${LOG}" 2>&1

#echo "Building openssl for ${PLATFORM} ${ARM_SDKVERSION} ${ARCH}, finished"
#############

#############
# iPhoneOS armv7
ARCH="armv7"
PLATFORM="iPhoneOS"
echo "Building openssl for ${PLATFORM} ${ARM_SDKVERSION} ${ARCH}"
echo "Please stand by..."

export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${ARM_SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${ARM_SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${ARM_SDKVERSION} ${ARCH}"

./configure BSD-generic32 --openssldir="${CURRENTPATH}/bin/${PLATFORM}${ARM_SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1

sed -ie "s!^CFLAG=!CFLAG=-isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${ARM_SDKVERSION}.sdk !" "Makefile"
# remove sig_atomic for iPhoneOS
sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"

echo "Make openssl for ${PLATFORM} ${ARM_SDKVERSION} ${ARCH}"

make >> "${LOG}" 2>&1
make install >> "${LOG}" 2>&1
make clean >> "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${ARM_SDKVERSION} ${ARCH}, finished"

#############

#############
# Universal Library
echo "Build universal library..."

lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SIM_SDKVERSION}.sdk/lib/libssl.a  ${CURRENTPATH}/bin/iPhoneOS${ARM_SDKVERSION}-armv7.sdk/lib/libssl.a -output ${CURRENTPATH}/libssl.a

lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SIM_SDKVERSION}.sdk/lib/libcrypto.a  ${CURRENTPATH}/bin/iPhoneOS${ARM_SDKVERSION}-armv7.sdk/lib/libcrypto.a -output ${CURRENTPATH}/libcrypto.a

mkdir -p ${CURRENTPATH}/include
cp -R ${CURRENTPATH}/bin/iPhoneSimulator${SIM_SDKVERSION}.sdk/include/openssl ${CURRENTPATH}/include/
echo "Building done."
echo "Cleaning up..."
rm -rf ${CURRENTPATH}/src
rm -rf ${CURRENTPATH}/bin
echo "Done."
