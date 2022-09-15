using PIV, Images, Plots, BenchmarkTools


ip1 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_01.tif"

ip2 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_02.tif"

#linear shift
ip3 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/linearshift_01.tif"

ip4 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/linearshift_02.tif"

#rankine
ip5 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/rankine_01.tif"

ip6 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/rankine_02.tif"

images = [load(ip1), load(ip2)]
method = Direct()

mat = preprocess(images)

iws = (32, 32)
overlap = 0.5
sws = (64, 64)
border = 0.55

# iy, ix, numimages = size(mat)
# iwy, iwx = iws
# swy, swx = sws

# xiw, yiw, xsw, ysw = PIV.getwindowlocations((iy, ix), iws, overlap, sws, border)

# xidx = 1
# yidx = 1
# plt = PIV.plot_windows(images[1], xiw[xidx], yiw[yidx], iwx, iwy, xsw[xidx], ysw[yidx], swx, swy)
# display(plt)

# plts = []

# for i = 1:length(yiw)
#     for j = 1:length(xiw)
#         plt = PIV.plot_IW(images[1], xiw[j], yiw[i], iwx, iwy)
#         push!(plts, plt)
#     end
# end

# anim = @animate for i = 1:length(plts)
#     plot(plts[i])
# end #every 10

# gif(anim, "interrogationwindows.gif", fps=1)


# iw = view(mat[:,:,1], yiw[1]:yiw[1]+iwy-1, xiw[1]:xiw[1]+iwx-1)
# sw = view(mat[:,:,2], ysw[1]:ysw[1]+swy-1, xsw[1]:xsw[1]+swx-1)
# phimat = PIV.phimatrix(method, iw, sw)

# xx = xiw[1]:xiw[1]+swx-iwx
# yy = yiw[1]:yiw[1]+swy-iwy

# plt = wireframe(xx, yy, phimat', camera=(35, 50), xaxis="X", yaxis="Y", zaxis="ϕ")
# display(plt)

# vel = PIV.getvelocity(method, phimat, xiw[1], yiw[1], xsw[1], ysw[1])


x, y, v = PIV.searchimagepair(method, mat, iws, overlap, sws, border)

plt = PIV.plot_velocityfield(x, y, v; skip=2, scaling=3.0)
display(plt) 

#=
time 1: 16.6 seconds (8255 allocations; 11.78 GiB) #Original
time 2: 16.5 seconds (6610 allocations; 11.77 GiB) #phi matrix in place
time 3: 15.2 seconds (6622 allocations; 11.77 GiB) #Velocity preallocated
time 4: 10.3 seconds (1798015 allocations; 25.65 GiB) #sum(sum())
time 5: 9.841 s (1798015 allocations: 25.65 GiB) #Switch order of i and j (which is computed first. )
time 6: 6.915 s (1798082 allocations: 25.65 GiB) #Threaded
=#






nothing 