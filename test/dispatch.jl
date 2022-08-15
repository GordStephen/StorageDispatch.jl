function dispatch_test()

@testset "Chronological Dispatch" begin

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
