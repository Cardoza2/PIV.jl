export plot_IW, plot_windows, prep_plotdata

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

function prep_plotdata(x, y, v; scaling=1, skip::Int=0)
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

    return xx[idxs], yy[idxs], u_[idxs], v_[idxs]
end

export prep_flagplot

function prep_flagplot(x, y, v, flags::Vector{CartesianIndex}; scaling=1)
    n = length(flags)

    xx = Array{Float64, 1}(undef, n) #It's not a problem with reverse plotting. 
    yy = Array{Float64, 1}(undef, n)
    uu = Array{Float64, 1}(undef, n)
    vv = Array{Float64, 1}(undef, n)

    for i = 1:n
        xx[i] = x[flags[i][2]]
        yy[i] = y[flags[i][1]]
        uu[i] = v[flags[i], 1]*scaling
        vv[i] = v[flags[i], 2]*scaling
    end
    return xx, yy, uu, vv
end


### This function is super mega broke. Don't use it. 
function prep_flagplot_special(xiw, yiw, xsw, ysw, x, y, flags; scaling=1)
    n = length(flags)

    xx = Array{Float64, 1}(undef, n) #It's not a problem with reverse plotting. 
    yy = Array{Float64, 1}(undef, n)
    uu = Array{Float64, 1}(undef, n)
    vv = Array{Float64, 1}(undef, n)


    for i = 1:n
        vidx = flags[i].vidx

        phi = flags[i].phi
        maxidx = flags[i].maxidxs[1]

        xv = xsw[vidx[2]] + maxidx[2] - 1
        yv = ysw[vidx[1]] + maxidx[1] - 1

        unew = xv-xiw[vidx[2]]
        vnew = -(yv-yiw[vidx[1]])

        # phi[maxidx[1]-1:maxidx[1]+1, maxidx[2]-1:maxidx[1]+1] .= 0

        # unew, vnew = getvelocity(method, spd, phi, xiw, yiw, xsw, ysw)

        xx[i] = x[vidx[2]]
        yy[i] = y[vidx[1]]
        uu[i] = unew*scaling
        vv[i] = vnew*scaling
    end
    return xx, yy, uu, vv
end