#!/bin/bash

echo ""
sys.info "Local IPs:"
if sys.os.mac; then
    ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}'
else
    hostname -I
fi
echo ""
sys.info "Public IP:"
public_ip=$(curl ifconfig.co/json)
ip=$(echo "$public_ip" | jq -r '.ip')
city=$(echo "$public_ip" | jq -r '.city')
region=$(echo "$public_ip" | jq -r '.region_name')
zip=$(echo "$public_ip" | jq -r '.zip_code')
country=$(echo "$public_ip" | jq -r '.country')
lat=$(echo "$public_ip" | jq -r '.latitude')
long=$(echo "$public_ip" | jq -r '.longitude')
time_zone=$(echo "$public_ip" | jq -r '.time_zone')
asn_org=$(echo "$public_ip" | jq -r '.asn_org')
echo ""
echo "IP: $ip"
echo ""
echo "${ORANGE}Address:${RESET} $city, $region, $zip, $country"
echo "${ORANGE}Latitude & Longitude:${RESET} ($lat, $long)"
echo "${ORANGE}Timezone:${RESET} $time_zone"
echo "${ORANGE}ASN Org:${RESET} $asn_org"

echo ""
sys.info "Eth0 MAC Address:"
if sys.os.mac; then
    ifconfig en1 | awk '/ether/{print $2}'
else
    cat "/sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address"
fi
echo ""