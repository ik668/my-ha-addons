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

# Transmit power is user configurable via the `tx_power` option (dBm).
# Upstream hardcoded `ot-ctl txpower 6` to avoid asymmetric link quality with
# other Thread routers; the default here is raised to 20 dBm, which is the
# maximum supported by most 2.4 GHz RCP radios (e.g. EFR32MG24).
if bashio::config.has_value 'tx_power'; then
    tx_power="$(bashio::config 'tx_power')"
else
    tx_power=20
fi
bashio::log.info "Setting OpenThread TX power to ${tx_power} dBm."
ot-ctl txpower "${tx_power}"
bashio::log.info "TX power reported by the radio: $(ot-ctl txpower | head -n 1)"
