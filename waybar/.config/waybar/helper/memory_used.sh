
#!/bin/bash
used_memory=$(free -m | awk '/^Mem:/ {print $3}')
used_memory_gb=$(awk "BEGIN {printf \"%.2f\", $used_memory/1024}")
echo "${used_memory_gb}GB"
