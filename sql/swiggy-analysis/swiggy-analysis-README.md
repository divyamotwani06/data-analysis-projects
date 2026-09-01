# Swiggy Restaurant Data — SQL Fundamentals (MySQL)

A 25-query progression through core SQL techniques on a single `restaurants` table from a Swiggy-style food-delivery dataset (columns used across the queries: `name`, `city`, `rating`, `rating_count`, `cost`, `cuisine`).

## Techniques Demonstrated (in order of appearance)
- Basic `SELECT` / column projection, `WHERE` filtering
- `DISTINCT`
- `ORDER BY` + `LIMIT` / `OFFSET` — including the classic "Nth highest" pattern (`LIMIT 1 OFFSET 1` for 2nd-highest rating)
- Aggregate functions: `COUNT`, `AVG`, `MAX`, `MIN`, `SUM`
- `GROUP BY` + `HAVING` (e.g. cuisines with >10 restaurants, cities with avg rating > 4.0)
- Scalar subqueries (restaurants priced above the overall average cost)
- Correlated subqueries (the highest-rated restaurant *within each city*)
- `COUNT(DISTINCT ...)` (cities offering more than one cuisine type)

This is a good, comprehensive fundamentals set — it covers filtering through correlated subqueries, which is a reasonable range to show in an interview as "I know core SQL end to end."

## QA Findings — issues found reading the script
1. **Query 20 likely has a column-name bug.** It selects `restaurant_name`, but every other query in this file (including query 2, which selects names directly) uses `name`. Unless the underlying table genuinely has both a `name` and a separate `restaurant_name` column, this query will fail with an "unknown column" error. Worth testing this one specifically and fixing to `name` before sharing.
2. **Inconsistent quoting on numeric comparisons.** Some `WHERE` clauses compare numeric columns to quoted strings (`rating > "4.0"`, `cost <= "300"`, `rating_count > "1000"`), while others correctly use unquoted numbers (`AVG(rating) > 4.0`). MySQL's implicit type coercion means both work, but it reads as inconsistent — worth standardizing to unquoted numeric literals throughout.
3. **Query 12 has an undocumented filter.** The comment says "Display restaurant names and costs ordered by cost in ascending order," but the query also filters `WHERE cost > 49` — a business rule the question never mentions. Either the comment should describe the filter, or the filter shouldn't be there.

## What's Not in This File
There's no `CREATE TABLE` statement defining the `restaurants` schema — the script assumes the table already exists. If this goes on GitHub as a standalone project, it's worth adding a short schema block (or a note on where the source CSV/table comes from) so someone else could actually run it.

## How to Run
Needs a MySQL-compatible database with a `restaurants` table already loaded (matching the columns used above). Run `USE swiggy;` then execute queries individually — this file reads as a practice/reference set rather than a single pipeline, so there's no strict order dependency between queries (unlike the World Layoffs project).
