

function phimatrix(method::FFT, IW1, IW2)
    g1 = FFTW.fft(IW1)
    g2 = FFTW.fft(IW2)

    return real(FFTW.fftshift(FFTW.ifft(g1.*conj(g2))))
end