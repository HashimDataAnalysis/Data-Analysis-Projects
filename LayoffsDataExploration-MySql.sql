-- Exploratory Data Analysis

Select *
from layoffs_staging2;

select max(total_laid_off), max(percentage_laid_off) 
from layoffs_staging2;

## When Percentage layoff = 1, it means that everybody got fired in that company
Select *
from layoffs_staging2
where percentage_laid_off = 1;

## Highest layoffs by companies when they fired everyone
Select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

## Companies that had highest funds raised along with complete layoffs 
Select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

## Companies with the most layoffs
select company, SUM(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

## The range date of when the layoffs happened
select min(`date`), max(`date`)
from layoffs_staging2;

## Industry with the most layoffs
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

## Countries with the most layoffs
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

## Years with the most layoffs
select year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

## layoffs and stage
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 1 desc;

## Progression of layoffs by month and year
select substring(`date`, 6,2) AS `month`, sum(total_laid_off)
from layoffs_staging2
group by substring(`date`, 6,2)
order by `month`;

select substring(`date`, 6,2) AS `month`, sum(total_laid_off)
from layoffs_staging2
group by `month`
order by `month`;

## Layoffs by month/year
select substring(`date`, 1 ,7) AS `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1 ,7) is not null
group by `month`
order by 1 ASC;

## Rolling Total
select * 
from layoffs_staging2;

with rolling_sum as
(
select substring(`date`, 1,7) as `month`, sum(total_laid_off) as laid_off
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by `month`
order by 1 asc
)
select `month`, laid_off,
sum(laid_off) over (order by `month`) as rolling_total
from rolling_sum;



select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

## Top layoffs by year and company
with company_year(company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
)
select *, dense_rank() over(partition by years order by total_laid_off desc) as 'rank'
from company_year
where years is not null
order by `rank`;


