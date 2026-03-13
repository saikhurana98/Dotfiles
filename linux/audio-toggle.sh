#!/bin/bash

A="alsa_output.usb-Topping_DX1-00.HiFi__Headphones__sink"
B="alsa_output.usb-Audient_EVO4-00.pro-output-0"

CURRENT=$(pactl get-default-sink)

if [ "$CURRENT" = "$A" ]; then
  pactl set-default-sink "$B"
else
  pactl set-default-sink "$A"
fi
