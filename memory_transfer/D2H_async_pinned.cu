#include <cuda_runtime.h>
#include <iostream>
#include <vector>
#include <iomanip>

#define MATRIX_SIZE   10
#define MAX_MATRICES  20000
#define GPU_ID        0

int main() {
    cudaSetDevice(GPU_ID);

    /* ---------- 1.  Stream + reusable pinned host buffer ---------- */
    cudaStream_t stream;
    cudaStreamCreate(&stream);

    const size_t max_elems = MAX_MATRICES * MATRIX_SIZE * MATRIX_SIZE;
    const size_t max_bytes = max_elems * sizeof(float);

    float* h_data = nullptr;                  // page-locked host memory
    cudaMallocHost(&h_data, max_bytes);       // so the copy can overlap

    std::cout << std::fixed << std::setprecision(6)
              << "Num_Matrices\tCopy_Time_ms\n";
              
    // run the cudaMemcpyAsync for warmup
    float* warmup = nullptr;
    cudaMalloc(&warmup, max_bytes);           // sync alloc OK in this micro-bench
    cudaMemcpyAsync(warmup, h_data, max_bytes,
                    cudaMemcpyHostToDevice, stream);
    cudaStreamSynchronize(stream);
    

    /* ---------- 2.  Timing loop ---------- */
    for (int n = 1; n <= MAX_MATRICES; n += 10) {
        size_t elems = n * MATRIX_SIZE * MATRIX_SIZE;
        size_t bytes = elems * sizeof(float);

        // /* fill the portion we’ll send */
        // for (size_t i = 0; i < elems; ++i)
        //     h_data[i] = static_cast<float>(rand()) / RAND_MAX;

        /* seed device buffer with something to copy back */
        float* d_data = nullptr;
        cudaMalloc(&d_data, bytes);
        cudaMemcpyAsync(d_data, h_data, bytes,          // cheap H2D warm-up
                        cudaMemcpyHostToDevice, stream);
        cudaStreamSynchronize(stream);                  // ensure data is ready

        /* events bracket ONLY the async D2H copy */
        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        cudaEventRecord(start, stream);
        cudaMemcpyAsync(h_data,      // ← destination now HOST
                        d_data,      // ← source is DEVICE
                        bytes,
                        cudaMemcpyDeviceToHost,  // ← D2H direction
                        stream);
        cudaEventRecord(stop, stream);

        cudaStreamSynchronize(stream);          // wait once per iteration

        float ms = 0.f;
        cudaEventElapsedTime(&ms, start, stop);

        std::cout << std::setw(12) << n << '\t' << ms << '\n';

        cudaEventDestroy(start); cudaEventDestroy(stop);
        cudaFree(d_data);
    }

    /* ---------- 3.  Cleanup ---------- */
    cudaFreeHost(h_data);
    cudaStreamDestroy(stream);
    return 0;
}
