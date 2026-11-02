# ECG R-Peak Detection Using Adaptive Thresholding in MATLAB

A MATLAB-based ECG signal processing project for accurate R-peak detection, heart-rate estimation, and comparative analysis of thresholding techniques using **Wavelet Transform, Hilbert Transform, and Adaptive Thresholding**.

## Overview

Electrocardiography (ECG) is widely used to monitor the electrical activity of the heart. R-peak detection is an important step in ECG analysis because it enables the calculation of RR intervals and heart rate.

This project implements an interactive MATLAB GUI for ECG R-peak detection using a combination of signal preprocessing, QRS feature enhancement, adaptive thresholding, and peak localization.

The system also compares three different thresholding approaches to evaluate their detection performance.

## Features

- ECG signal loading from MIT-BIH records, local DAT files, and MAT files.
- Interactive MATLAB GUI for ECG analysis.
- ECG preprocessing using Butterworth band-pass filtering.
- QRS enhancement using Stationary Wavelet Transform (SWT).
- Hilbert envelope extraction for improved QRS feature representation.
- Classical derivative-based detection as an alternative approach.
- Three-level adaptive thresholding with search-back mechanism.
- Comparison of three thresholding methods.
- R-peak localization and visualization.
- RR interval and heart-rate calculation.
- Performance evaluation using Sensitivity, PPV, Accuracy, and F1 Score.
- Visualization of intermediate processing stages and threshold histories.

## Methodology

The project follows the following signal processing pipeline:

```text
ECG Signal Input
       |
       v
Signal Preprocessing
       |
       v
Butterworth Band-Pass Filtering
       |
       v
QRS Feature Enhancement
       |
       +---------------------------+
       |                           |
       v                           v
Wavelet Transform             Classical Derivative
       |                           |
       v                           v
Hilbert Envelope              Squaring and Integration
       |                           |
       +-------------+-------------+
                     |
                     v
             Threshold Detection
                     |
                     v
              R-Peak Localization
                     |
                     v
              RR Interval Analysis
                     |
                     v
              Heart Rate Estimation
                     |
                     v
             Performance Evaluation
```

## Signal Processing Techniques

### 1. ECG Preprocessing

The input ECG signal is converted into a suitable numerical format, centered around its baseline, and processed using a Butterworth band-pass filter.

**Default filtering parameters:**

| Parameter | Value |
|---|---|
| Low cutoff frequency | 0.5 Hz |
| High cutoff frequency | 40 Hz |
| Filter order | 3 |
| Filtering method | Forward-backward filtering using `filtfilt` |

### 2. Wavelet-Based QRS Enhancement

The Stationary Wavelet Transform (SWT) is used to extract QRS-related features from the filtered ECG signal.

- Wavelet: `sym2`
- Decomposition level: 4

The wavelet detail emphasizes localized changes associated with the QRS complex.

### 3. Hilbert Transform

The Hilbert transform is used to obtain the envelope of the wavelet-derived signal.

The wavelet detail and Hilbert envelope are normalized and combined to generate a common detection feature.

### 4. Classical Derivative-Based Detection

A classical Pan-Tompkins-inspired approach is also implemented.

The processing steps include:

- Derivative calculation.
- Squaring of the derivative signal.
- Moving-window integration.
- Threshold-based QRS detection.

This method provides an alternative detection feature for comparison.

## Thresholding Methods

The project implements three thresholding strategies:

| Method | Description |
|---|---|
| 3-Level Adaptive | Uses high, normal, and search-back thresholds that adapt to signal and noise estimates. |
| 3-Level Fixed | Uses three threshold levels initialized from the initial signal and noise estimates and keeps them fixed. |
| Single-Level Adaptive | Uses a single adaptive threshold updated according to detected signal and noise peaks. |

The three methods operate on the same ECG segment and preprocessing pipeline to enable comparative evaluation.

## R-Peak Detection and Heart Rate Calculation

After threshold-based candidate detection, the candidates are mapped back to the filtered ECG signal for R-peak localization.

The system applies:

- Local peak search around candidate positions.
- Duplicate peak removal.
- Refractory period enforcement.
- Search-back for potentially missed beats.

The RR interval is calculated as:

