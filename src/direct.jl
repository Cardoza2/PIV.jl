#=

=#


function correlate(method::Direct, IW1, IW2)
    return sum(sum(IW1.*IW2))
end

function phimatrix(method::Union{Direct, MQD}, IW, SW) 
    nw, mw = size(SW) #Size of the search window
    ni, mi = size(IW) #Size of the interrogation window
    ns = nw - ni + 1  #number of vertical searches
    ms = mw - mi + 1  #number of horizontal searches

    phi = Array{eltype(IW), 2}(undef, ns, ms)

    for i = 1:ns
        for j = 1:ms
            IWi = view(SW, i:i+ni-1,j:j+mi-1)

            phi[i,j] = correlate(method, IW, IWi)
        end
    end
    return phi
end

function phimatrix!(method::Union{Direct, MQD}, phi, IW, SW) 
    nw, mw = size(SW) #Size of the search window
    ni, mi = size(IW) #Size of the interrogation window
    ns = nw - ni + 1  #number of vertical searches
    ms = mw - mi + 1  #number of horizontal searches

    for i = 1:ns
        for j = 1:ms
            IWi = view(SW, i:i+ni-1,j:j+mi-1)

            phi[i,j] = correlate(method, IW, IWi)
        end
    end
end
 
function getvelocity(method::Direct, spd::SubPixelDisplacement, phi, xiw, yiw, xsw, ysw)  
    xstar, ystar = getmax(spd, phi)

    xv = xsw + xstar - 1
    yv = ysw + ystar - 1

    #Find the relative change. 
    return xv-xiw, -(yv-yiw) #Change y axis to positive up. 
end

export searchimagepair

function searchimagepair(method::Union{Direct, MQD}, mat, IWsize, overlap, SWsize, border; verbose::Bool=true, spd::SubPixelDisplacement=Gauss5Point())

    if verbose
        println("Preparing analysis...")
    end
    
    iy, ix, numimages = size(mat)
    iwy, iwx = IWsize
    swy, swx = SWsize

    if numimages>2
        error("searchimagepair() is defined on two images.")
    end

    xiw, yiw, xsw, ysw = getwindowlocations((iy, ix), IWsize, overlap, SWsize, border)


    if verbose
        println("Analyzing...")
    end

    

    ### Pre-allocate
    ns = swy - iwy + 1  #number of vertical searches
    ms = swx - iwx + 1  #number of horizontal searches
    numx = length(xiw)
    numy = length(yiw)

    phi = Array{eltype(mat), 2}(undef, ns, ms)
    velocity = Array{Float64, 3}(undef, numy, numx, 2)

    for j = 1:numx
        for i = 1:numy
            interrogationwindow = view(mat, yiw[i]:yiw[i]+iwy-1, xiw[j]:xiw[j]+iwx-1, 1)

            searchwindow = view(mat, ysw[i]:ysw[i]+swy-1, xsw[j]:xsw[j]+swx-1, 2) 

            phimatrix!(method, phi, interrogationwindow, searchwindow)

            velocity[i, j, 1], velocity[i, j, 2] = getvelocity(method, spd, phi, xiw[j], yiw[i], xsw[j], ysw[i])
            
        end
    end
    
    if verbose
        println("Finished analyzing...")
    end
     
    return xiw.+(iwx/2), (iy+1).-(yiw.+(iwy/2)), velocity 
end

function testratios!(method::Union{Direct, FFT}, flagged, phi, cpr, ncpr, cprn, i, j)
    n, m = size(phi)
    idxs = CartesianIndex[]

    phicopy = deepcopy(phi)  
    phimax, maxidx = findmax(phicopy)
    maxi = maxidx

    for k = 1:ncpr
        xidxs = maxi[2]-cprn:maxi[2]+cprn  
        yidxs = maxi[1]-cprn:maxi[1]+cprn

        if maxi[1]==1 #Top edge
            yidxs = maxi[1]:maxi[1]+cprn
        elseif maxi[1]==n #Bot edge
            yidxs = maxi[1]-cprn:maxi[1]
        end

        if maxi[2]==1 #Left edge
            xidxs = maxi[2]:maxi[2]+cprn
        elseif maxi[2]==m #Right edge
            xidxs = maxi[2]-cprn:maxi[2]
        end


        phicopy[yidxs, xidxs] .= 0.0

        _, maxi = findmax(phicopy)

        if phicopy[maxi]>=cpr*phimax
            push!(idxs, maxi)
        end
    end
    if length(idxs)>0
        push!(flagged, (vidx=CartesianIndex(i,j), maxidxs=idxs, phi=deepcopy(phi)))
    end
    # @show flagged
end

function searchimagepair(method::Union{Direct, MQD}, mat, IWsize, overlap, SWsize, border, cpr; verbose::Bool=true, spd::SubPixelDisplacement=Gauss5Point(), ncpr::Int=1, cprn::Int=3)

    if verbose
        println("Preparing analysis...")
    end

    
    iy, ix, numimages = size(mat)
    iwy, iwx = IWsize
    swy, swx = SWsize

    if numimages>2
        error("searchimagepair() is defined on two images.")
    end

    
    xiw, yiw, xsw, ysw = getwindowlocations((iy, ix), IWsize, overlap, SWsize, border)


    if verbose
        println("Analyzing...")
    end

    

    ### Pre-allocate
    ns = swy - iwy + 1  #number of vertical searches
    ms = swx - iwx + 1  #number of horizontal searches
    numx = length(xiw)
    numy = length(yiw)

    ### Check if the ratio flattening window is larger than the correlation matrix.  
    if cprn>ns||cprn>ms
        @warn("The ratio test flattening window is larger than the correlation matrix. Reducing in size.")
        cprn = minimum(ns, ms)
    end

    phi = Array{eltype(mat), 2}(undef, ns, ms)
    velocity = Array{Float64, 3}(undef, numy, numx, 2)
    flagged = [] #Array{Tuple{Array{CaresianIndex, 1}, Array{Float64, 2}}, 1}(undef, ncpr)

    for j = 1:numx
        for i = 1:numy
            interrogationwindow = view(mat, yiw[i]:yiw[i]+iwy-1, xiw[j]:xiw[j]+iwx-1, 1)

            searchwindow = view(mat, ysw[i]:ysw[i]+swy-1, xsw[j]:xsw[j]+swx-1, 2) 

            phimatrix!(method, phi, interrogationwindow, searchwindow)

            testratios!(method, flagged, phi, cpr, ncpr, cprn, i, j)

            velocity[i, j, 1], velocity[i, j, 2] = getvelocity(method, spd, phi, xiw[j], yiw[i], xsw[j], ysw[i])
            
        end
    end
    
    if verbose
        println("Finished analyzing...")
    end
     
    return xiw.+(iwx/2), (iy+1).-(yiw.+(iwy/2)), velocity, flagged
end

