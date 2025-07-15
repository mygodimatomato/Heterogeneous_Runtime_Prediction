import subprocess
import numpy as np
import matplotlib.pyplot as plt
# import pandas as pd
from collections import defaultdict
# the data looks like this : 
#Num_Matrices	Median_Transfer_Time_ms
#1	0.015440
#11	0.016240
#21	0.016000
#31	0.016720
#41	0.016480
#51	0.016321
#61	0.016640
#71	0.014160
#81	0.014320
#91	0.014720
#101	0.014800
#111	0.015040
#121	0.015280
# ...

executable = f"./Data/D2H/D2H_MI200_async_hip.log"  # Update if named differently

log = "D2H_MI200_async_hip"

median_results = []
# read the log executable file and load the data into media_results
print(f"Reading log file {executable}...")
for line in open(executable, 'r'):
    line = line.strip()
    if line.startswith("Num_Matrices") or not line:
        continue  # Skip header or empty lines
    parts = line.split()
    if len(parts) == 2:
        num_matrices = int(parts[0])
        median_time = float(parts[1])
        median_results.append((num_matrices, median_time))
# Compute median times


#plot the median results, and save the plot
plt.figure(figsize=(10, 6))
num_matrices = [num for num, _ in median_results]
median_times = [median for _, median in median_results]
plt.plot(num_matrices, median_times, linestyle='-', color='b', label='Median Transfer Time (ms)')
plt.xlabel('Number of Matrices')
plt.ylabel('Median Transfer Time (ms)')
plt.title('Transfer Time (Median) vs Number of Matrices')
plt.grid(True, which='both', linestyle='--', linewidth=0.5)
plt.legend()
plt.tight_layout()
plt.savefig(f"{log}.png")