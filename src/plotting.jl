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

function print_tf(roots, gain)
    # Convert the numerator and denominator to strings
    num = []
    den = []

    for root in roots
        s = printroot(root.pos)
        if root.pole
            push!(den, s)
        else
            push!(num, s)
        end
    end

    if length(num) == 0
        numstr = "1.0"
    elseif length(num) == 1
        numstr = num[1]
    else
        numstr = "(" * join(num, ")(") * ")"
    end
    if length(den) == 0
        denstr = "1.0"
    elseif length(den) == 1
        denstr = den[1]
    else
        denstr = "(" * join(den, ")(") * ")"
    end

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
    return to_latex(numstr) * "\n" * repeat("-", dashcount) * "\n" * to_latex(denstr)
end

function printroot(z)
    a = z[1]
    b = z[2]
    if b == 0
        return "s $(a < 0 ? "+" : "-") $(round(abs(a), sigdigits=3))"
    else
        return "s^2 $(a < 0 ? "+" : "-") $(round(2abs(a), sigdigits=3))s + $(round(a^2 + b^2, sigdigits=3))"
    end
end