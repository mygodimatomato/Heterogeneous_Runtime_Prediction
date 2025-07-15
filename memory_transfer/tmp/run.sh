#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Compiling CUDA programs..."
nvcc -o H2D_async_pinned H2D_async_pinned.cu
nvcc -o D2H_async_pinned D2H_async_pinned.cu

echo "Running H2D benchmark..."
python3 script.py --file H2D_async_pinned --log H2D_H100_Nano5_async_pinned --runs 30

echo "Running D2H benchmark..."
python3 script.py --file D2H_async_pinned --log D2H_H100_Nano5_async_pinned --runs 100

echo "Running hardware spec script..."
bash ./hardware_spec.sh

echo "All tasks completed."
