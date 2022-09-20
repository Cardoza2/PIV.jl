export convertimage

function convertimage(image) 
    if !(eltype(image) <: Images.Gray) #if not grayscale, convert to grayscale
        image = Images.Gray.(image)
    end

    grays = Images.channelview(image) #Convert the image to color types
    return Images.float.(grays) #Convert the image to numbers
end

abstract type Preprocess end

abstract type ImageProcess <: Preprocess end

abstract type MatrixProcess <: Preprocess end

### Put new preprocessing structs here and define methods on the structs. 

export Contrast

struct Contrast <: MatrixProcess
    a::Float64
    b::Float64 #TODO: I'm not sure that I need this second value, because I'm ranging from 0 to 1. At the same time, it doesn't look like it hurts it, but I'll default to 1. 
end

function Contrast(a)
    return Contrast(a, 1)
end

function (method::Contrast)(mat)
    Gmax = maximum(mat)^method.a
    Gmin = minimum(mat)^method.a

    n, m = size(mat)

    for i = 1:n
        for j = 1:m
            mat[i,j] = (2^method.b - 1)*(mat[i,j]^method.a - Gmin)/(Gmax-Gmin)
        end
    end
end



export preprocess

function preprocess(images, kwargs...)
    ni = length(images)
    np = length(kwargs)

    isy, isx = size(images[1])
    for i = 2:ni
        isyi, isxi = size(images[i])
        if (isyi>isy)&&(isxi>isx)
            error("Haven't implemented trimming function, make sure the functions are the same size.")
        elseif (isy, isx)!=(isyi, isxi)
            error("Note that all image sizes must be the same.")
        end
    end

    mat = Array{Float64, 3}(undef, isy, isx, ni)

    ### sort kwargs into image processes, and matrix processes. 
    imageprocesses = Array{ImageProcess, 1}(undef, 0)
    matrixprocesses = Array{MatrixProcess, 1}(undef, 0)
    for i = 1:np
        if isa(kwargs[i],ImageProcess)
            push!(imageprocesses, kwargs[i])
        else
            push!(matrixprocesses, kwargs[i])
        end
    end 
    npi = length(imageprocesses)
    npm = length(matrixprocesses)

    for i = 1:ni
        image = images[i]
        for pi = 1:npi
            imageprocesses[pi](image)
        end

        mat[:,:,i] = convertimage(image)

        for pm = 1:npm
            matrixprocesses[pm](view(mat, :, :, i))
        end
    end

    return mat
end