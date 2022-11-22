if not exist "build\custom_sysimage.so" (
    echo "Building custom sysimage, this might take a while..."
    julia build/build_sysimage.jl
)

echo "Starting Pole Exploration"
julia --project -J build/custom_sysimage.so -e "using PoleExploration; PoleExploration.run()"