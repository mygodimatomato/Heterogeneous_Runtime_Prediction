#include <hip/hip_runtime.h>
#include <iostream>
#include <vector>
#include <iomanip>

#define MATRIX_SIZE   10
#define MAX_MATRICES  20000
#define GPU_ID        0

int main() {
    hipSetDevice(GPU_ID);

    hipStream_t stream;
    hipStreamCreate(&stream);

    const size_t max_elems = MAX_MATRICES * MATRIX_SIZE * MATRIX_SIZE;
    const size_t max_bytes = max_elems * sizeof(float);

    float* h_data = nullptr;
    hipHostMalloc(&h_data, max_bytes);          // pinned host buffer

    std::cout << std::fixed << std::setprecision(6)
              << "Num_Matrices\tCopy_Time_ms\n";

    // run the hipMemcpyAsync for warmup
    float* warmup = nullptr;
    hipMalloc(&warmup, max_bytes);              // sync alloc OK in this micro-b
    hipMemcpyAsync(warmup, h_data, max_bytes,
                   hipMemcpyHostToDevice, stream);
    hipStreamSynchronize(stream);
    

    for (int n = 1; n <= MAX_MATRICES; n += 10) {
        size_t elems = n * MATRIX_SIZE * MATRIX_SIZE;
        size_t bytes = elems * sizeof(float);

        float* d_data = nullptr;
        hipMalloc(&d_data, bytes);

        hipMemcpyAsync(d_data, h_data, bytes,               // warm-up H→D
                       hipMemcpyHostToDevice, stream);
        hipStreamSynchronize(stream);

        hipEvent_t start, stop;
        hipEventCreate(&start);
        hipEventCreate(&stop);

        hipEventRecord(start, stream);
        hipMemcpyAsync(h_data, d_data, bytes,               // timed D→H
                       hipMemcpyDeviceToHost, stream);
        hipEventRecord(stop, stream);
        hipStreamSynchronize(stream);

        float ms = 0.f;
        hipEventElapsedTime(&ms, start, stop);
        std::cout << std::setw(12) << n << '\t' << ms << '\n';

        hipEventDestroy(start); hipEventDestroy(stop);
        hipFree(d_data);
    }

    hipHostFree(h_data);
    hipStreamDestroy(stream);
    return 0;
}