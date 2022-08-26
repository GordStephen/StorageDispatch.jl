function dispatch_test()

@testset "Chronological Dispatch" begin

    @testset "Chronological Dispatch 1" begin

        units = [
            StorageUnit(10., 40.), # 4h
            StorageUnit(10., 20.), # 2h
        ]

        netload = Float64[-25, -15, -10, -5, 5, 10, 20, 30, 10]

        shortfall, surplus = dispatch(units, netload)

        @test shortfall == [0, 0, 0, 0, 0, 0, 0, 15, 10]
        @test surplus == [5, 0, 0, 0, 0, 0, 0, 0, 0]

    end

end

end

function dispatch_compare(seed::Int,
    charge1!::Function, charge2!::Function,
    discharge1!::Function, discharge2!::Function;
    atol::Float64=0., rtol::Float64=0.)

    @testset "Randomized Chronological Dispatch Comparison $seed" begin

        # Provide a unique seed since @testset resets the RNG seed
        Random.seed!(seed)

        units, nameplate = randomunits(10)
        netload = randn(1000) * nameplate

        state1 = StorageFleetState(units)
        state2 = StorageFleetState(units)

        for nl in netload

            if nl > 0
                s1 = discharge1!(state1, nl)
                s2 = discharge2!(state2, nl)
            else
                s1 = charge1!(state1, -nl)
                s2 = charge2!(state2, -nl)
            end

            @test s1 ≈ s2 atol=atol rtol=rtol
            @test state1 ≈ state2 atol=atol rtol=rtol

            reset!(state1)
            reset!(state2)

        end

    end

end

function dispatch_compare(charge1!::Function, charge2!::Function,
                          discharge1!::Function, discharge2!::Function;
                          atol::Float64=0., rtol::Float64=0.)

    @testset "Randomized Chronological Dispatch Comparison" begin
        for i in 1:n_random_replications
            dispatch_compare(i, charge1!, charge2!, discharge1!, discharge2!,
                             atol=atol, rtol=rtol)
        end
    end

end
