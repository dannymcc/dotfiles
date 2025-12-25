#!/bin/bash

profile=$(powerprofilesctl get 2>/dev/null)

case "$profile" in
    "performance")
        echo '{"text": "󰓅", "class": "performance", "tooltip": "Performance mode active"}'
        ;;
    "power-saver")
        echo '{"text": "󰌪", "class": "power-saver", "tooltip": "Power saver mode active"}'
        ;;
    *)
        echo '{"text": "", "class": "balanced"}'
        ;;
esac
