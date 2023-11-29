--Selecting the data what we are using
Select Location,Date,Total_cases,new_cases,total_deaths,population
from ['coviddeaths']
order by 1,2

--Altering the data type of the table
Alter table ['coviddeaths'] alter column total_cases decimal(5,2)
Alter table ['coviddeaths'] alter column total_deaths decimal(5,2)

--Finding the death percentage of all locations
Select location,date,total_cases,total_deaths,(total_deaths/total_cases) *100 as deathrate
from ['coviddeaths']

--Finding the death percentage of specific locations(India,United states)
Select location,date,total_cases,total_deaths,(total_deaths/total_cases) *100 as deathrate
from ['coviddeaths']
where location like '%states%'

Select location,date,total_cases,total_deaths,(total_deaths/total_cases) *100 as deathrate
from ['coviddeaths']
where location = 'India'

--Finding the total cases vs population
Select location,date,population,total_cases,(total_cases/population)*100 as Cases
from ['coviddeaths']

--Finding out the countries with highest infection rate
Select location,population,max(total_cases) as HighestInfected,
       max((total_cases/population))*100 as HighestPercentInfected
from ['coviddeaths']
group by location,population
order by HighestPercentInfected desc

--Selecting countries with highest death count
Select Location, Max(cast(Total_deaths as int)) as Maximumdeaths
from ['coviddeaths']
where continent is not null
group by location
order by Maximumdeaths desc

--Selecting continents with highest death count
Select continent, Max(cast(Total_deaths as int)) as Maximumdeaths
from ['coviddeaths']
where continent is not null
group by continent
order by Maximumdeaths desc

--Finding the total deaths in a particular date

Select Date,Sum(new_deaths) as Totaldeaths
from ['coviddeaths']
group by date
order by date

--Finding the total new cases  in a particular date

Select Date,Sum(new_cases) as Totalcases
from ['coviddeaths']
group by date
order by date

--Finding the death percentage in a particular date
Select Date,Sum(new_cases) as Totalcases,Sum(new_deaths) as Totaldeaths,
       Sum(new_deaths)/Sum(new_cases)*100
       as DeathPercentage
from ['coviddeaths']
where new_cases > 0
Group by Date
Order by 1

--Using Joins
--Finding the number of people vaccinated against total population
Select deaths.continent,deaths.date,
	   deaths.population,vaccine.date,vaccine.new_vaccinations
FROM ['coviddeaths'] as deaths
JOIN ['covidvaccinations'] as vaccine
ON deaths.location = vaccine.location
AND deaths.date = vaccine.date
where deaths.continent is not null
order by 1,2 desc

--Total Population Vs vaccinations using partition by

Select deaths.continent,deaths.location,deaths.date,deaths.population,vaccine.new_vaccinations,
	   Sum(convert(int,vaccine.new_vaccinations)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPplVaccinated
from ['coviddeaths'] as deaths
Join ['covidvaccinations'] as vaccine
on deaths.location =vaccine.location
and deaths.date = vaccine.date
where deaths.continent is not null
order by 2,3

--Using CTE
With PopVsVac (Continent,Location,date,population,new_vaccinations,RollingPplVaccinated)
as
(
Select deaths.continent,deaths.location,deaths.date,deaths.population,vaccine.new_vaccinations,
	   Sum(convert(int,vaccine.new_vaccinations)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPplVaccinated
from ['coviddeaths'] as deaths
Join ['covidvaccinations'] as vaccine
on deaths.location =vaccine.location
and deaths.date = vaccine.date
where deaths.continent is not null
)

Select *,(RollingPplVaccinated/Population)*100
from PopVsVac


--Temp Table
Drop Table if exists #Perpopvaccinated
Create Table #Perpopvaccinated
(
Continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPplVaccinated bigint
)

Insert into #Perpopvaccinated
Select deaths.continent,deaths.location,deaths.date,deaths.population,vaccine.new_vaccinations,
	   Sum(convert(bigint,vaccine.new_vaccinations)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPplVaccinated
from ['coviddeaths'] as deaths
Join ['covidvaccinations'] as vaccine
on deaths.location =vaccine.location
and deaths.date = vaccine.date

Select *,(RollingPplVaccinated/Population)*100
from #Perpopvaccinated

--Creating View

Create View Perpopvaccinated as
Select deaths.continent,deaths.location,deaths.date,deaths.population,vaccine.new_vaccinations,
	   Sum(convert(bigint,vaccine.new_vaccinations)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPplVaccinated
from ['coviddeaths'] as deaths
Join ['covidvaccinations'] as vaccine
on deaths.location =vaccine.location
and deaths.date = vaccine.date










