# PIV.jl
An simple PIV processing package in Julia that I wrote for my experimental fluids class. 

Note that the package is still under development. Currently there are 3 correlation methods:
1. Direct
2. Minimum Quadratic Difference (MQD)
3. Fast Fourier Transform (FFT)

Additional features include:
- Sub-pixel displacement (a 5 point Gaussian fit)
- A pre-processing contrast filter

Features under development:
- Some vector validation techniques:
  - Mean value test
  - median test using 8 neigbors
  - ratio of correlation peaks. 
- 8 neighbor average vector replacement
- Image set analysis
- Image set averaging
- Vorticity calculations. Derivatives will be calculated by:
  - By simple difference (a centrally averaged forward step difference technique)
  - 8 point circulation 
  - Central difference
  - Analytical derivative of fitted Akima splines. 
