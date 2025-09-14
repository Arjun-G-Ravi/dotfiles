# #!/usr/bin/env bash

# Thresholds (temperatures)
CPU_THRESHOLDS=(65 70 80 90 95)
GPU_THRESHOLDS=(70 80 90)
RAM_THRESHOLDS=(8 10 12 15)

# Usage thresholds
CPU_USAGE_THRESHOLD=75        # %
GPU_USAGE_THRESHOLD=50        # %

# State trackers
declare -A cpu_notified gpu_notified ram_notified
for t in "${CPU_THRESHOLDS[@]}"; do cpu_notified[$t]=false; done
for t in "${GPU_THRESHOLDS[@]}"; do gpu_notified[$t]=false; done
for t in "${RAM_THRESHOLDS[@]}"; do ram_notified[$t]=false; done

performance_mode_enabled=false

# --- Temperature helpers ---

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

# --- Usage helpers ---

# CPU usage (percentage) over last interval using /proc/stat
# We keep previous total & idle to compute delta.
prev_cpu_total=
prev_cpu_idle=

get_cpu_usage() {
  # Read first line of /proc/stat
  read -r _ user nice system idle iowait irq softirq steal guest guest_n < /proc/stat
  local idle_all=$(( idle + iowait ))
  local non_idle=$(( user + nice + system + irq + softirq + steal ))
  local total=$(( idle_all + non_idle ))

  if [[ -n "$prev_cpu_total" ]]; then
    local total_d=$(( total - prev_cpu_total ))
    local idle_d=$(( idle_all - prev_cpu_idle ))
    if (( total_d > 0 )); then
      # scale to integer percentage
      awk -v t=$total_d -v i=$idle_d 'BEGIN { printf "%.0f", (t - i) * 100 / t }'
    else
      echo 0
    fi
  fi

  prev_cpu_total=$total
  prev_cpu_idle=$idle_all
}

# GPU usage percentage
get_gpu_usage() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1
  elif command -v rocm-smi >/dev/null 2>&1; then
    # Simplistic parse for ROCm usage (may vary by version)
    rocm-smi --showuse 2>/dev/null | awk '/GPU/ && /%/ {gsub(/%/,""); print $NF; exit}'
  else
    echo ""
  fi
}

# --- Performance mode activation ---

enable_performance_mode() {
  if [[ $performance_mode_enabled == true ]]; then
    return
  fi

  {
    sudo nvidia-smi -pl 400 2>/dev/null
    sudo cpupower frequency-set -g performance 2>/dev/null
  } &

  notify-send -t 8000 "Performance mode activated" "High system usage detected. Performance settings applied."
  performance_mode_enabled=true
}

# Initial prime of CPU usage (first call sets prev_* only)
get_cpu_usage >/dev/null 2>&1 || true

while true; do
  cpu_temp=$(get_cpu_temp || true)
  gpu_temp=$(get_gpu_temp || true)
  ram_used=$(get_ram_used_gb || true)
  cpu_usage=$(get_cpu_usage || true)
  gpu_usage=$(get_gpu_usage || true)

  # Performance mode condition (only once)
  if [[ $performance_mode_enabled == false ]]; then
    # Accept non-empty CPU/GPU usage values only
    triggered=false
    if [[ -n "$cpu_usage" && "$cpu_usage" =~ ^[0-9]+$ ]] && (( cpu_usage > CPU_USAGE_THRESHOLD )); then
      triggered=true
    fi
    if [[ -n "$gpu_usage" && "$gpu_usage" =~ ^[0-9]+$ ]] && (( gpu_usage > GPU_USAGE_THRESHOLD )); then
      triggered=true
    fi
    if [[ $triggered == true ]]; then
      enable_performance_mode
    fi
  fi

  # CPU temperature checks
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

  # GPU temperature checks
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

  # RAM usage checks
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


  sleep 1
done