using PIV, Images, CairoMakie

### Provided images #Todo: Move all images into a test directory. 
ip1 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw4/synthetic00010.jpg"

ip2 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw4/synthetic00012.jpg"


### Rankine
ip3 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_01.tif"

ip4 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_02.tif"


### Load in the images to be analyzed
images = [load(ip3), load(ip4)]

### Choose a method that suits your fancy. 
# method = Direct()
method = MQD()
# method = FFT()

### Convert the images to matrices and apply any preprocessing.
mat = preprocess(images)

iws = (32, 32) #Interrogation window size
overlap = 0.5 #Interrogation window overlap percentage (as a decimal)
sws = (64, 64) #Search window size
border = 0.55 #Border percentage (of interrogation window size)

### Sub-Pixel Displacement
# spd = MaxMin()
spd = Gauss5Point()

x, y, v = searchimagepair(method, mat, iws, overlap, sws, border; spd)

xx, yy, uu, vv = prep_plotdata(x, y, v; skip=0, scaling=3.0)

strength = @. sqrt(uu^2 + vv^2)

plt = arrows(xx, yy, uu, vv; arrowhead=:utriangle, arrowsize=7, arrowcolor=strength, linecolor=strength, colormap=Reverse(:grays))
display(plt)

# iy, ix, numimages = size(mat)
# iwy, iwx = iws
# swy, swx = sws

# xiw, yiw, xsw, ysw = PIV.getwindowlocations((iy, ix), iws, overlap, sws, border)

# iw = view(mat[:,:,1], yiw[1]:yiw[1]+iwy-1, xiw[1]:xiw[1]+iwx-1)
# sw = view(mat[:,:,2], ysw[1]:ysw[1]+swy-1, xsw[1]:xsw[1]+swx-1)
# phimat = PIV.phimatrix(method, iw, sw)



# using Plots
# phim = phimat[1:3]
# phim[1] = 6.4
# phim[2] = 6
# y = -1:1:1
# y2 = -1:0.1:1
# ymin = g3pmin(phim)

# @show phim, ymin

# phig3p = gauss3point.(Ref(phim), y2) #Todo: Did not match very well. 

# plt = plot(y, phim, lab="actual")
# plot!(y2, phig3p, lab="gauss 3 point")
# vline!([ymin])
# display(plt)

nothing 