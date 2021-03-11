using MPI
MPI.Init()

comm = MPI.COMM_WORLD
numprocs = MPI.Comm_size(comm)
procid = MPI.Comm_rank(comm)

if numprocs != 2
    MPI.Abort(comm, 0)
end

if procid == 0
    pipi = 3.14
    MPI.Send(pipi, 1, 0, comm)
    println("ProcID $(procid) sent value $(pipi) to ProcID 1")
end

if procid == 1
    pipi, status = MPI.Recv(Float64, 0, 0, comm)
    println("ProcID $(procid) received value $(pipi) from ProcID 0")
end

MPI.Finalize()
