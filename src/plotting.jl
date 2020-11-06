function log_ticks(loglims)
    a = round(loglims[1], RoundDown)
    b = round(loglims[2], RoundUp)
    v = log10.(1:9)
    ticks = vcat([i .+ a .+ v for i in 0:b-a]..., [b])
    labels = [tick == round(tick) ? to_latex("10^{$(round(Int, tick))}") : " " for tick in ticks]
    return ticks, labels
end

function find_limits(vals, margins=0.05)
    vmin = first(vals)
    vmax = first(vals)
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