#!/bin/bash

# Get CPU temperature from k10temp-pci-00c3 section
cpu_temp=$(sensors | awk '/k10temp-pci-00c3/{flag=1; next} flag && /Tctl/{print $2; exit}' | sed 's/+//')

# Output the temperature
echo "${cpu_temp}"
