using BPA: Vec3, Front, insert_edge!, link!, glue!, join!, add_seed!, loops, get_active_edge!,
           can_add_triangle, can_add_seed, on_front, not_used, is_interior, undirected,
           ACTIVE, BOUNDARY

const Z = zero(Vec3)

# Build a front loop from a sequence of vertices (closed).
function make_loop!(f, verts)
    ids = [insert_edge!(f, verts[k], verts[mod1(k + 1, length(verts))], 0, Z) for k in eachindex(verts)]
    for k in eachindex(ids)
        link!(f, ids[k], ids[mod1(k + 1, length(ids))])
    end
    ids
end

edge_pairs(f, loop) = [(f.edges[id].i, f.edges[id].j) for id in loop]

@testset "glue cases (Fig. 7)" begin
    # (a) the two edges form a loop by themselves
    f = Front(10)
    ids = make_loop!(f, [1, 2])
    @test length(loops(f)) == 1
    glue!(f, ids[1], ids[2])
    @test f.nlive == 0
    @test isempty(loops(f))
    @test undirected(1, 2) in f.closed
    @test f.front_count[1] == 0 && f.front_count[2] == 0

    # (b) consecutive edges of the same loop
    f = Front(10)
    ids = make_loop!(f, [1, 2, 3, 2, 4])          # edges (1,2) (2,3) (3,2) (2,4) (4,1)
    glue!(f, f.lookup[(2, 3)], f.lookup[(3, 2)])
    L = loops(f)
    @test length(L) == 1
    @test edge_pairs(f, L[1]) == [(1, 2), (2, 4), (4, 1)]
    # ... and in the other order
    f = Front(10)
    ids = make_loop!(f, [1, 2, 3, 2, 4])
    glue!(f, f.lookup[(3, 2)], f.lookup[(2, 3)])
    L = loops(f)
    @test length(L) == 1
    @test edge_pairs(f, L[1]) == [(1, 2), (2, 4), (4, 1)]

    # (c) non-consecutive edges of the same loop: the loop splits in two
    f = Front(10)
    make_loop!(f, [1, 2, 3, 4, 5, 3, 2, 6])       # contains (2,3) and (3,2)
    @test length(loops(f)) == 1
    glue!(f, f.lookup[(2, 3)], f.lookup[(3, 2)])
    L = loops(f)
    @test length(L) == 2
    @test sort(sort.(edge_pairs.(Ref(f), L))) == sort([sort([(1, 2), (2, 6), (6, 1)]),
                                                       sort([(3, 4), (4, 5), (5, 3)])])

    # (d) edges of two different loops: the loops merge
    f = Front(10)
    make_loop!(f, [1, 2, 3])
    make_loop!(f, [3, 2, 4])
    @test length(loops(f)) == 2
    glue!(f, f.lookup[(2, 3)], f.lookup[(3, 2)])
    L = loops(f)
    @test length(L) == 1
    @test sort(edge_pairs(f, L[1])) == sort([(1, 2), (2, 4), (4, 3), (3, 1)])

    f = Front(10)
    make_loop!(f, [1, 2, 3])
    @test_throws ErrorException glue!(f, f.lookup[(1, 2)], f.lookup[(2, 3)])
end

@testset "seed, join and queue" begin
    f = Front(10)
    add_seed!(f, 1, 2, 3, Z)
    @test f.nlive == 3
    @test length(loops(f)) == 1
    @test all(k -> on_front(f, k), 1:3)
    @test not_used(f, 4)
    @test get_active_edge!(f) == f.lookup[(1, 2)]

    # pivot e(1,2) to vertex 4
    @test can_add_triangle(f, 1, 4, 2)
    join!(f, f.lookup[(1, 2)], 4, Z)
    @test f.nlive == 4
    @test undirected(1, 2) in f.closed
    L = loops(f)
    @test length(L) == 1
    @test edge_pairs(f, L[1]) == [(1, 4), (4, 2), (2, 3), (3, 1)] ||
          edge_pairs(f, L[1]) == [(4, 2), (2, 3), (3, 1), (1, 4)] ||
          edge_pairs(f, L[1]) == [(2, 3), (3, 1), (1, 4), (4, 2)] ||
          edge_pairs(f, L[1]) == [(3, 1), (1, 4), (4, 2), (2, 3)]
    @test f.edges[f.lookup[(1, 4)]].o == 2
    @test f.edges[f.lookup[(4, 2)]].o == 1
    # the removed edge is skipped by the queue; remaining active edges come out in FIFO order
    @test get_active_edge!(f) == f.lookup[(2, 3)]
    @test get_active_edge!(f) == f.lookup[(3, 1)]
    @test get_active_edge!(f) == f.lookup[(1, 4)]
    @test get_active_edge!(f) == f.lookup[(4, 2)]
    @test get_active_edge!(f) == 0

end

@testset "manifold checks" begin
    f = Front(10)
    add_seed!(f, 1, 2, 3, Z)
    join!(f, f.lookup[(1, 2)], 4, Z)
    # front: (1,4) (4,2) (2,3) (3,1); closed: {1,2}
    @test can_add_triangle(f, 2, 5, 3)
    @test !can_add_triangle(f, 2, 1, 3)          # {1,2} already has two triangles
    @test can_add_triangle(f, 2, 4, 3)           # new half-edges (2,4) and (4,3): (2,4) is opposite of (4,2)
    @test !can_add_triangle(f, 4, 1, 2)          # (4,1)? opposite of (1,4) ok; (1,2) closed -> reject
    # interior vertex: close the fan around 1 -> pivot (3,1) to 4 and (1,4)... simpler: mark directly
    f.used[7] = true
    @test is_interior(f, 7)
    @test !can_add_triangle(f, 2, 7, 3)
    @test !can_add_seed(f, 7, 8, 9)
    @test can_add_seed(f, 8, 9, 10)
    @test !can_add_seed(f, 1, 4, 8)              # (1,4) same orientation as front edge
    @test can_add_seed(f, 4, 1, 8)               # opposite orientation: would glue

    # a seed sharing an opposite edge with the front glues it
    n = add_seed!(f, 4, 1, 8, Z)
    @test n == 1
    @test !haskey(f.lookup, (1, 4)) && !haskey(f.lookup, (4, 1))
    @test undirected(1, 4) in f.closed
    @test length(loops(f)) == 1
end
