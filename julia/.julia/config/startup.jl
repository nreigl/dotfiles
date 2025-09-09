# Julia startup configuration for enhanced REPL experience
using Pkg
using REPL

# Auto-activate project environments
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end

# Set number of threads
ENV["JULIA_NUM_THREADS"] = "auto"

# Better error messages
ENV["JULIA_STACKTRACE_MINIMAL"] = false

# Add commonly used packages to REPL
atreplinit() do repl
    try
        @eval using Revise
        @info "Revise loaded - automatic code reloading enabled"
    catch e
        @info "Revise not installed. Install with: using Pkg; Pkg.add(\"Revise\")"
    end
    
    try
        @eval using BenchmarkTools
    catch e
        @info "BenchmarkTools not installed. Install with: using Pkg; Pkg.add(\"BenchmarkTools\")"
    end
end

# Convenience aliases
const jl = julia
println("Julia $(VERSION) - Enhanced REPL loaded")