import subprocess
import numpy as np
import matplotlib.pyplot as plt
# import pandas as pd
from collections import defaultdict

# Path to the CUDA executable
file = "D2H_async"
executable = f"./{file}"  # Update if named differently

log = "D2H_Titan03_V100_async"  # Log file name

# How many times to run the program
num_runs = 10

# Dictionary to accumulate timings
timing_accumulator = defaultdict(list)

print(f"Running CUDA program {num_runs} times...")

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
        print(f"Run {run + 1} failed with error:\n{e.stderr}")

# Compute average times
# averaged_results = []
median_results = []
# std_dev_results = []
# percentile_95_results = []
for num in sorted(timing_accumulator.keys()):
    times = timing_accumulator[num]
    # average_time = np.mean(times)
    median_time = np.median(times)
    # std_dev_time = np.std(times)
    # percentile_95_time = np.percentile(times, 95)
    # averaged_results.append((num, average_time))
    median_results.append((num, median_time))
    # std_dev_results.append((num, std_dev_time))
    # percentile_95_results.append((num, percentile_95_time))

# Print results
# print("\n\nResults:")
# print("Num_Matrices\tAverage_Transfer_Time_ms\tMedian_Transfer_Time_ms\tStandard_Deviation_ms\t95th_Percentile_ms")
# print("Num_Matrices\tMedian_Transfer_Time_ms")
# for num, median in median_results:
#     print(f"{num:12}\t{median:.6f}")

#plot the median results, and save the plot
# plt.figure(figsize=(10, 6))
# num_matrices = [num for num, _ in median_results]
# median_times = [median for _, median in median_results]
# plt.plot(num_matrices, median_times, linestyle='-', color='b', label='Median Transfer Time (ms)')
# plt.xlabel('Number of Matrices')
# plt.ylabel('Median Transfer Time (ms)')
# plt.title('Transfer Time (Median) vs Number of Matrices')
# plt.grid(True, which='both', linestyle='--', linewidth=0.5)
# plt.legend()
# plt.tight_layout()
# plt.savefig(f"{log}.png")


# Optional: save to a file, file name is log name with .log extension
with open(f"{log}.log", "w") as f:
    f.write("Num_Matrices\tMedian_Transfer_Time_ms\n")
    # for num, avg in averaged_results:
    for num, median in median_results:
        median = dict(median_results).get(num, 0)
        # std_dev = dict(std_dev_results).get(num, 0)
        # percentile_95 = dict(percentile_95_results).get(num, 0)
        f.write(f"{num}\t{median:.6f}\n")
        # f.write(f"{num}\t{avg:.6f}\t{median:.6f}\t{std_dev:.6f}\t{percentile_95:.6f}\n")

print(f"\nSaved results to '{log}.log'")
