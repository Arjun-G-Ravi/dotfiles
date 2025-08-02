
#!/bin/bash
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
cpu_usage_int=$(printf "%.0f" "$cpu_usage")
# cpu_temp=$(sensors | awk '/k10temp-pci-00c3/{flag=1; next} flag && /Tctl/{print $2; exit}' | sed 's/+//')

# echo "${cpu_usage_int}% @ ${cpu_temp}"
#!/bin/bash
cpu_temp=$(sensors | awk '/k10temp-pci-00c3/{flag=1; next} flag && /Tctl/{print $2; exit}' | sed 's/+//' | awk '{print int($1)}')

echo "${cpu_usage_int}% @ ${cpu_temp}°C"
