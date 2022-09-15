using PIV, Images 


ip1 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_01.tif"

ip2 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_02.tif"


### Load in the images to be analyzed
images = [load(ip1), load(ip2)]

### Choose a method that suits your fancy. 
method = Direct()
# method = MQD()
# method = FFT()

### Convert the images to matrices and apply any preprocessing.
mat = preprocess(images)

iws = (32, 32) #Interrogation window size
overlap = 0.5 #Interrogation window overlap percentage (as a decimal)
sws = (64, 64) #Search window size
border = 0.55 #Border percentage (of interrogation window size)


x, y, v = PIV.searchimagepair(method, mat, iws, overlap, sws, border)

plt = PIV.plot_velocityfield(x, y, v; skip=2, scaling=3.0)
display(plt)

# For faster speeds, run in terminal with `julia --threads auto include("demonstration.jl")`


nothing 