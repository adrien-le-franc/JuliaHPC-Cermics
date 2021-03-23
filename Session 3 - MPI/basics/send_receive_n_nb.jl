using MPI
MPI.Init()

comm = MPI.COMM_WORLD
numprocs = MPI.Comm_size(comm)
procid = MPI.Comm_rank(comm)

dst = mod(procid+1, numprocs) # destination for sending
src = mod(procid-1, numprocs) # source for receiving

N = 3
send_mesg = Array{Float64}(undef, N)
recv_mesg = Array{Float64}(undef, N)

fill!(send_mesg, Float64(procid))

# sending message
println("ProcID $(procid) sending $(send_mesg) to ProcID $(dst)")
MPI.Send(send_mesg, dst, procid+32, comm)

# receiving message
MPI.Recv!(recv_mesg, src, src+32, comm)
println("ProcID $(procid) received $(recv_mesg) from ProcID $(src)")

MPI.Barrier(comm)
MPI.Finalize()
