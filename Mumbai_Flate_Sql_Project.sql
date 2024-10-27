DROP TABLE IF EXISTS estate;

CREATE TABLE estate (
    SPID INT PRIMARY KEY,
    PROPERTY_TYPE VARCHAR(255),
    CITY VARCHAR(255),
    BEDROOM_NUM INT,
    AGE INT,
    TOTAL_FLOOR INT,
    CLASS VARCHAR(255),
    PRICE_SQFT INT,
    AREA INT,
    CLASS_LABEL VARCHAR(255),
    SOCIETY_NAME VARCHAR(255),
    LOCALITY_NAME VARCHAR(255),
    FURNISH VARCHAR(255),
    VALUE_IN_CR DECIMAL(10, 2) 
);

--- EDA ---
select * from estate;



-- Easy Queries (10)

-- Que 1 List all properties in a specific city.

SELECT * FROM estate WHERE CITY = 'Mumbai Harbour';

-- Que 2 Find the total number of properties available.

SELECT COUNT(*) AS total_properties FROM estate;

-- Que 3 Retrieve the details of properties with more than 3 bedrooms.

SELECT * FROM estate WHERE BEDROOM_NUM > 3;

-- Que 4  Get the total area of all properties combined.

SELECT SUM(AREA) AS total_area FROM estate;

-- Que 5 Find properties in a specific locality.

SELECT * FROM estate WHERE LOCALITY_NAME = 'Byculla East';

-- Que 6 List the top 5 cities with the most properties.

SELECT CITY, COUNT(*) AS total_properties
FROM estate
GROUP BY CITY
ORDER BY total_properties DESC
LIMIT 5;

-- Que 7 Get the average price per square foot across all properties.

SELECT AVG(PRICE_SQFT) AS avg_price_per_sqft FROM estate;

-- Que 8 Find all properties that are fully furnished.

SELECT * FROM estate WHERE FURNISH = 'Semi-furnished';

-- Que 9 Get the maximum number of floors a building can have.

SELECT MAX(TOTAL_FLOOR) AS max_floors FROM estate;

-- Que 10 Retrieve all properties sorted by age (newest first).

SELECT * FROM estate ORDER BY AGE ASC;

-- Medium Queries (10)

-- Que 11 Find the average property value (in crores) for each city.

SELECT CITY, AVG(VALUE_IN_CR) AS avg_value_in_cr
FROM estate
GROUP BY CITY;

-- Que 12 List properties with prices per square foot higher than the overall average.

SELECT * FROM estate
WHERE PRICE_SQFT > (SELECT AVG(PRICE_SQFT) FROM estate);

-- Que 13 Find properties where the price per sqft is less than ₹10,000 and area is greater than 1,000 sqft.

SELECT * FROM estate
WHERE PRICE_SQFT < 10000 AND AREA > 1000;

-- Que 14 Retrieve the number of properties for each furnishing status.

SELECT FURNISH , COUNT(*) AS num_properties
FROM estate
GROUP BY FURNISH;

-- Que 15 Find the property with the largest area in each city.

SELECT CITY, MAX(AREA) AS max_area
FROM estate
GROUP BY CITY;

-- Que 16 Get the average number of floors per property type.

SELECT PROPERTY_TYPE, AVG(TOTAL_FLOOR) AS avg_floors
FROM estate
GROUP BY PROPERTY_TYPE;

-- Que 17 Find properties with more than 2 bedrooms and less than ₹1 crore value.

SELECT * FROM RealEstateProperties
WHERE BEDROOM_NUM > 2 AND VALUE_IN_CR < 1;

-- Que 18 Retrieve the properties located in the top 3 cities with the highest average value in crores.

SELECT * FROM estate
WHERE CITY IN (
    SELECT CITY FROM estate
    GROUP BY CITY
    ORDER BY AVG(VALUE_IN_CR) DESC
    LIMIT 3
);

-- Using Windows Funcion

WITH CityRank AS (
    SELECT CITY, 
           AVG(VALUE_IN_CR) AS avg_value,
           DENSE_RANK() OVER (ORDER BY AVG(VALUE_IN_CR) DESC) AS city_rank
    FROM estate
    GROUP BY CITY
)
SELECT * 
FROM CityRank
WHERE city_rank <=3


