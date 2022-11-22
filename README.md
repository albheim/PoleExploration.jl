# PoleExploration

A simple GUI for playing around with poles and zeros and visualize how step/impulse/bode/nyquist plots change.

# Installation

```
julia> ] add https://github.com/albheim/PoleExploration.jl
```

# Usage 
### Start
Either start it from a running julia REPL like
```julia-repl
julia> import PoleExploration

julia> PoleExploration.run()
```
or from the command line like
```
julia -e "import PoleExploration; PoleExploration.run()"
```

Additionally there is a `run_sysimage.{sh/bat}` for linux/windows which compiles a system-image
and runs the program through this. This will take quite some time the first run, but reduce
the startup for consecutive runs.

### Interactive controls
Running it you will get a GUI where you can interact with poles/zeros. 

Double left click will add a pole in the pole-zero diagram.
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

This is currently the default in the `run_sysimage.sh` file.

# TODO
* Using unit static gain tfs, 1/(sT+1) and w^2/(s^2+2*z*w*s+w^2), though displaying the full tf could be improved.
* Add sliders for currently selected root(s) parameters, i.e. T or w/z. Needs to be linked with roots in both directions.
* Allow selecting a freq in bode/nyquist and reflect the point in the other.
* Impulse or not, need to fix delay problems.
* Allow setting timespan and freqspan (more sliders?)
* Maybe add textfield for each slider to allow more precise control?
* Improve instructions with tooltips and color, `tooltip!(Point2f(0), "This is a tooltip pointing at x")`
* Allow for multiple tfs, one is "active" and can be interacted with, the other are just for comparison in different color?
* Improve precompile as well as packagecompiler.
* Fix tests, could maybe be used for precompile/packagecompiler.