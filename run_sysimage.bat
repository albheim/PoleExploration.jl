if not exist "build\custom_sysimage.dll" (
    echo "Building custom sysimage, this might take a while..."
    julia build/build_sysimage.jl
)

echo "Starting Pole Exploration"
julia --project -J build/custom_sysimage.dll -e "using PoleExploration; PoleExploration.run()"