# -*- coding: utf-8 -*-
#
# VPN Status Script for WeeChat
# Shows VPN IP and location in the status bar
#

import weechat
import os

SCRIPT_NAME = "vpn_status"
SCRIPT_AUTHOR = "Secure IRC"
SCRIPT_VERSION = "1.1"
SCRIPT_LICENSE = "MIT"
SCRIPT_DESC = "Shows VPN status in the status bar"

vpn_info = {"ip": "...", "location": ""}

def get_vpn_status(data="", command="", return_code=0, out="", err=""):
    """Process the IP lookup result"""
    global vpn_info

    if return_code == weechat.WEECHAT_HOOK_PROCESS_ERROR:
        vpn_info["ip"] = "error"
        weechat.bar_item_update("vpn_status")
        return weechat.WEECHAT_RC_OK

    if out:
        # Clean the output - should be just an IP
        ip = out.strip()
        # Validate it looks like an IP (basic check)
        if ip and '.' in ip and len(ip) < 20 and '<' not in ip:
            vpn_info["ip"] = ip
            # Now get location
            weechat.hook_process(
                f"url:https://ipinfo.io/{ip}/city",
                5000,
                "get_location_cb",
                ""
            )
        else:
            vpn_info["ip"] = "VPN active"

    weechat.bar_item_update("vpn_status")
    return weechat.WEECHAT_RC_OK

def get_location_cb(data, command, return_code, out, err):
    """Process location lookup"""
    global vpn_info

    if out and '<' not in out and len(out.strip()) < 50:
        vpn_info["location"] = out.strip()

    weechat.bar_item_update("vpn_status")
    return weechat.WEECHAT_RC_OK

def vpn_status_item_cb(data, item, window):
    """Callback for the bar item"""
    global vpn_info

    color_green = weechat.color("green")
    color_reset = weechat.color("reset")

    if vpn_info["location"]:
        return f"{color_green}VPN:{color_reset} {vpn_info['ip']} ({vpn_info['location']})"
    return f"{color_green}VPN:{color_reset} {vpn_info['ip']}"

def vpn_refresh_cb(data, remaining_calls):
    """Timer callback to refresh VPN status"""
    weechat.hook_process(
        "url:https://api.ipify.org",
        5000,
        "get_vpn_status",
        ""
    )
    return weechat.WEECHAT_RC_OK

def vpn_cmd_cb(data, buffer, args):
    """Command to manually refresh VPN status"""
    vpn_refresh_cb("", 0)
    weechat.prnt(buffer, "VPN status refreshing...")
    return weechat.WEECHAT_RC_OK

if __name__ == "__main__":
    if weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION,
                        SCRIPT_LICENSE, SCRIPT_DESC, "", ""):
        # Create bar item
        weechat.bar_item_new("vpn_status", "vpn_status_item_cb", "")

        # Add command to manually refresh
        weechat.hook_command(
            "vpn",
            "Refresh VPN status",
            "",
            "",
            "",
            "vpn_cmd_cb",
            ""
        )

        # Initial check
        vpn_refresh_cb("", 0)

        # Refresh every 5 minutes
        weechat.hook_timer(300000, 0, 0, "vpn_refresh_cb", "")
