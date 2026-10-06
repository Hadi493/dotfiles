#!/bin/bash
# Login audio fix: make the USB mic the default source and unmute it.
# PipeWire restores the previous session's mute state, so without this
# a reboot can come back muted or pointing at the internal mic.
# Sinks/outputs are intentionally left alone.
until pactl info >/dev/null 2>&1; do sleep 0.5; done

# Wait for the USB mic to be enumerated (it appears after PipeWire is up).
USB=""
for _ in $(seq 1 30); do
    USB=$(pactl list short sources | awk '{print $2}' | grep -i -m1 'usb')
    [ -n "$USB" ] && break
    sleep 1
done
if [ -n "$USB" ]; then
    # Prefer the denoised EasyEffects source when available, else raw USB.
    EE=$(pactl list short sources | awk '{print $2}' | grep -m1 'easyeffects_source')
    [ -n "$EE" ] && USB="$EE"
    pactl set-default-source "$USB" 2>/dev/null
    pactl set-source-mute alsa_input.usb-YC1006_Usb_MIC-00.mono-fallback 0 2>/dev/null
    pactl set-source-mute "$USB" 0 2>/dev/null
    # Capsule sensitivity has collapsed: raw speech is too quiet even at
    # hardware max, so add digital boost on the hardware source
    # (10000% = +120dB). EasyEffects RNNoise cleans the extra hiss and its
    # limiter catches close-talk clipping.
    # Set twice with a delay: WirePlumber restores the previously saved
    # volume asynchronously, which can clobber the first set.
    pactl set-source-volume alsa_input.usb-YC1006_Usb_MIC-00.mono-fallback 10000% 2>/dev/null
    sleep 10
    pactl set-source-volume alsa_input.usb-YC1006_Usb_MIC-00.mono-fallback 10000% 2>/dev/null
fi
