#=
This is the direct correlation for an image. 


 
=#

export Direct, MQD, FFT

abstract type Method end

struct Direct <: Method
end

struct MQD <: Method
end

struct FFT <: Method
end


function findIWbuffer(ix, iwx, iwss_x, border)
    n = 1
    while n<(ix-iwx+1)  
        n += iwss_x
    end

    buff = ix - n
    return return max(floor(Int64, border*iwx), floor(Int64, buff/2),1)
end

function getwindowlocations(imagesize, IWsize, overlap, SWsize, border) #Note: This might be a general function. 

    if overlap>=1
        error("overlap must be less than 1.")
    end

    iy, ix = imagesize
    iwy, iwx = IWsize
    swy, swx = SWsize

    if (iwx>ix)||(iwy>iy)
        error("The interrogation window size cannot be larger than the image size.")
    end

    if (iwx>swx)||(iwy>swy)
        @warn("The interrogation window size cannot be larger than the search window size, adjusting the search window size.")
        swx = iwx
        swy = iwy
    end

    if (swx>ix)||(swy>iy)
        if (iwx<ix)&&(iwy<iy)
            @warn("The search window size cannot be larger that the image size. Adjusting to the interrogation window size.")
            swx=iwx
            swy=iwy
        else
            error("The search window size cannot be larger that the image size.")
        end
    end

    #Note: I'm not sure I like this because it requires an even number... meh. 
    if mod((swx-iwx),2)!=0||mod(swy-iwy,2)!=0
        @warn("Search window doesn't fit evenly around interrogation window. Modifying search window size.")
        if swx<ix
            swx += 1
        else
            swx -= 1
        end
        
        if swy<iy
            swy += 1
        else
            swy -= 1
        end
    end

    oterm = 1 - overlap

    ####### Buffers 
    ### Vertical
    iwss_y = Int(max(ceil(iwy*oterm), 1)) #Window step size
    bn = mod(iy, iwss_y) 
    tb = findIWbuffer(iy, iwy, iwss_y, border)

    ### Horizontal 
    iwss_x = Int(max(ceil(iwx*oterm),1)) #IW step size
    bm = mod(ix, iwss_x)
    lb = findIWbuffer(ix, iwx, iwss_x, border)

    ###### Interrogation Windows
    x_iw = collect(lb:iwss_x:ix-iwx)
    y_iw = collect(tb:iwss_y:iy-iwy)
    # @show y_iw
    

    num_iwx = length(x_iw) 
    num_iwy = length(y_iw)


    ###### Search windows
    bn = swy-iwy  #Total buffer size  
    tb = floor(Int64, bn/2) #Top buffer

    bm = swx-iwx #Total buffer size
    lb = floor(Int64, bm/2) #Left buffer

    ysw = y_iw .- tb
    xsw = x_iw .- lb

    for i = 1:num_iwx
        if xsw[i]<1
            xsw[i]=1
        end
        if xsw[i]+swx-1>ix
            xsw[i]=ix-swx+1
        end
    end

    for j = 1:num_iwy
        if ysw[j]<1
            ysw[j]=1
        end
        if ysw[j]+swy-1>iy
            ysw[j]=iy-swy+1
        end
    end

    return x_iw, y_iw, xsw, ysw
end

export MaxMin, Gauss5Point

abstract type SubPixelDisplacement end

struct MaxMin <: SubPixelDisplacement
end

struct Gauss5Point <: SubPixelDisplacement
end

#TODO: I could do a weighted average SPD. 

#=
Get the Gaussian 3 point where the derivative equals zero. 
=#
function gauss3point(phi)
    # c0 = ln(phi[2])
    c1 = ln(phi[3]/phi[1])/2
    c2 = ln(phi[1]*phi[3]/(2*phi[2]))/2

    return -c1/(2*c2)
end

function gauss5point(phi, idx)

    z01 = phi[idx[1]+1, idx[2]]
    z0_1 = phi[idx[1]-1, idx[2]]
    z00 = phi[idx]
    z10 = phi[idx[1], idx[2]+1]
    z_10 = phi[idx[1], idx[2]-1]

    xtop = log(z10)-log(z_10)
    xbot = 4*log(z00) - 2*log(z0_1) - 2*log(z01)
    xstar = idx[2] + xtop/xbot

    ytop = log(z01) - log(z0_1)
    ybot = 4*log(z00) - 2*log(z0_1) - 2*log(z01)
    ystar = idx[1] + ytop/ybot

    return xstar, ystar
end



function getmax(spd::MaxMin, phi)
    _, idx = findmax(phi)
    
    return idx[2], idx[1]
end

function getmax(spd::Gauss5Point, phi) #Todo. When passing the same image in I don't get zeros. Is it supposed to be zero? I should think so. -> It was associated with the indexing issue.
    #Question. Using the sub-pixel displacement, the location of the vector shouldn't change, just the distance of the vector? Right? Right.
    _, idx = findmax(phi) #Todo. Is indexing on the equation y, x or x, y? -> The indexing is x,y; there is an equation on the slide before. Now I need to fix it. - done
    #Todo. I should put something in to catch if the index is on the edge.

    ### Check if it is on the edge
    n, m = size(phi)

    if idx[1]==1||idx[1]==n
        if idx[2]==1||idx[2]==m ### Corner case
            return idx[2], idx[1]
        else ### X edge case
            xstar = gauss3point(view(phi, idx[1], idx[2]-1:idx[2]+1))
            return xstar, idx[1]
        end
    end

    if idx[2]==1||idx[2]==m ### Y edge case
        ystar = gauss3point(view(phi, idx[1]-1:idx[1]+1, idx[2]))
        return idx[2], ystar
    end

    ### Centerpoint case
    return gauss5point(phi, idx)
end

function getmin(spd::MaxMin, phi)
    _, idx = findmin(phi)
    return idx[2], idx[1]
end

function getmin(spd::Gauss5Point, phi)
    _, idx = findmin(phi)  
    
    ### Check if it is on the edge
    n, m = size(phi)

    if idx[1]==1||idx[1]==n
        if idx[2]==1||idx[2]==m ### Corner case
            return idx[2], idx[1]
        else ### X edge case
            xstar = gauss3point(view(phi, idx[2]-1:idx[2]+1))
            return xstar, idx[1]
        end
    end

    if idx[2]==1||idx[2]==m ### Y edge case
        ystar = gauss3point(view(phi, idx[1]-1:idx[1]+1))
        return idx[2], ystar
    end

    ### Centerpoint case
    return gauss5point(phi, idx)
end

