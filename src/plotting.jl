function log_ticks(loglims)
    a = round(loglims[1], RoundDown)
    b = round(loglims[2], RoundUp)
    @show a b
    v = log10.(1:9)
    ticks = vcat([i .+ a .+ v for i in 0:b-a]..., [b])
    @show ticks
    labels = [tick == round(tick) ? L"10^{%$(round(Int, tick))}" : " " for tick in ticks]
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

function print_tf(roots, gain, delay)
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
        numstr = "1"
    elseif length(num) == 1
        numstr = num[1]
    else
        numstr = "(" * join(num, ")(") * ")"
    end
    if length(den) == 0
        denstr = "1"
    elseif length(den) == 1
        denstr = den[1]
    else
        denstr = "(" * join(den, ")(") * ")"
    end

    return L"%$(round(gain, sigdigits=3))e^{-%$(round(delay, sigdigits=3))s}\cdot\frac{%$numstr}{%$denstr}"
end

function printroot(z)
    a = z[1]
    b = z[2]
    if b == 0
        return "1 $(a < 0 ? "+" : "-") s$(round(1/abs(a), sigdigits=3))"
    else
        return "$(round(1/(a^2 + b^2), sigdigits=3))s^2 $(a < 0 ? "+" : "-") $(round(2abs(a)/(a^2 + b^2), sigdigits=3))s + 1"
    end
end