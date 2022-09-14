using PIV, Images #, Plots


ip1 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_01.tif"

ip2 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/PIVlab_gen_2_02.tif"

#linear shift
ip3 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/linearshift_01.tif"

ip4 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/linearshift_02.tif"

#rankine
ip5 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/rankine_01.tif"

ip6 = "/Users/adamcardoza/Library/CloudStorage/OneDrive-cardoza.one/BYU/Fall 2022/ME 613/Homework/hw3/rankine_02.tif"

images = [load(ip1), load(ip2)]
method = FFT()

mat = preprocess(images)

iws = (32, 32)
overlap = 0.5
sws = (64, 64)
border = 0.55


x, y, v = PIV.searchimagepair(method, mat, iws, overlap, sws, border)

plt = PIV.plot_velocityfield(x, y, v; skip=2, scaling=3.0)
display(plt)






nothing 