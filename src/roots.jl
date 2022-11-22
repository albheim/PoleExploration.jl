function create_system(z, p, k, d)::DelayLtiSystem
    if d == 0 # It does not seem to like delay(0) for speed so better to special case them
        DelayLtiSystem(zpk([a + b*im for (a, b) in z], [a + b*im for (a, b) in p], k)) # Convert to make types same
    else
        delay(d) * zpk([a + b*im for (a, b) in z], [a + b*im for (a, b) in p], k)
    end
end

""" Root

A root is a single pole or zero stored as a 2d coordinate.
If `pole` is set it is a pole, otherwise a zero.
If `selected` is set it is the currently selected root.

For complex pairs we only store the root with positive imaginary part,
the other is generated on request in `get_poles`.
"""
mutable struct Root
    pos::Point2f
    pole::Bool
    selected::Bool
end

function get_poles(roots)
    a = Point2f[]
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

function to_points(roots)
    a = Point2f[]
    for node in roots
        push!(a, node.pos)
        if node.pos[2] != 0
            push!(a, node.pos .* [1, -1])
        end
    end
    return a
end

function get_zeros(roots)
    a = Point2f[]
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
    for i in eachindex(roots)
        if roots[i].selected
            if roots[i].pos[2] == 0
                return i, Point2f[roots[i].pos], roots[i].pole ? POLE_MARKER : ZERO_MARKER 
            else
                return i, Point2f[roots[i].pos, [1, -1] .* roots[i].pos], roots[i].pole ? POLE_MARKER : ZERO_MARKER
            end
        end
    end
    return 0, Point2f[], POLE_MARKER
end

function unselect_all!(roots)
    for root in roots[]
        root.selected = false
    end
end

function find_close(pos, roots, eps)
    pos = [pos[1], abs(pos[2])] # Root only has positive conjugate
    closest = Root(Point2f(Inf, Inf), false, false)
    for root in roots
        if sum(abs2, root.pos .- pos) < sum(abs2, closest.pos .- pos) 
            closest = root
        end
    end
    if all(abs.(closest.pos .- pos) .< eps)
        return closest
    end
end
