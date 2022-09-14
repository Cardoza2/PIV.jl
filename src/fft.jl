

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

    return (-(idx[2]-x0), (idx[1]-y0))
end

function searchimagepair(method::FFT, mat, IWsize, overlap, SWsize, border; verbose::Bool=true)

    if verbose
        println("Preparing analysis...")
    end
    
    iy, ix, numimages = size(mat)
    iwy, iwx = IWsize
    swy, swx = SWsize

    # @show ix, iy

    if numimages>2
        error("searchimagepair() is defined on two images.")
    end

    xiw, yiw, _, _ = getwindowlocations((iy, ix), IWsize, overlap, SWsize, border)

    numx = length(xiw)
    numy = length(yiw)

    velocity = Array{Tuple{Int64, Int64}, 2}(undef, numy, numx) #TODO: Might need to transpose. 

    if verbose
        println("Analyzing...")
    end


    for i = 1:numy
        for j = 1:numx
            interrogationwindow = view(mat[:,:,1], yiw[i]:yiw[i]+iwy-1, xiw[j]:xiw[j]+iwx-1)

            searchwindow = view(mat[:,:,2], yiw[i]:yiw[i]+iwy-1, xiw[j]:xiw[j]+iwx-1) 

            phi = phimatrix(method, interrogationwindow, searchwindow)
            
            velocity[i,j] = getvelocity(method, phi)
        end
    end
    
    if verbose
        println("Finished analyzing...")
    end
    #Todo: I should convert the locations to be from the center of the IW. 
    return xiw, (iy+1).-yiw, velocity #(iy+1).-yiw, velocity
end