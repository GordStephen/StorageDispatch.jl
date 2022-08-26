using Test
using StorageDispatch
using JuMP

import Random
import OSQP

const test_qp = true
const use_qp = true
const n_random_replications = 100

const atol = 1e-3
const rtol = 1e-3

include("utils.jl")
include("qp.jl")
include("charge.jl")
include("discharge.jl")
include("dispatch.jl")

@testset "Storage Dispatch" begin

    util_test()

    test_qp && @testset "QP Verification" begin # Test the testers
        charge_test(charge_qp!, "QP", atol=atol, rtol=rtol)
        discharge_test(discharge_qp!, "QP", atol=atol, rtol=rtol)
    end

    # Main tests

    charge_test(charge!, atol=atol)
    use_qp && charge_compare(charge!, charge_qp!, atol=atol, rtol=rtol)

    discharge_test(discharge!, atol=atol)
    use_qp && discharge_compare(discharge!, discharge_qp!, atol=atol, rtol=rtol)

    dispatch_test()
    use_qp && dispatch_compare(charge!, charge_qp!, discharge!, discharge_qp!,
                               atol=atol, rtol=rtol)

end
