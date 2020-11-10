function log_ticks(loglims)
    a = round(loglims[1], RoundDown)
    b = round(loglims[2], RoundUp)
    v = log10.(1:9)
    ticks = vcat([i .+ a .+ v for i in 0:b-a]..., [b])
    labels = [tick == round(tick) ? to_latex("10^{$(round(Int, tick))}") : " " for tick in ticks]
    return ticks, labels
end

function find_limits(vals; start=[first(vals), first(vals)], margins=0.05)
    vmin = start[1]
    vmax = start[2]
    for v in vals
        if v < vmin 
            vmin = v
        elseif v > vmax
            vmax = v
        end
    end
    diff = vmax - vmin
    vmax += margins * diff
    vmin -= margins * diff
    return vmin, vmax
end

function print_tf(sys)
    # Convert the numerator and denominator to strings
    numstr = sprint(printpolyfun(var), f.num)
    denstr = sprint(printpolyfun(var), f.den)

    # Figure out the length of the separating line
    len_num = length(numstr)
    len_den = length(denstr)
    dashcount = max(len_num, len_den)

    # Center the numerator or denominator
    if len_num < dashcount
        numstr = "$(repeat(" ", div(dashcount - len_num, 2)))$numstr"
    else
        denstr = "$(repeat(" ", div(dashcount - len_den, 2)))$denstr"
    end
    println(io, numstr)
    println(io, repeat("-", dashcount))
    println(io, denstr)
end