


------ Modelado de datos ------
select * from clean_furnace_requirements
select * from countries  -- Catalogo de Paises
select * from cities	 -- Catalogo de Ciudades (Referencia foranea con id_country)
select * from categories -- Catalogo de categorias unicas
select * from companies	 -- Catalogo de compañias (Referencia foranea con id_city)
select * from units_of_measure  -- Catalogo de unidades de medida unicas [- id_uom, uom_name -]
select * from items 	 -- Catalogo de items [- id_item, item_name, unit_weight -] (Referencias foraneas con -categories[id_category), units_of_measure[id_uom]-)
select * from company_item_prices  -- Catalogo de precios unicos por empresa y año para cada item (Refrencias foraneas companies[id_company], items[id_item])



------ Limpieza de datos ------

-- Creamos la nueva tabla maestra con los atributos limpios y estandarizados

CREATE TABLE clean_furnace_requirements AS
SELECT 
	"Project ID" AS project_id,
	"Sr No." AS serial_number,
	-- Limpieza de espacios y estandarizacion
	LOWER(TRIM("Item Name")) AS item_name,
	-- Limpieza de espacios invisibles
	LOWER(TRIM("Item Category ")) AS item_category,
	"Quantity" AS quantity,
	LOWER(REPLACE(TRIM("UOM"), '.', '')) AS unit_of_measure,
	-- Limpieza profunda y casteo a numero
	CAST(NULLIF(REPLACE(REPLACE(TRIM("  Rate ($)  "), '$', ''), ',', ''), '-') AS NUMERIC) AS rate_usd,
	CAST(NULLIF(REPLACE(REPLACE(TRIM("  Amount ($)  "), '$', ''), ',', ''), '-') AS NUMERIC) AS amount_usd,
	"Weight (kg)" AS weight_kg,
	-- Correción de errores humanos
	LOWER(TRIM(REPLACE("Month", 'Augest', 'August'))) AS month_name,
	"Year" AS year,
	LOWER("Company Name") AS company_name,
	LOWER("City") AS city,
	LOWER("Country") AS country
FROM raw_furnace_requirements




------ Normalización country y city ------
create table countries (
	id_country serial primary key,
	country_name varchar(50)
);

create table cities (
	id_city serial primary key,
	city_name varchar(50),
	id_country int references countries(id_country)
);

-- Poblar la nueva tabla countries con los datos del master
insert into countries (country_name)
select distinct country
from clean_furnace_requirements;

-- Poblar la nueva tabla cities con los datos del master
insert into cities (city_name, id_country)
select distinct city, id_country
from clean_furnace_requirements

------ Normalizamos company ------
create table companies (
	id_company serial primary key,
	company_name varchar(50),
	id_city int references cities(id_city)
);

-- Poblar la nueva tabla companies con los datos del master
insert into companies (company_name, id_city)
select distinct company_name, id_city
from clean_furnace_requirements;

-- Agregar la nueva columna de referencia para companies en el master
alter table clean_furnace_requirements add column id_company int;

-- Crear regla para indicar la referencia de master[id_company] con companies[id_company] 
alter table clean_furnace_requirements
add constraint fk_master_company
foreign key (id_company) references companies(id_company);

-- Poblar la nueva columna id_company en el master
update clean_furnace_requirements m 
set id_company = c.id_company
from companies c
where m.company_name = c.company_name;

-- Eliminar la columna company_name de la tabla master
alter table clean_furnace_requirements drop column company_name;
-- Eliminar las dos columnas id_country y id_city de la tabla master
alter table clean_furnace_requirements drop column id_country, drop column id_city;
-- Resultan redundantes en el master, ya que el modelo de datos indica que las referencia de ciudad proviene de cities[id_city, id_country], cuya tabla hace referencia con countries[id_country]



------ Normalizar Item_category --------
create table categories(
	id_category serial primary key,
	category_name varchar(100)
);

-- Extraer las categorias unicas de la tabla master
insert into categories (category_name)
select distinct item_category
from clean_furnace_requirements;

-- Crear la nueva columna id_category en la tabla master
alter table clean_furnace_requirements add column id_category int;

-- Actualizamos los nuevos valores de la nueva columna
update clean_furnace_requirements m
set id_category = c.id_category
from categories c
where m.item_category = c.category_name;
-- Eliminamos la columna item_category
alter table clean_furnace_requirements drop column item_category;

------ Normalizamos unit_of_measure ------
create table units_of_measure(
	id_uom serial primary key,
	uom_name varchar(50)
)

-- Extreamos las uom unicas de la tabla master
insert into units_of_measure (uom_name)
select distinct unit_of_measure
from clean_furnace_requirements

-- Creamos la nueva columna en la tabla master
alter table clean_furnace_requirements add column id_uom int;

-- Actualizamos el contenido de la nueva columna
update clean_furnace_requirements m
set id_uom = u.id_uom
from units_of_measure u
where m.unit_of_measure = u.uom_name;

-- Eliminamos la columna unit_of_measure
alter table clean_furnace_requirements drop column unit_of_measure;

------ Normalizamos item_name ------
create table items(
	id_item serial primary key,
	item_name varchar,
	unit_weight numeric,
	id_category int references categories(id_category),
	id_uom int references units_of_measure(id_uom)
);

-- Insertamos los nuevos datos para la tabla, asegurando que cada item sea unico en su clase, categoria y presentacion (uom)

insert into items (item_name, unit_weight, id_category,id_uom)
select item_name, 
	round(max(weight_kg/quantity)::numeric, 2) as unit_weight, 
	id_category, 
	id_uom
from clean_furnace_requirements
group by item_name, id_category, id_uom;

-- Actualizamos la tabla master con las nuevas id para items (aun no se borrara el contenido original)
alter table clean_furnace_requirements 
add column id_item int,
add constraint fk_tabla_items
foreign key (id_item)
references items(id_item);

update clean_furnace_requirements m
set id_item = i.id_item
from items i
where m.item_name = i.item_name;

------ Normalizar precios para cada item por compañia y año ------
create table company_item_prices (
	id_company int references companies(id_company),
	id_item int references items(id_item),
	price_year int not null,
	rate_usd numeric(10, 2),
	constraint pk_company_item_year primary key (id_company, id_item, price_year)
);

-- Poblamos la nueva tabla con los datos de la tabla master
insert into company_item_prices (id_company, id_item, price_year, rate_usd) 
select m.id_company,
	i.id_item,
	"year",
	min(m.rate_usd) as rate_usd
from clean_furnace_requirements m
join items i
	on m.item_name = i.item_name
	and m.id_category = i.id_category
	and m.id_uom = i.id_uom
group by m.id_company, i.id_item, "year";


-- Eliminamos las columnas redundantes del master
alter table clean_furnace_requirements
drop column item_name,
drop column id_category,
drop column weight_kg,
drop column id_uom;

-- Convertir los meses en formato numerico para cronologias
alter table clean_furnace_requirements
alter column "month" type integer
using extract(month from to_date("month", 'Month'));










	