#!/bin/bash
# uptime.sh - dock uptime module
awk '{d=int($1/86400);h=int(($1%86400)/3600);m=int(($1%3600)/60);if(d>0)printf "%dd %dh",d,h;else if(h>0)printf "%dh %dm",h,m;else printf "%dm",m}' /proc/uptime
echo
