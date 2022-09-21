

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

function testratios!(method::MQD, flagged, phi, cpr, ncpr, cprn, i, j)
    n, m = size(phi)
    idxs = CartesianIndex[]

    meanphi = Statistics.mean(phi)
    phicopy = deepcopy(phi)  
    phimin, minidx = findmin(phicopy)
    mini = minidx

    maxdistance = abs(meanphi-phimin)

    for k = 1:ncpr
        xidxs = mini[2]-cprn:mini[2]+cprn  
        yidxs = mini[1]-cprn:mini[1]+cprn

        if mini[1]==1 #Top edge
            yidxs = mini[1]:mini[1]+cprn
        elseif mini[1]==n #Bot edge
            yidxs = mini[1]-cprn:mini[1]
        end

        if mini[2]==1 #Left edge
            xidxs = mini[2]:mini[2]+cprn
        elseif mini[2]==m #Right edge
            xidxs = mini[2]-cprn:mini[2]
        end

        maxval, _ = findmax(phicopy)
        phicopy[yidxs, xidxs] .= maxval

        minphi, mini = findmin(phicopy)

        distance = abs(meanphi-minphi)

        if distance>=cpr*maxdistance
            push!(idxs, mini)
        end
    end
    if length(idxs)>0
        push!(flagged, (vidx=CartesianIndex(i,j), minidxs=idxs, phi=deepcopy(phi)))
    end
    # @show flagged
end