# PipeWire extra config (currently empty on purpose).
# echo-cancel was removed: it broke volume keys (apps bypassed the virtual
# sink while Noctalia drove it) and provided no benefit without a USB mic.
# To re-enable AEC for calls, restore 50-echo-cancel.conf from git history.
