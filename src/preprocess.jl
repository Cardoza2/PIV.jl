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
            matrixprocesses[pm](mat[:,:,i])
        end
    end

    return mat
end