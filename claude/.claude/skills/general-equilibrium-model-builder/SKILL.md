---
name: general-equilibrium-model-builder
description: Build and numerically solve Walrasian general equilibrium models in Julia
---

# General Equilibrium Model Builder

Set up and solve **pure exchange** Walrasian GE models: theory (existence, welfare theorems) plus Julia computation of equilibrium prices and allocations. For LaTeX typesetting conventions, defer to /latex-econ-model. Infer $L$ (goods), $I$ (consumers), preferences, and endowments from the user's description; ask only for missing primitives.

## Theory skeleton

A pure exchange economy: $u^i: \mathbb{R}^L_+ \to \mathbb{R}$, endowments $\omega^i \in \mathbb{R}^L_+$. Consumer $i$ solves $\max u^i(x^i)$ s.t. $p \cdot x^i \leq p \cdot \omega^i$. A Walrasian equilibrium is $(x^*, p^*)$ with utility maximization at $p^*$ and market clearing $\sum_i x^{*i} = \sum_i \omega^i$.

## Julia solver pattern

```julia
using LinearAlgebra, NLsolve

struct PureExchangeEconomy
    n_goods::Int
    n_consumers::Int
    endowments::Matrix{Float64}     # I × L
    utility_params::Vector{Any}
    utility_type::Symbol
end

demand_cobb_douglas(p, wealth, α) = (α ./ sum(α)) .* wealth ./ p

function excess_demand(p, e::PureExchangeEconomy)
    z = zeros(e.n_goods)
    for i in 1:e.n_consumers
        ω = e.endowments[i, :]
        x = demand_cobb_douglas(p, dot(p, ω), e.utility_params[i])
        z += x - ω
    end
    return z
end

function solve_equilibrium(e::PureExchangeEconomy)
    # normalize p₁ = 1; solve in logs to keep prices positive
    f!(F, x) = (F .= excess_demand(vcat(1.0, exp.(x)), e)[2:end])
    r = nlsolve(f!, zeros(e.n_goods - 1), autodiff = :forward)
    converged(r) || error("Equilibrium solver did not converge")
    return vcat(1.0, exp.(r.zero))
end

# 2×2 example
economy = PureExchangeEconomy(2, 2, [4.0 1.0; 1.0 4.0],
                              [[0.6, 0.4], [0.3, 0.7]], :cobb_douglas)
p_star = solve_equilibrium(economy)
```

Packages: `NLsolve`, `ForwardDiff`, `Plots` (Edgeworth boxes / contract curves).

## Verification checklist (always run after solving)

1. Market clearing holds numerically in every good
2. Walras' Law: $p \cdot z(p) \approx 0$ at any $p$
3. Pareto efficiency: MRS equalized across consumers
4. Try multiple initial guesses — multiple equilibria are possible; don't assume uniqueness

## Pitfalls

- Prices determined only up to scale — normalize (numeraire or simplex)
- Corner solutions (zero consumption) break interior FOC logic
- Numerical trouble near the boundary of the price simplex

References: Mas-Colell, Whinston & Green ch. 15-17; QuantEcon Julia lectures.
