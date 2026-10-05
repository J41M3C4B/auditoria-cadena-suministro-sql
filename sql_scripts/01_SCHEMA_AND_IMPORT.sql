CREATE TABLE raw_furnace_requirements (
	"Project ID" VARCHAR(50),
	"Sr No." INTEGER,
	"Item Name" VARCHAR(100),
	"Item Category " VARCHAR(50),
	"Quantity" NUMERIC,
	"UOM" VARCHAR(20),
	"  Rate ($)  " VARCHAR(50),
	"  Amount ($)  " VARCHAR(50),
	"Weight (kg)" NUMERIC,
	"Month" VARCHAR(20),
	"Year" INTEGER,
	"Company Name" VARCHAR(50),
	"City" VARCHAR(50),
	"Country" VARCHAR(50)
);

COPY raw_furnace_requirements
FROM 'E:\Proyecto 1\Global Furnace Requirments Dataset.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'LATIN1');