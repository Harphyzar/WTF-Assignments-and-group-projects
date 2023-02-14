
------------------Covid 19 Data Exploration --------------------------------

---THIS IS TO CHECK THE DATA  TO SEE IF IT IS INTACT

SELECT *
FROM WomenTechsters..CovidDeaths
ORDER BY 3,4

SELECT *
FROM WomenTechsters..CovidVaccinations
ORDER BY 3,4



SELECT location,date,total_cases,new_cases,total_deaths,population
FROM WomenTechsters..CovidDeaths
ORDER BY 1,2


--CHECKING OUT THE TOTAL CASES VS THE TOTAL DEATHS

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as PercentageDeath
FROM WomenTechsters..CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2

-- Percentage of the population that contacted Covid

SELECT location,date,population,total_cases,new_cases,total_deaths,(total_deaths/population)*100 as PercentagePopulationInfected
FROM WomenTechsters..CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2



--Countries  with highest rate of infection compared to the population
 SELECT location,population, MAX(total_cases) AS HighectInfectionCount, MAX(total_deaths/population)*100 as PercentagePopulationInfected
FROM WomenTechsters..CovidDeaths
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC


--Countries with the highest death count per population

 SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM WomenTechsters..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



---Checking by continent with the highest death count per population
 SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM WomenTechsters..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Checking the global number
--number of death
SELECT date, SUM(new_cases), SUM(CAST (NEW_deaths AS INT))
FROM WomenTechsters..CovidDeaths
WHERE continent  IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Death percentage globally
SELECT date, SUM(new_cases)AS total_cases, SUM(CAST (new_deaths AS INT)) AS total_deaths ,SUM(CAST(new_deaths AS INT))/SUM (new_cases) *100 AS DeathPercentage
FROM WomenTechsters..CovidDeaths
WHERE continent  IS NOT NULL
GROUP BY date
ORDER BY 1,2



-- JOINING THE TWO TABLES
SELECT *
FROM WomenTechsters..CovidVaccinations vac
JOIN WomenTechsters..CovidDeaths cdt
	ON cdt.location = vac.location
	AND cdt.date = vac.date

	-- Checking total vacination vs population
	

	SELECT cdt.continent, cdt.location, cdt.date, cdt.population,vac.new_vaccinations
		,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY cdt.Location 
		ORDER BY cdt.location,cdt.Date) 
FROM WomenTechsters..CovidVaccinations vac
JOIN WomenTechsters..CovidDeaths cdt
	ON cdt.location = vac.location
	AND cdt.date = vac.date
WHERE cdt.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cdt.continent, cdt.location, cdt.date, cdt.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by cdt.Location Order by cdt.location, cdt.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From WomenTechsters..CovidDeaths cdt
Join WomenTechsters..CovidVaccinations vac
	On cdt.location = vac.location
	and cdt.date = vac.date
where cdt.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cdt.continent, cdt.location, cdt.date, cdt.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From WomenTechsters..CovidDeaths cdt
Join WomenTechsters..CovidVaccinations vac
	On cdt.location = vac.location
	and cdt.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

