module StorageDispatch

import Base.isapprox

export StorageUnit, StorageUnitState, StorageFleetState,
       charge!, fullcharge!, discharge!, fulldischarge!, reset!,
       dispatch!, steadydispatch!, dispatch, isadequate, issteadyadequate

const epsilon = sqrt(eps())

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

function dispatch!(shortfall::Vector{Float64},
                   units::Vector{StorageUnit}, netload::Vector{Float64};
                   eps::Float64=epsilon)

    length(shortfall) == length(netload) ||
        error("Shortfall and net load vector lengths must match")

    state = StorageFleetState(units)

    for t in eachindex(netload)

        nl = netload[t]

        if nl > 0 # shortfall condition, discharge storage units
            sf = discharge!(state, nl)
            shortfall[t] = sf > eps ? sf : 0
        else # surplus condition, charge storage units
            shortfall[t] = 0.
            charge!(state, -nl)
        end

        reset!(state)

    end

end

function steadydispatch!(shortfall::Vector{Float64},
                         units::Vector{StorageUnit}, netload::Vector{Float64};
                         eps::Float64=epsilon)

    length(shortfall) == length(netload) ||
        error("Shortfall and net load vector lengths must match")

    state = StorageFleetState(units)

    n_units = length(units)
    ttg_start = Vector{Float64}(undef, n_units)

    adequate = false
    steadystate = false
    net_charge = false

    # Loop until system is sustainably resource adequate, OR
    # storage units are in steady-state.
    while !(adequate && net_charge) && !steadystate

        adequate = true
        ttg_start .= getproperty.(state.units, :ttg)

        for t in eachindex(netload)

            nl = netload[t]

            if nl > 0 # shortfall condition, discharge storage units

                sf = discharge!(state, nl, eps=eps)

                if sf > eps
                    shortfall[t] = sf
                    adequate = false
                else
                    shortfall[t] = 0.
                end

            else # surplus condition, charge storage units
                charge!(state, -nl, eps=eps)
                shortfall[t] = 0.
            end

            reset!(state)

        end

        # Probably a more efficient way to keep track of these...
        net_charge = all(i -> state.units[i].ttg > ttg_start[i], 1:n_units)
        steadystate = all(i -> ttg_start[i] ≈ state.units[i].ttg, 1:n_units)

    end

end

function isadequate(units::Vector{StorageUnit}, netload::Vector{Float64};
                    eps::Float64=epsilon)

    state = StorageFleetState(units)

    for t in eachindex(netload)

        nl = netload[t]

        if nl > 0 # shortfall condition, discharge storage units
            discharge!(state, nl, eps=eps) > eps && return false
        else # surplus condition, charge storage units
            charge!(state, -nl, eps=eps)
        end

        reset!(state)

    end

    return true

end

function issteadyadequate(units::Vector{StorageUnit}, netload::Vector{Float64};
                    eps::Float64=epsilon)

    state = StorageFleetState(units)

    n_units = length(units)
    ttg_start = Vector{Float64}(undef, n_units)

    adequate = false
    steadystate = false
    net_charge = false

    # Loop until system is sustainably resource adequate, OR
    # storage units are in steady-state.
    while !(adequate && net_charge) && !steadystate

        adequate = true
        ttg_start .= getproperty.(state.units, :ttg)

        for t in eachindex(netload)

            nl = netload[t]

            if nl > 0 # shortfall condition, discharge storage units
                discharge!(state, nl, eps=eps) > eps && (adequate = false)
            else # surplus condition, charge storage units
                charge!(state, -nl, eps=eps)
            end

            reset!(state)

        end

        # Probably a more efficient way to keep track of these...
        net_charge = all(i -> state.units[i].ttg > ttg_start[i], 1:n_units)
        steadystate = all(i -> ttg_start[i] ≈ state.units[i].ttg, 1:n_units)

    end

    return adequate

end

end # module
