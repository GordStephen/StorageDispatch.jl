function discharge!(x::StorageFleetState, shortfall::Float64; eps=eps())

    while shortfall > eps

        storset = dischargeset(x.units)
        isnothing(storset) && break # No dispatchable units left

        t = group_discharge(x.units, storset, shortfall)

        for i in storset

            # Can add floating point error checks here if needed
            stor = x.units[i]
            stor.ttg -= t
            stor.t_remaining -= t

            shortfall -= t * stor.p

        end

    end

    return shortfall

end

function group_discharge(stors::Vector{StorageUnitState},
                         storset::UnitRange{Int},
                         shortfall::Float64)

    last_idx = last(storset)

    set_p = 0
    min_remaining_t = Inf

    for i in storset
        stor = stors[i]
        set_p += stor.p
        min_remaining_t = min(min_remaining_t, stor.t_remaining)
    end

    eliminate_shortfall_t = shortfall / set_p
    next_set_t = stors[last_idx].ttg

    if last_idx != length(stors)
        next_set_t -= stors[last_idx+1].ttg
    end

    return min(min_remaining_t, eliminate_shortfall_t, next_set_t)

end

function dischargeset(units::Vector{StorageUnitState})

    n_units = length(units)

    setstart = findfirst(isdischargeable, units)
    isnothing(setstart) && return

    ttg = units[setstart].ttg
    setstop = setstart

    for i in (setstart+1):n_units
       if !isapprox(units[i].ttg, ttg)
           break
       else
           setstop = i
       end
    end

    return setstart:setstop

end
