/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

/* Creating the death table */

CREATE TABLE covid_data_death (
"iso_code" TEXT,
"continent" TEXT,
"location" TEXT,
"date" TEXT,
"population" INT,
"total_cases" FLOAT,
"new_cases" FLOAT,
"new_cases_smoothed" FLOAT,
"total_deaths" FLOAT,
"new_deaths" FLOAT,
"new_deaths_smoothed" FLOAT,
"total_cases_per_million" FLOAT,
"new_cases_per_million" FLOAT,
"new_cases_smoothed_per_million" FLOAT,
"total_deaths_per_million" FLOAT,
"new_deaths_per_million" FLOAT,
"new_deaths_smoothed_per_million" FLOAT,
"reproduction_rate" FLOAT,
"icu_patients" FLOAT,
"icu_patients_per_million" FLOAT,
"hosp_patients" FLOAT,
"hosp_patients_per_million" FLOAT,
"weekly_icu_admissions" FLOAT,
"weekly_icu_admissions_per_million" FLOAT,
"weekly_hosp_admissions" FLOAT,
"weekly_hosp_admissions_per_million" FLOAT
);

COPY covid_data_death FROM 'C:\Program Files\PostgreSQL\datasets\coviddeaths.csv' WITH (FORMAT csv, HEADER true);

ALTER TABLE covid_data_death ALTER COLUMN population TYPE BIGINT;

ALTER TABLE covid_data_death ALTER COLUMN date TYPE TIMESTAMP WITHOUT TIME ZONE USING date::timestamp;

SELECT * FROM covid_data_death;

/* Creating the vaccination table */

CREATE TABLE covid_vacination_data ( 
"iso_code" TEXT, 
"continent" TEXT, 
"location" TEXT, 
"date" TEXT, 
"total_tests" FLOAT, 
"new_tests" FLOAT, 
"total_tests_per_thousand" FLOAT, 
"new_tests_per_thousand" FLOAT, 
"new_tests_smoothed" FLOAT, 
"new_tests_smoothed_per_thousand" FLOAT, 
"positive_rate" FLOAT, 
"tests_per_case" FLOAT, 
"tests_units" TEXT, 
"total_vaccinations" FLOAT, 
"people_vaccinated" FLOAT, 
"people_fully_vaccinated" FLOAT, 
"total_boosters" FLOAT, 
"new_vaccinations" FLOAT, 
"new_vaccinations_smoothed" FLOAT, 
"total_vaccinations_per_hundred" FLOAT, 
"people_vaccinated_per_hundred" FLOAT, 
"people_fully_vaccinated_per_hundred" FLOAT, 
"total_boosters_per_hundred" FLOAT, 
"new_vaccinations_smoothed_per_million" FLOAT, 
"new_people_vaccinated_smoothed" FLOAT, 
"new_people_vaccinated_smoothed_per_hundred" FLOAT, 
"stringency_index" FLOAT, 
"population_density" FLOAT, 
"median_age" FLOAT, 
"aged_65_older" FLOAT, 
"aged_70_older" FLOAT, 
"gdp_per_capita" FLOAT, 
"extreme_poverty" FLOAT, 
"cardiovasc_death_rate" FLOAT, 
"diabetes_prevalence" FLOAT, 
"female_smokers" FLOAT, 
"male_smokers" FLOAT, 
"handwashing_facilities" FLOAT, 
"hospital_beds_per_thousand" FLOAT, 
"life_expectancy" FLOAT, 
"human_development_index" FLOAT, 
"excess_mortality_cumulative_absolute" FLOAT, 
"excess_mortality_cumulative" FLOAT, 
"excess_mortality" FLOAT, 
"excess_mortality_cumulative_per_million" FLOAT );

COPY covid_vacination_data FROM 'C:\Program Files\PostgreSQL\datasets\covidvacination.csv' WITH (FORMAT csv, HEADER true);

