#!/bin/bash

# Run intel_gpu_top and capture output
gpu_json=$(timeout 0.5s sudo intel_gpu_top -J -s 100 -o - 2>/dev/null)

# Extract actual frequency
freq=$(echo "$gpu_json" | grep -m1 '"actual":' | awk -F ': ' '{print $2}' | tr -d ',')

# Extract Render/3D usage %
usage=$(echo "$gpu_json" | grep '"Render/3D"' -A1 | grep '"busy":' | awk -F ': ' '{print $2}' | tr -d ',')

# Fallbacks
freq=${freq:-"N/A"}
usage=${usage:-"?"}

# Final output
echo "${usage}% @ ${freq}MHz"


