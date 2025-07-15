#include <cuda_runtime.h>
#include <iostream>
#include <vector>
#include <iomanip>

#define MATRIX_SIZE   10
#define MAX_MATRICES  20000
#define GPU_ID        0          // pick your device

int main() {
    cudaSetDevice(GPU_ID);

    /* ---------- 1.  Create one stream and one reusable pinned buffer ---------- */
    cudaStream_t stream;
    cudaStreamCreate(&stream);

    const size_t max_elems  = MAX_MATRICES * MATRIX_SIZE * MATRIX_SIZE;
    const size_t max_bytes  = max_elems * sizeof(float);

    float* h_data = nullptr;                 // page-locked host memory
    // cudaMallocHost(&h_data, max_bytes);      // ALWAYS pinned if you want overlap
    // call malloc and assign a size = max_bytes of h_data
    h_data = (float*)malloc(max_bytes); // Use malloc for simplicity in this example

    std::cout << std::fixed << std::setprecision(6)
              << "Num_Matrices\tCopy_Time_ms\n";

    /* ---------- 2.  Timing loop ---------- */
    for (int n = 1; n <= MAX_MATRICES; n += 10) {
        size_t elems  = n * MATRIX_SIZE * MATRIX_SIZE;
        size_t bytes  = elems * sizeof(float);

        /* fill the portion we’ll send */
        for (size_t i = 0; i < elems; ++i)
            h_data[i] = static_cast<float>(rand()) / RAND_MAX;

        float* d_data = nullptr;
        cudaMalloc(&d_data, bytes);          // sync alloc OK in this micro-bench

        /* events live in the SAME stream so they bracket only the async copy */
        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        cudaEventRecord(start, stream);
        cudaMemcpyAsync(d_data, h_data, bytes,
                        cudaMemcpyHostToDevice, stream);
        cudaEventRecord(stop, stream);

        cudaStreamSynchronize(stream);       // wait just once per iteration

        float ms = 0.f;
        cudaEventElapsedTime(&ms, start, stop);

        std::cout << std::setw(12) << n << '\t' << ms << '\n';

        cudaEventDestroy(start);
        cudaEventDestroy(stop);
        cudaFree(d_data);
    }

    /* ---------- 3.  Cleanup ---------- */
    cudaFreeHost(h_data);
    cudaStreamDestroy(stream);
    return 0;
}
