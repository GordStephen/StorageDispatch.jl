"""
Basic representation of a storage device
"""
struct StorageUnit
    capacity::Float64 # MW
    energy::Float64 # MWh
end

"""
Internal data for tracking unit-level state-of-charge relative to
unit capacity and energy constraints
"""
mutable struct StorageUnitState
    p::Float64
    ttg_max::Float64
    ttg::Float64
    t_remaining::Float64 # positive for both charging and discharging
end

isapprox(x::StorageUnitState, y::StorageUnitState; kwargs...) =
    (x.p == y.p) &&
    (x.ttg_max == y.ttg_max) &&
    isapprox(x.ttg, y.ttg; kwargs...) &&
    isapprox(x.t_remaining, y.t_remaining; kwargs...)

isdischargeable(unit::StorageUnitState) =
    (unit.ttg > 0) && (unit.t_remaining > 0)

ischargeable(unit::StorageUnitState) =
    (unit.ttg < unit.ttg_max) && (unit.t_remaining > 0)

StorageUnitState(unit::StorageUnit) = StorageUnitState(
    unit.capacity, unit.energy/unit.capacity, 0.0, 1.0
)

function reset!(stor::StorageUnitState)
    stor.t_remaining = 1.0
    return
end

function fullcharge!(stor::StorageUnitState)
    reset!(stor)
    stor.ttg = stor.ttg_max
    return
end

function fulldischarge!(stor::StorageUnitState)
    reset!(stor)
    stor.ttg = 0.
    return
end

"""
Tracks the state of the all of the individual units, enforcing the invariant
that units are sorted by max time-to-go.
"""
struct StorageFleetState

    units::Vector{StorageUnitState}

    function StorageFleetState(units::Vector{StorageUnit})
        sortedunits = sort(StorageUnitState.(units), by=x->x.ttg_max, rev=true)
        return new(sortedunits)
    end

end

reset!(x::StorageFleetState) = reset!.(x.units)
fullcharge!(x::StorageFleetState) = fullcharge!.(x.units)
fulldischarge!(x::StorageFleetState) = fulldischarge!.(x.units)

isapprox(x::StorageFleetState, y::StorageFleetState; kwargs...) =
    (length(x.units) == length(y.units)) &&
    all(isapprox(xu, yu; kwargs...) for (xu, yu) in zip(x.units, y.units))
