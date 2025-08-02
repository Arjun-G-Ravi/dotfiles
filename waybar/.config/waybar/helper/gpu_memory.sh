
#!/bin/bash
used_memory=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
used_memory_gb=$(awk "BEGIN {printf \"%.2f\", $used_memory/1024}")
echo "${used_memory_gb}GB"
