

function correlate(method::MQD, IW1, IW2)
    return sum(sum((IW1.-IW2).^2))
end

function getvelocity(method::MQD, spd::SubPixelDisplacement, phi, xiw, yiw, xsw, ysw) #Note: This might be general... I can't remember. 
    xstar, ystar = getmin(spd, phi)
    xv = xsw + xstar - 1
    yv = ysw + ystar - 1

    #Find the relative change. 
    return xv-xiw, -(yv-yiw) #Change y axis to positive up. 
end