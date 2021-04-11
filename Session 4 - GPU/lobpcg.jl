using CUDA
using LinearAlgebra
using Test

qrortho(X)    = Array(qr(X).Q)
qrortho(X, Y) = qrortho(X - Y * Y'X)

function rayleigh_ritz(X::Array, AX::Array, N)
    F = eigen(Hermitian(X'AX))
    F.vectors[:,1:N], F.values[1:N]
end

function lobpcg(A, X; precon=I, tol=1e-7, maxiter=100, display_progress=false)
    N, M = size(X)
    X  = qrortho(X)
    AX = A * X
    λs = diag(X'AX)  # X are orthonormal

    P  = nothing
    AP = nothing
    R  = nothing
    AR = nothing

    converged = false
    for niter = 0:maxiter
        # Matvec and Rayleigh-Ritz
        if niter > 0
            AR = A * R

            if niter > 1
                Y  = [X R P]
                AY = [AX AR AP]
            else
                Y  = [X R]
                AY = [AX AR]
            end
            cX, λs = rayleigh_ritz(Y, AY, M)

            X  = Y  * cX
            AX = AY * cX
        end

        # New residuals
        R = AX .- X .* λs'
        rnorms = map(norm, eachcol(R))
        display_progress && println("Iter $niter, $(typeof(R)) resid ", rnorms)
        converged = maximum(rnorms) < tol
        converged && break

        # New search direction
        if niter > 0
            cP = copy(cX)
            cP[1:M, 1:M] .= cX[1:M, 1:M] - I
            cP = qrortho(cP, cX)
            P  = Y  * cP
            AP = AY * cP
        end

        # Preconditioning and residual orthonormality
        if niter > 0
            Z = [X P]
        else
            Z = X
        end
        R = qrortho(precon \ R, Z)
    end

    λ = real(diag(X' * AX))
    (X=X, λ=λ, residuals=AX .- X * Diagonal(λ), converged=converged)
end

function run_test(N=10, M=2)
    λs = sort(rand(N))
    v = rand(N, M)
    ret = lobpcg(Diagonal(λs), v, display_progress=true, tol=1e-7)

    println("λs   ", λs)
    println("λ    ", ret.λ)
    println("diff ", λs[1:M] - ret.λ)
    @test λs[1:M] ≈ ret.λ atol=1e-13
end

function run_cutest(N=10, M=2)
    @assert CUDA.functional(true)
    CUDA.allowscalar(false)

    λs  = sort(rand(Float32, N))
    A   = cu(Array(Diagonal(λs)))
    v   = CUDA.rand(N, M)
    ret = lobpcg(A, v, display_progress=true, tol=1e-3)

    λ = Array(ret.λ)
    println("λs   ", λs)
    println("λ    ", λ)
    println("diff ", λs[1:M] - λ)
    @test λs[1:M] ≈ λ atol=1e-5
end
