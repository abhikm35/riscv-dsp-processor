//=============================================================================
// Main DSP Application for RISC-V DSP Processor
// Demonstrates FIR filtering and FFT processing
//=============================================================================

#include "dsp_math.h"
#include "fir_filter.h"
#include "fft.h"
#include <stdio.h>

#define FFT_SIZE 256
#define FIR_TAPS 64
#define BUFFER_SIZE 1024

// Global variables
int16_t input_buffer[BUFFER_SIZE];
int16_t output_buffer[BUFFER_SIZE];
int16_t fir_coeffs[FIR_TAPS];
int16_t fir_delay_line[FIR_TAPS];
complex_t fft_output[FFT_SIZE];
int16_t power_spectrum[FFT_SIZE/2];

// Function prototypes
void generate_test_signal(int16_t *signal, int16_t length);
void process_fir_filter(int16_t *input, int16_t *output, int16_t length);
void process_fft(int16_t *input, int16_t length);
void display_results(int16_t *input, int16_t *output, int16_t length);

int main() {
    printf("RISC-V DSP Processor Test Application\n");
    printf("=====================================\n\n");
    
    // Initialize FIR filter
    fir_filter_t fir_filter;
    fir_init(&fir_filter, fir_coeffs, fir_delay_line, FIR_TAPS);
    
    // Design low-pass FIR filter (cutoff at 0.1 * fs)
    fir_design_lowpass(fir_coeffs, FIR_TAPS, 1000, 10000); // 1kHz cutoff, 10kHz sample rate
    
    // Initialize FFT
    fft_t fft;
    fft_init(&fft, FFT_SIZE);
    
    printf("Generated test signal with multiple frequency components...\n");
    generate_test_signal(input_buffer, BUFFER_SIZE);
    
    printf("Processing signal through FIR low-pass filter...\n");
    process_fir_filter(input_buffer, output_buffer, BUFFER_SIZE);
    
    printf("Performing FFT analysis...\n");
    process_fft(output_buffer, FFT_SIZE);
    
    printf("Displaying results...\n");
    display_results(input_buffer, output_buffer, BUFFER_SIZE);
    
    // Cleanup
    fft_cleanup(&fft);
    
    printf("\nDSP processing completed successfully!\n");
    return 0;
}

// Generate test signal with multiple frequency components
void generate_test_signal(int16_t *signal, int16_t length) {
    for (int i = 0; i < length; i++) {
        float t = (float)i / 10000.0; // 10kHz sample rate
        float signal_val = 0;
        
        // Add multiple frequency components
        signal_val += 0.5 * sin(2 * M_PI * 500 * t);   // 500Hz component
        signal_val += 0.3 * sin(2 * M_PI * 1500 * t);  // 1.5kHz component
        signal_val += 0.2 * sin(2 * M_PI * 3000 * t);  // 3kHz component
        signal_val += 0.1 * sin(2 * M_PI * 5000 * t);  // 5kHz component
        
        // Add noise
        signal_val += 0.05 * ((float)rand() / RAND_MAX - 0.5);
        
        // Convert to 16-bit fixed point
        signal[i] = (int16_t)(signal_val * 32767);
    }
}

// Process signal through FIR filter
void process_fir_filter(int16_t *input, int16_t *output, int16_t length) {
    fir_filter_t fir_filter;
    fir_init(&fir_filter, fir_coeffs, fir_delay_line, FIR_TAPS);
    
    // Process signal sample by sample
    for (int i = 0; i < length; i++) {
        output[i] = fir_process(&fir_filter, input[i]);
    }
    
    printf("FIR filter processing completed. Filter taps: %d\n", FIR_TAPS);
}

// Process signal through FFT
void process_fft(int16_t *input, int16_t length) {
    fft_t fft;
    fft_init(&fft, FFT_SIZE);
    
    // Perform FFT on first FFT_SIZE samples
    fft_real(&fft, input, fft_output);
    
    // Calculate power spectrum
    fft_power_spectrum(&fft, fft_output, power_spectrum);
    
    fft_cleanup(&fft);
    printf("FFT processing completed. FFT size: %d\n", FFT_SIZE);
}

// Display processing results
void display_results(int16_t *input, int16_t *output, int16_t length) {
    printf("\nResults Summary:\n");
    printf("================\n");
    
    // Calculate signal statistics
    int32_t input_sum = 0, output_sum = 0;
    int32_t input_sq_sum = 0, output_sq_sum = 0;
    
    for (int i = 0; i < length; i++) {
        input_sum += input[i];
        output_sum += output[i];
        input_sq_sum += input[i] * input[i];
        output_sq_sum += output[i] * output[i];
    }
    
    float input_rms = sqrt((float)input_sq_sum / length);
    float output_rms = sqrt((float)output_sq_sum / length);
    
    printf("Input signal RMS: %.2f\n", input_rms);
    printf("Output signal RMS: %.2f\n", output_rms);
    printf("Signal attenuation: %.2f dB\n", 20 * log10(output_rms / input_rms));
    
    // Display power spectrum peaks
    printf("\nPower Spectrum Peaks:\n");
    int16_t max_power = 0;
    int16_t peak_freq = 0;
    
    for (int i = 1; i < FFT_SIZE/2; i++) {
        if (power_spectrum[i] > max_power) {
            max_power = power_spectrum[i];
            peak_freq = i * 10000 / FFT_SIZE; // Convert to Hz
        }
    }
    
    printf("Peak frequency: %d Hz\n", peak_freq);
    printf("Peak power: %d dB\n", max_power);
    
    // Display frequency components
    printf("\nFrequency Components (> -20 dB):\n");
    for (int i = 1; i < FFT_SIZE/2; i++) {
        if (power_spectrum[i] > max_power - 20) {
            printf("  %d Hz: %d dB\n", i * 10000 / FFT_SIZE, power_spectrum[i]);
        }
    }
    
    // Display sample values
    printf("\nSample Values (first 10 samples):\n");
    printf("Input -> Output\n");
    for (int i = 0; i < 10; i++) {
        printf("%6d -> %6d\n", input[i], output[i]);
    }
}

// Interrupt service routine for real-time processing
void __attribute__((interrupt)) dsp_isr() {
    static int16_t sample_count = 0;
    static int16_t adc_sample;
    
    // Read ADC sample
    adc_sample = read_adc();
    
    // Process through FIR filter
    input_buffer[sample_count] = adc_sample;
    output_buffer[sample_count] = fir_process(&fir_filter, adc_sample);
    
    // Update sample count
    sample_count = (sample_count + 1) % BUFFER_SIZE;
    
    // Trigger FFT processing when buffer is full
    if (sample_count == 0) {
        process_fft(output_buffer, FFT_SIZE);
    }
}

// ADC read function (hardware specific)
int16_t read_adc() {
    // This would interface with the actual ADC hardware
    // For simulation, return a random value
    return (int16_t)(rand() % 65536 - 32768);
}

// Timer interrupt for periodic processing
void __attribute__((interrupt)) timer_isr() {
    static int16_t timer_count = 0;
    
    timer_count++;
    
    // Process FFT every 100 timer interrupts
    if (timer_count >= 100) {
        timer_count = 0;
        process_fft(output_buffer, FFT_SIZE);
    }
}