ALTER TABLE covid_vacination_data ALTER COLUMN date TYPE TIMESTAMP WITHOUT TIME ZONE USING date::timestamp;

SELECT * FROM covid_vacination_data;

/* Data to analyze */

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM covid_data_death
WHERE continent is not null
ORDER BY 1,2;

/* Analyzing total cases and the percentage of total_death */

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS Death_Percentage
FROM covid_data_death
WHERE continent is not null
ORDER BY 1,2;

/* This query shows the likelihood of dying if you contact covid in nigeria */

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS Death_Percentage
FROM covid_data_death
WHERE location like '%Nigeria%'
and continent is not null
ORDER BY 1,2;

/* Analyzing total cases versus population */
/* This shows the percentage of people with covid */

SELECT location, date, population, total_cases, (total_cases / population) * 100 AS population_Percentage
FROM covid_data_death
WHERE location like '%Nigeria%'
ORDER BY 1,2;

/* countries with higher infection rate compared to population */

SELECT location, population, max(total_cases) AS HighInfectionCount, max((total_cases / population)) * 100 AS population_Percentage_infected
FROM covid_data_death
WHERE continent is not null
GROUP BY location, population
ORDER BY population_percentage_infected DESC;

/* countries with highest death rate per population */

SELECT location, MAX(cast(total_deaths as INT)) AS total_death_count
FROM covid_data_death
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;

/* BREAKING THINGS DOWN BY CONTINENT */

/* Showing contintents with the highest death count per population */

SELECT continent, MAX(cast(total_deaths as INT)) AS total_death_count
FROM covid_data_death
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC;

/* Global Numbers */

SELECT 
    date, 
    SUM(new_cases) AS total_new_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_death_cases, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(New_Cases) * 100 
    END AS global_death_percentage
FROM 
    covid_data_death
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    1,2 DESC;
	
SELECT  
    SUM(new_cases) AS total_new_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_death_cases, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(New_Cases) * 100 
    END AS global_death_percentage
FROM 
    covid_data_death
WHERE 
    continent IS NOT NULL
ORDER BY 
    1,2 DESC;

/* Total Population vs Vacinations */

SELECT * FROM covid_vacination_data;

SELECT * 
FROM covid_data_death AS dea
JOIN covid_vacination_data AS vac
ON dea.location = vac.location
AND dea.date = vac.date;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covid_data_death AS dea
JOIN covid_vacination_data AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevacinated
FROM covid_data_death AS dea
JOIN covid_vacination_data AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


/*  Using CTE to perform Calculation on Partition By in previous query */

WITH PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_data_death AS dea
JOIN covid_vacination_data AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (CAST(RollingPeopleVaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100 AS vaccination_percentage
FROM PopsVac;

/* TEMP TABLE */

-- Step 1: Drop the Temporary Table if it Exists
DROP TABLE IF EXISTS percent_population_vaccinated;

-- Step 2: Create the Temporary Table
CREATE TEMP TABLE percent_population_vaccinated
(
    continent VARCHAR(255),
    location VARCHAR(255),
    date TIMESTAMP,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_people_vaccinated NUMERIC
);

-- Step 3: Insert Data into the Temporary Table
INSERT INTO percent_population_vaccinated (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM 
    covid_data_death AS dea
JOIN 
    covid_vacination_data AS vac
ON 
    dea.location = vac.location
AND 
    dea.date = vac.date;

-- Step 4: Select Data from the Temporary Table and Calculate Vaccination Percentage
SELECT 
    *, 
    (CAST(rolling_people_vaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100 AS vaccination_percentage
FROM 
    percent_population_vaccinated;
	

/* Creating views for visualization */

CREATE VIEW percent_population_vaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM 
    covid_data_death AS dea
JOIN 
    covid_vacination_data AS vac
ON 
    dea.location = vac.location
AND 
    dea.date = vac.date
WHERE dea.continent is not null;

SELECT * FROM percent_population_vaccinated;