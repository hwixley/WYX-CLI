#!/bin/bash

host="$1"
port_range="$2"

sys.log.h1 "Port Scanner"
sys.log.hr
sys.log.h2 "This script scans all the open ports on a given host."
sys.log.h2 "Usage: ./port-scan.sh <host> <port-range>"
sys.log.hr
echo ""
if ! wyxd.arggt "1"; then
    host=$(sys.util.inlineread "Enter the host to scan (defaults to 'localhost'): ")
fi
if ! wyxd.arggt "2"; then
    port_range=$(sys.util.inlineread "Enter the port range to scan (defaults to 1-10000): ")
fi
host=$(echo "$host" | sed 's/https\?:\/\///')
host=${host:-"localhost"}
port_range=${port_range:-"1-10000"}

sys.log.info "Scanning $host for open ports in the range $port_range with nmap..."
nmap -p "$port_range" "$host"