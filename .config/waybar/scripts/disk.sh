#!/bin/bash
# disk.sh - dock disk module
df / | awk 'NR==2{gsub("%","",$5); print $5}'
