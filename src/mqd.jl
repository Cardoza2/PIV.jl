

function correlate(method::MQD, IW1, IW2)
    return sum(sum((IW1.-IW2).^2))
end

function getvelocity(method::MQD, phi, xiw, yiw, xsw, ysw) #Note: This might be general... I can't remember. 
    _, idx = findmin(phi)
    xv = xsw + idx[2] - 1
    yv = ysw + idx[1] - 1

    #Find the relative change. 
    return xv-xiw, -(yv-yiw) #Change y axis to positive up. 
end