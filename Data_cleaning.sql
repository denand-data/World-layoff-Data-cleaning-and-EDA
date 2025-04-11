-- Duplicates removal
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
/*
This shows a new column names 'row_num' that contains how many times a specific row is found in the dataset 
so rows where row_num is greater than 1 are duplicated
*/

