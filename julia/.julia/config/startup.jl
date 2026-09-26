# Julia startup configuration for enhanced REPL experience
using Pkg
using REPL

# Auto-activate project environments
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end

# Do not set JULIA_NUM_THREADS here. Julia reads it before startup.jl runs,
# so a value set here has no effect. Export it in the shell environment.

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

# Welcome message
println("Julia $(VERSION) - Enhanced REPL loaded")