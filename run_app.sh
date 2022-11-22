#!/usr/bin/bash

export LD_PRELOAD=/usr/lib64/libstdc++.so.6

if ! [ -f "build/compiled" ]; then
    echo "Building application, this might take a while..."
    julia build/build_app.jl
fi

echo "Starting Pole Exploration"
./build/compiled/bin/PoleExploration 