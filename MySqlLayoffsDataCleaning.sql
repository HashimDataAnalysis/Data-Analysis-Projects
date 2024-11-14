select * from
layoffs;

-- Data Cleaning in Mysql
-- 1. Create a staging table
-- 2. Remove duplicates
-- 3. Standardize the data
-- 4. Remove null and empty values
-- 5. Remove unwanted columns (if any)

-- 1. Create a staging table

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

## check
SELECT *
FROM layoffs_staging;

-- 2. REMOVE DUPLICATES

-- Create a unique row num to identify the duplicates (if there are duplicates the row num will be 2)
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Create a CTE
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
SELECT * FROM 
duplicate_cte
WHERE row_num > 1;

-- Double Checking
SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';

## THIS CODE DOESN'T WORK IN MYSQL ##
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;


-- Crete another table with a extra column called row_num to filter and delete the Duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

## Check Columns
SELECT *
FROM layoffs_staging2;

## INSERT DATA (THE SAME QUEREY AS CTE TABLE)
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- IDENTIFY WHAT YOU'RE DELETING
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- DELETE

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

## Check if it worked
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- 3. STANDARDIZING DATA

## Check company
SELECT company, TRIM(company)
FROM layoffs_staging2;

## Update (Trim empty spaces in company)
UPDATE layoffs_staging2
SET company = TRIM(company);

## check Industry
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE "Crypto%";

-- ALL THE UNIQUE VALUES OF CRYPTO String
SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry REGEXP '(?i)crypto'
ORDER BY industry;

-- Another method to find unique strings with similar words
SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE '%crypto%'
   OR industry LIKE '%Crypto%'
ORDER BY industry;

## UPDATE
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

## Check if it worked
SELECT * 
FROM layoffs_staging2
WHERE industry LIKE "Crypto%";

SELECT DISTINCT industry
FROM layoffs_staging2
order by 1;

## Lets check LOCATION
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

## Lets check COUNTRY
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country REGEXP '(?i)united states'
ORDER BY country;

## Lets update country
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "United States%";

## Check if it worked
SELECT DISTINCT country
FROM layoffs_staging2
WHERE country REGEXP '(?i)united states'
ORDER BY country;

## Lets change date from to text to date format
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


SELECT `date`
FROM layoffs_staging2;

## UPDATE
UPDATE layoffs_staging2
SET date = str_to_date(`date`, '%m/%d/%Y') ;

#check format (STILL TEXT FORMAT)
SHOW COLUMNS FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

#check format (NOW CHANGED)
SHOW COLUMNS FROM layoffs_staging2;

-- 4. REMOVE NULL VALUES

## LETS CHECK INDUSTRY FIRST 
select distinct industry
from layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE industry is null 
or industry = '';

select * 
from layoffs_staging2
where company = 'Airbnb';

-- FILL EMPLTY COLUMNS THAT CAN BE POPULATED
SELECT t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

## lets set blanks to null
update layoffs_staging2
set industry = null
where industry = '';

UPDATE layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

## CHECK
SELECT t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;


-- 5.REMOVE UNWANTED ROWS AND COLUMNS

-- Removing rows which has null or "" in both percentage_laid_off and total_laid_off
SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

select * FROM layoffs_staging2
WHERE (percentage_laid_off IS NULL OR percentage_laid_off = '')
 AND (total_laid_off IS NULL OR total_laid_off = '');

 DELETE FROM layoffs_staging2
 WHERE (percentage_laid_off IS NULL OR percentage_laid_off = '')
 AND (total_laid_off IS NULL OR total_laid_off = '');
 
 ## Check if the rows are deleted
select * FROM layoffs_staging2
WHERE (percentage_laid_off IS NULL OR percentage_laid_off = '')
AND (total_laid_off IS NULL OR total_laid_off = '');

## Drop row_num column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

## Check if its dropped
SELECT * 
FROM layoffs_staging2 