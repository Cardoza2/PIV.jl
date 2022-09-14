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

phi_1 = [1 1 1;
       0 3 0;
       1 1 1]

phi_2 = [3 0 0 0 0;
         0 0 1 1 0;
         1 0 0 0 0;
         1 0 0 0 0;
         0 0 1 1 0;]

v = (2, -2)

@testset "FFT" begin 

    @testset "phimatrix()" begin 
        phi1 = PIV.phimatrix(method, IW1, IW1) #These result in the same matrix... but now that I think about it, they should. They should be matching IWs. 
        phi2 = PIV.phimatrix(method, g1, g2)

        @test phi==phi1
        @test isapprox(phi2, phi_2; atol=1e-12)
    end

    @testset "getvelocity()" begin  
        v1 = PIV.getvelocity(method, phi_2)
        @test v==v1
    end
end
