# StorageDispatch

```julia
using StorageDispatch

units = [
    StorageUnit(10., 40.), # 4h storage device
    StorageUnit(10., 20.), # 2h storage device
]

# Negative means surplus energy available for charging
netload = Float64[-25, -15, -10, -5, 5, 10, 20, 30, 10]

# Storage devices start uncharged
shortfall, surplus = dispatch(units, netload)

# Shortfall is any net load that can't be eliminated
shortfall == [0, 0, 0, 0, 0, 0, 0, 15, 10] # true

# Surplus is any remaining energy that isn't used for charging
# (note that values are now positive, vs negative in the net load vector)
surplus == [5, 0, 0, 0, 0, 0, 0, 0, 0]
```
