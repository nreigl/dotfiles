---
description: Write and typeset economic models in LaTeX with standard notation
---

# LaTeX Economic Model Writer

Typeset theory sections, formal models, and lecture notes. Infer the model class from context; ask only whether proofs are needed if it's unclear.

## Standard notation (economics conventions)

- Utility $U$, $u$, $v$; production $F$, $f$, $Y$; prices $p$, $w$, $r$; quantities $q$, $x$, $y$
- Time subscripts $t$, $t+1$; individuals $i$; Greek letters for parameters ($\alpha$, $\beta$, $\gamma$, $\delta$)
- Keep subscript conventions consistent across the whole document

## Model structure

1. **Environment** — agents, goods, time horizon
2. **Preferences/Technology** — utility and production functions
3. **Constraints** — budget, resource, incentive compatibility
4. **Equilibrium concept** — definition and conditions
5. **Solution** — FOCs, closed forms where available

## LaTeX rules

- `align` for multiline derivations, aligned at `=`; `equation` for single displays — never `$$...$$`
- `\label{eq:...}` important equations; reference with `\eqref{}`
- `\text{}` for words in math (`\quad \text{s.t.} \quad`); `\left(`/`\right)` for sized brackets; `\cdot` not `*`
- Box the headline result: `\boxed{u'(c_1) = \beta R \, u'(c_2)}`

## Preamble macros

```latex
\newcommand{\E}{\mathbb{E}}
\newcommand{\Var}{\operatorname{Var}}
\newcommand{\Cov}{\operatorname{Cov}}
\newcommand{\Prob}{\mathbb{P}}
\newcommand{\pd}[2]{\frac{\partial #1}{\partial #2}}
\DeclareMathOperator*{\argmax}{arg\,max}
\DeclareMathOperator*{\argmin}{arg\,min}
```

## Reference example (two-period consumer)

```latex
\subsection{Environment}
A consumer lives for two periods, $t \in \{1, 2\}$, with preferences
\begin{equation}
    U(c_1, c_2) = u(c_1) + \beta u(c_2)
\end{equation}
where $\beta \in (0,1)$ and $u(\cdot)$ is strictly increasing and concave.

\subsection{Constraints}
\begin{align}
    c_1 + s &= y_1 \label{eq:bc1}\\
    c_2 &= y_2 + Rs \label{eq:bc2}
\end{align}
Combining \eqref{eq:bc1} and \eqref{eq:bc2}:
$c_1 + c_2/R = y_1 + y_2/R \equiv W$.

\subsection{Solution}
The FOCs of $\max u(c_1) + \beta u(c_2)$ s.t. the intertemporal
constraint yield the Euler equation:
\begin{equation}
    \boxed{u'(c_1) = \beta R \, u'(c_2)}
\end{equation}
```
