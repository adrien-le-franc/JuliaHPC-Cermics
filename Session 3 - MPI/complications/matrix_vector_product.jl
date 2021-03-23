using MPI
using Random

MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)

## Small example
n = 2

# random simulates different computations on different processes
M = rand(n, size * n)
u = rand(n * size)
MPI.Barrier(comm)

# u needs to be shared between processes
MPI.Allreduce!(u, +, comm)

v = M * u
println("My rank is $(rank), my local product $(v)")

# if you want the result on one process
MPI.Barrier(comm)
complete_v  = MPI.Gather(v, 0, comm)
println("My rank $(rank), M*u=$(complete_v)")

# if you want the result everywhere
MPI.Barrier(comm)
complete_v2 = MPI.Allgather(v, comm)

println("My rank $(rank), M*u=$(complete_v2)")

MPI.Finalize()