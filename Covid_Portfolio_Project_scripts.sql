SELECT * FROM covdeth 
WHERE continent <> ''  -- HERE "is not null" is not working with this data as there are no null values all empty values
ORDER BY 3,4;

SELECT * FROM covdeth 
WHERE continent = '' -- HERE "is null" is not working with this data as there are no null values all empty values
ORDER BY 3,4;

SELECT COUNT(iso_code) FROM covdeth;

SELECT * FROM covax
ORDER BY 3,4;

SELECT COUNT(iso_code) FROM covax;

-- select data that we are using

SELECT Location, covdeth.date, total_cases, new_cases, total_deaths, population
FROM covdeth
order by 1,2;

-- looking at total cases vs total deaths
-- shows the likelihood of dying if you get covid in your country

SELECT Location, covdeth.date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercent
FROM covdeth
WHERE Location like '%india%'
ORDER BY 1,2;

-- looking at Total Caes vs Population
-- shows what percentage of population got covid
SELECT Location, covdeth.date, total_cases, Population, (total_cases/Population) *100 AS Population_Percent_Infected
FROM covdeth
WHERE Location like '%india%'
ORDER BY Population_Percent_Infected DESC;

-- looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/Population) *100 AS Population_Percent_Infected
FROM covdeth
-- WHERE Location like '%united%'
GROUP BY Location, Population
ORDER BY Population_Percent_Infected DESC;



-- Showing the countries with the highest death count per population
SELECT Location, MAX(cast(total_deaths AS UNSIGNED)) AS Total_DeathCount
FROM covdeth
GROUP BY Location
ORDER BY Total_DeathCount DESC;
-- Result displays world, south america, grouping wrongly so we added continent is not null :

SELECT Location, MAX(cast(total_deaths AS UNSIGNED)) AS Total_DeathCount
FROM covdeth
WHERE continent <> ''
GROUP BY Location
ORDER BY Total_DeathCount DESC;

-- Let's break things down down by continent not null

-- Showing continents with highest death count per population
SELECT location, MAX(cast(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM covdeth
WHERE continent <> ''
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT location, MAX(cast(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM covdeth
WHERE continent = ''
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global Numbers by date

SELECT covdeth.date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercent
FROM covdeth
-- WHERE Location like '%india%'
WHERE continent <> ''
GROUP BY covdeth.date
ORDER BY total_cases,total_deaths;

-- Total count of Global Numbers
SELECT SUM(new_cases) AS total_cases1, SUM(new_deaths) AS total_deaths1, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercent
FROM covdeth
-- WHERE Location like '%india%'
WHERE continent <> '';

-- JOIN Both table 
SELECT * 
FROM covdeth d
JOIN covax v
ON d.location = v.location 
AND d.date = v.date 
;

-- Looking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM covdeth d
JOIN covax v
ON d.location = v.location 
AND d.date = v.date 
WHERE d.continent <> ''
ORDER BY d.location, d.date;

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS PeopleVaccinated -- bcz every time it goes to a new location we need a new rolling count
FROM covdeth d
JOIN covax v
ON d.location = v.location 
AND d.date = v.date 
WHERE d.continent <> ''
ORDER BY d.location, d.date;

-- USE CTE

With PopulationVSVaccination (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS PeopleVaccinated
FROM covdeth d
JOIN covax v
ON d.location = v.location 
AND d.date = v.date 
WHERE d.continent <> ''
-- ORDER BY d.location, d.date
)
SELECT *, (PeopleVaccinated/Population)*100 AS PopulationpercentVaccinated
FROM PopulationVSVaccination;

-- we can also use TEMP TABLE instead of CTE

DROP TABLE if exists PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population text,
New_Vaccinations text,
RollingPeopleVccinated text
); 
describe PercentPopulationVaccinated;

INSERT INTO PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS PeopleVaccinated
FROM covdeth d
JOIN covax v
ON d.location = v.location 
AND d.date = v.date 
WHERE d.continent <> ''
;
SELECT *, (RollingPeopleVccinated/Population)*100 AS PopulationpercentVaccinated
FROM PercentPopulationVaccinated;

-- CREATING VIEWS TO STORE DATA FOR LATER VIZ

Create View PerPopVax as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS PeopleVaccinated
FROM covdeth d
JOIN covax v
ON d.location = v.location 
AND d.date = v.date 
WHERE d.continent <> ''
-- ORDER BY d.location, d.date
;

SELECT * FROM Covid_Deaths.perpopvax;