-- Master Raw Table

Select *
From NetflixPortfolioProject..Netflix

-- Cleaning the raw data
-- First Step is to check for duplicates using unique column

With Duplicate(ShowID, Duplicates)
as
(
Select show_id, COUNT(*)
From NetflixPortfolioProject..Netflix
Group by show_id
)
Select *
From Duplicate
Where Duplicates <> 1

-- Check for nulls for each column

Select  COUNT(*) - COUNT(show_id) as ShowIdNulls,
		COUNT(*) - COUNT(type) as TypeNulls,
		COUNT(*) - COUNT(title) as TitleNulls,
		COUNT(*) - COUNT(director) as DirectorNulls,
		COUNT(*) - COUNT(cast) as CastNulls,
		COUNT(*) - COUNT(country) as CountryNulls,
		COUNT(*) - COUNT(date_added) as DateAddedNulls,
		COUNT(*) - COUNT(release_year) as ReleaseYearNulls,
		COUNT(*) - COUNT(rating) as RatingNulls,
		COUNT(*) - COUNT(duration) as DurationNulls,
		COUNT(*) - COUNT(listed_in) as ListedInNulls,
		COUNT(*) - COUNT(description) as DescriptionNulls
From NetflixPortfolioProject..Netflix

-- Update Master Table to Not given for Nulls

Update NetflixPortfolioProject..Netflix
Set director = 'NotGiven'
Where director is null

Update NetflixPortfolioProject..Netflix
Set cast = 'NotGiven'
Where cast is null

Update NetflixPortfolioProject..Netflix
Set country = 'NotGiven'
Where country is null

Update NetflixPortfolioProject..Netflix
Set date_added = 'NotGiven'
Where date_added is null

Update NetflixPortfolioProject..Netflix
Set rating = 'NotGiven'
Where rating is null

Update NetflixPortfolioProject..Netflix
Set duration = 'NotGiven'
Where duration is null

-- Update table with first country only

Select PARSENAME(REPLACE(country, ',', '.'), 1)
From NetflixPortfolioProject..Netflix

Update NetflixPortfolioProject..Netflix
Set country = PARSENAME(REPLACE(country, ',', '.'), 1)

-- Analysis of Netflix Data
-- To categorised type of movie 

Select type, COUNT(show_id) as ShowType
From NetflixPortfolioProject..Netflix
Group by type


-- To categorised type of movie for each country

Select country, type, COUNT(Country) as TotalTypeofShow
From NetflixPortfolioProject..Netflix
Where country is not null 
and country <> 'NotGiven'
Group by country, type
Order by country asc

-- Yearly release of Total Type

Select release_year, type, Count(type) as TotalType
From NetflixPortfolioProject..Netflix
Group by release_year, type
Order by release_year desc

-- Top Movie director with most content on Netflix

With TopMovieDirector(Director, TotalMovie, DirectorRank)
as
(
Select director, count(show_id) as TotalMovie, RANK () OVER (Partition by type Order by count(show_id) desc) as TopDirector
From NetflixPortfolioProject..Netflix
Where director <> 'NotGiven'
  and type = 'Movie'
Group by director, type
)
Select *
From TopMovieDirector
Where DirectorRank <= 5

-- Top TV Show director with most content on Netflix

With TopMovieDirector(Director, TotalMovie, DirectorRank)
as
(
Select director, count(show_id) as TotalMovie, RANK () OVER (Partition by type Order by count(show_id) desc) as TopDirector
From NetflixPortfolioProject..Netflix
Where director <> 'NotGiven'
  and type = 'TV Show'
Group by director, type
)
Select *
From TopMovieDirector
Where DirectorRank <= 5

-- Top 10 Genre in Netflix 

Drop table if exists #TopGenre
Create table #TopGenre
(
Genre nvarchar(255),
TotalGenre int
)

Insert into #TopGenre
Select listed_in, COUNT(show_id) as TotalGenre
From NetflixPortfolioProject..Netflix
Group by listed_in

With TopGenre(Genre, TotalGenre, TopGenre)
as
(
Select Genre, TotalGenre, RANK () OVER (Order by TotalGenre desc) as TopGenre
From #TopGenre
)
Select *
From TopGenre
Where TopGenre <= 10

-- Top 10 Rating in Netflix 

Select rating, count(show_id) as TotalRating
From NetflixPortfolioProject..Netflix
Group by rating
Order by TotalRating desc

Drop table if exists #TopRating
Create table #TopRating
(
Rating nvarchar(255),
TotalRating int
)

Insert into #TopRating
Select rating, COUNT(show_id) as TotalGenre
From NetflixPortfolioProject..Netflix
Group by rating

With TopRating(Rating, TotalRating, TopRating)
as
(
Select Rating, TotalRating, RANK () OVER (Order by TotalRating desc) as TopRating
From #TopRating
)
Select *
From  TopRating
Where TopRating <= 10

-- Yearly Movie Release Content

Select release_year, count(show_id) as TotalRelease
From NetflixPortfolioProject..Netflix
Where release_year >= 2000
	and type = 'Movie'
Group by release_year
Order by release_year desc

-- Yearly TV Show Release Content

Select release_year, count(show_id) as TotalRelease
From NetflixPortfolioProject..Netflix
Where release_year >= 2000
	and type = 'TV Show'
Group by release_year
Order by release_year desc








