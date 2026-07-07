---
description: Scaffold a new empirical research project with spec governance (central config, hash-based staleness detection, Makefile pipeline)
argument-hint: [project name]
---

# Initialize Research Project

You are a research project scaffolder. Set up a new empirical research project with governance patterns that prevent staleness, spec drift, and paper-code inconsistencies from day one.

## Step 1: Gather Project Details

Before creating anything, ask the user:

1. **Project name** (e.g., `mp_loanfeatures`, `labor_market_forecasts`)
2. **Primary language** (R, Python, Julia, Stata, or mixed)
3. **Research topic** (one sentence - used for CLAUDE.md context)
4. **Will it have a paper/presentation?** (determines whether to scaffold LaTeX structure)
5. **Data sources** (APIs, files, databases - for documenting in CLAUDE.md)
6. **Target directory** (default: `~/Documents/research/<project_name>`)

## Step 2: Create Directory Structure

Create the full directory tree. Adapt based on language choice.

```
<project_name>/
├── CLAUDE.md                    # Project instructions for Claude Code
├── README.md                    # Project overview
├── .gitignore                   # Language-appropriate ignores
├── Makefile                     # Pipeline orchestrator
│
├── R/                           # (or src/ for Python, or code/ for Stata)
│   ├── config.R                 # Central spec config with hash mechanism
│   ├── functions.R              # Shared utility functions
│   └── plot_functions.R         # Visualization helpers
│
├── scripts/
│   ├── pipeline/                # Sequential ETL stages
│   │   ├── 01_fetch_data.qmd   # (or .py, .do, .jl)
│   │   ├── 02_transform_data.qmd
│   │   └── 03_merge_data.qmd
│   ├── analysis/
│   │   ├── main/                # Core estimation scripts
│   │   ├── robustness/          # Robustness checks
│   │   └── specialized/         # Additional analyses
│   └── run_all.R                # Orchestrator script
│
├── data/
│   ├── raw/                     # NEVER modify
│   │   └── .gitkeep
│   └── processed/               # Pipeline outputs
│       └── .gitkeep
│
├── output/
│   ├── figures/                 # Generated plots
│   │   └── .gitkeep
│   ├── tables/                  # Generated tables
│   │   └── .gitkeep
│   └── robustness/              # Robustness results
│       └── .gitkeep
│
├── tests/                       # Compliance and equivalence tests
│   ├── test_spec_compliance.R
│   └── test_equivalence.R
│
├── docs/
│   ├── data_dictionary.md
│   └── methodology.md
│
├── bib/                         # (if paper=yes)
│   ├── master.bib               # Auto-exported from Zotero
│   └── README.md
│
└── paper/                       # (if paper=yes)
    └── working_paper/
        ├── manuscript.tex
        ├── figures/             # Symlink or copy from output/figures
        └── build/               # LaTeX build artifacts
```

For Python projects, replace `R/` with `src/`, `.qmd` with `.py` or `.ipynb`, `renv` with `pyproject.toml`/`uv`, etc.

## Step 3: Create Central Spec Config

This is the critical staleness prevention file. Create `R/config.R` (or equivalent) with:

### For R projects (`R/config.R`):

```r
# ============================================================================
# Central Specification Configuration
# ============================================================================
# ALL estimation scripts MUST source this file and use filter_sample().
# Changing values here invalidates all saved outputs (detected via spec_hash).
# ============================================================================

library(here)
library(digest)

# --- Core estimation parameters ---
HORIZONS      <- 0:8
SHOCK_SIZE    <- 0.25
VCOV_TYPE     <- "DK(3)"        # Driscoll-Kraay with 3 lags
FE_SPEC       <- "country"       # Fixed effects specification
SEED          <- 20250808
CUMULATIVE    <- "jorda_cumul"   # Cumulation method

# --- Sample restrictions ---
SAMPLE_START  <- "2007-01-01"
SAMPLE_END    <- "2025-04-01"
EXCLUDE_COUNTRIES <- c("CY")     # Countries to drop

# --- Filter function (all scripts must use this) ---
filter_sample <- function(data) {
  data %>%
    dplyr::filter(
      !country %in% EXCLUDE_COUNTRIES,
      quarter >= SAMPLE_START,
      quarter <= SAMPLE_END
    )
}

# --- Spec hash for staleness detection ---
spec_hash <- function() {
  params <- list(
    horizons = HORIZONS,
    shock_size = SHOCK_SIZE,
    vcov = VCOV_TYPE,
    fe = FE_SPEC,
    seed = SEED,
    cumulative = CUMULATIVE,
    sample_start = SAMPLE_START,
    sample_end = SAMPLE_END,
    exclude = EXCLUDE_COUNTRIES
  )
  digest::digest(params, algo = "md5")
}

# --- Save with embedded hash ---
save_with_hash <- function(object, path) {
  attr(object, "spec_hash") <- spec_hash()
  attr(object, "saved_at") <- Sys.time()
  saveRDS(object, path)
  message("Saved: ", path, " [hash: ", spec_hash(), "]")
}

# --- Check if saved output is current ---
check_hash <- function(path) {
  if (!file.exists(path)) return(FALSE)
  obj <- readRDS(path)
  saved_hash <- attr(obj, "spec_hash")
  if (is.null(saved_hash)) {
    warning(path, " has no spec hash - was saved before governance was set up")
    return(FALSE)
  }
  current <- spec_hash()
  if (saved_hash != current) {
    warning(path, " is STALE: saved under hash ", saved_hash, ", current is ", current)
    return(FALSE)
  }
  TRUE
}
```

### For Python projects (`src/config.py`):

```python
"""Central specification configuration.

ALL estimation scripts MUST import this module and use filter_sample().
Changing values here invalidates all saved outputs (detected via spec_hash).
"""

import hashlib
import json
import pickle
from datetime import datetime
from pathlib import Path

# --- Core estimation parameters ---
HORIZONS = range(0, 9)
SHOCK_SIZE = 0.25
VCOV_TYPE = "DK(3)"
FE_SPEC = "country"
SEED = 20250808

# --- Sample restrictions ---
SAMPLE_START = "2007-01-01"
SAMPLE_END = "2025-04-01"
EXCLUDE_COUNTRIES = ["CY"]

def filter_sample(df):
    """Apply standard sample restrictions. All scripts must use this."""
    return df[
        (~df["country"].isin(EXCLUDE_COUNTRIES)) &
        (df["quarter"] >= SAMPLE_START) &
        (df["quarter"] <= SAMPLE_END)
    ]

def spec_hash():
    """Generate hash of current spec for staleness detection."""
    params = {
        "horizons": list(HORIZONS),
        "shock_size": SHOCK_SIZE,
        "vcov": VCOV_TYPE,
        "fe": FE_SPEC,
        "seed": SEED,
        "sample_start": SAMPLE_START,
        "sample_end": SAMPLE_END,
        "exclude": EXCLUDE_COUNTRIES,
    }
    return hashlib.md5(json.dumps(params, sort_keys=True).encode()).hexdigest()

def save_with_hash(obj, path):
    """Save object with embedded spec hash."""
    wrapper = {"data": obj, "spec_hash": spec_hash(), "saved_at": str(datetime.now())}
    with open(path, "wb") as f:
        pickle.dump(wrapper, f)
    print(f"Saved: {path} [hash: {spec_hash()}]")

def check_hash(path):
    """Check if saved output is current."""
    p = Path(path)
    if not p.exists():
        return False
    with open(p, "rb") as f:
        wrapper = pickle.load(f)
    saved = wrapper.get("spec_hash")
    if saved is None:
        print(f"WARNING: {path} has no spec hash")
        return False
    current = spec_hash()
    if saved != current:
        print(f"WARNING: {path} is STALE: saved={saved}, current={current}")
        return False
    return True
```

Adapt variable names and parameters to the user's actual research question. The template values above are placeholders.

## Step 4: Create Makefile

Create a `Makefile` that encodes the pipeline dependencies:

```makefile
.PHONY: all pipeline analysis robustness clean audit

PROCESSED := data/processed
OUTPUT := output

# --- Full pipeline ---
all: pipeline analysis

# --- Data pipeline (sequential) ---
pipeline: $(PROCESSED)/final_data.rds

$(PROCESSED)/clean_data.rds: scripts/pipeline/01_fetch_data.qmd R/config.R
	quarto render $<

$(PROCESSED)/transformed_data.rds: scripts/pipeline/02_transform_data.qmd $(PROCESSED)/clean_data.rds R/config.R
	quarto render $<

$(PROCESSED)/final_data.rds: scripts/pipeline/03_merge_data.qmd $(PROCESSED)/transformed_data.rds R/config.R
	quarto render $<

# --- Analysis (depends on final data) ---
analysis: $(PROCESSED)/final_data.rds
	Rscript scripts/analysis/main/baseline.R
	Rscript scripts/analysis/main/interactions.R

# --- Robustness (depends on analysis) ---
robustness: analysis
	Rscript scripts/run_all.R

# --- Clean generated outputs ---
clean:
	rm -f $(PROCESSED)/*.rds
	rm -f $(OUTPUT)/figures/*.pdf $(OUTPUT)/figures/*.png
	rm -f $(OUTPUT)/tables/*.tex

# --- Audit (run research-code-auditor checks) ---
audit:
	@echo "Run /audit-research-code in Claude Code or use the research-code-auditor agent"
```

Adapt targets and commands to the user's language and pipeline structure.

## Step 5: Create CLAUDE.md

Generate a project-specific `CLAUDE.md` that includes:

1. **Repository Overview** - one paragraph describing the research question
2. **Core Data Pipeline Commands** - the exact commands to run each stage
3. **Architecture and Data Flow** - directory structure, key data dependencies
4. **Critical Variable Names** - key variables with naming conventions
5. **Specification Governance** section with:
   - Reference to central config file
   - `filter_sample()` documentation
   - `spec_hash()` documentation
   - Compliance testing commands
6. **Common Issues and Solutions** - known pitfalls

Use the gathered project details to fill in specifics. Do NOT use placeholder text - make it concrete and accurate for this project.

## Step 6: Create .gitignore

Language-appropriate `.gitignore`:

```gitignore
# Data (raw data tracked selectively, processed never)
data/processed/*.rds
data/processed/*.csv
data/processed/*.parquet
*.rds.bak

# Output (regenerable)
output/figures/*.pdf
output/figures/*.png
output/tables/*.tex
output/robustness/

# R
.Rproj.user/
.Rhistory
.RData
.Ruserdata
*_cache/

# LaTeX build artifacts
paper/**/build/
*.aux
*.bbl
*.bcf
*.blg
*.fdb_latexmk
*.fls
*.log
*.out
*.run.xml
*.synctex.gz
*.toc
*.nav
*.snm
*.vrb

# OS
.DS_Store
Thumbs.db

# Environment
.env*
renv/library/
renv/staging/
```

## Step 7: Create Test Stubs

Create `tests/test_spec_compliance.R`:

```r
# Test that all estimation scripts source the central config
# and use filter_sample() for data preparation.

library(here)

scripts <- list.files(
  here("scripts", "analysis"),
  pattern = "\\.(R|qmd)$",
  recursive = TRUE,
  full.names = TRUE
)

cat("Checking", length(scripts), "scripts for spec compliance...\n\n")

issues <- 0

for (script in scripts) {
  content <- readLines(script)
  has_config <- any(grepl('source.*config\\.R', content))
  has_filter <- any(grepl('filter_sample', content))

  if (!has_config) {
    cat("FAIL:", script, "\n  Missing: source(here('R', 'config.R'))\n")
    issues <- issues + 1
  }
  if (!has_filter) {
    cat("WARN:", script, "\n  Missing: filter_sample() call\n")
    issues <- issues + 1
  }
}

if (issues == 0) {
  cat("All scripts pass spec compliance.\n")
} else {
  cat("\n", issues, "issue(s) found.\n")
}
```

## Step 8: Initialize Version Control and Package Management

```bash
# Git
git init
git add -A
git commit -m "feat: scaffold project with spec governance"

# R: renv
# Rscript -e 'renv::init()'

# Python: uv
# uv init
```

Only run the package manager init if the user confirms.

## Step 9: Summary

After creating everything, print a summary:

```
Project scaffolded: <project_name>
Location: <path>

Key files:
  R/config.R          - Central spec config (edit parameters here)
  Makefile             - Pipeline orchestrator (run: make all)
  CLAUDE.md            - Project instructions for Claude Code
  tests/               - Spec compliance tests (run: Rscript tests/test_spec_compliance.R)

Staleness prevention:
  - All estimation scripts must source R/config.R
  - Use save_with_hash() / check_hash() for saved outputs
  - Run spec compliance tests before committing
  - Use /audit-research-code or research-code-auditor agent before submission

Next steps:
  1. Edit R/config.R with your actual parameters
  2. Add pipeline scripts to scripts/pipeline/
  3. Run: make pipeline
```
