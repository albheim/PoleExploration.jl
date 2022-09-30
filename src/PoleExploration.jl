module PoleExploration

using GLMakie
using ControlSystems

export start

include("roots.jl")
include("plotting.jl")
include("scene.jl")

const POLE_MARKER = 'x'
const ZERO_MARKER = 'o'

using SnoopPrecompile
@precompile_setup begin
    # Some stuff here?
    @precompile_all_calls begin
        fig = scenesetup()
        display(fig) # Adds a lot to precompile, and reducing a little on use
        # Simulate clicks?
        # Call all root finders with Observables?
    end
end

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
    fig = scenesetup()
    wait(display(fig))
end

# For packagecompiler
function julia_main()::Cint
    start()
    return 0
end

end