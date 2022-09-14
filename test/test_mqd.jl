#=
Test all the code for the cross correlation method. 

=#
using Test, PIV

method = MQD()

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

phi = [3 3 2;
       2 4 5;
       4 4 0]

v = (2, -2)

@testset "Minimum Quadratic Difference" begin
    @testset "correlate()" begin
        c1 = PIV.correlate(method, IW1, IW2)
        c2 = PIV.correlate(method, IW1, IW3)

        @test c1==3
        @test c2==1
    end

    @testset "phimatrix()" begin 
        phi1 = PIV.phimatrix(method, IW1, g2)
        @test phi==phi1
    end

    @testset "getvelocity()" begin #Todo: Now there is an error here, so I get to go back through. 
        v1 = PIV.getvelocity(method, phi, 1, 1, 1, 1)
        @test v==v1
    end
end

