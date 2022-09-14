#=
Test all the code for the cross correlation method. 

=#
using Test, PIV

method = CrossCorrelate()

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

phi = [0 0 1;
       1 0 0;
       0 0 3]

v = (2, -2)

@testset "Direct Correlation" begin 
    @testset "correlate()" begin
        c1 = PIV.correlate(method, IW1, IW2)
        c2 = PIV.correlate(method, IW1, IW3)

        @test c1==0
        @test c2==1
    end

    @testset "phimatrix()" begin 
        phi1 = PIV.phimatrix(method, IW1, g2)
        @test phi==phi1
    end

    @testset "getvelocity()" begin  
        #Todo: I should probably test that the same matrix results in a matrix of zeros. 
        #Todo: I should check what the behavior is when the phi matrix is all the same value. 
        v1 = PIV.getvelocity(method, phi, 1, 1, 1, 1)
        @test v==v1
    end
end