\[
RR(i)=\frac{r_{i+1}-r_i}{F_s}
\]

where:

- \(r_i\) is the sample index of the detected R-peak.
- \(F_s\) is the sampling frequency.

Heart rate is calculated using:

\[
HR(i)=\frac{60}{RR(i)}
\]

The heart rate is expressed in beats per minute (BPM).

## Performance Evaluation

The detection performance is evaluated using the following metrics:

| Metric | Description |
|---|---|
| Sensitivity | Measures the proportion of actual R-peaks correctly detected. |
| Positive Predictive Value (PPV) | Measures the proportion of detected peaks that are correct. |
| Accuracy | Evaluates overall detection correctness. |
| F1 Score | Represents the harmonic mean of Sensitivity and PPV. |

The MATLAB GUI provides comparative plots to visualize the performance of the three thresholding approaches.

## Dataset

The project supports ECG signals from:

- MIT-BIH Arrhythmia Database through WFDB.
- Locally stored MIT-BIH DAT files.
- MATLAB MAT files containing ECG signals.

**Example configuration used in the project:**

| Parameter | Value |
|---|---|
| Dataset | MIT-BIH Arrhythmia Database |
| Record | 100 |
| Channel | 1 |
| Sampling frequency | 360 Hz |
| Analysis duration | 60 seconds |

The example configuration can be changed through the MATLAB GUI.

## Requirements

- MATLAB
- Signal Processing Toolbox
- Wavelet Toolbox for SWT-based feature extraction
- WFDB MATLAB toolbox for direct MIT-BIH record access

The classical derivative-based detection option can be used when the Wavelet Toolbox is unavailable.

## How to Run

1. Clone or download this repository.

2. Open MATLAB.

3. Navigate to the project directory.

4. Ensure the required MATLAB toolboxes are available.

5. Run the main MATLAB GUI script.

6. Select the ECG input source:
   - MIT-BIH record through WFDB.
   - Local DAT file.
   - MAT file.

7. Configure the ECG channel, start time, and duration.

8. Select the QRS feature extraction method.

9. Choose the thresholding method:
   - 3-Level Adaptive.
   - 3-Level Fixed.
   - Single-Level Adaptive.

10. Run the detection and inspect the ECG waveform, detected R-peaks, RR intervals, heart rate, and performance metrics.

**Note:** Replace the main script name in these instructions with the actual MATLAB GUI filename in your repository.

## GUI Outputs

The MATLAB GUI displays:

- Original ECG waveform.
- Filtered ECG waveform.
- SWT detail signal.
- Hilbert envelope.
- Fused detection feature.
- Classical derivative and integration feature.
- Detected R-peak locations.
- Adaptive threshold histories.
- Heart-rate summary.
- Comparative performance plots.

## Limitations

- Detection performance may vary with ECG signal quality and noise.
- SWT-based processing requires the Wavelet Toolbox.
- Threshold initialization can influence detection results.
- The refractory period and search-back settings may require adjustment for different ECG conditions.
- Further validation on additional ECG records is required for broader performance assessment.

## Future Scope

- Testing on additional ECG databases and records.
- Improving artifact rejection and noise robustness.
- Automated parameter optimization.
- Batch processing of multiple ECG recordings.
- Exporting detection results and performance metrics.
- Extending the system toward real-time ECG analysis.

## References

1. J. Pan and W. J. Tompkins, “A Real-Time QRS Detection Algorithm,” *IEEE Transactions on Biomedical Engineering*, 1985.
2. G. B. Moody and R. G. Mark, “The Impact of the MIT-BIH Arrhythmia Database,” *IEEE Engineering in Medicine and Biology Magazine*, 2001.
3. S. Mallat, *A Wavelet Tour of Signal Processing*, 3rd Edition, Academic Press, 2009.
4. MATLAB Documentation — Signal Processing Toolbox.
5. MATLAB Documentation — Wavelet Toolbox.

## Contributors

**Group 2 — Section F2**

Department of Electronics and Communication Engineering  
Motilal Nehru National Institute of Technology Allahabad  
Prayagraj, Uttar Pradesh, India

- Saksham Tiwari
- Samarth Bose
- Sameer Ali
- Sandeep Kumar

---

⭐ If you find this project useful, consider giving the repository a star!
