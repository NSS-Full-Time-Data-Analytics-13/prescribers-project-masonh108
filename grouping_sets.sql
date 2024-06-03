--1. 
SELECT specialty_description
	,SUM(total_claim_count)
FROM prescriber
INNER JOIN prescription
	USING(npi)
WHERE specialty_description = 'Interventional Pain Management'
	OR specialty_description = 'Pain Management'
GROUP BY specialty_description;


--2.
SELECT specialty_description
	,SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
	USING(npi)
WHERE specialty_description = 'Interventional Pain Management'
	OR specialty_description = 'Pain Management'
GROUP BY specialty_description
UNION
SELECT 'Combined' AS specialty_description
	,SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
	USING(npi)
WHERE specialty_description = 'Interventional Pain Management'
	OR specialty_description = 'Pain Management'
ORDER BY total_claims DESC;


--3
SELECT specialty_description
	,SUM(total_claim_count)
FROM prescriber
INNER JOIN prescription
	USING(npi)
WHERE specialty_description = 'Interventional Pain Management'
	OR specialty_description = 'Pain Management'
GROUP BY GROUPING SETS(
	(specialty_description),
	()
);

--4
SELECT specialty_description
	,SUM(total_claim_count) AS total_claims
	,opioid_drug_flag
FROM prescriber
INNER JOIN prescription
	USING(npi)
INNER JOIN drug
	USING(drug_name)
WHERE specialty_description = 'Interventional Pain Management'
	OR specialty_description = 'Pain Management'
GROUP BY GROUPING SETS(
	(specialty_description),
	(opioid_drug_flag),
	()
);

--5
SELECT specialty_description
	,SUM(total_claim_count) AS total_claims
	,opioid_drug_flag
FROM prescriber
INNER JOIN prescription
	USING(npi)
INNER JOIN drug
	USING(drug_name)
WHERE specialty_description = 'Interventional Pain Management'
	OR specialty_description = 'Pain Management'
GROUP BY ROLLUP(opioid_drug_flag, specialty_description);

--Each opiod_drug_flag is grouped with every possible combination of specialty_description

--6

SELECT specialty_description
	,SUM(total_claim_count) AS total_claims
	,opioid_drug_flag
FROM prescriber
INNER JOIN prescription
	USING(npi)
INNER JOIN drug
	USING(drug_name)
WHERE specialty_description = 'Interventional Pain Management'
	OR specialty_description = 'Pain Management'
GROUP BY ROLLUP(specialty_description, opioid_drug_flag);

--Each specialty_description is grouped with every possible opiod_drug_flag

--7
SELECT specialty_description
	,SUM(total_claim_count) AS total_claims
	,opioid_drug_flag
FROM prescriber
INNER JOIN prescription
	USING(npi)
INNER JOIN drug
	USING(drug_name)
WHERE specialty_description = 'Interventional Pain Management'
	OR specialty_description = 'Pain Management'
GROUP BY CUBE(specialty_description, opioid_drug_flag);

--CUBE seems to do both combinations of ROLLUP

--8

WITH categorized AS(SELECT nppes_provider_city
	,total_claim_count
	,CASE WHEN generic_name ILIKE '%codeine%' THEN 'codeine'
		  WHEN generic_name ILIKE '%fentanyl%' THEN 'fentanyl'
		  WHEN generic_name ILIKE '%hydrocodone%' THEN 'hydrocodone'
		  WHEN generic_name ILIKE '%morphine%' THEN 'morphine'
		  WHEN generic_name ILIKE '%oxycodone' THEN 'oxycodone'
		  WHEN generic_name ILIKE '%oxymorphone%' THEN 'oxymorphone'
		  ELSE 'NA' END AS drug_category
FROM drug
INNER JOIN prescription
	USING(drug_name)
INNER JOIN prescriber
	USING(npi))
SELECT *
FROM crosstab('SELECT nppes_provider_city
	,drug_category
	,SUM(total_claim_count) AS total_claims
	FROM categorized') AS table1(nppes_provider_city text, drug_category text, total_claims int)

SELECT *
FROM crosstab('SELECT nppes_provider_city
	,CASE WHEN generic_name ILIKE ''%codeine%'' THEN ''codeine'' 
	 WHEN generic_name ILIKE ''%fentanyl%'' THEN ''fentanyl'' 
	 WHEN generic_name ILIKE ''%hydrocodone%'' THEN ''hydrocodone'' 
	 WHEN generic_name ILIKE ''%morphine%'' THEN ''morphine'' 
	 WHEN generic_name ILIKE ''%oxycodone'' THEN ''oxycodone'' 
	 WHEN generic_name ILIKE ''%oxymorphone%'' THEN ''oxymorphone'' END AS drug_category
	,SUM(total_claim_count) AS total_claims
FROM drug
INNER JOIN prescription
	USING(drug_name)
INNER JOIN prescriber
	USING(npi)
WHERE nppes_provider_city ILIKE ''CHATTANOOGA''
	OR nppes_provider_city ILIKE ''KNOXVILLE''
	OR nppes_provider_city ILIKE ''MEMPHIS''
	OR nppes_provider_city ILIKE ''NASHVILLE''
GROUP BY nppes_provider_city, generic_name
')
AS womp(nppes_provider_city int, drug_category int)


SELECT *
FROM prescriber


