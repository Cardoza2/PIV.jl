
export MeanValue

abstract type PostProcess end

abstract type Validation <: PostProcess end

struct MeanValue <: Validation
n::Int #Number of pixels in to test (which correlates to testing the 8 closest neighbors for a distance of 1).
c1::Float64 #Threshold.
c2::Float64 
end

function MeanValue(c1, c2)
    return MeanValue(1, c1, c2)
end

function MeanValue(eps)
    return MeanValue(1, eps, 0)
end

function (method::MeanValue)(v)
    n, m = size(v)
    idxs = CartesianIndex[]
    for i = 1:n
        for j = 1:m
            idx = CartesianIndex(i,j)
            vee = v[idx]

            xidxs = collect(idx[2]-method.n:idx[2]+method.n)
            yidxs = collect(idx[1]-method.n:idx[1]+method.n)
            if i==1 #Top edge
                yidxs = collect(idx[1]:idx[1]+method.n)
            elseif i==n #Bot edge
                yidxs = collect(idx[1]-method.n:idx[1])
            end

            if j==1 #Left edge
                xidxs = collect(idx[2]:idx[2]+method.n)
            elseif j==m #Right edge
                xidxs = collect(idx[2]-method.n:idx[2])
            end

            vsample = vec(v[yidxs, xidxs])
            
            deleteat!(vsample, findfirst(x->x==vee, vsample)) #Remove the entry of question. 

            if meanvalue(vsample, vee, method.c1, method.c2)
                push!(idxs, idx)
            end
        end
    end
    return idxs
end

function meanvalue(vsample, v, c1, c2) 

    mu = Statistics.mean(vsample)
    sigma = sqrt(Statistics.mean((vsample.-mu).^2))
    eps = c1 + c2*sigma
    # @show mu, v, eps
    if abs(mu-v)<eps
        return false #Accept the vector
    else
        return true #Yes, reject the vector 
    end
end

export MedianValue

struct MedianValue <: Validation
    n::Int #Number of pixels in to test (which correlates to testing the 8 closest neighbors for a distance of 1).
    eps::Float64 #Threshold.
end

function MedianValue(eps)
    return MedianValue(1, eps)
end


function (method::MedianValue)(v)
    n, m = size(v)
    idxs = CartesianIndex[]
    for i = 1:n
        for j = 1:m
            idx = CartesianIndex(i,j)
            vee = v[idx]

            xidxs = collect(idx[2]-method.n:idx[2]+method.n)
            yidxs = collect(idx[1]-method.n:idx[1]+method.n)
            if i==1 #Top edge
                yidxs = collect(idx[1]:idx[1]+method.n)
            elseif i==n #Bot edge
                yidxs = collect(idx[1]-method.n:idx[1])
            end

            if j==1 #Left edge
                xidxs = collect(idx[2]:idx[2]+method.n)
            elseif j==m #Right edge
                xidxs = collect(idx[2]-method.n:idx[2])
            end

            vsample = vec(v[yidxs, xidxs])
            deleteat!(vsample, findfirst(x->x==vee, vsample)) #Remove the entry of question. 

            if medianvalue(vsample, vee, method.eps)
                push!(idxs, idx)
            end
        end
    end
    return idxs
end

function medianvalue(vsample, v, eps) #Todo: Test me. 

    mu = Statistics.median(vsample)

    if abs(mu-v)<eps
        return false #Accept the vector
    else
        return true #Yes, reject the vector 
    end
end




abstract type Replacement <: PostProcess end

export Decimate, Average

struct Decimate <: Replacement
end

function (method::Decimate)(v, flags::Vector{CartesianIndex})
    for i = 1:length(flags)
        v[flags[i]] = 0
    end
end

struct Average <: Replacement #LinearIndices(uvec)[flagged[1]]
    n::Int #Distance from flag to average by. 
end

function Average()
    return Average(1)
end

