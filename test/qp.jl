const optimizer = optimizer_with_attributes(OSQP.Optimizer,
    "verbose" => false, "polish" => true, "polish_refine_iter" => 20,
    "eps_rel" => 1e-6, "eps_abs" => 1e-6,
    "eps_prim_inf" => 1e-6, "eps_dual_inf" => 1e-6
)

function charge_qp!(x::StorageFleetState, surplus::Float64)

    n_units = length(x.units)
    R = maximum(u -> u.ttg_max, x.units)

    m = Model(optimizer)

    @variable(m, 0 <= c[i in 1:n_units] <= x.units[i].p)

    @constraint(m, maxenergy[i in 1:n_units],
                x.units[i].ttg + c[i] / x.units[i].p <= x.units[i].ttg_max)

    @constraint(m, surplussize, sum(c) <= surplus)

    @objective(m, Max, sum((R - x.units[i].ttg) * c[i] - 0.5 * c[i]^2 / x.units[i].p
                           for i in 1:n_units))

    optimize!(m)

    for (i, u) in enumerate(x.units)

        # Lots of checks here to try to supress
        # floating point errors / spurious infeasibilities

        c_i = max(value(c[i]), 0.)
        t = c_i / u.p

        u.ttg = min(u.ttg_max, u.ttg + t)
        u.t_remaining = max(0., u.t_remaining - t)
        surplus = max(0., surplus - c_i)

    end

    return surplus

end

function discharge_qp!(x::StorageFleetState, shortfall::Float64)

    n_units = length(x.units)

    m = Model(optimizer)

    @variable(m, 0 <= d[i in 1:n_units] <= x.units[i].p)

    @constraint(m, maxenergy[i in 1:n_units],
                d[i] <= x.units[i].ttg * x.units[i].p)

    @constraint(m, shortfallsize, sum(d) <= shortfall)

    @objective(m, Max, sum(x.units[i].ttg * d[i] - 0.5 * d[i]^2 / x.units[i].p
                           for i in 1:n_units))

    optimize!(m)

    for (i, u) in enumerate(x.units)

        # Lots of checks here to try to supress
        # floating point errors / spurious infeasibilities

        d_i = max(value(d[i]), 0.)
        t = d_i / u.p

        u.ttg = max(0, u.ttg - t)
        u.t_remaining = max(0., u.t_remaining - t)
        shortfall = max(0., shortfall - d_i)

    end

    return shortfall

end
