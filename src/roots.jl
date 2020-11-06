function find_close(pos, roots, eps)
    pos = [pos[1], abs(pos[2])] # Root only has positive conjugate
    closest = Root(Point2f0(Inf, Inf), false, false)
    for root in roots
        if sum(abs2, root.pos .- pos) < sum(abs2, closest.pos .- pos) 
            closest = root
        end
    end
    if all(abs.(closest.pos .- pos) .< eps)
        @show closest
        return closest
    else
        println("nothing")
    end
end

""" Root only contain the conjugate with positive imaginary part
"""
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

function to_points(roots)
    a = Point2f0[]
    for node in roots
        push!(a, node.pos)
        if node.pos[2] != 0
            push!(a, node.pos .* [1, -1])
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
    for i in eachindex(roots)
        if roots[i].selected
            return i
        end
    end
    return 0
end

function unselect_all!(roots)
    for root in roots[]
        root.selected = false
    end
end