-- Summary of bankrupt companies
/*If a company went bankrupt its percentage_laid_off will be 1*/
SELECT company, country, industry, total_laid_off
FROM layoffs_2
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC;
/*Katerra was the biggest company to go bankrupt (by number of employees)
The top 4 of companies were located at the United States and in different industries*/

/*Slicing the summary into country*/
SELECT country, sum(total_laid_off) as layoffs
FROM layoffs_2
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
GROUP BY country
ORDER BY layoffs DESC;
/*This shows that the United States was by far the country that made the most 
layoffs due to bankruptcy, this could be due to a higher number of companies or a deepper crisis*/

/*Slicing the summary into industry*/
SELECT industry, sum(total_laid_off) as layoffs, 
COUNT(industry) AS total_industry
FROM layoffs_2
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY layoffs DESC;
/* Construction and Food were the industries in which more people were laid off, far behind are
retail, transportation, and education. Construction's layoffs are totally explained by one company (Katerra),
while food is the industry that had the most companies on bankruptcy*/

--- Funds raised analysis
/*analyzing which companies, countries, and industries raised themost funds before going bankrupt*/ 
SELECT company, country, total_laid_off, funds_raised_millions
FROM layoffs_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
LIMIT 10;
/*Britishvolt, Quibi, Deliveroo Australia, Katerra, and BlockFi are the five
companies that collected more than $1,000,000 before bankruptcy*/

/*Slicing by country*/
SELECT country, sum(funds_raised_millions) as raised_millions, 
       COUNT(country) AS total_companies
FROM layoffs_2
WHERE percentage_laid_off = 1
GROUP BY country
ORDER BY raised_millions DESC;
/*The United States is the country in which the companies collected the most funds before bankruptcy, but it had 73 compannies
United Kingdom and Australia are second and third, with 5 and 8 companies in total*/

/*Slicing by industry*/
SELECT industry, sum(funds_raised_millions) as raised_millions, 
       COUNT(industry) AS total_companies
FROM layoffs_2
WHERE percentage_laid_off = 1
GROUP BY industry
ORDER BY raised_millions DESC;
/*Transportation raised the most funds, but food and retail had a maximum of 13 bankrupt companies*/

-- Layoffs in general (not only bankruptcy)
--- By company
SELECT company, SUM(total_laid_off) AS total_layoffs, 
       ROUND(AVG(percentage_laid_off), 2) AS average_percentage
FROM layoffs_2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;
/*Big companies are responsible of many of the layoffs, for example, the top 3 is formed by Amazon, Google, and Meta.
Also, their layoff average is around 10%, being the Booking.com the most affected with a 25%.
So, the bigger the company, the better it can resist crisis, meaning that small companies were the hardest-hit.*/

--- By industry
SELECT industry, 
       SUM(total_laid_off) AS total_layoffs,
       COUNT(industry)
FROM layoffs_2
GROUP BY industry
ORDER BY total_layoffs DESC
LIMIT 10;
/**/
