#!/usr/bin/env bash
read -r pi pt < <(awk '/^cpu / {idle=$5; for(i=2;i<=NF;i++) total+=$i; print idle, total}' /proc/stat)
sleep 0.3
read -r ci ct < <(awk '/^cpu / {idle=$5; for(i=2;i<=NF;i++) total+=$i; print idle, total}' /proc/stat)

echo $((100 * (ct - ci - pt + pi) / (ct - pt)))
