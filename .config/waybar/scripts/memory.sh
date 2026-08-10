#!/bin/bash
# memory.sh - dock memory module
free -b | awk '/^Mem:/{used=$3; total=$2; printf "%.0f\n", used/total*100}'
