#include <cuda_runtime.h>
#include <iostream>
#include <cstdlib>
#include <ctime>
#include <vector>
#include <iomanip>  // for std::setw

#define MATRIX_SIZE 10
#define MAX_MATRICES 20000
#define GPU_ID 0  // Change this to your desired GPU device ID

int main() {
    cudaSetDevice(GPU_ID);

    const size_t max_elems  = MAX_MATRICES * MATRIX_SIZE * MATRIX_SIZE;
    const size_t max_bytes  = max_elems * sizeof(float);

    float* h_data = nullptr;  // Host memory
    h_data = (float*)malloc(max_bytes);

    std::cout << std::fixed << std::setprecision(6)
              << "Num_Matrices\tCopy_Time_ms\n";

    for (int n = 1; n <= MAX_MATRICES; n += 10) {
        size_t elems = n * MATRIX_SIZE * MATRIX_SIZE;
        size_t bytes = elems * sizeof(float);

        // Allocate and fill host memory
        for (size_t i = 0; i < elems; ++i) {
            h_data[i] = static_cast<float>(rand()) / RAND_MAX;
        }

        // Allocate device memory
        float* d_data = nullptr;
        cudaMalloc(&d_data, bytes);

        // Setup CUDA events
        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        // Record timing for cudaMemcpy
        cudaEventRecord(start);
        cudaMemcpy(d_data, h_data, bytes, cudaMemcpyHostToDevice);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float ms = 0;
        cudaEventElapsedTime(&ms, start, stop);

        // Print result
        std::cout << std::setw(12) << n << "\t" << ms << std::endl;

        // Cleanup
        cudaEventDestroy(start);
        cudaEventDestroy(stop);
        cudaFree(d_data);
    }

    free(h_data);
    return 0;
}
