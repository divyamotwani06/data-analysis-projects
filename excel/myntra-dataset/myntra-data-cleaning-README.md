# Myntra Product Data — Cleaning, Enrichment & QA Review (Excel)

Excel-based data cleaning and analysis on a scraped Myntra product catalog. The core exercise: separate real signal from noise in an "average rating" KPI that's badly skewed by unreviewed listings, quantify discount patterns, and audit the workbook's own formulas for correctness rather than trusting cached numbers at face value.

## What's in this workbook (4 sheets)
| Sheet | What it is |
|---|---|
| `clean data v1` | Raw scraped data — **21,605 products**, 12 real columns + 5 blank columns + 1 broken column (see QA Findings) |
| `clean data v2` | Filtered to the **11,438 products** that have at least one customer rating, with 3 new calculated columns: `revenue`, `discount %`, `is discount?` |
| `analysis` | Side-by-side summary stats: uncleaned catalog vs. cleaned catalog |
| `pivot chart` | PivotTable + pie chart — average `rating_count` (engagement) per brand, with an Excel Slicer applied |

## Cleaning Methodology (v1 → v2)
- **Removed unreviewed placeholder listings**: 10,167 of 21,605 products had `rating = 0` and `rating_count = 0` — not genuinely bad ratings, just products with zero customer engagement. Leaving them in makes the catalog look far worse than it is.
- **Added `revenue`** = `discounted_price × rating_count` (proxy for units sold — no real sales data in the source export).
- **Added `discount %`** = `(marked_price − discounted_price) / marked_price × 100`.
- **Added `is discount?`** flag — `good discount` vs. `neglegible`, rule-based on discount %.
- **Dropped unused columns**: `product_link`, `brand symbol`, `product description`, and 5 blank columns.

## Key Metrics (verified directly against the data, not just the sheet's cached numbers)
- **Raw catalog: 21,605 products.** *(The workbook's own `analysis` sheet displays 21,606 — see QA Finding #1 for why that's off by one.)*
- **Cleaned catalog: 11,438 products, 1,458 unique brands**
- **Average rating: 2.20 (raw, misleading) → 4.16 (cleaned, real)** — driven entirely by removing zero-engagement listings
- **Price range:** ₹49–₹33,900 (discounted, cleaned); the single most expensive raw listing (₹40,900, Tom Ford sunglasses) has zero reviews and drops out during cleaning
- **Estimated revenue (proxy metric): ₹1,28,12,37,476**
- **Total engagement (sum of rating_count): 14,04,665**
- **Discount profile:** 86.9% of rated products (9,944 of 11,438) are "good discount"; median discount 50%, average 44%
- **Top categories:** T-shirts (1,121), Dresses (710), Shirts (650), Tops (616), Kurta Sets (590)
- **Top brands by product count:** Roadster (452), Mast & Harbour (260), DressBerry (225)

## QA Findings — formula-level audit (this is the part worth highlighting in an interview)
I opened the actual formulas behind every cached number in the `analysis` sheet rather than trusting the displayed values. Found 4 real issues:

1. **The "uncleaned" product count formula double-counts one row.** `E3` is `=COUNTA('clean data v1'!A2:A21606, 'clean data v1'!A21606)` — the last row (`A21606`) is referenced twice (once inside the range, once again on its own), so Excel counts it twice. True raw count is **21,605**, not the 21,606 the sheet shows.
2. **The "cleaned data" product count and unique-brand count are hardcoded, not formulas — and were never updated.** `H3` (=21,606) and `H4` (=2,139) are static values, identical to the uncleaned column. They should read **11,438** and **1,458** to reflect `clean data v2`.
3. **The "uncleaned unique brand count" formula doesn't actually count unique values.** `E4` is `=COUNTA('clean data v1'!R2:R2140)` — a plain non-blank count over a fixed 2,139-row slice of `brand_name.1` (the broken column, see below). It lands on the correct answer (2,139) only because that specific range happens to contain no blanks — not because the formula computes distinctness. Excel needs `COUNTIF`/`SUMPRODUCT`-style array logic (or a PivotTable) for a real unique count; this formula would silently break if the data shifted at all.
4. **The cleaned average rating formula also double-counts its last row** — `H5` is `=AVERAGE('clean data v2'!C2:C11439, 'clean data v2'!C11439)`. The true average is **4.159774**; the double-counted formula produces **4.159830** (matches the cached 4.15983 exactly). Numerically trivial at this row count, but the same bug pattern as #1 — worth fixing on principle.
5. **Revenue (`H10`) and traffic totals (`H11`, `E11`) are hardcoded text strings, not live formulas** (e.g. `H10` = the literal text `'1,28,12,37,476'`). They're correct today, but won't recalculate if the underlying data changes, and being text (not numbers) they can't be referenced in further formulas without conversion.
6. **`clean data v1` has a broken trailing column, `brand_name.1`.** It matches the real `brand_name` column for roughly the first 50 rows, then drifts out of alignment for the remaining 21,554 rows — a leftover artifact from an editing/copy step. Not used correctly anywhere; safe to delete.
7. **The pivot chart is a filtered demo, not a brand ranking.** A Slicer is applied, currently showing only 4 brands (AKKRITI BY PANTALOONS, Akshatani, ALBERTO MORENO, Alcis) — the first 4 alphabetically, not a "top N" selection. Good demonstration of Slicer/PivotTable skill; just shouldn't be described as a performance ranking as-is.

## Caveat on the revenue estimate
`revenue = discounted_price × rating_count` treats every customer rating as one unit sold. In reality only a fraction of buyers leave a rating, so this systematically *understates* true revenue. It's useful for relative comparison (which products/brands outperform others), not as an absolute sales figure — worth stating explicitly if asked about it.

## Tools & Skills Demonstrated
- Data cleaning (removing invalid rows, dropping unused columns)
- Formula-driven enrichment (calculated columns, conditional bucketing)
- PivotTables, PivotCharts, and Slicers
- **Formula auditing** — verifying cached values against live formula logic rather than trusting what's displayed
