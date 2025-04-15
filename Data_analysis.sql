-- Summary of bankrupt companies
/*If a company went bankrupt its percentage_laid_off will be 1*/
SELECT company, country, industry, total_laid_off
FROM layoffs_2
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC;
/*This code selects bankrupt companies whose layoff number is not null (an integer value) and summarises by 
company name, country, and industry*/

/*Slicing the summary into country*/
SELECT country, sum(total_laid_off) as layoffs
FROM layoffs_2
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
GROUP BY country
ORDER BY layoffs DESC;
/*The code is derivate from the earlier one, but it summarises only by country to make better comparisons*/

/*Slicing the summary into industry*/
SELECT industry, sum(total_laid_off) as layoffs, 
COUNT(industry) AS total_industry
FROM layoffs_2
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY layoffs DESC;
/*Allows to compare layoffs across different industries, and the number of bankrupted companies*/

--- Funds raised analysis
/*analyzing which companies, countries, and industries raised themost funds before going bankrupt*/ 
SELECT company, country, total_laid_off, funds_raised_millions
FROM layoffs_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
LIMIT 10;

/*Slicing by country*/
SELECT country, sum(funds_raised_millions) as raised_millions, 
       COUNT(country) AS total_companies
FROM layoffs_2
WHERE percentage_laid_off = 1
GROUP BY country
ORDER BY raised_millions DESC;
/*Finds how many funds by how many companies were raised by country */

/*Slicing by industry*/
SELECT industry, sum(funds_raised_millions) as raised_millions, 
       COUNT(industry) AS total_companies
FROM layoffs_2
WHERE percentage_laid_off = 1
GROUP BY industry
ORDER BY raised_millions DESC;
/*Finds how many funds by how many companies were raised by industry*/

-- Layoffs in general (not only bankruptcy)
--- By company
SELECT company, SUM(total_laid_off) AS total_layoffs, 
       ROUND(AVG(percentage_laid_off), 2) AS average_percentage
FROM layoffs_2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;
/*Finds the company that made the most layoffs and how much of their worforce it represented in average*/

--- By industry
SELECT industry, 
       SUM(total_laid_off) AS total_layoffs,
       COUNT(industry)
FROM layoffs_2
GROUP BY industry
ORDER BY total_layoffs DESC
LIMIT 10;
/*Finds industries that made the most layoffs and counts the ocurrence frequency*/

--- By country
SELECT country,
       SUM(total_laid_off) AS total_layoffs,
       COUNT(country)
FROM layoffs_2
GROUP BY country
ORDER BY total_layoffs DESC
LIMIT 10;
/*Finds countries that made the most layoffs and counts the ocurrence frequency*/

--- layoffs by year
SELECT YEAR(`date`) AS years, SUM(total_laid_off), COUNT(total_laid_off)
FROM layoffs_2
GROUP BY YEAR(`date`)
HAVING years IS NOT NULL
ORDER BY 1 asc
;
/*'years' takes the year of the date column, then it is used to group layoffs and occurrence frequency*/

