module PoleExploration

using GLMakie
using ControlSystems

export start

include("roots.jl")
include("plotting.jl")

function scenesetup()
    # Parent scene
    fig = Figure(resolution = (1200, 1000), backgroundcolor = RGBf(0.98, 0.98, 0.98))

    # Variables
    roots = Observable(Root[Root(Point2f(-1, 0), true, false)])

    zeros = lift(get_zeros, roots)
    poles = lift(get_poles, roots)
    gain = Observable(1.0)

    selected_data = lift(get_selected, roots)
    selected_idx = lift(x -> x[1], selected_data)
    selected_pos = lift(x -> x[2], selected_data)
    selected_token = lift(x -> x[3], selected_data)
    
    sys = lift((z, p, k) -> begin
        zpk([a + b*im for (a, b) in z], [a + b*im for (a, b) in p], k)
    end, zeros, poles, gain)

    # Reactiveness
    mouseevents = addmouseevents!(fig.scene)

    # General settings
    kwargs = Dict()#:xtickalign => 1, :ytickalign => 1, :yticklabelspace => 25)

    # Root locus
    root_ax = Axis(fig[1:2, 1]; title = "Root locus", kwargs...)
    scatter!(root_ax, poles, color=:red, marker='+', markersize=10)
    scatter!(root_ax, zeros, color=:red, marker='o', markersize=10)
    scatter!(root_ax, selected_pos, color=:green, marker=selected_token, markersize=10)

    # Step plot
    step_ax = Axis(fig[3, 1]; title = "Step", kwargs...)
    step_points = lift(sys -> begin
        y, t, x = step(sys)
        limits!(step_ax, find_limits(t), find_limits(y))
        convert.(Point2f, zip(t, vec(y)))
    end, sys)
    lines!(step_ax, step_points)

    # Impulse plot
    impulse_ax = Axis(fig[4, 1]; title = "Impulse", kwargs...)
    impulse_points = lift(sys -> begin
        y, t, x = impulse(sys)
        limits!(impulse_ax, find_limits(t), find_limits(y))
        #axes[4].xticks = 0:pi:2pi
        convert.(Point2f, zip(t, vec(y)))
    end, sys)
    lines!(impulse_ax, impulse_points)

    # Bode plot
    bodemag_ax = Axis(fig[1, 2]; title = "Magnitude", yscale=log10, xscale=log10, kwargs...)
    bodephase_ax = Axis(fig[2, 2]; title = "Phase", xscale=log10, kwargs...)
    linkxaxes!(bodemag_ax, bodephase_ax)
    bodevars = lift(sys -> begin
        mag, phase, w = bodev(sys)
        logmag = log10.(mag)
        logw = log10.(w)
        wlims = find_limits(logw)
        maglims = find_limits(logmag)
        phaselims = find_limits(phase)
        limits!(bodemag_ax, exp10.(wlims), exp10.(maglims))
        limits!(bodephase_ax, exp10.(wlims), phaselims)
        w, mag, phase
    end, sys) # TODO use nyquist instead to calculate this?
    bodemag_points = lift(x -> convert.(Point2f, zip(x[1], x[2])), bodevars)
    bodephase_points = lift(x -> convert.(Point2f, zip(x[1], x[3])), bodevars)
    lines!(bodemag_ax, bodemag_points)
    lines!(bodephase_ax, bodephase_points)

    # Nyquist plot
    nyquist_ax = Axis(fig[3:4, 2]; title = "Nyquist", kwargs...)
    nyquist_points = lift(sys -> begin
        a, b, _ = nyquistv(sys)
        limits!(nyquist_ax, find_limits(a, start=[-1, 1]), find_limits(b, start=[-1, 1]))
        convert.(Point2f, zip(a, b))
    end, sys)
    lines!(nyquist_ax, nyquist_points)
    lines!(nyquist_ax, cos.(0:0.01:2pi), sin.(0:0.01:2pi), color=:red)

    gain_box = fig[0, 1] = GridLayout()
    gain_slider = Slider(gain_box[1, 1], range=-10:0.01:10, startvalue=gain[])
    gain_label = Label(gain_box[1, 2], text = lift(x -> "K=$(x)", gain_slider.value), textsize=20)
    on(gain_slider.value) do value
        gain[] = value
    end

    # Other
    tf_text = lift(print_tf, roots, gain)
    tf_label = Label(fig[0, 2], text=tf_text, tellwidth=false)

    mousestate = addmouseevents!(root_ax.scene)
    onmouseleftclick(mousestate) do state
        # Find closest point, if point is within reasonable distance given scale select it
        root = find_close(state.data, roots[], root_ax.finallimits[].widths ./ 50)
        # TODO set selected
        if !isnothing(root)
            unselect_all!(roots) # Unselects without sending out update
            root.selected = true
            roots[] = roots[] # Update
            #@show "selected", root
        end
    end
    onmouseleftdoubleclick(mousestate) do state
        x = state.data[1]
        y = state.data[2]
        if abs(y) < root_ax.finallimits[].widths[2] / 100
            y = 0
        end
        unselect_all!(roots) # Unselects without sending out update
        newroot = Root(Point2f(x, abs(y)), true, true) # Add new root and send update
        roots[] = push!(roots[], newroot)
    end
    onmouserightclick(mousestate) do state
        if selected_idx[] != 0
            x = state.data[1]
            y = state.data[2]
            if roots.val[selected_idx[]].pos[2] == 0                    
                y = 0
            else
                y = abs(y)
            end
            roots.val[selected_idx[]].pos = Point2f(x, y)
            roots[] = roots[]
        end
    end

    on(events(fig).keyboardbutton) do event
        if event.action == Keyboard.press || event.action == Keyboard.repeat
            if event.key == Keyboard.r
                roots[] = Root[Root(Point2f(-1, 0), true, false)]
                set_close_to!(gain_slider, 1.0)
                autolimits!(root_ax)
            elseif event.key == Keyboard.space
                if selected_idx[] != 0
                    if roots.val[selected_idx[]].pole && length(poles[]) - length(zeros[]) < 2 * (1 + (roots.val[selected_idx[]].pos[2] != 0))
                        println("Can't change that since it would create an system with more poles than zeros.")
                    else
                        roots.val[selected_idx[]].pole = !roots.val[selected_idx[]].pole
                        roots[] = roots[]
                    end
                end
            elseif event.key == Keyboard.delete
                if selected_idx[] != 0
                    if roots.val[selected_idx[]].pole && length(poles[]) - length(zeros[]) < (1 + (roots.val[selected_idx[]].pos[2] != 0))
                        println("Can't remove that since it would create an system with more poles than zeros.")
                    else
                        roots[] = [roots[][1:selected_idx[]-1]; roots[][selected_idx[]+1:end]]
                        selected_idx[] = 0
                    end
                end
            elseif event.key == Keyboard.z
                sys[] = sys[]
                autolimits!(root_ax)
            end
        end
    end

    fig
end
fig = scenesetup()

function start()
    println("""
    This is a tool for pole/zero exploration.

    Double left click will add poles in the root locus.
    Select roots with left click to modify them. 
    * Space will switch between pole and zero for the selected root.
    * Right click moves the selected root.
    * Delete will remove the selected root.

    Panning is done with left click. Zooming can be done with scroll or right click drag.
    Zooming or panning while holding x or y will constrain the zoom/pan to that axis.
    Pressing z will reset all zoom/pan to the automatic value.
    
    Pressing r will reset everything to the start configuration.
    """)
    scenesetup()
end

end