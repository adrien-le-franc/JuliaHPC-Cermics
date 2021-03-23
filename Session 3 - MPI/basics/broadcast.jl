using MPI
MPI.Init()

comm = MPI.COMM_WORLD
N = 5
root = 0

if MPI.Comm_rank(comm) == root
    println("Running on $(MPI.Comm_size(comm)) processes")
end
MPI.Barrier(comm)

if MPI.Comm_rank(comm) == root
    A = [Float64(i) for i = 1:N]
else
    A = Array{Float64}(undef, N)
end

MPI.Bcast!(A, root, comm)
println("rank = $(MPI.Comm_rank(comm)), A = $A")

if MPI.Comm_rank(comm) == root
    B = Dict("foo" => "bar")
else
    B = nothing
end

B = MPI.bcast(B, root, comm)
println("rank = $(MPI.Comm_rank(comm)), B = $B")
