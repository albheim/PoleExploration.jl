@testitem "Interactive system creation" begin
    import PoleExploration: Observable, Point2f, lift
    import PoleExploration: Root, create_system
    import PoleExploration: get_selected, get_zeros, get_poles
    import PoleExploration: DelayLtiSystem, zpk, delay

    roots = Observable(Root[Root(Point2f(-1, 0), true, false)])

    zeros = lift(get_zeros, roots)
    poles = lift(get_poles, roots)
    gain = Observable(1.0)
    outputdelay = Observable(0.0)

    selected_data = lift(get_selected, roots)
    selected_idx = lift(x -> x[1], selected_data)
    selected_pos = lift(x -> x[2], selected_data)
    selected_token = lift(x -> x[3], selected_data)

    sys = lift(create_system, zeros, poles, gain, outputdelay)

    @test sys[] isa DelayLtiSystem
    @test sys[] == DelayLtiSystem(zpk([], [-1.0], 1.0))

    roots[] = push!(roots[], Root(Point2f(-0.5, 1.0), true, true))
    roots[] = push!(roots[], Root(Point2f(5.0, 0.0), false, true))

    @test sys[] == DelayLtiSystem(zpk([5.0], [-1.0, -0.5+im, -0.5-im], 1.0))

    gain[] = 2.0
    outputdelay[] = 1.0
    @test sys[] == delay(1.0) * zpk([5.0], [-1.0, -0.5+im, -0.5-im], 2.0)
end
