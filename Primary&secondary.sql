CREATE TABLE t_zdenek_brabec_project_SQL_primary_final AS
WITH
-- výběr mzdových dat
salary_raw AS (
    SELECT
        payroll_year AS "year",
        industry_branch_code,
        value
    FROM czechia_payroll
    WHERE value IS NOT NULL
      AND value_type_code = 5958
),
-- přiřazení odvětví a výpočet průměrné mzdy
salary AS (
    SELECT
        sr."year",
        ib.name AS industry_name,
        AVG(sr.value) AS average_salary
    FROM salary_raw sr
    LEFT JOIN czechia_payroll_industry_branch ib
        ON sr.industry_branch_code = ib.code
    GROUP BY sr."year", ib.name
),
-- výpočet průměrné roční ceny potravin
food_prices AS (
    SELECT
        EXTRACT(YEAR FROM pr.date_from)::int AS "year",
        fc.name AS food_category_name,
        fc.price_unit AS price_unit,
        AVG(pr.value) AS average_price
    FROM czechia_price pr
    JOIN czechia_price_category fc
        ON pr.category_code = fc.code
    WHERE pr.value IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM pr.date_from), fc.name, fc.price_unit
)
-- spojení mezd a cen
SELECT
    s."year",
    s.industry_name,
    s.average_salary,
    fp.food_category_name,
    fp.average_price,
    fp.price_unit
FROM salary s
INNER JOIN food_prices fp
    ON s."year" = fp."year"
ORDER BY s."year", s.industry_name, fp.food_category_name;

-- Vytvoření sekundární tabulky:
CREATE TABLE t_zdenek_brabec_project_SQL_secondary_final AS
SELECT
    c.country,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM countries c
LEFT JOIN economies e
    ON c.country = e.country
WHERE c.region_in_world ILIKE '%Europe%'
  AND e.year BETWEEN 2006 AND 2018
ORDER BY c.country, e.year;