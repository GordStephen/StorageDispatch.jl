function discharge_test(d!::Function, label::String="";
                        atol::Float64=0., rtol::Float64=0.)

@testset "Discharge $label" begin

@testset "Discharge $label 1" begin

    units = [
        StorageUnit(10., 40.), # 4h
        StorageUnit(10., 20.), # 2h
    ]

    state = StorageFleetState(units)
    fullcharge!(state)

    sf = d!(state, 10.)
    @test state.units[1].t_remaining ≈ 0. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 1. atol=atol rtol=rtol

    reset!(state)
    @test state.units[1].t_remaining ≈ 1. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 1. atol=atol rtol=rtol

    @test sf ≈ 0. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 3. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 2. atol=atol rtol=rtol

    sf = d!(state, 10.)
    reset!(state)

    @test sf ≈ 0. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 2. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 2. atol=atol rtol=rtol

    sf = d!(state, 10.)
    reset!(state)

    @test sf ≈ 0. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 1.5 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 1.5 atol=atol rtol=rtol

    sf = d!(state, 25.)
    reset!(state)

    @test sf ≈ 5. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 0.5 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 0.5 atol=atol rtol=rtol

    sf = d!(state, 15.)
    reset!(state)

    @test sf ≈ 5. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 0. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 0. atol=atol rtol=rtol

end

@testset "Discharge $label 2" begin

    units = [
        StorageUnit(10., 40.), # 4h
        StorageUnit(10., 20.), # 2h
    ]

    state = StorageFleetState(units)
    fullcharge!(state)

    sf = d!(state, 20.)

    @test state.units[1].t_remaining ≈ 0. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 0. atol=atol rtol=rtol

    reset!(state)

    @test sf ≈ 0. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 3. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 1. atol=atol rtol=rtol


    sf = d!(state, 20.)
    reset!(state)

    @test sf ≈ 0. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 2. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 0. atol=atol rtol=rtol

    sf = d!(state, 20.)
    reset!(state)

    @test sf ≈ 10. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 1. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 0. atol=atol rtol=rtol

    sf = d!(state, 20.)
    reset!(state)

    @test sf ≈ 10. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 0. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 0. atol=atol rtol=rtol

end

@testset "Discharge $label 3" begin

    units = [
        StorageUnit(10., 30.), # 3h
        StorageUnit(10., 20.), # 2h
    ]

    state = StorageFleetState(units)
    fullcharge!(state)

    sf = d!(state, 20.)

    @test state.units[1].t_remaining ≈ 0. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 0. atol=atol rtol=rtol

    @test state.units[1].ttg ≈ 2. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 1. atol=atol rtol=rtol

end

@testset "Discharge $label 4" begin

    units = [
        StorageUnit(10., 20.), # 2h
        StorageUnit(10., 15.), # 1.5h
    ]

    state = StorageFleetState(units)
    fullcharge!(state)

    sf = d!(state, 10.)

    @test state.units[1].t_remaining ≈ 0.25 atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 0.75 atol=atol rtol=rtol

    @test state.units[1].ttg ≈ 1.25 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 1.25 atol=atol rtol=rtol

end

@testset "Discharge $label 5" begin

    units = [
        StorageUnit(10., 100.), # 10h
        StorageUnit(10., 15.), # 1.5h
    ]

    state = StorageFleetState(units)
    fullcharge!(state)

    sf = d!(state, 25.)

    @test sf ≈ 5. atol=atol rtol=rtol

    @test state.units[1].t_remaining ≈ 0. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 0. atol=atol rtol=rtol

    @test state.units[1].ttg ≈ 9. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ .5 atol=atol rtol=rtol

end

@testset "Discharge $label 6" begin

    units = [
        StorageUnit(10., 100.), # 10h
        StorageUnit(10., 5.), # 0.5h
    ]

    state = StorageFleetState(units)
    fullcharge!(state)

    sf = d!(state, 20.)

    @test sf ≈ 5. atol=atol rtol=rtol

    @test state.units[1].t_remaining ≈ 0. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ .5 atol=atol rtol=rtol

    @test state.units[1].ttg ≈ 9. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 0. atol=atol rtol=rtol

end

end

end

function discharge_compare(
    seed::Int, discharge1!::Function, discharge2!::Function;
    atol::Float64=0., rtol::Float64=0.)

    @testset "Randomized Discharge Comparison $seed" begin

        # Provide a unique seed since @testset resets the RNG seed
        Random.seed!(seed)

        units, nameplate = randomunits(10)

        state1 = StorageFleetState(units)
        state2 = StorageFleetState(units)

        fullcharge!(state1)
        fullcharge!(state2)

        for t in 1:10

            shortfall = nameplate * 1.2 * rand()

            sp1 = discharge1!(state1, shortfall)
            sp2 = discharge2!(state2, shortfall)
            
            @test sp1 ≈ sp2 atol=atol rtol=rtol
            @test state1 ≈ state2 atol=atol rtol=rtol

            reset!(state1)
            reset!(state2)

        end

    end

end

function discharge_compare(
    discharge1!::Function, discharge2!::Function;
    atol::Float64=0., rtol::Float64=0.)

    @testset "Randomized Discharge Comparison" begin
        for i in 1:n_random_replications
            discharge_compare(i, discharge1!, discharge2!, atol=atol, rtol=rtol)
        end
    end

end
