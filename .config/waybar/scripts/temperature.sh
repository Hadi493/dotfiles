#!/usr/bin/env bash
sensors -j 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    temps = []
    for chip in data.values():
        for key, val in chip.items():
            if isinstance(val, dict) and 'temp1_input' in val:
                temps.append(val['temp1_input'])
    if temps:
        print(f'{max(temps):.0f}')
    else:
        print(0)
except:
    print(0)
"
