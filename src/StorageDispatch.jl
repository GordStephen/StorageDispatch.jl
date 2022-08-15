module StorageDispatch

import Base.isapprox

export StorageUnit, StorageUnitState, StorageFleetState,
       charge!, fullcharge!, discharge!, fulldischarge!, reset!, dispatch

include("types.jl")
include("charge.jl")
include("discharge.jl")

function dispatch(units::Vector{StorageUnit}, netload::Vector{Float64})

    T = length(netload)
    shortfall = zeros(T)
    surplus = zeros(T)

    state = StorageFleetState(units)

    for t in eachindex(netload)

        nl = netload[t]

        if nl > 0 # shortfall condition, discharge storage units
            shortfall[t] = discharge!(state, nl)
        else # surplus condition, charge storage units
            surplus[t] = charge!(state, -nl)
        end

        reset!(state)

    end

    return shortfall, surplus

end

end # module
