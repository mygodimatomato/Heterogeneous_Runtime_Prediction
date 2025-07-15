#include <cuda_runtime.h>
#include <iostream>
#include <cstdlib>
#include <ctime>
#include <vector>
#include <iomanip>  // for std::setw

#define MATRIX_SIZE 100
#define MAX_MATRICES 10000
#define device_id 3  // Change this to your desired GPU device ID

int main() {
    cudaSetDevice(device_id);
    srand(time(0));
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "Num_Matrices\tDtoH_Time_ms" << std::endl;

    for (int num_matrices = 1; num_matrices <= MAX_MATRICES; num_matrices += 10) {
        size_t total_elements = num_matrices * MATRIX_SIZE * MATRIX_SIZE;
        size_t bytes = total_elements * sizeof(float);

        // Allocate and fill host memory
        float* h_data = new float[total_elements];
        float* h_result = new float[total_elements];  // for device-to-host transfer
        for (size_t i = 0; i < total_elements; ++i) {
            h_data[i] = static_cast<float>(rand()) / RAND_MAX;
        }

        // Allocate device memory
        float* d_data;
        cudaError_t err = cudaMalloc(&d_data, bytes);
        if (err != cudaSuccess) {
            std::cerr << "cudaMalloc failed at n=" << num_matrices << ": "
                      << cudaGetErrorString(err) << std::endl;
            delete[] h_data;
            delete[] h_result;
            break;
        }

        // CUDA events for Host-to-Device
        // cudaEvent_t h2d_start, h2d_stop;
        // cudaEventCreate(&h2d_start);
        // cudaEventCreate(&h2d_stop);
        // cudaEventRecord(h2d_start);
        cudaMemcpy(d_data, h_data, bytes, cudaMemcpyHostToDevice);
        // cudaEventRecord(h2d_stop);
        // cudaEventSynchronize(h2d_stop);

        // float h2d_elapsed = 0.0f;
        // cudaEventElapsedTime(&h2d_elapsed, h2d_start, h2d_stop);

        // CUDA events for Device-to-Host
        cudaEvent_t d2h_start, d2h_stop;
        cudaEventCreate(&d2h_start);
        cudaEventCreate(&d2h_stop);
        cudaEventRecord(d2h_start);
        cudaMemcpy(h_result, d_data, bytes, cudaMemcpyDeviceToHost);
        cudaEventRecord(d2h_stop);
        cudaEventSynchronize(d2h_stop);

        float d2h_elapsed = 0.0f;
        cudaEventElapsedTime(&d2h_elapsed, d2h_start, d2h_stop);

        // Output
        std::cout << std::setw(12) << num_matrices << "\t"
                  << d2h_elapsed << std::endl;

        // Cleanup
        cudaEventDestroy(d2h_start);
        cudaEventDestroy(d2h_stop);
        cudaFree(d_data);
        delete[] h_data;
        delete[] h_result;
    }

    return 0;
}
