#!/bin/bash
sleep 2
pw-link alsa_input.pci-0000_00_1f.3.analog-stereo:capture_FL effect_input.highpass:input_FL 2>/dev/null
pw-link alsa_input.pci-0000_00_1f.3.analog-stereo:capture_FR effect_input.highpass:input_FR 2>/dev/null
pactl set-source-volume effect_output.highpass 150% 2>/dev/null
