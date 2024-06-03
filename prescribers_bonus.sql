--1. How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT COUNT(npi)
FROM(	
SELECT npi
FROM prescriber
EXCEPT
SELECT npi 
FROM prescription);

--2a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice
SELECT generic_name
		,COUNT(npi) AS times_prescribed
FROM prescriber
INNER JOIN prescription AS p
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description ='Family Practice'
GROUP BY generic_name
ORDER BY times_prescribed DESC
LIMIT 5;

--2b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT generic_name
		,COUNT(npi) AS times_prescribed
FROM prescriber
INNER JOIN prescription AS p
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description ='Cardiology'
GROUP BY generic_name
ORDER BY times_prescribed DESC
LIMIT 5;

--2c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question
SELECT generic_name
		,COUNT(npi) AS times_prescribed
FROM prescriber
INNER JOIN prescription AS p
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description ='Family Practice'
GROUP BY generic_name
UNION
SELECT generic_name
		,COUNT(npi) AS times_prescribed
FROM prescriber
INNER JOIN prescription AS p
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description ='Cardiology'
GROUP BY generic_name
ORDER BY times_prescribed DESC
LIMIT 5;

--3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.

--3a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
SELECT npi
	   ,SUM(total_claim_count) AS total_claims
	   ,nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi, nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5;

--3b. Now, report the same for Memphis.
SELECT npi
	   ,SUM(total_claim_count) AS total_claims
	   ,nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi, nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5;

--3c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.
SELECT npi
	   ,SUM(total_claim_count) AS total_claims
	   ,nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi, nppes_provider_city
UNION
SELECT npi
	   ,SUM(total_claim_count) AS total_claims
	   ,nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi, nppes_provider_city
UNION
SELECT npi
	   ,SUM(total_claim_count) AS total_claims
	   ,nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'KNOXVILLE'
GROUP BY npi, nppes_provider_city
UNION
SELECT npi
	   ,SUM(total_claim_count) AS total_claims
	   ,nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING (npi)
WHERE nppes_provider_city = 'CHATTANOOGA'
GROUP BY npi, nppes_provider_city
ORDER BY total_claims DESC
LIMIT 10; --Limited to 10 instead of 5 so we could see the new cities added. 

--4 Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.
SELECT county, overdose_deaths, year
FROM overdose_deaths AS o
INNER JOIN fips_county AS f
ON f.fipscounty::int = o.fipscounty
WHERE o.overdose_deaths > (SELECT AVG(overdose_deaths) FROM overdose_deaths);

--5a. Write a query that finds the total population of Tennessee.
SELECT SUM(population) AS tn_total_pop
FROM population
INNER JOIN fips_county
USING (fipscounty)
WHERE state = 'TN';

--5b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.
SELECT county
	   ,population
	   ,ROUND((population /
(SELECT SUM(population) AS tn_total_pop
FROM population
INNER JOIN fips_county
USING (fipscounty)
WHERE state = 'TN') * 100), 3) AS percentage_tn_pop
FROM fips_county
INNER JOIN population 
USING (fipscounty);

--Making sure percentage adds to 100. 
SELECT ROUND(SUM(percentage_tn_pop), 5)
FROM
(SELECT county
	   ,population
	   ,(population /
(SELECT SUM(population) AS tn_total_pop
FROM population
INNER JOIN fips_county
USING (fipscounty)
WHERE state = 'TN') * 100) AS percentage_tn_pop
FROM fips_county
INNER JOIN population 
USING (fipscounty));










