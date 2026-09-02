# Spatial queries (Section 4.1): a regular grid of cubic voxels of side δ = 2ρ.
# Points are bucket-sorted so that the points of one voxel form a contiguous sublist of
# `sorted`; `cell_start` holds the sublist offsets (with one extra entry at the end).
#
# When the bounding box would need far more voxels than there are points (tiny ρ), the
# grid switches to a sparse representation where only non-empty voxels get a slot.

"""
    VoxelGrid(positions, delta)

Uniform grid of cubic voxels of side `delta` covering the bounding box of `positions`.
A voxel is addressed by integer cell coordinates `(ix, iy, iz)` (0-based, relative to the
bounding-box corner) and stored in a *slot*; the points of slot `s` are
`sorted[cell_start[s]:cell_start[s+1]-1]`.

Two layouts share the same interface:

- **dense** (`dense == true`): every cell of the `dims` box has a slot, addressed
  arithmetically. Used when the box has at most about 8 cells per point.
- **sparse**: only non-empty cells have a slot, found through `slot_of`. Used when `delta`
  is tiny relative to the extent of the data, where a dense box would exhaust memory.

The grid stores a reference to `positions` (not a copy) and is immutable; a new grid is built
for each ball radius.
"""
struct VoxelGrid
    positions::Vector{Vec3}
    delta::Float64                       # voxel side (= 2ρ in the algorithm)
    origin::Vec3                         # minimum corner of the bounding box
    dims::NTuple{3,Int}                  # number of cells along each axis
    dense::Bool
    slot_of::Dict{NTuple{3,Int},Int}     # sparse mode only: cell coordinates → slot
    slot_coords::Vector{NTuple{3,Int}}   # sparse mode only: slot → cell coordinates
    cell_start::Vector{Int}              # length nslots + 1
    sorted::Vector{Int}                  # point ids bucket-sorted by slot
end

"Integer cell coordinates of point `p` (may lie outside the box for points outside the data)."
@inline function cell_of(g::VoxelGrid, p::Vec3)
    inv = 1 / g.delta
    (floor(Int, (p[1] - g.origin[1]) * inv),
     floor(Int, (p[2] - g.origin[2]) * inv),
     floor(Int, (p[3] - g.origin[3]) * inv))
end

"Row-major slot of cell `c` in a dense `dims` box, or 0 if `c` is outside the box."
@inline function dense_slot(dims::NTuple{3,Int}, c::NTuple{3,Int})
    (0 <= c[1] < dims[1] && 0 <= c[2] < dims[2] && 0 <= c[3] < dims[3]) || return 0
    1 + c[1] + dims[1] * (c[2] + dims[2] * c[3])
end

"Slot of cell `c`, or 0 if the cell has no slot (outside the box, or empty in sparse mode)."
@inline function slot(g::VoxelGrid, c::NTuple{3,Int})
    g.dense ? dense_slot(g.dims, c) : get(g.slot_of, c, 0)
end

