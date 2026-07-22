---
name: econ-visualization
description: Create publication-quality figures for economics papers (ggplot2-first)
---

# Econ Visualization

Produce journal-quality figures. Default to R/ggplot2; use matplotlib only if the project is Python-based. Infer variables and chart type from context.

## Conventions

- **Vector output**: PDF via `ggsave(..., width = 7, height = 4)`; PNG only for slides/web
- **Theme**: `theme_minimal(base_size = 12)`, legend at bottom, drop minor gridlines
- Label axes with units; keep titles short (in papers, the caption carries the description)
- Save to the project's figures path (`path_figures` if the pipeline defines one), never inline
- Make the figure regenerable: script the full data-prep chain, document filters used
- Consistent scales and palette across all figures in a paper

## Core pattern

```r
library(tidyverse)

ggplot(df, aes(x = year, y = gdp_per_capita, color = country)) +
  geom_line(linewidth = 1) +
  scale_y_continuous(labels = scales::comma) +
  labs(x = "Year", y = "GDP per capita (USD)", color = NULL) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())

ggsave("output/figures/gdp_per_capita.pdf", width = 7, height = 4)
```

For event studies / coefficient plots: always show confidence bands, mark the reference period, and state the CI level in the figure note.

## Pitfalls

- Raster exports for print (blurry at journal resolution)
- Inconsistent y-scales across faceted or paired figures inviting misreading
- Overcrowded legends — facet or direct-label instead
