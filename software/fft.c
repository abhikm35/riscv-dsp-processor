//=============================================================================
// FFT Implementation for RISC-V DSP Processor
// Optimized for hardware MAC unit and bit-reverse addressing
//=============================================================================

#include "dsp_math.h"

// Complex number structure
typedef struct {
    int16_t real;
    int16_t imag;
} complex_t;

// FFT structure
typedef struct {
    complex_t *twiddle_factors;  // Twiddle factors
    complex_t *temp_buffer;      // Temporary buffer
    int16_t fft_size;           // FFT size (power of 2)
    int16_t log2_size;          // Log2 of FFT size
} fft_t;

// Initialize FFT
void fft_init(fft_t *fft, int16_t size) {
    fft->fft_size = size;
    fft->log2_size = 0;
    
    // Calculate log2 of size
    int16_t temp = size;
    while (temp > 1) {
        temp >>= 1;
        fft->log2_size++;
    }
    
    // Allocate memory for twiddle factors and temp buffer
    fft->twiddle_factors = (complex_t*)malloc(size * sizeof(complex_t));
    fft->temp_buffer = (complex_t*)malloc(size * sizeof(complex_t));
    
    // Generate twiddle factors
    for (int i = 0; i < size; i++) {
        float angle = -2.0 * M_PI * i / size;
        fft->twiddle_factors[i].real = (int16_t)(cos(angle) * 32767);
        fft->twiddle_factors[i].imag = (int16_t)(sin(angle) * 32767);
    }
}

// Bit-reverse function using hardware support
int16_t bit_reverse(int16_t x, int16_t log2_size) {
    int16_t result = 0;
    for (int i = 0; i < log2_size; i++) {
        result = (result << 1) | (x & 1);
        x >>= 1;
    }
    return result;
}

// Complex multiplication using hardware MAC
complex_t complex_mul(complex_t a, complex_t b) {
    complex_t result;
    
    // Use hardware MAC for complex multiplication
    // (a + jb) * (c + jd) = (ac - bd) + j(ad + bc)
    int32_t real_part = mac(0, a.real, b.real) - mac(0, a.imag, b.imag);
    int32_t imag_part = mac(0, a.real, b.imag) + mac(0, a.imag, b.real);
    
    result.real = saturate_16(real_part);
    result.imag = saturate_16(imag_part);
    
    return result;
}

// Complex addition
complex_t complex_add(complex_t a, complex_t b) {
    complex_t result;
    result.real = saturate_16(a.real + b.real);
    result.imag = saturate_16(a.imag + b.imag);
    return result;
}

// Complex subtraction
complex_t complex_sub(complex_t a, complex_t b) {
    complex_t result;
    result.real = saturate_16(a.real - b.real);
    result.imag = saturate_16(a.imag - b.imag);
    return result;
}

// Radix-2 FFT implementation
void fft_radix2(fft_t *fft, complex_t *input, complex_t *output) {
    int16_t size = fft->fft_size;
    int16_t log2_size = fft->log2_size;
    
    // Bit-reverse the input
    for (int i = 0; i < size; i++) {
        int16_t reversed_index = bit_reverse(i, log2_size);
        output[i] = input[reversed_index];
    }
    
    // FFT computation
    for (int stage = 0; stage < log2_size; stage++) {
        int16_t group_size = 1 << stage;
        int16_t twiddle_step = size >> (stage + 1);
        
        for (int group = 0; group < size; group += 2 * group_size) {
            for (int k = 0; k < group_size; k++) {
                int16_t twiddle_index = k * twiddle_step;
                complex_t twiddle = fft->twiddle_factors[twiddle_index];
                
                int16_t index1 = group + k;
                int16_t index2 = group + k + group_size;
                
                complex_t temp = complex_mul(output[index2], twiddle);
                complex_t sum = complex_add(output[index1], temp);
                complex_t diff = complex_sub(output[index1], temp);
                
                output[index1] = sum;
                output[index2] = diff;
            }
        }
    }
}

// Inverse FFT
void ifft_radix2(fft_t *fft, complex_t *input, complex_t *output) {
    int16_t size = fft->fft_size;
    
    // Conjugate the input
    for (int i = 0; i < size; i++) {
        input[i].imag = -input[i].imag;
    }
    
    // Perform forward FFT
    fft_radix2(fft, input, output);
    
    // Conjugate and scale the output
    for (int i = 0; i < size; i++) {
        output[i].real = output[i].real >> fft->log2_size;
        output[i].imag = -output[i].imag >> fft->log2_size;
    }
}

// Real-valued FFT (input is real, output is complex)
void fft_real(fft_t *fft, int16_t *input, complex_t *output) {
    int16_t size = fft->fft_size;
    complex_t *temp = fft->temp_buffer;
    
    // Convert real input to complex
    for (int i = 0; i < size; i++) {
        temp[i].real = input[i];
        temp[i].imag = 0;
    }
    
    // Perform FFT
    fft_radix2(fft, temp, output);
}

// Real-valued IFFT (input is complex, output is real)
void ifft_real(fft_t *fft, complex_t *input, int16_t *output) {
    int16_t size = fft->fft_size;
    complex_t *temp = fft->temp_buffer;
    
    // Perform IFFT
    ifft_radix2(fft, input, temp);
    
    // Extract real part
    for (int i = 0; i < size; i++) {
        output[i] = temp[i].real;
    }
}

// Power spectrum calculation
void fft_power_spectrum(fft_t *fft, complex_t *fft_output, int16_t *power_spectrum) {
    int16_t size = fft->fft_size;
    
    for (int i = 0; i < size / 2; i++) {
        int32_t real_sq = mac(0, fft_output[i].real, fft_output[i].real);
        int32_t imag_sq = mac(0, fft_output[i].imag, fft_output[i].imag);
        int32_t power = real_sq + imag_sq;
        
        // Convert to dB scale (approximate)
        power_spectrum[i] = (int16_t)(10 * log10(power + 1));
    }
}

// Frequency domain filtering
void fft_filter(fft_t *fft, int16_t *input, int16_t *filter_response, int16_t *output) {
    int16_t size = fft->fft_size;
    complex_t *fft_input = fft->temp_buffer;
    complex_t *fft_output = (complex_t*)malloc(size * sizeof(complex_t));
    
    // Forward FFT
    fft_real(fft, input, fft_input);
    fft_radix2(fft, fft_input, fft_output);
    
    // Apply filter in frequency domain
    for (int i = 0; i < size; i++) {
        fft_output[i].real = (fft_output[i].real * filter_response[i]) >> 15;
        fft_output[i].imag = (fft_output[i].imag * filter_response[i]) >> 15;
    }
    
    // Inverse FFT
    ifft_real(fft, fft_output, output);
    
    free(fft_output);
}

// Cleanup FFT resources
void fft_cleanup(fft_t *fft) {
    if (fft->twiddle_factors) {
        free(fft->twiddle_factors);
        fft->twiddle_factors = NULL;
    }
    if (fft->temp_buffer) {
        free(fft->temp_buffer);
        fft->temp_buffer = NULL;
    }
}
