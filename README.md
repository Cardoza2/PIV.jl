# PIV.jl
An simple PIV processing package in Julia that I wrote for my experimental fluids class. 

Note that the package is still under development. Currently there are 3 correlation methods:
1. Direct
2. Minimum Quadratic Difference (MQD)
3. Fast Fourier Transform (FFT)

Additional features include:
- Sub-pixel displacement (a 5 point Gaussian fit)
- A pre-processing contrast filter
- Some vector validation techniques:
  - Mean value test
  - median test using 8 neigbors
  - ratio of correlation peaks. 
- Vector replacement
  - 8 neighbor average
  - Decimation
- Vorticity calculations. Derivatives will be calculated by:
  - Central Difference
  - 8 point circulation using trapezoidal integration. 
  - Richardson Extrapolation
- Image set analysis

Features under development:
- Image set averaging

