CREATE DATABASE world_layoffs;

USE world_layoffs;

-- Assumes `layoffs` table already exists / raw data already imported

-- 1. Create a staging table with the same structure as the layoffs table.
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Copy all the data from the layoffs table into the staging table.
INSERT INTO layoffs_staging
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
FROM layoffs;

-- Display all records from the staging table.
SELECT * FROM layoffs_staging;

-- Find duplicate records based on company, industry, total_laid_off, and date.
SELECT
    company,
    industry,
    total_laid_off,
    `date`,
    COUNT(*) AS duplicate_count
FROM layoffs_staging
GROUP BY
    company,
    industry,
    total_laid_off,
    `date`
HAVING COUNT(*) > 1;

-- Find complete duplicate records using all relevant columns
-- (company, location, industry, total_laid_off, percentage_laid_off, date, stage,
--  country, and funds_raised_millions).
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    COUNT(*) AS duplicate_count
FROM layoffs_staging
GROUP BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions
HAVING COUNT(*) > 1;

-- Display only the duplicate records.
SELECT *
FROM layoffs_staging
WHERE (
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions
) IN (
    SELECT
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
    FROM layoffs_staging
    GROUP BY
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
    HAVING COUNT(*) > 1
);

-- Create a new table named layoffs_staging2, same structure as layoffs_staging
-- plus a row_num column to identify duplicates.
CREATE TABLE layoffs_staging2
LIKE layoffs_staging;

ALTER TABLE layoffs_staging2
ADD COLUMN row_num INT;

-- Insert data into layoffs_staging2, generating row_num via ROW_NUMBER().
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Delete all duplicate records while keeping only the first occurrence.
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Display all unique industries.
SELECT DISTINCT industry
FROM layoffs_staging2;

-- Find all rows where the industry column is NULL or empty.
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';

-- Replace all empty ('') values in the industry column with NULL.
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill missing industry values using another row with the same company name.
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Standardize the industry column by replacing all variations of "Crypto" with a single value (Crypto).
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Display all unique country names.
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- Remove any trailing periods (.) from country names.
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Convert the date column from text format to a proper SQL date format.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change the datatype of the date column to DATE.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Find all rows where total_laid_off is NULL.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

-- Find all rows where both total_laid_off and percentage_laid_off are NULL.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete rows where both total_laid_off and percentage_laid_off are NULL.
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove the temporary row_num column from the table.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- ============================================
-- EDA / ANALYSIS PHASE (on cleaned layoffs_staging2)
-- ============================================

-- 1. Overall scale: total layoffs, date range
SELECT MIN(`date`) AS earliest, MAX(`date`) AS latest,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2;

-- 2. Worst single layoff events
SELECT company, total_laid_off, percentage_laid_off, `date`
FROM layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 10;

-- 3. Companies that laid off 100% of staff (shut down)
SELECT company, location, funds_raised_millions
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- 4. Total layoffs by company (all-time)
SELECT company, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY company
ORDER BY total DESC
LIMIT 10;

-- 5. Total layoffs by industry
SELECT industry, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY industry
ORDER BY total DESC;

-- 6. Total layoffs by country
SELECT country, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY country
ORDER BY total DESC;

-- 7. Layoffs by year
SELECT YEAR(`date`) AS yr, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY yr
ORDER BY yr;

-- 8. RANK: top 3 companies with most layoffs, PER YEAR (window function)
WITH company_year AS (
    SELECT company, YEAR(`date`) AS yr, SUM(total_laid_off) AS total
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
),
ranked AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY yr ORDER BY total DESC) AS ranking
    FROM company_year
    WHERE total IS NOT NULL
)
SELECT * FROM ranked
WHERE ranking <= 3
ORDER BY yr, ranking;

-- 9. Rolling monthly total layoffs (trend over time — good for a line chart)
WITH monthly AS (
    SELECT SUBSTRING(`date`,1,7) AS month, SUM(total_laid_off) AS total
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY month
)
SELECT month, total,
       SUM(total) OVER (ORDER BY month) AS rolling_total
FROM monthly
ORDER BY month;

-- 10. Stage (e.g. Post-IPO, Series C) vs total layoffs — funding-stage risk view
SELECT stage, SUM(total_laid_off) AS total, COUNT(DISTINCT company) AS companies_affected
FROM layoffs_staging2
GROUP BY stage
ORDER BY total DESC;