function find_close(pos, poles, zeros, eps)
    closest = [Inf, Inf]
    for pole in poles[]
        if sum(abs2, pole .- pos) < sum(abs2, closest .- pos)
            closest = pole
        end
    end
    for zero in zeros[]
        if sum(abs2, zero .- pos) < sum(abs2, closest .- pos)
            closest = zero
        end
    end
    eps = [0.5, 0.5] # Should be like (xlim, ylim) / 100 or smth
    if all(abs.(closest .- pos) .< eps)
        println(closest)
    else
        println("nothing")
    end
end

mutable struct Root
    pos::Point2f0
    pole::Bool
    selected::Bool
end

function get_poles(roots)
    a = Point2f0[]
    for node in roots
        if node.pole 
            push!(a, node.pos)
            if node.pos[2] != 0
                push!(a, node.pos .* [1, -1])
            end
        end
    end
    return a
end

function get_zeros(roots)
    a = Point2f0[]
    for node in roots
        if !node.pole
            push!(a, node.pos)
            if node.pos[2] != 0
                push!(a, node.pos .* [1, -1])
            end
        end
    end
    return a
end

function get_selected(roots)
    a = Point2f0[]
    for node in roots
        if node.selected
            push!(a, node.pos)
            if node.pos[2] != 0
                push!(a, node.pos .* [1, -1])
            end
        end
    end
    return a
end