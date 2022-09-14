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
method = MQD()

mat = preprocess(images)

iws = (32, 32)
overlap = 0.5
sws = (64, 64)
border = 0.55

iy, ix, numimages = size(mat)
iwy, iwx = iws
swy, swx = sws

xiw, yiw, xsw, ysw = PIV.getwindowlocations((iy, ix), iws, overlap, sws, border)

xidx = 1
yidx = 1
plt = PIV.plot_windows(images[1], xiw[xidx], yiw[yidx], iwx, iwy, xsw[xidx], ysw[yidx], swx, swy)
display(plt)

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

# vel = PIV.getvelocity(method, phimat, xiw[1], yiw[1], xsw[1], ysw[1])


x, y, v = PIV.searchimagepair(method, mat, iws, overlap, sws, border)

plt = PIV.plot_velocityfield(x, y, v; skip=2, scaling=3.0)
display(plt)

n, m = size(v)
u_ = zeros(n, m)
v_ = zeros(n, m)

for i = 1:length(v)
    u_[i] = v[i][1]
    v_[i] = v[i][2]
end





nothing 