using PIV, Images


ip1 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_01.tif"

ip2 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_02.tif"


### Load in the images to be analyzed
images = [load(ip1), load(ip2)]

### Choose a method that suits your fancy. 
# method = Direct()
# method = MQD()
method = FFT()

### Convert the images to matrices and apply any preprocessing.
mat = preprocess(images)

iws = (32, 32) #Interrogation window size
overlap = 0.5 #Interrogation window overlap percentage (as a decimal)
sws = (64, 64) #Search window size
border = 0.55 #Border percentage (of interrogation window size)


x, y, v = PIV.searchimagepair(method, mat, iws, overlap, sws, border; spd=MaxMin())

# plt = PIV.plot_velocityfield(x, y, v; skip=2, scaling=3.0)
# display(plt)

# For faster speeds, run in terminal with `julia --threads auto include("demonstration.jl")`

scaling = 1.0
skip = 1
nx = length(x)
ny = length(y)
nn = nx*ny

xx = repeat(x, inner=ny)
yy = repeat(y, outer=nx)

u_ = Array{Float64, 1}(undef, nn)
v_ = Array{Float64, 1}(undef, nn)

idx = 1
for j = 1:nx
    for i = 1:ny
        global idx
        u_[idx] = v[i, j, 1]*scaling
        v_[idx] = v[i, j, 2]*scaling
        idx += 1
    end
end

idxs = 1:1+skip:nn

### Plots
# plt = quiver(xx[idxs], yy[idxs], quiver=(u_[idxs], v_[idxs]), arrow=(:closed, .1))
# display(plt)

### Makie
using CairoMakie

uu = zeros(ny, nx)
vv = zeros(ny, nx)

for j = 1:nx
    for i = 1:ny
        uu[i, j] = v[i, j, 1]*scaling
        vv[i, j] = v[i, j, 2]*scaling
        
    end
end

strength = @. sqrt(u_^2 + v_^2)

plt = arrows(xx, yy, u_, v_; arrowhead=:utriangle, arrowsize=7, arrowcolor=strength, linecolor=strength, colormap=Reverse(:grays))
display(plt)


nothing 