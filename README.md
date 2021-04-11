# PoleExploration

A simple GUI for playing around with poles and zeros and visualize how step/impulse/bode/nyquist plots change.

# News

Currently it is not working with recent versions of Makie. Instantiate the environment to be sure that versions are compatible.

```julia
using Pkg
Pkg.develop(url="https://github.com/albheim/PoleExploration")
Pkg.activate(joinpath(Base.DEPOT_PATH[1], "dev", "PoleExploration"))
Pkg.instantiate()
using PoleExploration
start()
```

# Installation

```julia
julia> ] add https://github.com/albheim/PoleExploration
```

# Usage 

```julia
using PoleExploration
start()
```

This will start a GUI where you can interact with poles/zeros. 

Double left click will add a pole in the root locus.
Left click will select a root (pole/zero), when selected you can:
* Move it to a new location with right click.
* Switch between pole/zero with space.
* Remove it with delete.

Zooming is done with scroll or left click drag, panning is done with right click drag. Holding x or y while doing these actions will constrain them to only x or y axis.