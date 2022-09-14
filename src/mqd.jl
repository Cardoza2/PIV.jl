

function correlate(method::MQD, IW1, IW2)
    n = length(IW1)
    D = 0.0
    for i = 1:n
        D += (IW1[i]-IW2[i])^2
    end
    return D
end

function getvelocity(method::MQD, phi, xiw, yiw, xsw, ysw) #Note: This might be general... I can't remember. 
    _, idx = findmin(phi)
    xv = xsw + idx[2] - 1
    yv = ysw + idx[1] - 1

    #Need to find the relative change. 
    return (xv-xiw, -(yv-yiw)) #Change y axis to positive up. 
end