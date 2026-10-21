#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Configure OTBR depending on add-on settings
# ==============================================================================

ot-ctl trel enable

if bashio::config.true 'nat64'; then
    bashio::log.info "Enabling NAT64."
    ot-ctl nat64 enable
    ot-ctl dns server upstream enable
fi

mdns_localhostname="$(hostname)-otbr"
bashio::log.info "Setting OpenThread mDNS local hostname to ${mdns_localhostname}."
ot-ctl mdns localhostname "${mdns_localhostname}"
ot-ctl mdns enable

# Transmit power is user configurable via the `发射功率` option (dBm).
# Upstream hardcoded `ot-ctl txpower 6` to avoid asymmetric link quality with
# other Thread routers; the default here is raised to 20 dBm, which is the
# maximum supported by most 2.4 GHz RCP radios (e.g. EFR32MG24).
#
# NOTE: the option key is non-ASCII, so bashio::config cannot be used here
# (it builds a jq expression like `.发射功率`, which is not valid jq syntax).
# Read the raw options file with bracket notation instead.
tx_power=20
if [ -f /data/options.json ]; then
    tx_power_value="$(jq --raw-output '.["发射功率"] // empty' /data/options.json 2>/dev/null)"
    if [ -n "${tx_power_value}" ]; then
        tx_power="${tx_power_value}"
    fi
fi
bashio::log.info "Setting OpenThread TX power to ${tx_power} dBm."
ot-ctl txpower "${tx_power}" >/dev/null 2>&1

# Report what the radio actually accepted. The radio only supports discrete
# power levels, so it quantizes/clamps the requested value; showing the
# difference is how the user discovers the real usable range of the chip.
actual_power="$(ot-ctl txpower 2>/dev/null | head -n 1 | tr -d '\r')"
actual_dbm="$(echo "${actual_power}" | awk '{print $1}')"
bashio::log.info "TX power reported by the radio: ${actual_power}"
if [ -n "${actual_dbm}" ] && [ "${actual_dbm}" != "${tx_power}" ]; then
    bashio::log.warning "Radio quantized/clamped ${tx_power} dBm to ${actual_dbm} dBm (only discrete power levels are supported)"
fi
