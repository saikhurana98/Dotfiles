#!/bin/bash

A="alsa_output.usb-Topping_DX1-00.HiFi__Headphones__sink"
B="alsa_output.pci-0000_18_00.6.analog-stereo"

CURRENT=$(pactl get-default-sink)

if [ "$CURRENT" = "$A" ]; then
  pactl set-default-sink "$B"
else
  pactl set-default-sink "$A"
fi
