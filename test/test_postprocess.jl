using Test, PIV, Statistics



uvec1 = ones(3, 3).*2
uvec1[2,2] = -1 #Interior, wrong way
epsilon1 = mean(uvec1)

ud1 = deepcopy(uvec1)
ud1[2,2] = 0

ua1 = deepcopy(uvec1)
ua1[2,2] = 2

flags1 = CartesianIndex[]
push!(flags1, CartesianIndex(2,2))

uvec2 = ones(5, 5).*2
uvec2[2,2] = -1 #Interior, wrong way
uvec2[3, 5] = 0 #Edge, zero
uvec2[5, 1] = 4 #Corner, large

flags2 = CartesianIndex[]
push!(flags2, CartesianIndex(2, 2), CartesianIndex(3, 5), CartesianIndex(5, 1)) #Note: This should be in order of increasing i coordinate, then j coordinate.  

epsilon2 = mean(uvec2)

@testset "PostProcessing" begin
    @testset "Vector Validation" begin
        @testset "Mean Vector" begin #Todo: Need to test a no flags case. 
            ### Test a small array. 
            vsample1 = deleteat!(vec(uvec1[1:2, 1:2]),1)

            #Test meanvalue()
            flag = PIV.meanvalue(vsample1, uvec1[1], epsilon1, 0.0)
            @test flag==false

            #Test method on struct to search velocity field and flag. 
            method = MeanValue(epsilon1)
            fms = method(uvec1)
            @test fms==flags1




            ### Test a larger array
            method = MeanValue(epsilon2)
            fms = method(uvec2)
            @test fms==flags2
        end
    end

    @testset "Vector Replacement" begin
        ### Test small vector 
        #Test Decimate replacement. 
        rmethod = Decimate()
        umat = deepcopy(uvec1)
        rmethod(umat, flags1)
        @test umat == ud1

        rmethod = Average()
        umat = deepcopy(uvec1)
        rmethod(umat, flags1)
        @test umat == ua1
    end
end

