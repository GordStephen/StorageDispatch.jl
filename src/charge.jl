function charge!(x::StorageFleetState, surplus::Float64; eps=epsilon)

    while surplus > eps

        storset = chargeset(x.units)
        isnothing(storset) && break # No chargeable units left

        t = group_charge(x.units, storset, surplus)

        for i in storset

            # Can add floating point error checks here if needed
            stor = x.units[i]

            stor.ttg += t
            stor.t_remaining -= t

            surplus -= t * stor.p

        end

    end

    return surplus

end

function group_charge(stors::Vector{StorageUnitState},
                      storset::UnitRange{Int},
                      surplus::Float64)

    first_idx = first(storset)
    first_stor = stors[first_idx]
    last_stor = stors[last(storset)]

    next_set_t = last_stor.ttg_max - last_stor.ttg

    set_p = 0
    min_remaining_t = Inf

    for i in storset
        stor = stors[i]
        set_p += stor.p
        min_remaining_t = min(min_remaining_t, stor.t_remaining)
    end

    eliminate_surplus_t = surplus / set_p

    if first_idx != 1
        prev_stor = stors[first_idx-1]
        next_set_t = min(next_set_t, prev_stor.ttg - first_stor.ttg)
    end

    return min(min_remaining_t, eliminate_surplus_t, next_set_t)

end

function chargeset(units::Vector{StorageUnitState})

    n_units = length(units)

    setstop = findlast(ischargeable, units)
    isnothing(setstop) && return

    ttg = units[setstop].ttg
    setstart = setstop

    for i in (setstop-1):-1:1
       if !isapprox(units[i].ttg, ttg)
           break
       else
           setstart = i
       end
    end

    return setstart:setstop

end
