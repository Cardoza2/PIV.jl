using Test, PIV

ims1 = (5, 5)
iws1 = (3, 3)
overlap1 = .4
sws1 = (5, 5)

ims2 = (10, 10)
iws2 = (3,3)
overlap2 = .7
sws2 = (5,5) 

ims3 = (600, 800)
iws3 = (32, 32)
overlap3 = 0
sws3 = (64, 64)

@testset "general.jl" begin
    @testset "getwindowlocations()" begin  
        xiw1, yiw1, xsw1, ysw1 = PIV.getwindowlocations(ims1, iws1, overlap1, sws1)

        @test xiw1==[1, 3] #Check that the interrogation windows begin where I expect them to. 
        @test xsw1==[1, 1] #Check that the search windows begin where I expect them to. 
        @test xiw1[end]+iws1[2]-1<=ims1[2] #Check that the IW doesn't go off the right side of the image
        @test xsw1[end]+sws1[2]-1<=ims1[2] #Check that that the SW doesn't go off the right side of the image. 
        @test length(xiw1)==length(xsw1)
        @test eltype(xiw1)==Int64
        @test eltype(xsw1)==Int64 

        # ## Check the vertical direction. 
        @test yiw1==[1, 3]
        @test ysw1==[1, 1] 
        @test yiw1[end]+iws1[1]-1<=ims1[1]
        @test ysw1[end]+sws1[1]-1<=ims1[1]
        @test length(yiw1)==length(ysw1)
    

        # xiw2, yiw2, xsw2, ysw2 = PIV.getwindowlocations(ims2, iws2, overlap2, sws2)

        # @test xiw2==1:1:8
        # @test xsw2==vcat(1,1:1:6,6)
        # @test xiw2[end]+iws2[2]-1<=ims2[2]
        # @test xsw2[end]+iws2[2]-1<=ims2[2]
        # @test length(xiw2)==length(xsw2)
        # @test yiw2==1:1:8
        # @test ysw2==vcat(1,1:1:6,6)
        # @test yiw2[end]+iws2[1]-1<=ims2[1]
        # @test ysw2[end]+sws2[1]-1<=ims2[1]
        # @test length(yiw2)==length(ysw2)
        

        # xiw3, yiw3, xsw3, ysw3 = PIV.getwindowlocations(ims3, iws3, overlap3, sws3)


        # @test xiw3==17:32:753  
        # @test xsw3==1:32:737  
        # @test xiw3[end]+iws3[2]-1<=ims3[2]
        # @test length(xiw3)==length(xsw3)
        # @test yiw3==17:32:529
        # @test ysw3==1:32:513
        # @test yiw3[end]+iws3[1]-1<=ims3[1]
        # @test length(yiw3)==length(ysw3)

    end
end