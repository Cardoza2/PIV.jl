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


# function getwindowlocations(imagesize, IWsize, overlap, SWsize) #Note: This might be a general function. 

#     if overlap>=1
#         error("overlap must be less than 1.")
#     end

#     iy, ix = imagesize
#     iwy, iwx = IWsize
#     swy, swx = SWsize

#     if (iwx>ix)||(iwy>iy)
#         error("The interrogation window size cannot be larger than the image size.")
#     end

#     if (iwx>swx)||(iwy>swy)
#         @warn("The interrogation window size cannot be larger than the search window size, adjusting the search window size.")
#         swx = iwx
#         swy = iwy
#     end

#     if (swx>ix)||(swy>iy)
#         if (iwx<ix)&&(iwy<iy)
#             @warn("The search window size cannot be larger that the image size. Adjusting to the interrogation window size.")
#             swx=iwx
#             swy=iwy
#         else
#             error("The search window size cannot be larger that the image size.")
#         end
#     end

#     #Note: I'm not sure I like this because it requires an even number... meh. 
#     if mod((swx-iwx),2)!=0||mod(swy-iwy,2)!=0
#         @warn("Search window doesn't fit evenly around interrogation window. Modifying search window size.")
#         if swx<ix
#             swx += 1
#         else
#             swx -= 1
#         end
        
#         if swy<iy
#             swy += 1
#         else
#             swy -= 1
#         end
#     end

#     oterm = 1 - overlap

#     ####### Buffers 
#     ### Vertical
#     iwss_y = Int(max(ceil(iwy*oterm), 1)) #Window step size
#     bn = swy-iwy  #Total buffer size #Todo: I'm not convinced that the way I've done this is correct. I just tried tiny IWs and a large SW and I didn't get what I want. ... So I think that I want to come up with a different version of this functioon. 
#     tb = Int(floor(bn/2)) #Top buffer
#     bb = bn-tb #Bottom buffer

#     ### Horizontal 
#     iwss_x = Int(max(ceil(iwx*oterm),1)) #IW step size
#     bm = swx-iwx #Total buffer size
#     lb = Int(floor(bm/2)) #Left buffer
#     rb = bm-lb  #Right buffer

#     @show iwss_x, bm, lb, rb

#     ###### Interrogation Windows
#     if swx==ix
#         x_iw = (lb:iwss_x:ix-rb)
#     else
#         x_iw = (lb:iwss_x:ix-rb-iwx).+1 #TODO: I need to add something that allows the search windows on the right to shift left (So I could fit another interrogation window on). 
#     end

#     if swy==iy
#         y_iw = (tb:iwss_y:iy-bb)
#     else
#         y_iw = (tb:iwss_y:iy-bb-iwx).+1
#     end

#     num_iwx = length(x_iw) 
#     num_iwy = length(y_iw)


#     ###### Search windows
#     if swx==ix
#         xs = [1 for i = 1:num_iwx]
#     else
#         xs = [x_iw[i]-lb for i = 1:num_iwx]
#     end

#     if swy==iy
#         ys = [1 for i = 1:num_iwy]
#     else
#         ys = [y_iw[i]-tb for i=1:num_iwy]
#     end

#     return Int.(x_iw), Int.(y_iw), Int.(xs), Int.(ys)
# end

function findIWbuffer(ix, iwx, iwss_x, border)
    n = 1
    while n<(ix-iwx+1) #TODO: do I need to add one? 
        n += iwss_x
    end
    # @show n
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
    bn = mod(iy, iwss_y) #Todo: I don't think that this is right. This doesn't include the interrogation window size. I think that I need to see how much is left over, then 
    # tb = max(floor(Int64, bn/2),1)
    # println("y: ")
    tb = findIWbuffer(iy, iwy, iwss_y, border)

    ### Horizontal 
    iwss_x = Int(max(ceil(iwx*oterm),1)) #IW step size
    bm = mod(ix, iwss_x)
    # lb = max(floor(Int64, bm/2),1)
    # println("x: ")
    lb = findIWbuffer(ix, iwx, iwss_x, border)

    # @show tb, iwss_y, iy-iwy, iy
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

# function getwindowlocations(imagesize, IWsize, overlap, SWsize)

#     iy, ix = imagesize
#     iwy, iwx = IWsize
#     swy, swx = SWsize

#     oterm = 1 - overlap

#     ####### Buffers 
#     ### Vertical
#     iwss_y = max(ceil(Int64, iwy*oterm),1)
#     bn = mod(iy, iwss_y) 
#     tb = max(floor(Int64, bn/2),1)
#     # println("y: ")
#     # tb = findIWbuffer(iy, iwy, iwss_y)

#     ### Horizontal 
#     iwss_x = max(ceil(Int64, iwx*oterm),1) #IW step size
#     bm = mod(ix, iwss_x)
#     lb = max(floor(Int64, bm/2),1)
#     # println("x: ")
#     # lb = findIWbuffer(ix, iwx, iwss_x)

#     # @show tb, iwss_y, iy-iwy, iy
#     ###### Interrogation Windows
#     x_iw = collect(iwx:iwss_x:ix-iwx+1)
#     y_iw = collect(iwy:iwss_y:iy-iwy+1)
#     # @show y_iw
    

#     num_iwx = length(x_iw) 
#     num_iwy = length(y_iw)

#     y_sw = ones(Int64, num_iwy)
#     x_sw = ones(Int64, num_iwx)

#     return x_iw, y_iw, x_sw, y_sw
# end

function plot_IW(image, xiw, yiw, iwx, iwy; linecolor=:red)
    x = [xiw, xiw+iwx, xiw+iwx, xiw, xiw]
    y = [yiw, yiw, yiw+iwy, yiw+iwy, yiw]

    plt = plot(image)
    plot!(x, y; linewidth=3, linecolor=linecolor, leg=false) #background_color=:transparent,
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
     #background_color=:transparent,
    return plt
end

function plot_velocityfield(x, y, v; scaling=1, skip::Int=0)
    nx = length(x)
    ny = length(y)
    nn = nx*ny

    xx = repeat(x, inner=ny)
    yy = repeat(y, outer=nx)
    # vv = v #reverse(v, dims=1)

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