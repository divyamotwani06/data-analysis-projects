# Data Analysis Projects

A collection of SQL and Excel-based data analysis work — cleaning messy datasets, building dashboards, and extracting business-relevant insights. Built as part of self-directed learning in analytics, data cleaning, and business intelligence.

---

## 1. Myntra Product Data — Cleaning & Analysis
`myntra-dataset.xlsx`

Cleaned and analyzed a 24,000+ row fashion e-commerce product dataset (product name, brand, rating, pricing, discounts).

**What I did:**
- Took raw, unclean product data through a structured pipeline: Unclean → Filtered → Cleaned → Pivot/Analysis
- Removed inconsistencies and structured pricing/rating fields for analysis
- Built pivot tables to surface brand- and pricing-level patterns

**Skills demonstrated:** Data cleaning, Excel PivotTables, structured multi-stage data pipelines

---

## 2. Vrinda Store — Sales Data Analysis
`Vrinda_Store_Data_Analysis.xlsx`

A sales analytics dashboard built on order-level e-commerce data, covering order volume, revenue, and customer segments.

**What I did:**
- Built views for Order vs. Sales performance, gender-based purchase behavior, order status breakdown, and sales channel comparison
- Analyzed order patterns by customer age and gender
- Structured raw order data into decision-ready dashboard views

**Skills demonstrated:** Excel dynamic dashboards, PivotTables, business/sales analytics, segmentation

---

## 3. Swiggy Restaurant Data — SQL Fundamentals
`swiggy_project.sql`

A set of SQL queries against a restaurant dataset (city, cuisine, cost, rating, rating count), covering core query patterns used in day-to-day analysis.

**What I did:**
- Filtering, sorting, and aggregation (`WHERE`, `GROUP BY`, `HAVING`)
- Subqueries for comparative analysis (e.g. restaurants priced above the average cost)
- Window functions (e.g. finding the 2nd-highest-rated restaurant)

**Skills demonstrated:** SQL fundamentals — joins-free aggregation, subqueries, basic window functions. *(Written as a practice/fundamentals exercise — included to show SQL fluency, not positioned as a flagship project.)*

---

## 4. World Layoffs — SQL Data Cleaning & EDA
`world_layoffs.sql`

A two-phase SQL project: cleaning a messy real-world layoffs dataset, then running original exploratory analysis on top of it.

**Phase 1 — Data Cleaning:**
- Removed duplicate records using `ROW_NUMBER()` window functions partitioned across all relevant columns
- Standardized inconsistent category values (e.g. merging `Crypto Currency` / `CryptoCurrency` → `Crypto`)
- Fixed trailing-period inconsistencies in country names, converted string dates to proper `DATE` type
- Handled nulls deliberately — populated where inferable from other rows, left null where appropriate for downstream calculations, removed rows with no usable data

**Phase 2 — Exploratory Analysis (original):**
- Ranked companies by total layoffs, both all-time and **per year using `DENSE_RANK()`**
- Built a **rolling monthly total** of layoffs using a windowed running sum — trend-ready for visualization
- Identified companies that laid off 100% of staff (shutdowns), ranked by funds raised
- Broke down layoffs by industry, country, and funding stage to surface where risk concentrated

**Skills demonstrated:** Advanced SQL — window functions, CTEs, deduplication logic, data standardization, trend analysis

**Note on sourcing:** The cleaning methodology in Phase 1 follows a well-known public dataset and cleaning approach used widely in SQL learning resources — I'm noting that openly rather than presenting it as fully original. Phase 2 (the ranking, rolling-trend, and funding-stage analysis) is my own extension beyond the base cleaning exercise.

---

## Tools
SQL (MySQL) · Excel (PivotTables, dynamic dashboards, data cleaning) · Window functions · CTEs

## About
Built by Divya Motwani as part of self-directed analytics practice. Open to feedback — feel free to raise an issue or reach out.
