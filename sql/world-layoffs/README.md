# World Layoffs — SQL Data Cleaning & EDA (MySQL)

A two-phase MySQL project: clean a messy raw "world layoffs" dataset (staging-table workflow, dedup, standardization), then build original exploratory analysis on top — including window functions beyond what the base cleaning exercise covers.

## What's in this script
| Phase | What it does |
|---|---|
| **Setup** | Creates `world_layoffs` database, renames in the raw `layoffs` table from a `data_cleaning` source DB, builds a `layoffs_staging` copy to work on (raw table stays untouched) |
| **1. Remove duplicates** | `ROW_NUMBER() OVER (PARTITION BY ...)` across all 9 real columns to find true full-row duplicates, isolates them into `layoffs_staging2`, deletes rows where `row_num > 1` |
| **2. Standardize** | Blank `industry` → `NULL`; backfills missing `industry` via a self-join on `company`; merges `'Crypto Currency'` / `'CryptoCurrency'` → `'Crypto'`; strips trailing `.` from `'United States.'`; converts `date` from text to a real `DATE` type via `STR_TO_DATE` |
| **3. Handle nulls** | Reviews rows with null `total_laid_off` / `percentage_laid_off`, deletes the ones with no usable layoff figure at all |
| **4. Cleanup** | Drops the helper `row_num` column |
| **5. EDA (original)** | Scale & date range, worst single layoff events, companies that shut down (100% laid off), totals by company/industry/country/year, **top-3-companies-per-year via `DENSE_RANK()`**, **rolling monthly total via `SUM() OVER (ORDER BY month)`**, layoffs by funding stage |

## Techniques Demonstrated
- Staging-table workflow (never modifies the raw table directly — a real data-hygiene habit, not just a nice-to-have)
- `ROW_NUMBER()` + CTE for duplicate detection (works around MySQL not allowing `DELETE` directly from a CTE)
- Self-join to backfill missing categorical values
- String standardization (`TRIM`, pattern-based category merging)
- Date parsing and type conversion (`STR_TO_DATE`, `ALTER TABLE ... MODIFY COLUMN`)
- `DENSE_RANK()` for top-N-per-group
- Running/rolling totals with a window function (`SUM() OVER (ORDER BY ...)`)

## Honest Note on Originality
The **cleaning phase** (staging tables, the exact `Crypto Currency`/`CryptoCurrency` merge, the `United States.` trailing-period fix, the self-join industry backfill) closely follows the well-known public "Alex The Analyst" layoffs SQL cleaning tutorial — this exact dataset and cleaning sequence is genuinely common across data-analyst portfolios online, so an interviewer familiar with it may recognize the pattern. That's fine — it's a legitimate way to learn the fundamentals — but it means the cleaning phase alone won't differentiate you. **The EDA phase (from the `DENSE_RANK` ranking onward) is where the original, portfolio-worthy work is**, and it's worth leading with that in interviews rather than the cleaning steps.

## QA Findings — issues found reading the script (flagging honestly, not silently fixing)
1. **The script isn't runnable top-to-bottom as-is.** `RENAME TABLE` creates `world_layoffs.layoffs_staging` early on — then a later `CREATE TABLE world_layoffs.layoffs_staging LIKE world_layoffs.layoffs` tries to create a table with that same name again, which MySQL will reject ("table already exists"). One of these two steps needs to go.
2. **There are three different attempts at building `layoffs_staging2` left in the file** (an early `CREATE TABLE ... AS SELECT`, a `DELETE`-via-CTE block targeting `layoffs_staging` directly, and finally the explicit `CREATE TABLE` + `INSERT` version with a defined schema). Only the last one is the clean, correct version — the earlier two look like exploratory attempts that were never removed. Worth trimming before this goes on GitHub, both for it to run cleanly and so it reads as a finished deliverable rather than a work-in-progress log.
3. **The first `layoffs_staging2` attempt has a real logic bug**: its `PARTITION BY` list includes `'date'` in single quotes — that's a string literal, not a reference to the `` `date` `` column — so it silently doesn't partition by date at all. Not a live issue since this block gets superseded by the correct version later, but worth removing rather than leaving in.
4. **`percentage_laid_off` stays a `TEXT` column for the whole script**, even though the EDA phase compares it numerically (`WHERE percentage_laid_off = 1`). MySQL's implicit type coercion makes this work, but it's fragile — a stray space or formatting difference in the source data would silently break the comparison. `date` gets properly converted to a real type (`STR_TO_DATE` + `ALTER TABLE MODIFY`); `percentage_laid_off` should get the same treatment (`DECIMAL` or `FLOAT`).
5. **Not fully reproducible from this file alone** — the very first step renames tables out of a `data_cleaning` database that isn't created or populated anywhere in this script. Anyone trying to run this from scratch needs the raw `layoffs` CSV imported into that source table first; worth a one-line note in the README (or the script) on where the raw data comes from and how it's loaded.

## How to Run
Needs a MySQL-compatible database with the raw layoffs data loaded into a `layoffs` table first (commonly sourced from the public "Layoffs 2022" Kaggle dataset used in this tutorial lineage). Run top-to-bottom in a MySQL client — after fixing QA finding #1, since the current version errors partway through on a fresh database.
