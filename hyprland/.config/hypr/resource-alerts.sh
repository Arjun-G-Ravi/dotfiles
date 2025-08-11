#!/usr/bin/env bash

# Thresholds
CPU_THRESHOLDS=(70 80 90 95)
GPU_THRESHOLDS=(70 80 90)
RAM_THRESHOLDS=(10 12 15)

# State trackers
declare -A cpu_notified gpu_notified ram_notified
for t in "${CPU_THRESHOLDS[@]}"; do cpu_notified[$t]=false; done
for t in "${GPU_THRESHOLDS[@]}"; do gpu_notified[$t]=false; done
for t in "${RAM_THRESHOLDS[@]}"; do ram_notified[$t]=false; done

# CPU temperature
get_cpu_temp() {
  sensors 2>/dev/null | awk '
    /Package id 0/ || /Tdie/ || /Tctl/ || /Core 0/ {
      for(i=1;i<=NF;i++) if ($i ~ /\+[0-9]+(\.[0-9]+)?°C/) {
        gsub(/[^0-9.]/,"",$i); print $i; exit
      }
    }' | head -n1
}

# GPU temperature
get_gpu_temp() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1
  else
    sensors 2>/dev/null | awk 'match($0, /[0-9]+(\.[0-9]+)?°C/) { t=substr($0,RSTART,RLENGTH); gsub(/°C/,"",t); print t; exit }' | head -n1
  fi
}

# RAM used in GB
get_ram_used_gb() {
  free -m | awk '/Mem:/ { printf "%.0f", $3/1024 }'
}

while true; do
  cpu_temp=$(get_cpu_temp || true)
  gpu_temp=$(get_gpu_temp || true)
  ram_used=$(get_ram_used_gb || true)

  # CPU checks
  if [[ -n "$cpu_temp" ]]; then
    cpu_val=${cpu_temp%.*}
    for t in "${CPU_THRESHOLDS[@]}"; do
      if (( cpu_val > t )) && [[ ${cpu_notified[$t]} = false ]]; then
        notify-send -t 10000 "CPU Temperature exceeded ${t}°C" "CPU Temperature: ${cpu_temp}°C"
        cpu_notified[$t]=true
      elif (( cpu_val < t - 10 )); then
        cpu_notified[$t]=false
      fi
    done
  fi

  # GPU checks
  if [[ -n "$gpu_temp" ]]; then
    gpu_val=${gpu_temp%.*}
    for t in "${GPU_THRESHOLDS[@]}"; do
      if (( gpu_val > t )) && [[ ${gpu_notified[$t]} = false ]]; then
        notify-send -t 10000 "GPU Temperature exceeded ${t}°C" "GPU Temperature: ${gpu_temp}°C"
        gpu_notified[$t]=true
      elif (( gpu_val < t - 10 )); then
        gpu_notified[$t]=false
      fi
    done
  fi

  # RAM checks
  if [[ -n "$ram_used" ]]; then
    for t in "${RAM_THRESHOLDS[@]}"; do
      if (( ram_used > t )) && [[ ${ram_notified[$t]} = false ]]; then
        notify-send -t 10000 "RAM Usage exceeded ${t} GB" "RAM Usage: ${ram_used} GB"
        ram_notified[$t]=true
      elif (( ram_used < t - 3 )); then
        ram_notified[$t]=false
      fi
    done
  fi
  echo 'hi'

  sleep 1
done
