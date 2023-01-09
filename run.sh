#!/usr/bin/bash

echo "Starting Pole Exploration"
julia --project -e "using PoleExploration; PoleExploration.run()"
