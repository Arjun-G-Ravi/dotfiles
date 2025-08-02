#!/bin/bash

# Get GPU temperature (NVIDIA)
gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)

# Output the temperature
echo "${gpu_temp}°C"
