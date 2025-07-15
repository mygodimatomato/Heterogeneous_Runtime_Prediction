#include <hip/hip_runtime.h>
#include <iostream>
#include <vector>
#include <iomanip>

#define MATRIX_SIZE   10
#define MAX_MATRICES  20000
#define GPU_ID        0          // pick your device

int main() {
    hipSetDevice(GPU_ID);

    /* ---------- 1.  Create one stream and one reusable pinned buffer ---------- */
    hipStream_t stream;
    hipStreamCreate(&stream);

    const size_t max_elems  = MAX_MATRICES * MATRIX_SIZE * MATRIX_SIZE;
    const size_t max_bytes  = max_elems * sizeof(float);

    float* h_data = nullptr;                 // page-locked host memory
    hipHostMalloc(&h_data, max_bytes);      // ALWAYS pinned if you want overlap

    std::cout << std::fixed << std::setprecision(6)
              << "Num_Matrices\tCopy_Time_ms\n";

    // run the hipMemcpyAsync for warmup
    float* warmup = nullptr;
    hipMalloc(&warmup, max_bytes);          // sync alloc OK in this micro-bench
    hipMemcpyAsync(warmup, h_data, max_bytes,
                   hipMemcpyHostToDevice, stream);
    hipStreamSynchronize(stream);

    /* ---------- 2.  Timing loop ---------- */
    for (int n = 1; n <= MAX_MATRICES; n += 10) {
        size_t elems  = n * MATRIX_SIZE * MATRIX_SIZE;
        size_t bytes  = elems * sizeof(float);

        /* fill the portion we’ll send */
        for (size_t i = 0; i < elems; ++i)
            h_data[i] = static_cast<float>(rand()) / RAND_MAX;

        float* d_data = nullptr;
        hipMalloc(&d_data, bytes);          // sync alloc OK in this micro-bench

        /* events live in the SAME stream so they bracket only the async copy */
        hipEvent_t start, stop;
        hipEventCreate(&start);
        hipEventCreate(&stop);

        hipEventRecord(start, stream);
        hipMemcpyAsync(d_data, h_data, bytes,
                       hipMemcpyHostToDevice, stream);
        hipEventRecord(stop, stream);

        hipStreamSynchronize(stream);       // wait just once per iteration

        float ms = 0.f;
        hipEventElapsedTime(&ms, start, stop);

        std::cout << std::setw(12) << n << '\t' << ms << '\n';

        hipEventDestroy(start);
        hipEventDestroy(stop);
        hipFree(d_data);
    }

    /* ---------- 3.  Cleanup ---------- */
    hipHostFree(h_data);
    hipStreamDestroy(stream);
    return 0;
}
