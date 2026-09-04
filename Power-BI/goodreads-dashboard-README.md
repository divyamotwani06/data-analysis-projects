# Goodreads Books Dashboard (Power BI)

An interactive Power BI dashboard built on a Goodreads-style books export (`good_read.csv`), with substantial data cleaning done in Power Query (M) before the report layer — 1 page, 12 visuals.

## ⚠️ Before you upload this — one blocking fix needed
The Power Query source step has your **local file path hardcoded**:
```
Source = Csv.Document(File.Contents("C:\Users\DELL\Downloads\good_read.csv"), ...)
```
A `.pbit` file never contains the actual data — it's a template (schema + report design + query steps only). Right now, if anyone else (or you, on another machine) opens this file, Power BI will fail immediately trying to read a path that only exists on your computer.
1. In Power BI Desktop → Transform Data → Data Source Settings, change the source path — or better, convert it to a **Parameter** so anyone opening the template gets prompted to point at their own copy of the CSV. That's what makes a `.pbit` actually function as a *template* rather than a broken shortcut.
2. Include `good_read.csv` in the same GitHub folder so the path is easy to relink.

## Data Preparation (Power Query / M)
The raw CSV arrives as 10 unnamed, unparsed columns. The M query does real work, not just a straight load:
- Promotes headers, filters out rows with blank `id`, `title`, `rating`, or the combined ratings/reviews field, deduplicates on `id`
- **Splits `author_detail`** into a clean `main_author` (text before the `|` delimiter)
- **Splits a combined `rat_rev` field** into separate `num_of_ratings` and `num_of_reviews` numeric columns (then drops the original `rat_rev`)
- **Splits `genre`** into a clean `main_genre` (text before the first comma)
- **Parses a compound `page` field** into two clean columns, `num_of_pages` (integer) and `binding_type`, via delimiter extraction (then drops the original `page`)
- **Extracts `author_id`** from a URL-style `author_link` field
- **Parses a messy `year` field** into a real `published_date` (date type), then derives a clean `year` integer from it

This cleaning layer is the strongest, most defensible part of the project — genuinely more involved than a typical "load CSV and drag fields" exercise, and worth explicitly walking through in an interview.

## QA Findings (verified against the actual Power Query steps and report JSON — not just what the dashboard shows on the surface)

1. **The `year` column you built is unused.** After all that parsing work to derive a clean `year` integer, none of the 12 visuals actually reference it — the line chart's year axis instead uses Power BI's auto-generated Date Hierarchy (built automatically off `published_date`). Either wire a visual to your own `year` column to justify building it, or drop it and rely on the auto date hierarchy — right now it's dead work that doesn't show up anywhere in the report.
2. **Not all messy source columns get dropped.** `rat_rev` and `page` are correctly removed once split. But `author_detail`, the full `genre` string, and `author_link` are all still sitting in the final table alongside their cleaned versions (`main_author`, `main_genre`, `author_id`). Worth removing them in a final "Remove Columns" step — keeping raw and cleaned versions side by side undercuts the "cleaned data" story a little.
3. **The `published_year`/`published_date` parsing has ~5 redundant rebuild cycles** in the M query — insert, remove, re-insert with a different type conversion, repeat, before landing on the final version. Functionally harmless (the final output is correct), but it reads as an unfinished edit trail rather than a deliberate pipeline. Worth condensing before this goes on GitHub, the same way you'd clean up commented-out code before a PR.
4. **The "authors" table's second column is `Average of num_of_pages`, not total pages.** (I want to flag that I initially misread this as "total pages" — worth double-checking yourself in Power BI Desktop before you describe this table to anyone, since it changes what the table is actually telling a viewer: average book length per author, not their total page output.)

A note on the two findings above and below: I pulled these from reading the underlying `.pbit` file structure directly rather than the rendered dashboard. When you sent screenshots of the actual live dashboard, two of my original findings turned out to be wrong (the "Authors" card, and a claim about missing custom titles) — the live render is the ground truth, not my file-level read. I've corrected both below rather than leave a wrong claim in here. Worth trusting what you see in Power BI Desktop over any of my static-analysis claims if the two ever disagree — offer to re-check against a screenshot if you're unsure about anything else in this list.

## Dashboard (1 page, 12 visuals) — verified from the report JSON and confirmed against the live dashboard
- **4 KPI cards (with business-friendly custom titles already set):** "Total books on the platform" (Count of `id`, 78.076K), "Authors" (Distinct Count of `author_id`, 36.12K — confirmed correct: ~2.16 books/author on average, a realistic ratio), "Pages" (Sum of `num_of_pages`, 24M), "Reviews" (Sum of `num_of_reviews`, 96M)
- **Gauge:** Average of `rating` (correctly uses Average, not Sum)
- **Line chart:** Count of `id` by Year (via the auto Date Hierarchy — see Finding #1)
- **Clustered bar chart:** Count of `id` by `binding_type`
- **Donut chart:** Count of `id` by `main_genre`
- **2 slicers:** `binding_type`, `published_date`
- **Table:** `main_author` + Average of `num_of_pages` (see Finding #4)
- **"Top 5 Books" table:** `title` + Sum of `num_of_ratings` + Sum of `num_of_reviews` — genuinely uses a real **Top-N filter** (Top 5 by Sum of `num_of_reviews`, descending; verified directly in the report's filter subquery, not a manually sorted/truncated list)

## Data Model
- 1 real table (`good_read`) + 2 auto-generated hidden date tables (Power BI's built-in **Auto Date/Time** feature, triggered by the `published_date` column) — not a manually built date dimension, worth knowing so you don't overstate this as custom star-schema modeling if asked directly.
- 1 relationship: `good_read.published_date` → the auto date table (powers the Year axis on the line chart — see Finding #1 on why the manual `year` column doesn't do this instead).

## A note on sharing this on GitHub
Most visitors to your repo won't have Power BI Desktop installed (Windows-only, heavy download), so they likely can't open the `.pbit` file directly. Strongly recommend exporting a **screenshot or short screen-recording GIF** of the finished dashboard and embedding it in this README — that's what most people will actually see.

## Repo contents (recommended)
```
├── goodread.pbit           # Power BI template — fix the hardcoded path (see above) before sharing
├── good_read.csv           # Source data — include so the path is easy to relink
├── README.md
└── dashboard-preview.png   # Screenshot — add so non-Power BI users can see the result
```
