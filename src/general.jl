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



function plot_IW(image, xiw, yiw, iwx, iwy; linecolor=:red)
    x = [xiw, xiw+iwx, xiw+iwx, xiw, xiw]
    y = [yiw, yiw, yiw+iwy, yiw+iwy, yiw]

    plt = plot(image)
    plot!(x, y; linewidth=3, linecolor=linecolor, leg=false) 
    return plt
end

function plot_windows(image, xiw, yiw, iwx, iwy, xsw, ysw, swx, swy)
    x = [xiw, xiw+iwx, xiw+iwx, xiw, xiw]
    y = [yiw, yiw, yiw+iwy, yiw+iwy, yiw]

    xs = [xsw, xsw+swx, xsw+swx, xsw, xsw]
    ys = [ysw, ysw, ysw+swy, ysw+swy, ysw]
    
    plt = plot(image)
    plot!(x, y; linewidth=3, linecolor=:red, leg=false)
    plot!(xs, ys; linewidth=3, linecolor=:blue, leg=false)
    return plt
end

function plot_velocityfield(x, y, v; scaling=1, skip::Int=0)
    nx = length(x)
    ny = length(y)
    nn = nx*ny

    xx = repeat(x, inner=ny)
    yy = repeat(y, outer=nx)

    u_ = Array{Float64, 1}(undef, nn)
    v_ = Array{Float64, 1}(undef, nn)

    idx = 1
    for j = 1:nx
        for i = 1:ny
            u_[idx] = v[i, j, 1]*scaling
            v_[idx] = v[i, j, 2]*scaling
            idx += 1
        end
    end

    idxs = 1:1+skip:nn

    return quiver(xx[idxs], yy[idxs], quiver=(u_[idxs], v_[idxs])) 
end