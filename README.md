# World Layoffs — SQL Data Cleaning & EDA

A SQL project analyzing a global tech/startup layoffs dataset — covering data cleaning and exploratory data analysis using MySQL.

## What this project does

1. **Data Cleaning**: Removes duplicate records, standardizes inconsistent categorical values (e.g. multiple spellings of "Crypto"), fixes malformed dates, trims formatting issues (e.g. "United States." vs "United States"), and handles null values with clear reasoning.
2. **Exploratory Data Analysis**: Uses window functions (ROW_NUMBER, DENSE_RANK, SUM() OVER) and CTEs to answer real business questions — not just basic aggregates.

## Tools used
- MySQL / MySQL Workbench

## Key Findings

- **Layoffs peaked in April 2020** (53,420 layoffs in a single month), during the early COVID-19 shock, with elevated levels continuing through mid-2020.
- **High funding didn't prevent shutdowns** — Britishvolt, a company that raised $2.4B, still had 100% of its staff laid off, showing that capital raised isn't a reliable predictor of company survival.
- **Consumer and Retail sectors were hit hardest** by total layoffs — not tech — suggesting the disruption was broader and more consumer-facing than the "tech layoffs" narrative usually implies.

## What I'd build next
- Visualize the monthly rolling total as a line chart
- Join with a funding-round or stock-price dataset for deeper correlation analysis
- Extend to a dashboard (Tableau/Power BI) for interactive exploration

## File
- `world_layoffs.sql` — full cleaning + EDA script, with comments explaining each step
