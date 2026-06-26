CREATE TABLE covid_deaths (
    iso_code TEXT,
    continent TEXT,
    location TEXT,
    date DATE,
    population DOUBLE PRECISION,
    total_cases DOUBLE PRECISION,
    new_cases DOUBLE PRECISION,
    new_cases_smoothed DOUBLE PRECISION,
    total_deaths DOUBLE PRECISION,
    new_deaths DOUBLE PRECISION,
    new_deaths_smoothed DOUBLE PRECISION,
    total_cases_per_million DOUBLE PRECISION,
    new_cases_per_million DOUBLE PRECISION,
    new_cases_smoothed_per_million DOUBLE PRECISION,
    total_deaths_per_million DOUBLE PRECISION,
    new_deaths_per_million DOUBLE PRECISION,
    new_deaths_smoothed_per_million DOUBLE PRECISION,
    reproduction_rate DOUBLE PRECISION,
    icu_patients DOUBLE PRECISION,
    icu_patients_per_million DOUBLE PRECISION,
    hosp_patients DOUBLE PRECISION,
    hosp_patients_per_million DOUBLE PRECISION,
    weekly_icu_admissions DOUBLE PRECISION,
    weekly_icu_admissions_per_million DOUBLE PRECISION,
    weekly_hosp_admissions DOUBLE PRECISION,
    weekly_hosp_admissions_per_million DOUBLE PRECISION
);

select * from covid_deaths
order by 3,4


CREATE TABLE covid_vaccinations (
    iso_code TEXT,
    continent TEXT,
    location TEXT,
    date DATE,
    new_tests DOUBLE PRECISION,
    total_tests DOUBLE PRECISION,
    total_tests_per_thousand DOUBLE PRECISION,
    new_tests_per_thousand DOUBLE PRECISION,
    new_tests_smoothed DOUBLE PRECISION,
    new_tests_smoothed_per_thousand DOUBLE PRECISION,
    positive_rate DOUBLE PRECISION,
    tests_per_case DOUBLE PRECISION,
    tests_units TEXT,
    total_vaccinations DOUBLE PRECISION,
    people_vaccinated DOUBLE PRECISION,
    people_fully_vaccinated DOUBLE PRECISION,
    new_vaccinations DOUBLE PRECISION,
    new_vaccinations_smoothed DOUBLE PRECISION,
    total_vaccinations_per_hundred DOUBLE PRECISION,
    people_vaccinated_per_hundred DOUBLE PRECISION,
    people_fully_vaccinated_per_hundred DOUBLE PRECISION,
    new_vaccinations_smoothed_per_million DOUBLE PRECISION,
    stringency_index DOUBLE PRECISION,
    population_density DOUBLE PRECISION,
    median_age DOUBLE PRECISION,
    aged_65_older DOUBLE PRECISION,
    aged_70_older DOUBLE PRECISION,
    gdp_per_capita DOUBLE PRECISION,
    extreme_poverty DOUBLE PRECISION,
    cardiovasc_death_rate DOUBLE PRECISION,
    diabetes_prevalence DOUBLE PRECISION,
    female_smokers DOUBLE PRECISION,
    male_smokers DOUBLE PRECISION,
    handwashing_facilities DOUBLE PRECISION,
    hospital_beds_per_thousand DOUBLE PRECISION,
    life_expectancy DOUBLE PRECISION,
    human_development_index DOUBLE PRECISION
);

select * from covid_vaccinations
order by 3,4



select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2


--looking for total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths
where location = 'India'
order by 1,2

-- percentage of population infected
select  location,date,
    population,
    total_cases,
    (total_cases/population)*100 AS Percent_Population_Infected
	from covid_deaths 
	where location = 'India'
	order by 2;

-- countries with Highest infection rate 
select location,
max(total_cases) as Highest_infection,
max((total_cases/population))*100 AS Percent_Population_Infected
from covid_deaths
WHERE total_deaths IS NOT NULL
AND population IS NOT NULL
group by location
order by Percent_Population_Infected DESC;


--Death Count by Continent
select location,
max(total_deaths) as TotalDeaths
from covid_deaths 
where  continent is not null and 
total_deaths is not null
group by location
order by TotalDeaths DESC


--Daily Global Numbers

SELECT
    date,
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


--Global Numbers
SELECT
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL;


--Join Deaths and Vaccinations
SELECT *
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location=v.location
AND d.date=v.date;


-- Rolling Vaccinations 
select d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
sum(new_vaccinations) over (partition by d.location
order by d.date, d.date) as RollingVaccination
from covid_deaths d
JOIN covid_vaccinations v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent IS NOT NULL;




--Percentage Vaccinated
WITH PopvsVac AS
(
SELECT
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(v.new_vaccinations)
OVER
(PARTITION BY d.location ORDER BY d.date)
AS RollingPeopleVaccinated
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location=v.location
AND d.date=v.date
)

SELECT *,
(RollingPeopleVaccinated/population)*100
AS VaccinatedPercent
FROM PopvsVac;


--Top 10 Vaccinated Countries
SELECT
location,
MAX(total_vaccinations) AS Vaccinations
FROM covid_vaccinations
GROUP BY location
ORDER BY Vaccinations DESC
LIMIT 10;


--Countries with Lowest Vaccination
SELECT
location,
MAX(total_vaccinations) AS Vaccinations
FROM covid_vaccinations
GROUP BY location
ORDER BY Vaccinations
LIMIT 10;
13. Average Stringency Index
SELECT
location,
AVG(stringency_index)
FROM covid_vaccinations
GROUP BY location
ORDER BY AVG(stringency_index) DESC;

--Highest GDP vs Vaccination
SELECT
location,
gdp_per_capita,
MAX(total_vaccinations)
FROM covid_vaccinations
GROUP BY location,gdp_per_capita
ORDER BY gdp_per_capita DESC;

---Life Expectancy vs Death Rate
SELECT
d.location,
v.life_expectancy,
MAX(d.total_deaths)
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location=v.location
GROUP BY d.location,v.life_expectancy
ORDER BY life_expectancy DESC;




---Create a View
CREATE VIEW PercentPopulationVaccinated AS

SELECT
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(v.new_vaccinations)
OVER(PARTITION BY d.location ORDER BY d.date)
AS RollingPeopleVaccinated
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location=v.location
AND d.date=v.date;
