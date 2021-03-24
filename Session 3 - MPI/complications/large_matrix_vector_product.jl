using MPI
using Random

MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)

n = 10000

@time begin
M = rand(n, size * n)
u = rand(n * size)
MPI.Barrier(comm)

MPI.Allreduce!(u, +, comm)
v = M * u
MPI.Barrier(comm)
complete_v  = MPI.Gather(v, 0, comm)
end

if rank == 0
    @time begin
    M2 = rand(size * n, size * n)
    u2 = rand(n * size)
    v2 = M2 * u2
    end
end


MPI.Finalize()