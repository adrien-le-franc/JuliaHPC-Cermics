# serial integration
include("integrate.jl")

@time begin
    a = 0.0
    b = 1.0
    n = 2048*100000
    h = (b-a)/n
    total = trap(a, b, n, h)
    println("With $(n) trapezoids in serial, we have the following estimate : $(total)")
end
