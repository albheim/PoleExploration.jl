module PoleExploration

using GLMakie
using ControlSystems

include("roots.jl")
include("plotting.jl")
include("scene.jl")

const POLE_MARKER = 'x'
const ZERO_MARKER = 'o'

using PrecompileTools
@setup_workload begin
    # Some setup?
    @compile_workload begin
        # Standard setup
        roots = Observable(Root[Root(Point2f(-1, 0), true, false, false)])
        gain = Observable(1.0)
        outputdelay = Observable(0.0)
        fig, mousestate = scenesetup(roots, gain, outputdelay)

        # Simulate changing the values in the transfer function
        roots[] = push!(roots[], Root(Point2f(-0.5, 1.0), true, true, true))
        roots[] = push!(roots[], Root(Point2f(5.0, 0.0), false, true, false))
        gain[] = 2.0
        outputdelay[] = 1.0

        # Simulate click and doubleclick on root plot
        mousestate.obs[] = Makie.MouseEvent(Makie.MouseEventTypes.leftclick, 1.673275059403704e9, Float32[-0.24714828, 0.25], Float32[206.0, 250.0], 1.673275059334463e9, Float32[-0.24714828, 0.25], Float32[206.0, 250.0])
        mousestate.obs[] = Makie.MouseEvent(Makie.MouseEventTypes.leftdoubleclick, 1.673275059533142e9, Float32[-0.24714828, 0.25], Float32[206.0, 250.0], 1.673275059498469e9, Float32[-0.24714828, 0.25], Float32[206.0, 250.0])

        # Can we precompile display without showing a window?
        # display(fig) # Adds a lot to precompile, and reducing a little on use

        # Call all root finders with Observables?
    end
end

function run()
    println("""
    This is a tool for exploring how pole-zero placements affect the system properties.

    Double left click will add poles in the pole-zero diagram.
    Select roots with left click to drag or modify them. 
    * Space will switch between pole and zero for the selected root.
    * Delete will remove the selected root.

    Panning is done with right click. Zooming can be done with scroll or left click drag.
    Zooming or panning while holding x or y will constrain the zoom/pan to that axis.
    Pressing z will reset all zoom/pan to the automatic value.
    
    Pressing r will reset everything to the start configuration.
    """)

    # Initial values
    roots = Observable(Root[Root(Point2f(-1, 0), true, false, false)])
    gain = Observable(1.0)
    outputdelay = Observable(0.0)

    # Create scene and wait for the display to be closed
    fig, = scenesetup(roots, gain, outputdelay)
    wait(display(fig))
end

end