-- Que 19 Find the average price per sqft for fully furnished properties in 'Mumbai'.

SELECT AVG(PRICE_SQFT) AS avg_price_sqft
FROM estate
WHERE CITY = 'Mumbai Harbour' AND FURNISH = 'Semi-furnished';

-- Que 20 Get properties that have both high value (> ₹5 crores) and a large area (> 2000 sqft).

SELECT * FROM estate
WHERE VALUE_IN_CR > 5 AND AREA > 2000;

-- Hard Queries (10)

-- Quee 21 Find the top 3 most expensive properties (based on VALUE_IN_CR) in each city.

WITH PropertyRank AS (
    SELECT CITY,
           
		   DENSE_RANK() OVER (PARTITION BY CITY ORDER BY VALUE_IN_CR DESC) AS property_rank
    FROM estate
)
SELECT * 
FROM PropertyRank
WHERE property_rank <= 3;

--Que 22  Calculate the total value of properties in each city that have more than 4 floors.

SELECT CITY, SUM(VALUE_IN_CR) AS total_value
FROM estate
WHERE TOTAL_FLOOR > 4
GROUP BY CITY
ORDER BY total_value desc;

-- 23 - Get the most common property type in each city.

SELECT CITY, PROPERTY_TYPE, COUNT(*) AS property_count
FROM estate
GROUP BY CITY, PROPERTY_TYPE
ORDER BY CITY, property_count DESC;

-- 24 - Find the cities where the average age of 
----    properties is less than 10 years, and the average value is more than ₹2 crores.

SELECT CITY
FROM RealEstateProperties
GROUP BY CITY
HAVING AVG(AGE) < 10 AND AVG(VALUE_IN_CR) > 2;

-- Que 25 List the properties where the price per sqft is higher than the average price for that city.

SELECT * FROM estate r1
WHERE PRICE_SQFT > (
    SELECT AVG(PRICE_SQFT)
    FROM estate r2
    WHERE r2.CITY = r1.CITY
);

-- Que 26 Identify the properties with the highest price per square foot for each locality.

WITH PricePerSqft AS (
    SELECT *,
          
           ROW_NUMBER() OVER (PARTITION BY LOCALITY_NAME ORDER BY price_sqft DESC) AS rank_per_locality
    FROM estate
)
SELECT * 
FROM PricePerSqft
WHERE rank_per_locality = 1;

-- Que 27 Find the city where the total value of all properties is the highest.

SELECT CITY, SUM(VALUE_IN_CR) AS total_value
FROM estate
GROUP BY CITY
ORDER BY total_value DESC
LIMIT 1;

-- Que 28 Retrieve properties in societies that have more than 50 properties listed.

SELECT * FROM estate
WHERE SOCIETY_NAME IN (
    SELECT SOCIETY_NAME
    FROM estate
    GROUP BY SOCIETY_NAME
    HAVING COUNT(*) > 50
);

-- Que 29 Calculate the total number of bedrooms in 
-- properties located in 'Mumbai' where the price per sqft is greater than ₹20,000.

SELECT SUM(BEDROOM_NUM) AS total_bedrooms
FROM estate
WHERE CITY = 'Mumbai' AND PRICE_SQFT > 1000;

-- Que 30 List the top 5 most expensive localities (based on the average value in crores) within each city

SELECT CITY, LOCALITY_NAME, AVG(VALUE_IN_CR) AS avg_value
FROM estate
GROUP BY CITY, LOCALITY_NAME
ORDER BY avg_value DESC
LIMIT 5;

--- USing Window Fuction ---
WITH LocalityAverages AS (
    SELECT CITY, 
           LOCALITY_NAME, 
           AVG(VALUE_IN_CR) AS avg_value,
           ROW_NUMBER() OVER (ORDER BY AVG(VALUE_IN_CR) DESC) AS rank
    FROM estate
    GROUP BY CITY, LOCALITY_NAME
)
SELECT CITY, LOCALITY_NAME, avg_value
FROM LocalityAverages
WHERE rank <= 5
ORDER BY avg_value DESC;






