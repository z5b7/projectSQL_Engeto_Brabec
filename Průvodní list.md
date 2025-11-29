Projekt SQL



Autor: Zdeněk Brabec



---



**Data**



**1) Primární tabulka:** t\_zdenek\_brabec\_project\_SQL\_primary\_final

&nbsp;   Obsah: Detailní data o mzdách a cenách potravin v ČR. Roční průměry mezd za celou ekonomiku jsou počítány až dynamicky v analytických dotazech.

**2) Sekundární tabulka:** t\_zdenek\_brabec\_project\_SQL\_secondary\_final

&nbsp;   Obsah: Ekonomické ukazatele (HDP, GINI, populace) pro vybrané evropské země (včetně ČR) v letech 2006–2018.



**Informace ke zpracování dat**



**1. Chybějící hodnoty (NULL)**: Při tvorbě primární tabulky byly odstraněny řádky, kde chyběla hodnota průměrné mzdy. Řádky HDP nutné pro výpočet meziroční změny byly z analýzy automaticky vyloučeny.

**2. Přetypování:** Z důvodu chyby `function round(double precision, integer) does not exist` bylo nutné veškeré výpočty percentuálních změn a poměrů přetypovat na `::numeric` před zaokrouhlením.

**3.** Mzdy jsou analyzovány pouze pro kód `5958` (Průměrná hrubá mzda na přepočteného zaměstnance).

**4.** Společným sledovaným obdobím pro všechny analytické dotazy jsou roky 2006 až 2018



---



**Výzkumné otázky a odpovědi:**



**Otázka č. 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**



Průměrné mzdy v České republice v letech 2006–2018 nerostly ve všech odvětvích. I když většina odvětví vykazovala růst, docházelo k dočasným poklesům, které silně korelují s makroekonomickými událostmi. Nejvýraznější pokles nastal v roce 2013, kdy zasáhl 11 odvětví. Tento plošný jev je silným důkazem negativního dopadu dluhové krize Eurozóny a navazující domácí recese na český pracovní trh, což vedlo k plošnému snížení mzd.



**Otázka č. 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**



Za první sledované období, kterým je rok 2006 bylo možné z průměrné mzdy zakoupit 1 432 l mléka a 1 282 Kg chleba. V posledním období, kterým byl rok 2018 bylo možné zakoupit 1 639 l mléka a 1 340 Kg chleba.



**Otázka č. 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**



Nejnižši procentuální nárůst (kladný) byl v kategorie Banány žluté a to o 0,81 %.



**Otázka č. 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**



V žádném roce v dostupném obdob nebyl meziroční nárůst průměrných cen potravin výrazně vyšší než růst průměrné mzdy (o více než 10 %).



**Otázka č. 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**



A: Silný růst HDP se projeví v rychlejším růstu mezd v následujícím roce. Příkladem je rok 2007, kdy HDP vzrostlo o 5,57 %, na což v roce 2008 navázal růst mezd o 7,87 %.

B: Vliv růstu HDP na ceny potravin v následujícím roce je slabý a nekonzistentní. Příkladem je rok 2015, kdy HDP silně vzrostlo o 5,39 %, ale ceny potravin v následujícím roce 2016 klesly o -1,19 %..



---



Všechny skripty pro vytvoření tabulek a zodpovězení otázek 1-5 jsou k dispozici v souborech Primary\&secondary.sql a Questions.sql

