import matplotlib.pyplot as plt

# Define your two log files and labels
log_files = [
    # ("./Data/H2D/H2D_1080_apollo_async_pinned.log", "1080-apollo"),  # Example first log
    # ("./Data/H2D/H2D_MI210_apollo_async_pinned.log", "MI210-apollo"),  # Example second log
    # ("./Data/H2D/H2D_V100_Titan03_async_pinned.log", "V100-Titan03"),  # Example second log
    # ("./Data/H2D/H2D_P100_Titan01_async_pinned.log", "P100-Titan01"),  # Example second log
    # # ("./Data/H2D/H2D_A100_IBM_async_pinned.log", "A100-IBM"),  # Example second log
    # ("./Data/H2D/H2D_A100_IBM_async_pinned_2.log", "A100-IBM-2"),  # Example second log
    # ("./Data/H2D/H2D_H100_Nano5_async_pinned.log", "H100_Nano5"),  # Example second log

    ("./Data/D2H/D2H_1080_apollo_async_pinned.log", "1080-apollo"),  # Example first log
    ("./Data/D2H/D2H_MI210_apollo_async_pinned.log", "MI210-apollo"),  # Example second log
    ("./Data/D2H/D2H_MI200_AMD_async_pinned.log", "MI200-AMD"),  # Example second log
    ("./Data/D2H/D2H_V100_Titan03_async_pinned.log", "V100-Titan03"),  # Example second log
    ("./Data/D2H/D2H_P100_Titan01_async_pinned.log", "P100-Titan01"),  # Example second log
    # ("./Data/D2H/D2H_A100_IBM_async_pinned.log", "A100-IBM"),
    # ("./Data/D2H/D2H_A100_IBM_async_pinned_2.log", "A100-IBM-2"),
    # ("./Data/D2H/D2H_A100_IBM_async_pinned_3.log", "A100-IBM-3"),
    # ("./Data/D2H/D2H_A100_IBM_async_pinned_100.log", "A100-IBM-100"),
    # ("./Data/D2H/D2H_A100_IBM_async_pinned_200.log", "A100-IBM-200"),
    ("./Data/D2H/D2H_A100_IBM_async_pinned_300.log", "A100-IBM"),
    ("./Data/D2H/D2H_H100_Nano5_async_pinned.log", "H100-Nano5"),
]

all_median_results = {}

# Read both log files
for log_path, label in log_files:
    median_results = []
    print(f"Reading log file {log_path}...")
    with open(log_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith("Num_Matrices") or not line:
                continue
            parts = line.split()
            if len(parts) == 2:
                num_matrices = int(parts[0])
                median_time = float(parts[1])
                median_results.append((num_matrices, median_time))
    all_median_results[label] = median_results

# Plotting
plt.figure(figsize=(10, 6))

for label, results in all_median_results.items():
    num_matrices = [num for num, _ in results]
    median_times = [median for _, median in results]
    plt.plot(num_matrices, median_times, label=f'{label} Median Transfer Time (ms)')

plt.xlabel('Number of Matrices')
plt.ylabel('Median Transfer Time (ms)')
plt.title('Transfer Time (Median) vs Number of Matrices')
plt.grid(True, which='both', linestyle='--', linewidth=0.5)
plt.legend()
plt.tight_layout()
plt.savefig("./Data/D2H_async_pinned_compare.png")
# plt.savefig("./Data/H2D_async_pinned_compare.png")
