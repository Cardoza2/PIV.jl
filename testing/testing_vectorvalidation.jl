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

if !@isdefined(v)
    x, y, v = searchimagepair(method, mat, iws, overlap, sws, border; spd)
end

xx, yy, uu, vv = prep_plotdata(x, y, v; skip=0, scaling=3.0)

strength = @. sqrt(uu^2 + vv^2)

# plt = arrows(xx, yy, uu, vv; arrowhead=:utriangle, arrowsize=7, arrowcolor=strength, linecolor=strength, colormap=Reverse(:grays))
# display(plt)

n=1
uvec = v[:,:,1]
idx = CartesianIndex(2,2)  
vee = uvec[idx]

xidxs = collect(idx[2]-n:idx[2]+n)
yidxs = collect(idx[1]-n:idx[1]+n)

vsample = vec(uvec[yidxs, xidxs])

flag = PIV.meanvalue(vsample, vee, .5, 0)


method = MeanValue(0.5)

flagged = method(uvec)

method = MedianValue(0.5)
flagged = method(uvec)


nothing 