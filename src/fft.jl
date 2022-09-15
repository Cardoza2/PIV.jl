

function phimatrix(method::FFT, IW1, IW2)
    g1p = FFTW.fft(IW1)
    g2p = FFTW.fft(IW2)

    return real(FFTW.fftshift(FFTW.ifft(g1p.*conj(g2p))))
end

function getvelocity(method::FFT, phi)
    N, M = size(phi)
    _, idx = findmax(phi)
    x0 = ceil(Int64, M/2)
    y0 = ceil(Int64, N/2)

    return -(idx[2]-x0-1), (idx[1]-y0-1) #The negative ones push the velocities to zero when the same image is input. 
end

function searchimagepair(method::FFT, mat, IWsize, overlap, SWsize, border; verbose::Bool=true)

    if verbose
        println("Preparing analysis...")
    end
    
    iy, ix, numimages = size(mat)
    iwy, iwx = IWsize
    swy, swx = SWsize

    if numimages>2
        error("searchimagepair() is defined on two images.")
    end

    xiw, yiw, _, _ = getwindowlocations((iy, ix), IWsize, overlap, SWsize, border)

    numx = length(xiw)
    numy = length(yiw)

    velocity = Array{Int64, 3}(undef, numy, numx, 2)
    phi = Array{Float64, 2}(undef, iwy, iwx) 

    if verbose
        println("Analyzing...")
    end


    for i = 1:numy
        for j = 1:numx
            interrogationwindow_1 = view(mat, yiw[i]:yiw[i]+iwy-1, xiw[j]:xiw[j]+iwx-1, 1)

            interrogationwindow_2 = view(mat, yiw[i]:yiw[i]+iwy-1, xiw[j]:xiw[j]+iwx-1, 2) 

            phi .= phimatrix(method, interrogationwindow_1, interrogationwindow_2)
            
            velocity[i, j, 1], velocity[i, j, 2] = getvelocity(method, phi)
        end
    end
    
    if verbose
        println("Finished analyzing...")
    end
     
    return xiw.+(iwx/2), (iy+1).-(yiw.+(iwy/2)), velocity 
end