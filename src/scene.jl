function scenesetup(roots, gain, outputdelay)
    set_window_config!(; title = "Pole Exploration")

    # Parent scene
    fig = Figure(resolution = (1200, 1000), backgroundcolor = RGBf(0.98, 0.98, 0.98))

    # Variables
    zeros = lift(get_zeros, roots)
    poles = lift(get_poles, roots)
    sys = lift(create_system, roots, gain, outputdelay)

    selected_data = lift(get_selected, roots)
    selected_idx = lift(x -> x[1], selected_data)
    selected_pos = lift(x -> x[2], selected_data)
    selected_token = lift(x -> x[3], selected_data)

    # Layout
    slider_box = fig[1, 1] = GridLayout()
    tf_box = fig[1, 2] = GridLayout()
    root_ax = Axis(fig[2:3, 1]; title = "System roots ($POLE_MARKER) and zeros ($ZERO_MARKER)")
    step_ax = Axis(fig[4:5, 1]; title = "System step response")
    # impulse_ax = Axis(fig[5, 1]; title = "System impulse response")
    bodemag_ax = Axis(fig[2, 2]; title = "Bode magnitude", yscale=log10, xscale=log10)
    bodephase_ax = Axis(fig[3, 2]; title = "Bode phase", xscale=log10)
    nyquist_ax = Axis(fig[4:5, 2]; title = "Nyquist diagram")

    # Plots

    # Root locus
    scatter!(root_ax, poles, color=:black, marker=POLE_MARKER, markersize=12)
    scatter!(root_ax, zeros, color=:black, marker=ZERO_MARKER, markersize=12)
    scatter!(root_ax, selected_pos, color=:red, marker=selected_token, markersize=12)
    vlines!(root_ax, 0.0; linestyle=:dash, color=:gray)
    hlines!(root_ax, 0.0; linestyle=:dash, color=:gray)
    xlims!(root_ax, high=1)

    # Step plot
    stepvars = lift(sys -> begin
        y, t, x = step(sys)
        static_gain = only(dcgain(sys))
        limits!(step_ax, find_limits(t), find_limits(y))
        t, y, static_gain
    end, sys)
    step_points = lift(x -> convert.(Point2f, zip(x[1], x[2])), stepvars)
    step_gain = lift(x -> x[3], stepvars)
    lines!(step_ax, step_points)
    hlines!(step_ax, step_gain; linestyle=:dash, color=:gray)

    # Impulse plot
    # impulse_points = lift(sys -> begin
    #     y, t, x = impulse(sys)
    #     limits!(impulse_ax, find_limits(t), find_limits(y))
    #     #axes[4].xticks = 0:pi:2pi
    #     convert.(Point2f, zip(t, vec(y)))
    # end, sys)
    # lines!(impulse_ax, impulse_points)

    # Bode plot
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
    hlines!(bodemag_ax, 1; linestyle=:dash, color=:gray)
    lines!(bodephase_ax, bodephase_points)
    hlines!(bodephase_ax, -180; linestyle=:dash, color=:gray)

    # Nyquist plot
    nyquist_points = lift(sys -> begin
        a, b, _ = nyquistv(sys)
        limits!(nyquist_ax, find_limits(a, start=[-1, 1]), find_limits(b, start=[-1, 1]))
        convert.(Point2f, zip(a, b))
    end, sys)
    lines!(nyquist_ax, nyquist_points)
    lines!(nyquist_ax, cos.(0:0.01:2pi), sin.(0:0.01:2pi); color=:gray, linestyle=:dash)
    scatter!(nyquist_ax, -1, 0; marker='+', color=:red, markersize=12)

    # Sliders
    gain_slider = Slider(slider_box[1, 1], range=-10:0.01:10, startvalue=gain[])
    gain_label = Label(slider_box[1, 2], text = lift(x -> "K=$(x)", gain_slider.value), fontsize=20)
    on(gain_slider.value) do value
        gain[] = value
    end
    delay_slider = Slider(slider_box[2, 1], range=0:0.01:2, startvalue=outputdelay[])
    delay_label = Label(slider_box[2, 2], text = lift(x -> "Output delay $(x)", delay_slider.value), fontsize=20)
    on(delay_slider.value) do value
        outputdelay[] = value
    end

    # Two way connections for these, changing in pzplot should update slider, update slider should update pzplot
    # How to do this without creating loop?
    # omega_slider = Slider(slider_box[3, 1], range=-10:0.01:10, startvalue=gain[])
    # omega_label = Label(slider_box[3, 2], text = lift(x -> "K=$(x)", omega_slider.value), fontsize=20)
    # on(omega_slider.value) do value
    #     omega[] = value
    # end
    # # Turn off zeta if single pole selected?
    # zeta_slider = Slider(slider_box[4, 1], range=-10:0.01:10, startvalue=gain[])
    # zeta_label = Label(slider_box[4, 2], text = lift(x -> "K=$(x)", zeta_slider.value), fontsize=20)
    # on(zeta_slider.value) do value
    #     zeta[] = value
    # end

    # Display transfer function
    tf_text = lift(print_tf, roots, gain, outputdelay)
    tf_label = Label(tf_box[1, 1], text=tf_text, tellwidth=false)

    # Interaction
    deregister_interaction!(root_ax, :rectanglezoom) # To allow for dragging roots
    mousestate = addmouseevents!(root_ax.scene)
    onmouseleftclick(mousestate) do state
        # Find closest point, if point is within reasonable distance given scale select it
        root = find_close(state.data, roots[], root_ax.finallimits[].widths ./ 50)
        unselect_all!(roots) # Unselects without sending out update
        if !isnothing(root)
            root.selected = true
        end
        roots[] = roots[] # Update only here to reduce redraw cost
    end
    onmouseleftdragstart(mousestate) do state
        # Find closest point, if point is within reasonable distance given scale select it
        root = find_close(state.data, roots[], root_ax.finallimits[].widths ./ 50)
        unselect_all!(roots) # Unselects without sending out update
        if !isnothing(root)
            root.selected = true
        end
        roots[] = roots[] # Update only here to reduce redraw cost
    end
    onmouseleftdrag(mousestate) do state
        if selected_idx[] != 0
            x = state.data[1]
            y = state.data[2]
            if !roots.val[selected_idx[]].double
                y = 0
            else
                y = abs(y)
            end
            roots.val[selected_idx[]].pos = Point2f(x, y)
            roots[] = roots[]
        end
    end
    onmouseleftdoubleclick(mousestate) do state
        x = state.data[1]
        y = state.data[2]
        if abs(y) < root_ax.finallimits[].widths[2] / 100
            y = 0
        end
        unselect_all!(roots) # Unselects without sending out update
        newroot = Root(Point2f(x, abs(y)), true, true, y != 0) # Add new root and send update
        roots[] = push!(roots[], newroot)
    end

    on(events(fig).keyboardbutton) do event
        if event.action == Keyboard.press || event.action == Keyboard.repeat
            if event.key == Keyboard.r
                roots[] = Root[Root(Point2f(-1, 0), true, false, false)]
                set_close_to!(gain_slider, 1.0)
                set_close_to!(delay_slider, 0.0)
                autolimits!(root_ax)
                xlims!(root_ax, high=1)
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
                xlims!(root_ax, high=1)
            end
        end
    end

    fig, mousestate
end