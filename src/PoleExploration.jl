module PoleExploration

using GLMakie
using ControlSystems

include("roots.jl")
include("plotting.jl")
include("scene.jl")

const POLE_MARKER = 'x'
const ZERO_MARKER = 'o'

using SnoopPrecompile
@precompile_setup begin
    # Some stuff here?
    @precompile_all_calls begin
        roots = Observable(Root[Root(Point2f(-1, 0), true, false, false)])
        gain = Observable(1.0)
        outputdelay = Observable(0.0)

        fig = scenesetup(roots, gain, outputdelay)

        roots[] = push!(roots[], Root(Point2f(-0.5, 1.0), true, true, true))
        roots[] = push!(roots[], Root(Point2f(5.0, 0.0), false, true, false))
        gain[] = 2.0
        outputdelay[] = 1.0

        display(fig) # Adds a lot to precompile, and reducing a little on use
        # Simulate clicks?
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
    fig = scenesetup(roots, gain, outputdelay)
    wait(display(fig))
end

end