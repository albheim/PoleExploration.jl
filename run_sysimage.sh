#!/usr/bin/bash

# When should this be needed? Intel graphics and some other cases?
export LD_PRELOAD=/usr/lib64/libstdc++.so.6 

if ! [ -f "build/custom_sysimage.so" ]; then
    echo "Building custom sysimage, this might take a while..."
    julia build/build_sysimage.jl
fi

echo "Starting Pole Exploration"
julia --project -J build/custom_sysimage.so -e "using PoleExploration; start()"