//=============================================================================
// DSP Math Library Header for RISC-V DSP Processor
// Hardware-optimized mathematical functions
//=============================================================================

#ifndef DSP_MATH_H
#define DSP_MATH_H

#include <stdint.h>
#include <math.h>

// Hardware MAC instruction wrapper
static inline int32_t mac(int32_t acc, int16_t a, int16_t b) {
    int32_t result;
    __asm__ volatile (
        "mac %0, %1, %2, %3"
        : "=r" (result)
        : "r" (acc), "r" (a), "r" (b)
    );
    return result;
}

// Hardware SIMD MAC instruction wrapper
static inline int32_t simd_mac4(int16_t *coeffs, int16_t *samples) {
    int32_t result;
    __asm__ volatile (
        "simd_mac4 %0, %1, %2"
        : "=r" (result)
        : "r" (coeffs), "r" (samples)
    );
    return result;
}

// Saturation function
static inline int16_t saturate_16(int32_t value) {
    if (value > 32767) return 32767;
    if (value < -32768) return -32768;
    return (int16_t)value;
}

// Clipping function
static inline int16_t clip(int16_t value, int16_t min_val, int16_t max_val) {
    if (value < min_val) return min_val;
    if (value > max_val) return max_val;
    return value;
}

// Rounding function
static inline int16_t round_16(int32_t value) {
    return (int16_t)((value + 16384) >> 15);
}

// Absolute value
static inline int16_t abs_16(int16_t value) {
    return (value < 0) ? -value : value;
}

// Maximum function
static inline int16_t max_16(int16_t a, int16_t b) {
    return (a > b) ? a : b;
}

// Minimum function
static inline int16_t min_16(int16_t a, int16_t b) {
    return (a < b) ? a : b;
}

// Square root (using Newton's method)
int16_t sqrt_16(int16_t value);

// Sine function (lookup table based)
int16_t sin_16(int16_t angle);

// Cosine function (lookup table based)
int16_t cos_16(int16_t angle);

// Arctangent function
int16_t atan2_16(int16_t y, int16_t x);

// Logarithm function (base 10)
int16_t log10_16(int16_t value);

// Exponential function
int16_t exp_16(int16_t value);

// Power function
int16_t pow_16(int16_t base, int16_t exponent);

// Convolution function
void convolution_16(int16_t *input, int16_t *kernel, int16_t *output, 
                   int16_t input_len, int16_t kernel_len);

// Correlation function
void correlation_16(int16_t *input1, int16_t *input2, int16_t *output, 
                   int16_t len1, int16_t len2);

// Moving average filter
void moving_average_16(int16_t *input, int16_t *output, int16_t length, int16_t window_size);

// Median filter
void median_filter_16(int16_t *input, int16_t *output, int16_t length, int16_t window_size);

// Peak detection
int16_t find_peaks_16(int16_t *input, int16_t *peaks, int16_t length, int16_t threshold);

// Signal normalization
void normalize_16(int16_t *input, int16_t *output, int16_t length);

// Signal scaling
void scale_16(int16_t *input, int16_t *output, int16_t length, int16_t scale_factor);

// Signal offset
void offset_16(int16_t *input, int16_t *output, int16_t length, int16_t offset);

// Signal addition
void add_16(int16_t *input1, int16_t *input2, int16_t *output, int16_t length);

// Signal subtraction
void sub_16(int16_t *input1, int16_t *input2, int16_t *output, int16_t length);

// Signal multiplication
void mul_16(int16_t *input1, int16_t *input2, int16_t *output, int16_t length);

// Signal division
void div_16(int16_t *input1, int16_t *input2, int16_t *output, int16_t length);

// Window functions
void hamming_window_16(int16_t *window, int16_t length);
void hanning_window_16(int16_t *window, int16_t length);
void blackman_window_16(int16_t *window, int16_t length);
void kaiser_window_16(int16_t *window, int16_t length, int16_t beta);

// Frequency domain operations
void magnitude_16(int16_t *real, int16_t *imag, int16_t *magnitude, int16_t length);
void phase_16(int16_t *real, int16_t *imag, int16_t *phase, int16_t length);

// Digital modulation functions
void bpsk_modulate_16(int16_t *bits, int16_t *output, int16_t length);
void qpsk_modulate_16(int16_t *bits, int16_t *output, int16_t length);
void bpsk_demodulate_16(int16_t *input, int16_t *bits, int16_t length);
void qpsk_demodulate_16(int16_t *input, int16_t *bits, int16_t length);

// Pulse shaping
void raised_cosine_filter_16(int16_t *input, int16_t *output, int16_t length, 
                            int16_t rolloff_factor, int16_t samples_per_symbol);

// Timing recovery
int16_t timing_recovery_16(int16_t *input, int16_t length);

// Carrier recovery
int16_t carrier_recovery_16(int16_t *input, int16_t length);

// Adaptive equalization
void lms_equalizer_16(int16_t *input, int16_t *desired, int16_t *output, 
                     int16_t length, int16_t filter_length, int16_t step_size);

// Noise generation
void awgn_16(int16_t *output, int16_t length, int16_t snr_db);

// Signal quality metrics
int16_t snr_estimate_16(int16_t *signal, int16_t *noise, int16_t length);
int16_t ber_estimate_16(int16_t *transmitted, int16_t *received, int16_t length);

#endif // DSP_MATH_H
