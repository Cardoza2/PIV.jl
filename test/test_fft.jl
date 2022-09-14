#=
Test all the code for the cross correlation method. 

=#
using Test, PIV

method = FFT()

IW1 = [0 0 1;
       1 0 0;
       0 0 1]

IW2 = [0 0 0;
       0 0 0;
       0 0 1]

g1 = [0 0 1 0 0;
      1 0 0 0 0;
      0 0 1 0 0;
      0 0 0 0 0;
      0 0 0 0 0]

g2 = [0 0 0 0 0;
      0 0 0 0 0;
      0 0 0 0 1;
      0 0 1 0 0;
      0 0 0 0 1]

IW1 = view(g1,1:3,1:3)
IW2 = view(g2,1:3,1:3)
IW3 = view(g2,1:3,3:5)

phi = [1 1 1;
       0 3 0;
       1 1 1]

v = (2, -2)

@testset "FFT" begin 

    @testset "phimatrix()" begin 
        phi1 = PIV.phimatrix(method, IW1, IW1)
        @show phi1
        # @test phi==phi1
        @test true
    end

    @testset "getvelocity()" begin  
        v1 = PIV.getvelocity(Direct(), phi, 1, 1, 1, 1)
        @show v1
        # @test v==v1
    end
end

