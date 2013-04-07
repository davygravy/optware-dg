#!/bin/sh
#
# $Id: rc.tellstick.sh 12559 2011-09-04 14:20:11Z jenkins $
#

insmod usbserial
insmod ftdi_sio

if [ -e /dev/ttyUSB0 ];then
   device=/dev/ttyUSB0
else
   mknod /dev/ttyUSB0 c 188 0
   device=/dev/ttyUSB0
fi

if [ ! -e /dev/tellstick ];then
   ln -sf $device /dev/tellstick
fi

echo "/dev/tellstick initialised..."

