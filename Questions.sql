-- Otázka č.1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
WITH annual_payroll AS (
    -- 1. Výpočet průměrné roční mzdy pro každé odvětví.
    SELECT
        "year",
        industry_name,
        AVG(average_salary) AS current_year_pay
    FROM t_zdenek_brabec_project_SQL_primary_final
    GROUP BY
        "year",
        industry_name
)
SELECT
    t_current."year" AS year_of_drop, -- Rok, ve kterém k poklesu došlo
    t_current.industry_name,
    ROUND(t_prev.current_year_pay, 0) AS previous_year_pay_CZK,
    ROUND(t_current.current_year_pay, 0) AS current_year_pay_CZK,
    -- Výpočet percentuální změny
    ROUND(((t_current.current_year_pay - t_prev.current_year_pay) / t_prev.current_year_pay) * 100, 2) AS pay_change_percent
FROM annual_payroll t_current
JOIN annual_payroll t_prev
    -- 2. Spojení s daty z předchozího roku ve stejném odvětví (SELF JOIN).
    ON t_current.industry_name = t_prev.industry_name
    AND t_current."year" = t_prev."year" + 1
WHERE
    -- 3. Filtrace pouze na poklesy mezd.
    t_current.current_year_pay < t_prev.current_year_pay
ORDER BY
    year_of_drop,
    pay_change_percent; -- Řazení podle velikosti poklesu 

-- Závěr: Průměrné mzdy v České republice v letech 2006–2018 nerostly ve všech odvětvích. I když většina odvětví vykazovala růst, docházelo k dočasným poklesům, které silně korelují s makroekonomickými událostmi. Nejvýraznější pokles nastal v roce 2013, kdy zasáhl 11 odvětví. Tento plošný jev je silným důkazem negativního dopadu dluhové krize Eurozóny a navazující domácí recese na český pracovní trh, což vedlo k plošnému snížení mzd.

--Otázka č. 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
    
SELECT DISTINCT name
FROM czechia_price_category
WHERE name ILIKE '%mléko%' OR name ILIKE '%chléb%';
WITH national_averages AS (
    -- agregace průměrné mzdy a cen chleba/mléka pro každý rok.
    SELECT
        "year",
        AVG(average_salary) AS average_national_salary,
        AVG(CASE WHEN food_category_name ILIKE '%Mléko%' THEN average_price END) AS milk_price_CZK,
        AVG(CASE WHEN food_category_name ILIKE '%Chléb%' THEN average_price END) AS bread_price_CZK
    FROM t_zdenek_brabec_project_SQL_primary_final
    GROUP BY "year"
)
-- výpočet nákupní síly pro roky 2006 a 2018.
SELECT
    na."year",
    ROUND(na.average_national_salary::numeric, 0) AS average_national_salary_CZK,
    
    -- Mléko
    ROUND(na.milk_price_CZK::numeric, 2) AS milk_price_CZK,
    FLOOR(na.average_national_salary / na.milk_price_CZK) AS milk_units_purchasable_L,
    
    -- Chléb
    ROUND(na.bread_price_CZK::numeric, 2) AS bread_price_CZK,
    FLOOR(na.average_national_salary / na.bread_price_CZK) AS bread_units_purchasable_Kg
FROM national_averages na
WHERE
    na."year" IN (2006, 2018)
ORDER BY
    na."year";  
    
-- Závěr: Za první sledované období, kterým je rok 2006 bylo možné z průměrné mzdy zakoupit 1 432 l mléka a 1 282 Kg chleba. V posledním období, kterým byl rok 2018 bylo možné zakoupit 1 639 l mléka a 1 340 Kg chleba.   
    
    
-- Otázka č. 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

WITH annual_category_prices AS (
    -- výpočet průměrné roční ceny pro každou kategorii potravin
SELECT
	"year",
	food_category_name,
	AVG(average_price) AS avg_price
FROM t_zdenek_brabec_project_SQL_primary_final
GROUP BY "year", food_category_name
)
SELECT
    t1.food_category_name,
    -- výpočet průměru meziročních nárůstů
    ROUND(
        AVG(
            -- výpočet percentuální změny
            ((t1.avg_price - t2.avg_price) / t2.avg_price)::numeric * 100 
        ),
        2
    ) AS average_annual_increase_percent
FROM annual_category_prices t1
-- spojení s daty z předchozího roku
INNER JOIN annual_category_prices t2
    ON t1.food_category_name = t2.food_category_name 
    AND t1."year" = t2."year" + 1
GROUP BY
    t1.food_category_name
ORDER BY
    average_annual_increase_percent ASC -- Seřazení podle nejnižšího nárůstu.
LIMIT 1; 

-- Závěr: Nejmenší procentuální nárůst v průměru zaznamenala kategorie Cuker krystalový, který zlevnil o -1,92%.

