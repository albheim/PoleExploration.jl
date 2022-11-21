# PoleExploration

A simple GUI for playing around with poles and zeros and visualize how step/impulse/bode/nyquist plots change.

# Installation

```julia
julia> ] add https://github.com/albheim/PoleExploration.jl
```

# Usage 
Either start it from a running julia REPL like
```julia-repl
julia> import PoleExploration

julia> PoleExploration.run()
```
or from the command line like
```
julia -e "import PoleExploration; PoleExploration.run()"
```

This will start a GUI where you can interact with poles/zeros. 

Double left click will add a pole in the root locus.
Left click will select a root (pole/zero), when selected you can:
* Move it to a new location with right click.
* Switch between pole/zero with space.
* Remove it with delete.

Zooming is done with scroll or left click drag, panning is done with right click drag. Holding x or y while doing these actions will constrain them to only x or y axis.

# Problems
There is some problem with `GLFW.jl` on some computers resulting in an error along the lines of `libGL error: MESA-LOADER: failed to open iris: ...`, this can be worked around by telling julia to use the local `libstdc++` version instead of its own
```bash
export LD_PRELOAD=/usr/lib64/libstdc++.so.6 julia --project -e "using PoleExploration; start()"
```