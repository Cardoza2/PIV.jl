#=

=#

# function correlate(IW1, IW2)
#     N, M = size(IW1)
#     # phi = Array{eltype(IW1), 2}(undef, N, M)
#     phi = 0.0

#     for i = 1:N
#         for j = 1:M
#             # phi[i,j] = IW1[i,j]*IW2[i,j]
#             phi += IW1[i,j]*IW2[i,j]
#         end
#     end

#     return phi #sum(phi)
# end
#TODO: Try timing against sum(sum(IW1.*IW2))
function correlate(method::Direct, IW1, IW2)
    n = length(IW1)
    phi = 0.0
    for i = 1:n
        phi += IW1[i]*IW2[i]
    end
    return phi
end

function phimatrix(method::Union{Direct, MQD}, IW, SW) #Option: I could include a step size on moving the IW. (nw - ni)/stepsize + 1
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

#Todo: I need to get something to handle if the velocities should be zero, i.e. the same image is passed in. Tyler did somethere where he ignores the IW if the sum is below some threshold. 
function getvelocity(method::Direct, phi, xiw, yiw, xsw, ysw) #Note: This might be general... I can't remember. 
    _, idx = findmax(phi)
    xv = xsw + idx[2] - 1
    yv = ysw + idx[1] - 1

    #Need to find the relative change. 
    return (xv-xiw, -(yv-yiw)) #Change y axis to positive up. 
end



function searchimagepair(method::Union{Direct, MQD}, mat, IWsize, overlap, SWsize, border; verbose::Bool=true)

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

    xiw, yiw, xsw, ysw = getwindowlocations((iy, ix), IWsize, overlap, SWsize, border)

    numx = length(xiw)
    numy = length(yiw)

    velocity = Array{Tuple{Int64, Int64}, 2}(undef, numy, numx) #TODO: Might need to transpose. 

    if verbose
        println("Analyzing...")
    end


    for i = 1:numy
        for j = 1:numx
            interrogationwindow = view(mat[:,:,1], yiw[i]:yiw[i]+iwy-1, xiw[j]:xiw[j]+iwx-1)

            searchwindow = view(mat[:,:,2], ysw[i]:ysw[i]+swy-1, xsw[j]:xsw[j]+swx-1) 

            phi = phimatrix(method, interrogationwindow, searchwindow)
            
            velocity[i,j] = getvelocity(method, phi, xiw[j], yiw[i], xsw[j], ysw[i])
            # if i==numy&&j==numx
            #     @show phi
            # end
            # # @show phi

            # if verbose&&mod(i+j,speakiter)==0
            #     percent = round((i+j)/(numx*numy))
            #     println("$percent % done")
            # end
        end
    end
    
    if verbose
        println("Finished analyzing...")
    end
    #Todo: I should convert the locations to be from the center of the IW. 
    return xiw, (iy+1).-yiw, velocity #(iy+1).-yiw, velocity
end