function (method::Average)(v, flags::Vector{CartesianIndex})

    n, m = size(v)
    k = length(flags)
    vreplace = Array{Float64, 1}(undef, k)

    for i = 1:k
        idx = flags[i]
        vee = v[idx]

        ### Find which indices to average over. 
        xidxs = collect(idx[2]-method.n:idx[2]+method.n)
        yidxs = collect(idx[1]-method.n:idx[1]+method.n)

        if idx[1]==1 #Top edge
            yidxs = collect(idx[1]:idx[1]+method.n)
        elseif idx[1]==n #Bot edge
            yidxs = collect(idx[1]-method.n:idx[1])
        end

        if idx[2]==1 #Left edge
            xidxs = collect(idx[2]:idx[2]+method.n)
        elseif idx[2]==m #Right edge
            xidxs = collect(idx[2]-method.n:idx[2])
        end

        vsample = vec(v[yidxs, xidxs])
        deleteat!(vsample, findfirst(x->x==vee, vsample)) #Remove the entry of question. 
    
        vreplace[i] = Statistics.mean(vsample) #Replace with the average
    end

    for i = 1:k
        v[flags[i]] = vreplace[i]
    end

end

abstract type Calculation <: PostProcess end

abstract type Vorticity <: Calculation end

export CentralDiff

struct CentralDiff <: Vorticity
end

function (method::CentralDiff)(x, y, v)
    n, m, _ = size(v)
    uvec = view(v, :, :, 1)
    vvec = view(v, :, :, 2)
    vorticity = zeros(n, m)
    for i = 2:n-1
        for j = 2:m-1
            dx = x[j+1] - x[j-1]  #Note: The distance is the distance between the two points, not the spacing. This allows for non-uniform spacing. The 2deltaX disappears from the denominator. 
            dy = y[i+1] - y[i-1]
            t1 = (vvec[i, j+1] - vvec[i,j-1])/dx
            t2 = (uvec[i+1,j] - uvec[i-1,j])/dy #This might be negative. 
            vorticity[i,j] = (t1 - t2)
        end
    end
    return x, reverse(y), reverse(vorticity, dims=1)
end

export TrapezoidalCirculation

struct TrapezoidalCirculation <: Vorticity
end

function (method::TrapezoidalCirculation)(x, y, vmat)

    n, m, _ = size(vmat)

    u = vmat[:, :, 1]
    v = vmat[:, :, 2]

    vorticity = zeros(n, m)
    for i = 2:n-1
        for j = 2:m-1
            dx = x[j+1] - x[j-1]
            dy = y[i+1] - y[i-1]
            ta = (u[i-1, j-1] + u[i-1, j])*(x[j]-x[j-1])/2 + (u[i-1, j] + u[i-1, j+1])*(x[j+1] - x[j])/2 #Top edge
            tb = (v[i-1, j+1] + v[i, j+1])*(y[i]-y[i-1])/2 + (v[i, j+1] + v[i+1, j+1])*(y[i+1] - y[i])/2 #Right edge
            tc = (u[i+1, j+1] + u[i+1, j])*(x[j]-x[j+1])/2 + (u[i+1, j+1] + u[i+1, j])*(x[j-1] - x[j])/2 #Bottom edge
            td = (v[i+1, j-1] + v[i, j-1])*(y[i]-y[i+1])/2 + (v[i+1, j-1] + v[i, j-1])*(y[i-1] - y[i])/2 #Left edge
            gamma = ta + tb + tc + td
            vorticity[i,j] = gamma/(dx*dy)
        end
    end
    return x, reverse(y), reverse(vorticity, dims=1)
end

export Richardson

struct Richardson <: Vorticity
end

function (method::Richardson)(x, y, v)

    n, m, _ = size(v)

    uvec = view(v, :, :, 1)
    vvec = view(v, :, :, 2)

    vorticity = zeros(n, m)
    for i = 3:n-2
        for j = 3:m-2
            dx = x[j+1] - x[j-1]
            dy = y[i+1] - y[i-1]
            t1 = (vvec[i, j-2] - 8*vvec[i,j-1] + 8*vvec[i, j+1] - vvec[i, j+2])/(6*dx)
            t2 = (uvec[i-2,j] - 8*uvec[i-1,j] + 8*uvec[i+1,j] - uvec[i+2,j])/(6*dy)
            vorticity[i,j] = t1 - t2
        end
    end
    return x, reverse(y), reverse(vorticity, dims=1)
end

struct AkimaSpline <: Vorticity
end