--- evolution of layoffs by year and month
SELECT substring(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
/*'MONTH' is the first seven digits from the date, for example, from 2020-03-17 it would take the value of 2020-03
This variable is used to group the layoffs*/

--- Finding a bankruptcy ratio by month
---- Bankrupt companies by month
SELECT substring(`date`, 1,7 ) AS Months, 
       COUNT(company) AS bankrupt_companies
FROM layoffs_2
WHERE percentage_laid_off = 1
GROUP BY Months
ORDER BY 1;
/*Now it counts companies in bankrupt by each date value*/

---- Total of companies that laid off by month
SELECT substring(`date`, 1, 7) AS Months, 
       COUNT(company) AS companies
FROM layoffs_2
WHERE Months IS NOT NULL
GROUP BY Months
ORDER BY 1;
/*Counts total of companies by month*/
/*These queries can be joined to calculate a bankruptcy ratio*/

---- Bankruptcy ratio by date
WITH monthly_bankrupt AS (
SELECT bankrupt.Months, bankrupt.bankrupt_companies, 
total_count.total_companies
    FROM(
        SELECT substring(`date`, 1, 7) AS Months, 
               COUNT(company) AS bankrupt_companies
        FROM layoffs_2
        WHERE percentage_laid_off = 1
        GROUP BY Months) AS bankrupt
    LEFT JOIN(
        SELECT substring(`date`, 1, 7) AS Months, 
               COUNT(company) AS total_companies
        FROM layoffs_2
        WHERE `date` IS NOT NULL
        GROUP BY Months) AS total_count
    ON bankrupt.Months = total_count.Months
) 
SELECT Months, 
       bankrupt_companies,
       total_companies,
       ROUND(1.0*bankrupt_companies/total_companies, 4) AS bankruptcy_ratio
FROM monthly_bankrupt
ORDER BY 1;
/*First, it creates a tabla named 'bankrupt', which contains the count of bankrupt companies by month.
Then, from a table named 'total_count' that contains total company layoff frequency is applied a left join 
on the months taken into consideration.
All that process is a CTE named 'monthly_bankrupt'*/

--- Bankruptcy ratio by country
WITH bankrupt_perc AS(
SELECT bankrupt.country, bankrupt.bankrupt_companies, total_count.total
    FROM(
        SELECT country, COUNT(country) AS bankrupt_companies 
        FROM layoffs_2
        WHERE percentage_laid_off = 1
        GROUP BY country
    ) AS bankrupt
    LEFT JOIN(
        SELECT country, COUNT(country) AS total 
        FROM layoffs_2
        GROUP BY country
    ) AS total_count
    ON bankrupt.country = total_count.country 
)
SELECT *, 
       ROUND((1.0*bankrupt_companies/total), 4) AS bankrupt_percentage
FROM bankrupt_perc
ORDER BY 4 DESC;
/*Similar to the previous query, joins two tables, one containing the frequency of bankrupt companies, 
and other one containing frequency of layoffs in total*/

--- Bankruptcy ratio by industry
WITH bankrupt_perc AS(
SELECT bankrupt.industry, bankrupt.bankrupt_companies, total_count.total
    FROM(
        SELECT industry, COUNT(industry) AS bankrupt_companies 
        FROM layoffs_2
        WHERE percentage_laid_off = 1
        GROUP BY industry
    ) AS bankrupt
    LEFT JOIN(
        SELECT industry, COUNT(industry) AS total 
        FROM layoffs_2
        GROUP BY industry
    ) AS total_count
    ON bankrupt.industry = total_count.industry 
)
SELECT *, 
       ROUND((1.0*bankrupt_companies/total), 4) AS bankrupt_percentage
FROM bankrupt_perc
ORDER BY 4 DESC;
/*Finds percentage of bankrupt companies by industry following the same structure from the previous queries*/

--- Top 5 countries, companies, and industries with the most layoffs by year
WITH company_year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`),SUM(total_laid_off)
FROM layoffs_2
WHERE company != ''
GROUP BY company, YEAR(`date`)
), company_year_rank as 
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) as rank_laid_off
FROM company_year
WHERE years IS NOT NULL
ORDER BY years ASC
)
SELECT * 
FROM company_year_rank
WHERE rank_laid_off <= 5
;
/*First it calculates the sum of layoffs for each company by year, then a rank is applied according to the values
of the column 'total_laid_off', finally, these values are filtered to show only the top 5 by year*/

WITH country_year (country, years, total_laid_off) AS 
(
SELECT country, YEAR(`date`),SUM(total_laid_off)
FROM layoffs_2
WHERE country != ''
GROUP BY country, YEAR(`date`)
), country_year_rank as 
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) as rank_laid_off
FROM country_year
WHERE years IS NOT NULL
ORDER BY years ASC
)
SELECT * 
FROM country_year_rank
WHERE rank_laid_off <= 5
;
/*Analysis by country*/

WITH industry_year (industry, years, total_laid_off) AS 
(
SELECT industry, YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
WHERE industry != ''
GROUP BY country, YEAR(`date`)
), industry_year_rank as 
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) as rank_laid_off
FROM industry_year
WHERE years IS NOT NULL
ORDER BY years ASC
)
SELECT * 
FROM industry_year_rank
WHERE rank_laid_off <= 5
;
/*Analysis by industry*/
