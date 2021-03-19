# to be launched with two workers
using MPI

function cosmetics(rank::Int, comm, str_::String)
    MPI.Barrier(comm)
    if rank == 0
        println("--------------------------------------------------------------")
        println("---- $(str_)----")
        println("--------------------------------------------------------------")
    end    
end

MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)
if rank == 0 && size < 2
    println("!!!Warning : you need at least two workers for this example!!!")
end


## Method 1 : check the comunication order
send_message = Array{Float64}(undef, 1)
receive_container = Array{Float64}(undef, 1)
fill!(send_message,rank)
fill!(receive_container,-1)

if rank == 0
    MPI.Send(send_message, 1, 0, comm)
    MPI.Recv!(receive_container, 1, 1, comm)
end

if rank == 1
    MPI.Recv!(receive_container, 0, 0, comm)
    MPI.Send(send_message, 0, 1, comm)
end

# We check everyone received from each other (rank>2 must have "-1").

cosmetics(rank, comm,"solution 1 : Correct communication Order")
println("My rank is $(rank) and I talked to worker $(Int(receive_container[1]))\n")


## Method 2 : sendrecv routine
send_message = Array{Float64}(undef, 1)
receive_container = Array{Float64}(undef, 1)
fill!(send_message,rank)
fill!(receive_container,-1)

if rank == 0
    MPI.Sendrecv!(send_message, 1, 0, receive_container, 1, 1, comm)
end

## I am worker 1 : I send "1" to worker 0
if rank == 1
    MPI.Sendrecv!(send_message, 0, 1, receive_container, 0, 0, comm)
end

# We check everyone received from each other (rank>2 must have "-1").

cosmetics(rank, comm, "Solution 2 : Send-Receive ")
println("My rank is $(rank) and I talked to worker $(Int(receive_container[1]))\n")

## Method 3 : non blocking communication
send_message = Array{Float64}(undef, 1)
receive_container = Array{Float64}(undef, 1)
fill!(send_message,rank)
fill!(receive_container,-1)


if rank == 0
    MPI.Irecv!(receive_container, 1, 1, comm)
    MPI.Isend(send_message, 1, 0, comm)
end

## I am worker 1 : I send "1" to worker 0
if rank == 1
    MPI.Irecv!(receive_container, 0, 0, comm)
    MPI.Isend(send_message, 0, 1, comm)
end

# We check everyone received from each other (rank>2 must have "-1").

cosmetics(rank, comm, "Solution 3 : Non Blocking communication")
println("My rank is $(rank) and I talked to worker $(Int(receive_container[1]))\n")

## What is faster
size_ = 1000000
### Method 1 :  correct order
send_message = Array{Float64}(undef, size_)
receive_container = Array{Float64}(undef, size_)
fill!(send_message,rank)
fill!(receive_container,-1)

@time begin
if rank == 0
    MPI.Send(send_message, 1, 0, comm)
    MPI.Recv!(receive_container, 1, 1, comm)
end

if rank == 1
    MPI.Recv!(receive_container, 0, 0, comm)
    MPI.Send(send_message, 0, 1, comm)
end
end
cosmetics(rank, comm, "Timed solution 1")

### Method 2 :  send-receiv
send_message = Array{Float64}(undef, size_)
receive_container = Array{Float64}(undef, size_)
fill!(send_message,rank)
fill!(receive_container,-1)

@time begin
if rank == 0
    MPI.Sendrecv!(send_message, 1, 0, receive_container, 1, 1, comm)
end

if rank == 1
    MPI.Sendrecv!(send_message, 0, 1, receive_container, 0, 0, comm)
end
end
cosmetics(rank, comm, "Timed solution 2")

### Method 3 : non blocking
send_message = Array{Float64}(undef, size_)
receive_container = Array{Float64}(undef, size_)
fill!(send_message,rank)
fill!(receive_container,-1)

@time begin
if rank == 0
    MPI.Irecv!(receive_container, 1, 1, comm)
    MPI.Isend(send_message, 1, 0, comm)
end
if rank == 1
    MPI.Irecv!(receive_container, 0, 0, comm)
    MPI.Isend(send_message, 0, 1, comm)
end
end
cosmetics(rank, comm,"Timed solution 3")


MPI.Finalize()