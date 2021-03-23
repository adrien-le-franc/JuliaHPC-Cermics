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

# First, we define the variables common to all processes
a = 0.0                     # left endpoint
b = 1.0                     # right endpoint
n = 2048*100000                   # number of trapezoids
h = (b-a)/n                 # integration step
dst = 0                     # destination process

MPI.Init()
comm = MPI.COMM_WORLD
procid = MPI.Comm_rank(comm)
numprocs = MPI.Comm_size(comm)

MPI.Barrier(comm)
start_time = MPI.Wtime()

# another common variable
local_n = n / numprocs      # number of trapezoids per process
@assert mod(local_n,1) == 0 # assert that n is a multiple of
                            # the number of processes
# variables local to the process
# this process deals with interval [a + local_n*i*h, a + local_n*(i+1)*h]
local_a = a + local_n * procid * h
local_b = local_a + local_n*h
integral = trap(local_a, local_b, local_n, h)

# /!\ Now, each process has calculated its interval, we can sum everything up

if procid == 0
    total = integral
    for src = 1:(numprocs-1)
        rcv_integral, status = MPI.recv(src, src+32, comm)
        println("$(procid) received integral from $(src)")
        global total
        total += rcv_integral
    end
else
    println("$(procid) sending integral to $(dst)")
    MPI.send(integral, dst, procid+32, comm)
end

MPI.Barrier(comm)
end_time = MPI.Wtime()

# print the result
if procid == 0
    println("With $(n) trapezoids and $(numprocs) processes, we have the following estimate : $(total)")
    println("Computation time = $(end_time - start_time)")
end








