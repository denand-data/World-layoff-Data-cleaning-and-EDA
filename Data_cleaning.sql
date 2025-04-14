-- Duplicates removal
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
/*
This shows a new column named 'row_num' that contains how many times a specific row is found in the dataset 
so rows where row_num is greater than 1 are duplicated values
*/

-- Creating a CTE to find duplicates values
WITH duplicate as 
(
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
        stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM duplicate
WHERE row_num >1;
/*
This allows to filter the rows where row_num >1
*/

-- Updating the table with the row_num column
CREATE TABLE `layoffs_2` (
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

-- Filling the new column
INSERT INTO layoffs_2
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
        stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging;

-- Removing duplicates
DELETE
FROM layoffs_2
WHERE row_num >1;

-- Standardizing values by column
--- for companies
SELECT DISTINCT company, (TRIM(company))
FROM layoffs_2;
/*
This allows to see the difference between the original values and the trimmed version of them (no whitespace at beginning)
*/
-- Updating company names
UPDATE layoffs_2
SET company = TRIM(company);

--- for industries
SELECT DISTINCT industry
FROM layoffs_2
ORDER BY 1;
/* There are variations of crypt industries*/

SELECT DISTINCT industry
FROM layoffs_2
WHERE industry LIKE 'Crypto%';
/*Before updating*/

UPDATE layoffs_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
/* Updating the table after standardizing these crypto values*/

SELECT DISTINCT industry
FROM layoffs_2
WHERE industry LIKE 'Crypto%';
/*Only one value should be printed*/

SELECT DISTINCT country
FROM layoffs_2;
/*Two rows for United States because one has a point in the end of the srting*/

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
/* replacing values with point with 'United States'*/

SELECT DISTINCT country
FROM layoffs_2
WHERE country LIKE 'United States%';
/* Only one row should be visible*/

--- Changing 'date' from text to date format
UPDATE layoffs_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_2
MODIFY COLUMN `date` DATE;
/*Now 'date' is in m-d-Y date format*/

--- Dealing with NULL and empty values
SELECT *
FROM layoffs_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;
/* These rows can be deleted as the have no total of layoff neither the percentage*/

DELETE
FROM layoffs_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
; /*deleting the rows*/

SELECT DISTINCT *
FROM layoffs_2
WHERE industry IS NULL 
OR industry = '';
/*Visualizing rows where industry is null or empty*/

/*the way to solve this is to find if there exist another row from the same company with a valid value for industry*/ 
SELECT *
FROM layoffs_2 as t1
JOIN layoffs_2 as t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry='')
AND t2.industry IS NOT NULL;
/*These queries name t1 as the table with empty or null values for industry, while
t2 contains valid values, both tables are joined by the company name*/

UPDATE layoffs_2 as t1
JOIN layoffs_2 as t2
	ON t1.company = t2.company
SET t1.company = t2.industry
WHERE (t1.industry IS NULL OR t1.industry='')
AND t2.industry IS NOT NULL;
/*The companies in t1 are filled with the respective names from t2, and updated into the table*/

--- Deleting row_num column
ALTER TABLE layoffs_2
DROP COLUMN row_num;
