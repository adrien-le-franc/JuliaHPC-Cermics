# to be launched with two workers
using MPI

MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)
if rank == 0 && size < 2
    println("!!!Warning : you need at least two workers for this example!!!")
end

## Goal : send my rank to the other communicator
send_message = Array{Float64}(undef, 1)
receive_container = Array{Float64}(undef, 1)
fill!(send_message,rank)
fill!(receive_container,-1)

## I am worker 0 : I send "0" to worker 1
if rank == 0
    println("I am worker 0, sending to 1")
    MPI.Recv!(receive_container, 1, 1, comm)
    println("I am worker 0, waiting info from 1")
    MPI.Send(send_message, 1, 0, comm)
end

## I am worker 1 : I send "1" to worker 0
if rank == 1
    println("I am worker 1, sending to 0")
    MPI.Recv!(receive_container, 0, 0, comm)
    println("I am worker 1, waiting info from 0")
    MPI.Send(send_message, 0, 1, comm)
end

# We check everyone received from each other (rank>2 must have "-1").
MPI.Barrier(comm)
println("My rank is $(rank) and I talked to worker $(Int(receive_container[1]))\n")

MPI.Finalize()