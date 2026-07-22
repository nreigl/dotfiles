---
name: python-panel-data
description: Panel data analysis in Python with linearmodels and pandas
---

# Python Panel Data

Generate panel estimation code in Python. Infer panel identifiers, fixed effects, and clustering from the data and project context; ask only if the clustering level is genuinely ambiguous.

## Conventions

- **Environment**: `uv add pandas linearmodels statsmodels` (never pip/conda)
- **`linearmodels.PanelOLS`** for FE models; set a `(entity, time)` MultiIndex first
- Cluster SEs at the level of treatment assignment (`cov_type="clustered", cluster_entity=True`)
- Verify panel structure before estimating: unique identifiers, balanced vs unbalanced, missingness
- Note the assumptions the design leans on (strict exogeneity, parallel trends) and suggest matching robustness checks

## Core pattern

```python
import pandas as pd
from linearmodels.panel import PanelOLS

df = pd.read_csv("panel_data.csv").set_index(["firm_id", "year"])
df["treat_post"] = df["treated"] * df["post"]

model = PanelOLS.from_formula(
    "outcome ~ 1 + treat_post + EntityEffects + TimeEffects", data=df
)
results = model.fit(cov_type="clustered", cluster_entity=True)
print(results.summary)
```

## Pitfalls

- Missing or non-unique panel index (silently misestimates FE)
- Pooled OLS where the design needs fixed effects
- Interpreting coefficients without reference to what the FE absorb
