function randomunits(maxcount::Int;
                     maxcap::Float64=50.,
                     maxenergy::Float64=100.
)

    n_units = rand(1:maxcount)
    units = Vector{StorageUnit}(undef, n_units)

    for i in eachindex(units)
        units[i] = StorageUnit(maxcap*rand(), maxenergy*rand())
    end

    return units, maxcap*n_units

end

function util_test()

@testset "Utilities" begin

    units = [
        StorageUnit(10., 20.), # 2h
        StorageUnit(10., 40.), # 4h
    ]

    state = StorageFleetState(units)

    @test state.units[1].p == 10.
    @test state.units[1].ttg_max == 4.

    @test state.units[2].p == 10.
    @test state.units[2].ttg_max == 2.

    @test state.units[1].ttg == 0.
    @test state.units[2].ttg == 0.

    fullcharge!(state)

    @test state.units[1].ttg == 4.
    @test state.units[2].ttg == 2.

    fulldischarge!(state)

    @test state.units[1].ttg == 0.
    @test state.units[2].ttg == 0.

end

end
