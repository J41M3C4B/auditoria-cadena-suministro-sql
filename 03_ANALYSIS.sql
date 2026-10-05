------ Analisis de Riesgo Geografico ------
-- % Dependencia Economica
-- Monto total en USD
-- Estrategia: agrupar el gasto por país, ciudad y año para calcular que porcentaje del presupuesto total representa se detina para cada región


-- Extraer el gasto global por año
with total_gasto_anual as (
	select 
		"year",
		sum(amount_usd) as gasto_global
	from clean_furnace_requirements
	group by "year"
)
select
	m."year" as  anio,
	cou.country_name as pais,
	cit.city_name as ciudad,	-- Granularidad maestra
	sum(m.amount_usd) as gasto_total_pais,
	count(distinct m.id_company) as total_provedores_pais,
	round(sum (m.amount_usd) / t.gasto_global * 100,2) as proc_dependencia_financiera
from clean_furnace_requirements m
join companies com on m.id_company = com.id_company
join cities cit on com.id_city = cit.id_city
join countries cou on cit.id_country = cou.id_country 
join total_gasto_anual t on m."year" = t."year"
group by m.year, cou.country_name, cit.city_name, t.gasto_global
order by m.year desc, gasto_total_pais desc;



------ Analisis Eficiencia Logistica ------

select
	c.category_name as categoria,
	sum(i.unit_weight*quantity) as peso_total_kg,
	sum(amount_usd) as gasto_total,
	round(sum(m.amount_usd)/nullif(sum(m.quantity * i.unit_weight),0), 4) as ratio_kg,
	m."year"
from clean_furnace_requirements m 
join items i on m.id_item = i.id_item
join categories c on i.id_category = c.id_category
join units_of_measure u on i.id_uom = u.id_uom
group by c.category_name, m."year"
order by m."year" desc, sum(m.amount_usd)/nullif(sum(m.quantity * i.unit_weight),0) desc;
select * from clean_furnace_requirements


------ Analisis de Proveedores ------
WITH 
-- 1. Mantenemos a los líderes globales (como los tienes en tu consulta original)
prov_micro_ordenes AS (
    SELECT id_company FROM clean_furnace_requirements
    GROUP BY id_company ORDER BY COUNT(project_id) DESC LIMIT 1
),
prov_volumen AS (
    SELECT id_company FROM clean_furnace_requirements
    GROUP BY id_company ORDER BY AVG(quantity) DESC LIMIT 1
),

-- 3. Catálogo desglosado POR AÑO para el proveedor A
items_prov_micro AS (
    SELECT 
        m.id_company,
        m.id_item,
        m.year,
        ROUND(AVG(m.rate_usd), 2) AS precio_micro
    FROM clean_furnace_requirements m
    WHERE m.id_company = (SELECT id_company FROM prov_micro_ordenes)
    GROUP BY m.id_company, m.id_item, m.year
),

-- 4. Catálogo desglosado POR AÑO para el proveedor B
items_prov_volumen AS (
    SELECT 
        m.id_company,
        m.id_item,
        m.year,
        ROUND(AVG(m.rate_usd), 2) AS precio_volumen
    FROM clean_furnace_requirements m
    WHERE m.id_company = (SELECT id_company FROM prov_volumen)
    GROUP BY m.id_company, m.id_item, m.year
)

-- 5. Cara a cara: comparamos el mismo artículo en el MISMO AÑO
SELECT 
    a.id_item,
    ca.company_name AS prov_micro,
    a.year AS anio_micro,
    a.precio_micro,
    cb.company_name AS prov_volumen,
    b.year AS anio_volumen,
    b.precio_volumen,
    ROUND(a.precio_micro - b.precio_volumen, 2) AS dif_precio_usd
FROM items_prov_micro a
INNER JOIN items_prov_volumen b 
    -- SOLO cruzamos por artículo, quitamos el "AND a.year = b.year"
    ON a.id_item = b.id_item 
JOIN companies ca 
    ON a.id_company = ca.id_company
JOIN companies cb 
    ON b.id_company = cb.id_company
ORDER BY a.id_item, a.year DESC, b.year DESC;



	
	
	
 
 
