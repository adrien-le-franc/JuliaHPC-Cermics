using MPI


MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)


N = 48
## Bad load balancing : rst to the last worker
q = trunc(Int, N / size)
if rank == size - 1
    q += N % size
end
MPI.Barrier(comm)
println("My rank is $(rank), I have $(q) jobs to do.\n")

tot = MPI.Reduce(q, +, 0, comm)
if rank == 0
    println("N=$(N), sum(q)=$(tot)")
end

## Better load balancing : 
q = trunc(Int, N / size)
if rank < N % size
    q += 1
end
MPI.Barrier(comm)
println("My rank is $(rank), I have $(q) jobs to do.\n")
tot = MPI.Reduce(q, +, 0, comm)
if rank == 0
    println("N=$(N), sum(q)=$(tot)")
end

MPI.Finalize()