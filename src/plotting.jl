function log_ticks(lims, n)
    a = round(lims[1], RoundNearest)
    b = round(lims[2], RoundNearest)
    r = range(a, b, length=n)
    l = raw"10^{".*string.(r).*"}"
    t = to_latex.(l)
    return r, t
end

function find_limits(x, y, xmargins=0.05, ymargins=0.05)
    xmin = ymin = Inf
    xmax = ymax = -Inf
    for i in eachindex(x)
        if x[i] < xmin 
            xmin = x[i]
        end
        if x[i] > xmax
            xmax = x[i]
        end
        if y[i] < ymin 
            ymin = y[i]
        end
        if y[i] > ymax 
            ymax = y[i]
        end
    end
    xdiff = xmax - xmin
    xmax += xmargins * xdiff
    xmin -= xmargins * xdiff
    ydiff = ymax - ymin
    ymax += ymargins * ydiff
    ymin -= ymargins * ydiff
    return xmin, xmax, ymin, ymax
end