function VoxelGrid(positions::Vector{Vec3}, delta::Real)
    delta > 0 || throw(ArgumentError("voxel size must be positive"))
    n = length(positions)
    delta = Float64(delta)
    if n == 0
        return VoxelGrid(positions, delta, zero(Vec3), (1, 1, 1), true,
                         Dict{NTuple{3,Int},Int}(), NTuple{3,Int}[], [1, 1], Int[])
    end
    lo = positions[1]; hi = positions[1]
    for p in positions
        lo = min.(lo, p); hi = max.(hi, p)
    end
    origin = lo
    # Cell coordinates are computed by the same expression `cell_of` uses, and the box
    # dimensions are taken from them, so that no point can round to a cell outside the box.
    tmp = VoxelGrid(positions, delta, origin, (0, 0, 0), true,
                    Dict{NTuple{3,Int},Int}(), NTuple{3,Int}[], Int[], Int[])
    coords = [cell_of(tmp, p) for p in positions]
    dims = ntuple(k -> maximum(c -> c[k], coords) + 1, 3)
    ncells = prod(Float64.(dims))
    dense = ncells <= max(8.0 * n, 4096.0)

    if dense
        nslots = Int(ncells)
        slots = [dense_slot(dims, c) for c in coords]
        slot_of = Dict{NTuple{3,Int},Int}()
        slot_coords = NTuple{3,Int}[]
    else
        keys = sort!(unique(coords), by = c -> (c[3], c[2], c[1]))
        slot_of = Dict{NTuple{3,Int},Int}(c => s for (s, c) in enumerate(keys))
        slot_coords = keys
        nslots = length(keys)
        slots = [slot_of[c] for c in coords]
    end

    # Counting sort of the point ids by slot (the paper's bucket sort): `counts[s+1]` is the
    # number of points in slot s, so the exclusive prefix sum gives the start of each sublist.
    counts = zeros(Int, nslots + 1)
    for s in slots
        counts[s + 1] += 1
    end
    cell_start = cumsum(counts) .+ 1          # cell_start[s]:cell_start[s+1]-1 is slot s
    fill_pos = copy(cell_start)
    sorted = Vector{Int}(undef, n)
    for (id, s) in enumerate(slots)
        sorted[fill_pos[s]] = id
        fill_pos[s] += 1
    end
    VoxelGrid(positions, delta, origin, dims, dense, slot_of, slot_coords, cell_start, sorted)
end

"Number of slots (all cells in dense mode, non-empty cells in sparse mode)."
nslots(g::VoxelGrid) = length(g.cell_start) - 1

"Range of indices into `g.sorted` holding the points of slot `s`."
@inline slot_range(g::VoxelGrid, s::Int) = g.cell_start[s]:(g.cell_start[s + 1] - 1)

"Range of indices into `g.sorted` holding the points of cell `c` (empty if the cell has none)."
@inline function cell_range(g::VoxelGrid, c::NTuple{3,Int})
    s = slot(g, c)
    s == 0 ? (1:0) : slot_range(g, s)
end

"""
    neighbors!(buf, grid, p, r)

Fill `buf` with the ids of all points within distance `r` of `p`, using the 27 voxels around
the voxel containing `p`. Requires `r ≤ δ`: a point within `r` of `p` then differs from `p`
by at most one cell along each axis, so the 3×3×3 block is exhaustive. `p` may lie outside
the data's bounding box (ball centres and edge midpoints usually do, slightly).
"""
function neighbors!(buf::Vector{Int}, g::VoxelGrid, p::Vec3, r::Real)
    r <= g.delta * (1 + 1e-12) || throw(ArgumentError("query radius must not exceed the voxel size"))
    empty!(buf)
    c = cell_of(g, p)
    r2 = r * r
    P = g.positions
    for dz in -1:1, dy in -1:1, dx in -1:1
        for t in cell_range(g, (c[1] + dx, c[2] + dy, c[3] + dz))
            id = g.sorted[t]
            if sum(abs2, P[id] - p) <= r2
                push!(buf, id)
            end
        end
    end
    buf
end

"""
    empty_ball(grid, center, rho, e1, e2, e3; tol)

`true` if no point other than `e1`, `e2`, `e3` lies strictly inside the ball of radius `rho`
centred at `center`. Points within relative tolerance `tol` of the sphere are treated as
outside. Requires `rho ≤ δ`.
"""
function empty_ball(g::VoxelGrid, center::Vec3, rho::Real, e1::Int, e2::Int, e3::Int;
                    tol::Real = 1e-9)
    c = cell_of(g, center)
    r2 = (rho * (1 - tol))^2
    P = g.positions
    for dz in -1:1, dy in -1:1, dx in -1:1
        for t in cell_range(g, (c[1] + dx, c[2] + dy, c[3] + dz))
            id = g.sorted[t]
            (id == e1 || id == e2 || id == e3) && continue
            if sum(abs2, P[id] - center) < r2
                return false
            end
        end
    end
    true
end
