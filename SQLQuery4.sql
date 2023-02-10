USE PROJECTO

SELECT *
FROM PROJECTO.DBO.coviddeath
ORDER BY 3,4

SELECT *
FROM PROJECTO.DBO.covidvac
ORDER BY 3,4

--SELECT DATA WE ARE GOING TO USE

SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION
FROM PROJECTO.DBO.coviddeath
ORDER BY 1,2

--LOOK AT TOTAL CASES VS TOTAL DEATHS

select location, date, total_cases, total_deaths, cast(total_deaths as decimal)/cast(total_cases as decimal)*100 as deathpercentage
from projecto.dbo.coviddeath
where location like 'canada'
order by 1,2
go

---looking at total cases vs population

select location, date, total_cases, population,cast(total_cases as float)/(population)*100 as casespercent
from projecto.dbo.coviddeath
--where location like 'australia'
order by 1,2
go


--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as highestinfection,Max((cast(total_cases as float)/(population))*100)as percentcases
from projecto.dbo.coviddeath
--where location like 'australia'
group by location, population
order by percentcases desc
go

--show countries with highest deat per population

select location, MAX(cast(total_deaths as float)) as Totaldeaths
from projecto.dbo.coviddeath
--where location like 'australia'
where continent is not null
group by location
order by Totaldeaths desc
go


-- lets break down things down by continent

select continent, MAX(cast(total_deaths as float)) as Totaldeaths
from projecto.dbo.coviddeath
--where location like 'australia'
where continent is not null
group by continent
order by Totaldeaths desc
go

--global numbers

select SUM(cast(new_cases as float)) as newcases ,SUM(cast(new_deaths as float)) as newdeaths , SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as percentnew
from projecto.dbo.coviddeath
--where location like 'canada'
where continent is not null
--group by date
order by 1,2
go

--oking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float))over (partition by dea.location order by dea.location, dea.date) -- rollingpeoplevac,
--ollingpeoplevac/popula
from projecto.dbo.coviddeath dea
join projecto.dbo.covidvac vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use ct
with PopvsVac (continent, location, date, population,new_vaccinations, rollingpeoplevac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
--ollingpeoplevac/population)
from projecto.dbo.coviddeath dea
join projecto.dbo.covidvac vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevac/population)*100
from PopvsVac


--temp table
drop table if exists #percentpopulationvac
create table #percentpopulationvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevac numeric
)

insert into #percentpopulationvac

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
--ollingpeoplevac/population)
from projecto.dbo.coviddeath dea
join projecto.dbo.covidvac vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevac/population)*100
from #percentpopulationvac


--create view to store data for later visualization

create view percentpopulationvac as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
from projecto.dbo.coviddeath dea
join projecto.dbo.covidvac vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvac