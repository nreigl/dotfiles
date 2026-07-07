---
description: Clean and transform messy data in Stata with reproducible do-files
---

# Stata Data Cleaning

Generate a reproducible cleaning do-file. Infer the unit of observation and key variables from the data; ask only about known quality issues you cannot detect (undocumented missing-value codes, merge keys).

## Do-file structure

1. **Header**: project, purpose, input, output
2. **Setup**: `clear all`, `set more off`, open a log file
3. **Load & inspect**: `describe`, `summarize`, `codebook, compact`, `duplicates report`
4. **Clean**: rename for clarity, `mvdecode` missing-value codes (-99, -88, ...), standardize strings, create labeled categoricals
5. **Validate**: `assert` expected ranges, `isid` on the identifier
6. **Label**: every kept variable gets `label variable`; categoricals get value labels
7. **Save**: `keep`/`order` relevant variables, `compress`, save to a clean-data path — never overwrite raw data

## Core pattern

```stata
clear all
cap log close
log using "logs/clean_`c(current_date)'.log", replace
global raw "data/raw"
global clean "data/clean"

use "${raw}/raw_data.dta", clear
duplicates report id_var

mvdecode age income, mv(-99 -88 -77)
replace state = upper(trim(state))

gen log_income = ln(income + 1)
label variable log_income "Log of annual income"

assert age >= 18 & age <= 120 if !mi(age)
isid id_var

compress
save "${clean}/analysis_data.dta", replace
log close
```

## Pitfalls

- Merging without first checking duplicates on the key
- Unhandled sentinel missing codes contaminating estimates
- Overwriting raw data files
- Undocumented transformations (comment *why*, not what)
