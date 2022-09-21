
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

