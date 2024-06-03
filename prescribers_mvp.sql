--1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT SUM(total_claim_count) AS total_claims
	,npi
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC;



--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT SUM(total_claim_count) AS total_claims
	,nppes_provider_first_name
	,nppes_provider_last_org_name
	,specialty_description
FROM prescription
INNER JOIN prescriber 
	USING (npi)
GROUP BY nppes_provider_first_name
	,nppes_provider_last_org_name
	,specialty_description
ORDER BY total_claims DESC;

--2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT SUM(total_claim_count) AS total_claims
	,specialty_description
FROM prescriber 
INNER JOIN prescription 
	USING (npi)
GROUP BY specialty_description
ORDER BY total_claims DESC;



--2b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description
	,SUM(total_claim_count) AS total_opioid_claims
FROM prescriber 
INNER JOIN prescription
	USING(npi)
INNER JOIN drug 
	USING(drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_opioid_claims DESC;

--2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
WITH specialties AS (SELECT specialty_description, npi
FROM prescriber)
SELECT specialty_description, COUNT(drug_name) AS entry_count
FROM specialties
FULL JOIN prescription 
	USING(npi)
GROUP BY specialty_description
ORDER BY entry_count;
--Specialties with an entry_count of 0 have null for every instance of drug_name for that specialty, meaning they have no associated prescriptions.

--2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--3a. Which drug (generic_name) had the highest total drug cost?
SELECT SUM(total_drug_cost) AS highest_total_drug_cost
	,generic_name
FROM prescription INNER JOIN drug USING(drug_name)
GROUP BY generic_name
ORDER BY highest_total_drug_cost DESC;

--3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT ROUND((SUM(total_drug_cost) / SUM(total_day_supply)), 2) AS cost_per_day
	,generic_name
FROM prescription AS p
INNER JOIN drug AS d	
	USING(drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC;


--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 
SELECT DISTINCT drug_name
	,CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		  WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
		  ELSE 'Neither' END AS drug_type
FROM drug;

--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT SUM(total_drug_cost)::money AS total_cost_by_type
	,CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		  WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
		  ELSE 'Neither' END AS drug_type
FROM drug AS d
INNER JOIN prescription AS p
	USING(drug_name)
GROUP BY drug_type
ORDER BY total_cost_by_type DESC;

--5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(DISTINCT cbsa) AS cbsa_in_tn
FROM fips_county
INNER JOIN cbsa
	USING(fipscounty)
WHERE state = 'TN';

--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT SUM(population) AS total_population
	,cbsaname
FROM fips_county
INNER JOIN cbsa
	USING(fipscounty)
INNER JOIN population 
	USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population;

SELECT SUM(population) AS total_population
	,cbsaname
FROM fips_county AS f
INNER JOIN cbsa AS c
	ON c.fipscounty = f.fipscounty
INNER JOIN population AS p
	ON p.fipscounty = f.fipscounty
	AND p.fipscounty = c.fipscounty
GROUP BY cbsaname
ORDER BY total_population;


--5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

--With CTE
WITH pop_no_csba AS (SELECT fipscounty
FROM population
EXCEPT
SELECT fipscounty
FROM cbsa)

SELECT county
	,population
FROM pop_no_csba 
INNER JOIN population
	USING(fipscounty)
INNER JOIN fips_county
	USING(fipscounty)
ORDER BY population DESC;

/*SELECT county
	,population
FROM pop_no_csba AS pc
INNER JOIN population AS p
	USING(fipscounty)
INNER JOIN fips_county AS f
	ON f.fipscounty = pc.fipscounty
	AND f.fipscounty = p.fipscounty
ORDER BY population DESC;*/

--With subquery
SELECT county
	,population
FROM (SELECT fipscounty
	FROM population
	EXCEPT
	SELECT fipscounty
	FROM cbsa)
INNER JOIN fips_county
	USING(fipscounty)
INNER JOIN population
	USING(fipscounty)
ORDER BY population DESC;

--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name
	,total_claim_count
FROM prescription
WHERE total_claim_count > 3000
ORDER BY total_claim_count DESC;

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name
	,total_claim_count
	,CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		  ELSE 'Not an Opioid' END AS is_opioid
FROM prescription
INNER JOIN drug
	USING(drug_name)
WHERE total_claim_count > 3000
ORDER BY total_claim_count DESC;

--6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT nppes_provider_first_name
	,nppes_provider_last_org_name
	,drug_name
	,total_claim_count
	,CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		  ELSE 'Not an Opioid' END AS is_opioid
FROM prescription
INNER JOIN drug
	USING(drug_name)
INNER JOIN prescriber
	USING(npi)
WHERE total_claim_count > 3000
ORDER BY total_claim_count DESC;

--7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT npi
	,drug_name
	,specialty_description
	,nppes_provider_city
	,opioid_drug_flag
FROM prescriber AS p1
CROSS JOIN drug AS d
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';

--7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT p2.npi
	,d.drug_name
	,total_claim_count
FROM prescription AS p1
FULL JOIN drug AS d
	USING(drug_name)
CROSS JOIN prescriber AS p2
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC;
    
--7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT p2.npi
	,d.drug_name
	,COALESCE(total_claim_count, 0) AS total_claims
FROM prescription AS p1
FULL JOIN drug AS d
	USING(drug_name)
CROSS JOIN prescriber AS p2
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY total_claims DESC;