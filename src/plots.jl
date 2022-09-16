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

