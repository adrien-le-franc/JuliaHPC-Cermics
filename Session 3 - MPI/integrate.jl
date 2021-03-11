# Trapezoid rule for integration of a function f

function f(x)
    x^2
end

function trap(a, b, n, h)

    integral = (f(a) + f(b)) / 2.0
    x = a
    for i = 1:(n-1)
        x += h
        integral += f(x)
    end

    integral * h
end
