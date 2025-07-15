#!/bin/bash

echo "===== GPU Information ====="
nvidia-smi -q > gpu_info.txt 2>/dev/null || rocm-smi --showallinfo > gpu_info.txt 2>/dev/null

echo "===== PCIe Information ====="
lspci -vv | grep -A 50 -E 'NVIDIA|AMD' > pcie_info.txt

echo "===== CPU Information ====="
lscpu > cpu_info.txt

echo "===== NUMA Information ====="
numactl --hardware > numa_info.txt

echo "===== RAM Information ====="
sudo dmidecode -t memory > ram_info.txt
