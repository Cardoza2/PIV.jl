using PIV, Images #, Plots


ip1 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_01.tif"

ip2 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_02.tif"



images = [load(ip1), load(ip2)]
method = FFT()

mat = preprocess(images)

iws = (32, 32)
overlap = 0.5
sws = (64, 64)
border = 0.55

# iy, ix, numimages = size(mat)
# iwy, iwx = iws
# swy, swx = sws

# xiw, yiw, xsw, ysw = PIV.getwindowlocations((iy, ix), iws, overlap, sws, border)

# iw1 = view(mat[:,:,1], yiw[1]:yiw[1]+iwy-1, xiw[1]:xiw[1]+iwx-1)
# iw2 = view(mat[:,:,2], yiw[1]:yiw[1]+iwy-1, xiw[1]:xiw[1]+iwx-1) 

# phimat = PIV.phimatrix(method, iw1, iw2)

# xx = xiw[1]:xiw[1]+iwx-1
# yy = yiw[1]:yiw[1]+iwy-1

# plt = wireframe(xx, yy, phimat', camera=(35, 50), xaxis="X", yaxis="Y", zaxis="ϕ")
# display(plt)


x, y, v = PIV.searchimagepair(method, mat, iws, overlap, sws, border)

plt = PIV.plot_velocityfield(x, y, v; skip=2, scaling=3.0)
display(plt)

#=
time 1: 4.623 s (171109 allocations: 11.99 GiB)
time 2: 4.675 s (171217 allocations: 11.99 GiB) #Changing velocity. 
time 3: 5.227 s (172725 allocations: 11.99 GiB) #swapping calc order of i and j. 
time 4: 4.766 s (171122 allocations: 11.99 GiB) #Swapping back. 
time 5: 3.505 s (161239 allocations: 11.99 GiB) #Threading. 
=#






nothing 