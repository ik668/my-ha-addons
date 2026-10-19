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
ot-ctl txpower "${tx_power}"
bashio::log.info "TX power reported by the radio: $(ot-ctl txpower | head -n 1)"
