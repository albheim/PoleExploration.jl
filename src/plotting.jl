function log_ticks(lims, n)
    a = round(lims[1], RoundNearest)
    b = round(lims[2], RoundNearest)
    r = range(a, b, length=n)
    l = raw"10^{".*string.(r).*"}"
    t = to_latex.(l)
    return r, t
end

function find_limits(points)
    xmin = ymin = Inf
    xmax = ymax = -Inf
    for p in points
        if p[1] < xmin 
            xmin = p[1]
        elseif p[1] > xmax
            xmax = p[1]
        end
        if p[2] < ymin 
            ymin = p[2]
        elseif p[2] > ymax 
            ymax = p[2]
        end
    end
    return xmin, xmax, ymin, ymax
end