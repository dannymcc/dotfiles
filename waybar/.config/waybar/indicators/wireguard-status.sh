#!/bin/bash

# Get the first active wireguard interface
WG_OUTPUT=$(ip link show type wireguard 2>/dev/null)
WG_INTERFACE=$(echo "$WG_OUTPUT" | head -1 | awk -F': ' '{print $2}')

if [[ -n "$WG_INTERFACE" ]]; then
  # Get the VPN IP address for tooltip
  VPN_IP=$(ip -4 addr show "$WG_INTERFACE" 2>/dev/null | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+')
  echo "{\"text\": \"󰌆 $WG_INTERFACE\", \"tooltip\": \"Wireguard: $WG_INTERFACE\\nIP: $VPN_IP\\nClick to disconnect\", \"class\": \"connected\"}"
else
  echo '{"text": "", "class": "disconnected"}'
fi
