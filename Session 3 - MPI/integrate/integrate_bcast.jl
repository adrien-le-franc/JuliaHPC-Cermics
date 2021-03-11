# Trapezoid rule for parallel integration of a function f
#
# Algorithm
# ---------
#   1) Each process calculates its interval of integration
#   2) Each process estimates the integral of f(x) over its interval using the
#   trapezoidal rule
#   3) a) Each process != 0 sends its integral to 0
#      b) Process 0 sums the calculations received from the individual processes
#      and prints the result.
#
#   /!\ We assume that the number of processes (p) should evenly divide the
#   number of trapezoids (n=1024).
#

using MPI

include("integrate.jl")

MPI.Init()
comm = MPI.COMM_WORLD
procid = MPI.Comm_rank(comm)
numprocs = MPI.Comm_size(comm)

MPI.Barrier(comm)
start_time = MPI.Wtime()

# generate data only on root
if procid == 0
    a = 0.0                     # left endpoint
    b = 1.0                     # right endpoint
    n = 2048                    # number of trapezoids
    h = (b-a) / n               # step size
    local_n = n / numprocs      # number of trapezoids per process
    @assert mod(local_n,1) == 0 # assert that n is a multiple of
                                # the number of processes
else
    a = undef
    h = undef
    local_n = undef
end

# broadcast data
a = MPI.bcast(a, 0, comm)
h = MPI.bcast(h, 0, comm)
local_n = MPI.bcast(local_n, 0, comm)

# variables local to the process
# this process deals with interval [a + local_n*i*h, a + local_n*(i+1)*h]
local_a = a + local_n * procid * h
local_b = local_a + local_n*h
integral = trap(local_a, local_b, local_n, h)

function sum_op(x,y)
    x+y
end

total = MPI.Reduce(integral, sum_op, 0, comm)

MPI.Barrier(comm)
end_time = MPI.Wtime()

# print the result
if procid == 0
    println("With $(n) trapezoids and $(numprocs) processes, we have the following estimate : $(total)")
    println("Computation time = $(end_time - start_time)")
end








