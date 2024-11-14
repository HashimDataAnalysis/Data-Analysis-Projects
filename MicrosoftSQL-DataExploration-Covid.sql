
-- Data Exploration

-- Checking if we improrted the right data (there are some null data in continent)
select * 
from PorfolioProject..CovidDeaths
where continent is not null
order by 3,4;

select * 
from PorfolioProject..CovidVaccinations
order by 3, 4;

select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as "death_percentage"
from PorfolioProject..CovidDeaths
order by 1,2;


-- Likelihood of death if you contract Covid depending on your country
-- person_survived_per_death == case-to-death-ration
-- no. of people died = death_percentage

select location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as "death_percentage" , (total_cases/total_deaths) as "case-to-death_ratio"
from PorfolioProject..CovidDeaths
where location like '%singapore'
order by 1,2;

select location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as "death_percentage", (total_cases/total_deaths) as "case-to-death_ratio"
from PorfolioProject..CovidDeaths
where continent is not null
and location like '%india'
order by 1,2;

select location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as "death_percentage", (total_cases/total_deaths) as "case-to-death_ratio"
from PorfolioProject..CovidDeaths
where location like '%states'
order by 1,2;


select location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as "death_percentage", (total_cases/total_deaths) as "case-to-death_ratio"
from PorfolioProject..CovidDeaths
where location like '%malaysia'
order by 1,2;


-- LOOKING AT TOTAL CASES VS POPULATION
-- What percentage of population got Covid depending on the country

select location, date, population, total_cases, (total_cases/population * 100)as "COVID-19-InfectionPercentage"
from PorfolioProject..CovidDeaths
where location like '%states' and
continent is not null
order by 1,2;


-- Countries with highest infection rate and highest death rate compared to the Population
select Location, Population, max(total_cases) as Higest_Infection_Count, max((total_cases/population * 100))as COVID19_InfectionPercentage, max((total_deaths)) as Highest_deaths,
max((total_deaths/total_cases * 100)) as Highest_death_Percentage
from PorfolioProject..CovidDeaths
where continent is not null
group by location, population
order by Highest_deaths desc;

-- There is an issue with total_death data type 
select Location, Population, max(total_cases) as Higest_Infection_Count, max((total_cases/population * 100))as COVID19_InfectionPercentage, max(cast(total_deaths as int)) as Highest_deaths,
max((total_deaths/total_cases * 100)) as Highest_death_Percentage
from PorfolioProject..CovidDeaths
-- where location like '%states'
group by location, population
order by Highest_deaths desc;

-- Coutries with highest death
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc


-- Break down and Continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths
where continent is not null
group by continent 
order by TotalDeathCount desc

-- 'I believe this is much more accurate since there is an error with continent'
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount

-- GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
from PorfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- Death rate by date
select date, sum(new_cases) as total_cases
from PorfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

-- Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PorfolioProject..CovidDeaths as dea
join PorfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	where dea.continent is not null
	and dea.date = vac.date
order by 2,3

-- Rolling sum of Vaccination by Countries
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rolling_sum_vac
from PorfolioProject..CovidDeaths as dea
join PorfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	where dea.continent is not null
	and dea.date = vac.date
order by 2,3

-- CTE to check percentage of vaccinated population
with percent_vacc (location, date, population, new_vaccinations, rolling_sum_vac) as
(
select
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rolling_sum_vac
from PorfolioProject..CovidDeaths as dea
join PorfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	where dea.continent is not null
	and dea.date = vac.date
)
select *, (rolling_sum_vac/population)*100 as percent_vaccinated
from percent_vacc;

-- View for Visualizations

DROP VIEW IF EXISTS vaccinated_percent;

CREATE VIEW vaccinated_percent AS
SELECT
    dea.continent,
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS rolling_sum_vac
FROM 
    PorfolioProject..CovidDeaths AS dea
JOIN 
    PorfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
WHERE 
    dea.continent IS NOT NULL 
    AND dea.date = vac.date;


select * from
vaccinated_percent





