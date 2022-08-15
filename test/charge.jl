function charge_test(c!::Function, label::String="";
                     atol::Float64=0., rtol::Float64=0.)

@testset "Charge $label" begin

@testset "Charge $label 1" begin

    units = [
        StorageUnit(10., 40.), # 4h
        StorageUnit(10., 20.), # 2h
    ]

    state = StorageFleetState(units)

    sp = c!(state, 20.)

    @test state.units[1].t_remaining ≈ 0. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 0. atol=atol rtol=rtol

    reset!(state)

    @test sp ≈ 0. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 1. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 1. atol=atol rtol=rtol

    sp = c!(state, 20.)
    reset!(state)

    @test sp ≈ 0. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 2. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 2. atol=atol rtol=rtol

    sp = c!(state, 20.)
    reset!(state)

    @test sp ≈ 10. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 3. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 2. atol=atol rtol=rtol

    sp = c!(state, 20.)
    reset!(state)

    @test sp ≈ 10. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 4. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 2. atol=atol rtol=rtol

end

@testset "Charge $label 2" begin

    units = [
        StorageUnit(10., 40.), # 4h
        StorageUnit(10., 20.), # 2h
    ]

    state = StorageFleetState(units)

    sp = c!(state, 10.)
    @test state.units[1].t_remaining ≈ 0.5 atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 0.5 atol=atol rtol=rtol

    reset!(state)
    @test state.units[1].t_remaining ≈ 1. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 1. atol=atol rtol=rtol

    @test sp ≈ 0. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 0.5 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 0.5 atol=atol rtol=rtol

    sp = c!(state, 20.)
    reset!(state)

    @test sp ≈ 0. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 1.5 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 1.5 atol=atol rtol=rtol

    sp = c!(state, 20.)
    reset!(state)

    @test sp ≈ 5. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 2.5 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 2.0 atol=atol rtol=rtol

    sp = c!(state, 25.)
    reset!(state)

    @test sp ≈ 15. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 3.5 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 2.0 atol=atol rtol=rtol

    sp = c!(state, 15.)
    reset!(state)

    @test sp ≈ 10. atol=atol rtol=rtol
    @test state.units[1].ttg ≈ 4.0 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 2.0 atol=atol rtol=rtol

end

@testset "Charge $label 3" begin

    units = [
        StorageUnit(10., 30.), # 3h
        StorageUnit(5., 10.), # 2h
    ]

    state = StorageFleetState(units)

    sp = c!(state, 20.)

    @test sp ≈ 5. atol=atol rtol=rtol

    @test state.units[1].t_remaining ≈ 0. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 0. atol=atol rtol=rtol

    @test state.units[1].ttg ≈ 1. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 1. atol=atol rtol=rtol

end

@testset "Charge $label 4" begin

    units = [
        StorageUnit(10., 20.), # 2h
        StorageUnit(10., 15.), # 1.5h
    ]

    state = StorageFleetState(units)
    fullcharge!(state)

    sp = c!(state, 10.)

    @test sp ≈ 10. atol=atol rtol=rtol

    @test state.units[1].t_remaining ≈ 1. atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 1. atol=atol rtol=rtol

    @test state.units[1].ttg ≈ 2. atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 1.5 atol=atol rtol=rtol

end

@testset "Charge $label 5" begin

    units = [
        StorageUnit(100., 20.), # .2h
        StorageUnit(100., 15.), # .15h
        StorageUnit(100., 10.), # .1h
        StorageUnit(100., 5.), # .05h
    ]

    state = StorageFleetState(units)

    sp = c!(state, 4.)

    @test sp ≈ 0. atol=atol rtol=rtol

    @test state.units[1].t_remaining ≈ .99 atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ .99 atol=atol rtol=rtol
    @test state.units[3].t_remaining ≈ .99 atol=atol rtol=rtol
    @test state.units[4].t_remaining ≈ .99 atol=atol rtol=rtol

    @test state.units[1].ttg ≈ .01 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ .01 atol=atol rtol=rtol
    @test state.units[3].ttg ≈ .01 atol=atol rtol=rtol
    @test state.units[4].ttg ≈ .01 atol=atol rtol=rtol

end

@testset "Charge $label 6" begin

    # Catches a bug in the QP formulation where charging wasn't appropriately
    # weighted by power

    Random.seed!(100)
    units, nameplate = randomunits(10)
    surplus = nameplate * 1.2 * rand()

    state = StorageFleetState(units)

    sp = c!(state, surplus)

    @test sp ≈ 0. atol=atol rtol=rtol

    @test state.units[1].t_remaining ≈ 0.945944 atol=atol rtol=rtol
    @test state.units[2].t_remaining ≈ 0.945944 atol=atol rtol=rtol
    @test state.units[3].t_remaining ≈ 0.945944 atol=atol rtol=rtol
    @test state.units[4].t_remaining ≈ 0.945944 atol=atol rtol=rtol

    @test state.units[1].ttg ≈ 0.054055 atol=atol rtol=rtol
    @test state.units[2].ttg ≈ 0.054055 atol=atol rtol=rtol
    @test state.units[3].ttg ≈ 0.054055 atol=atol rtol=rtol
    @test state.units[4].ttg ≈ 0.054055 atol=atol rtol=rtol

end

end

end

function charge_compare(
    seed::Int, charge1!::Function, charge2!::Function;
    atol::Float64=0., rtol::Float64=0.)

    @testset "Randomized Charge Comparison $seed" begin

        # Provide a unique seed since @testset resets the RNG seed
        Random.seed!(seed)

        units, nameplate = randomunits(10)

        state1 = StorageFleetState(units)
        state2 = StorageFleetState(units)

        for t in 1:10

            surplus = nameplate * 1.2 * rand()

            sp1 = charge1!(state1, surplus)
            sp2 = charge2!(state2, surplus)
            
            @test sp1 ≈ sp2 atol=atol rtol=rtol
            @test state1 ≈ state2 atol=atol rtol=rtol

            reset!(state1)
            reset!(state2)

        end

    end

end

function charge_compare(charge1!::Function, charge2!::Function;
                        atol::Float64=0., rtol::Float64=0.)

    @testset "Randomized Charge Comparison" begin
        for i in 1:n_random_replications
            charge_compare(i, charge1!, charge2!, atol=atol, rtol=rtol)
        end
    end

end
