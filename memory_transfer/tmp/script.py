import subprocess
import numpy as np
import argparse
# import matplotlib.pyplot as plt
from collections import defaultdict

# --- Argument parsing ---
parser = argparse.ArgumentParser(description="Run CUDA executable multiple times and log median transfer times.")
parser.add_argument("--file", required=True, help="Name of the CUDA executable (without './')")
parser.add_argument("--log", required=True, help="Base name for log output files")
parser.add_argument("--runs", type=int, default=10, help="Number of times to run the executable")
args = parser.parse_args()

executable = f"./{args.file}"
log = args.log
num_runs = args.runs

# --- Timing dictionary ---
timing_accumulator = defaultdict(list)

print(f"Running {executable} {num_runs} times...")

for run in range(num_runs):
    print(f"Run {run + 1}/{num_runs}", end='\r')
    try:
        result = subprocess.run([executable], capture_output=True, text=True, check=True)
        lines = result.stdout.strip().split("\n")

        for line in lines:
            if line.startswith("Num_Matrices") or line.startswith("Using"):
                continue
            parts = line.strip().split()
            if len(parts) == 2:
                num, time = int(parts[0]), float(parts[1])
                timing_accumulator[num].append(time)
    except subprocess.CalledProcessError as e:
        print(f"\nRun {run + 1} failed:\n{e.stderr}")

# --- Compute median ---
median_results = []
for num in sorted(timing_accumulator.keys()):
    median_time = np.median(timing_accumulator[num])
    median_results.append((num, median_time))

# --- Save log ---
with open(f"{log}.log", "w") as f:
    f.write("Num_Matrices\tMedian_Transfer_Time_ms\n")
    for num, median in median_results:
        f.write(f"{num}\t{median:.6f}\n")

print(f"\nSaved results to '{log}.log'")