-- druhá varianta pro zodpovězení otázky:
WITH annual_category_prices AS (
    -- výpočet průměrné roční ceny pro každou kategorii potravin.
    SELECT
        "year",
        food_category_name,
        AVG(average_price) AS avg_price
    FROM t_zdenek_brabec_project_SQL_primary_final
    GROUP BY "year", food_category_name
),
average_increase AS (
    -- výpočet průměrné roční percentuální změny pro každou kategorii
    SELECT
        t1.food_category_name,
        ROUND(
            AVG(
                ((t1.avg_price - t2.avg_price) / t2.avg_price)::numeric * 100 
            ),
            2
        ) AS average_annual_increase_percent
    FROM annual_category_prices t1
    INNER JOIN annual_category_prices t2
        ON t1.food_category_name = t2.food_category_name 
        AND t1."year" = t2."year" + 1
    GROUP BY
        t1.food_category_name
)
-- filtrace a výběr kategorie s nejnižším kladným nárůstem
SELECT 
    * FROM average_increase 
WHERE average_annual_increase_percent > 0 
ORDER BY average_annual_increase_percent ASC
LIMIT 1;
-- Závěr: Nejnižši procentuální nárůst (kladný) je kategorie Banány žluté a to o 0,81 %.

--Otázka č.4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
SELECT
    t1."year" AS year_of_comparison,
    -- výpočet růstu ceny a růstu mzdy
    ROUND(
        ((t1.avg_price - t2.avg_price) / t2.avg_price)::numeric * 100, 
        2
    ) AS price_increase_percent, 
    ROUND(
        ((t1.avg_salary - t2.avg_salary) / t2.avg_salary)::numeric * 100, 
        2
    ) AS salary_increase_percent,   
    -- výpočet rozdílu
    (
        ROUND(((t1.avg_price - t2.avg_price) / t2.avg_price)::numeric * 100, 2)
        -
        ROUND(((t1.avg_salary - t2.avg_salary) / t2.avg_salary)::numeric * 100, 2)
    ) AS difference_pp
    
FROM (
	SELECT
        "year",
        AVG(average_salary) AS avg_salary,
        AVG(average_price) AS avg_price
    FROM t_zdenek_brabec_project_SQL_primary_final
    GROUP BY "year"
) t1
-- spojení s daty z předchozího roku
INNER JOIN (
    SELECT
        "year",
        AVG(average_salary) AS avg_salary,
        AVG(average_price) AS avg_price
    FROM t_zdenek_brabec_project_SQL_primary_final
    GROUP BY "year"
) t2
    ON t1."year" = t2."year" + 1 
WHERE
    -- filtrace rozdílu cen a mezd větší než 10 %.
    (
        ROUND(((t1.avg_price - t2.avg_price) / t2.avg_price)::numeric * 100, 2)
        -
        ROUND(((t1.avg_salary - t2.avg_salary) / t2.avg_salary)::numeric * 100, 2)
    ) > 10
ORDER BY
    difference_pp DESC;

-- Závěr: V žádném roce v dostupném obdob nebyl meziroční nárůst průměrných cen potravin výrazně vyšší než růst průměrné mzdy (o více než 10 %).

-- Otázka č. 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH czechia_annual_data AS (
    -- průměrné roční mzdy a ceny pro ČR
    SELECT 
        "year",
        AVG(average_salary) AS avg_salary,
        AVG(average_price) AS avg_price
    FROM t_zdenek_brabec_project_SQL_primary_final
    GROUP BY "year"
    ORDER BY "year"
),
gdp_data AS (
    SELECT
        "year",
        gdp
    FROM t_zdenek_brabec_project_SQL_secondary_final
    WHERE country = 'Czech Republic' OR country = 'Czechia' 
    ORDER BY "year"
)
-- spojení dat HDP se mzdami a cenami
SELECT
    t1."year" AS year_N,
    -- meziroční růst HDP
    ROUND(
        ((t1.gdp - t2.gdp) / t2.gdp)::numeric * 100,
        2
    ) AS gdp_increase_N_percent,
    -- meziroční růst mzdy
    ROUND(
        ((t3.avg_salary - t4.avg_salary) / t4.avg_salary)::numeric * 100,
        2
    ) AS salary_increase_N_plus_1_percent,
    -- meziroční růst cen
    ROUND(
        ((t3.avg_price - t4.avg_price) / t4.avg_price)::numeric * 100,
        2
    ) AS price_increase_N_plus_1_percent
FROM gdp_data t1 
INNER JOIN gdp_data t2 
    ON t1."year" = t2."year" + 1
INNER JOIN czechia_annual_data t3 
    ON t1."year" = t3."year" - 1
INNER JOIN czechia_annual_data t4
    ON t3."year" = t4."year" + 1 
ORDER BY
    year_N ASC;

-- Závěr: 
-- Silný růst HDP se projeví v rychlejším růstu mezd v následujícím roce. Příkladem je rok 2007, kdy HDP vzrostlo o 5,57 %, na což v roce 2008 navázal růst mezd o 7,87 %.
-- Vliv růstu HDP na ceny potravin v následujícím roce je slabý a nekonzistentní. Příkladem je rok 2015, kdy HDP silně vzrostlo o 5,39 %, ale ceny potravin v následujícím roce 2016 klesly o -1,19 %.