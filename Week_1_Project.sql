WITH Customers AS (
    SELECT 
        c.customer_id AS customer_id, 
        c.first_name AS customer_first_name, 
        c.last_name AS customer_last_name, 
        c.email AS customer_email, 
        TRIM(LOWER(a.customer_city)) AS customer_city, 
        TRIM(LOWER(a.customer_state)) AS customer_state    
    FROM VK_DATA.CUSTOMERS.CUSTOMER_DATA AS c
    INNER JOIN VK_DATA.CUSTOMERS.CUSTOMER_ADDRESS AS a 
        ON c.customer_id = a.customer_id
    ORDER BY c.last_name ASC
),

suppliers AS (
    SELECT
        supplier_id,
        supplier_name,
        LOWER(TRIM(supplier_city)) AS supplier_city,
        LOWER(TRIM(supplier_state)) AS supplier_state
    FROM VK_DATA.SUPPLIERS.SUPPLIER_INFO

),

US_Cities AS (
    SELECT
        LOWER(TRIM(city_name)) AS city_name,
        LOWER(TRIM(state_name)) AS state_name,
        LOWER(TRIM(state_abbr)) as state_abbr,
        lat,
        long,
        geo_location
    FROM VK_DATA.RESOURCES.US_CITIES AS c    
),

eligible_customers AS (
    SELECT
        customer_id,
        customer_first_name,
        customer_last_name,
        customer_email,
        customer_city,
        customer_state,
        US_Cities.lat AS Lat,
        US_Cities.long AS Long
    FROM Customers
    INNER JOIN US_Cities
        ON Customers.customer_city = US_Cities.city_name
        AND Customers.customer_state = US_Cities.state_abbr
),

suppliers_location AS (
	SELECT
        s.*,
        uc.lat AS supplier_lat,
        uc.long AS supplier_long
  FROM suppliers AS s
  INNER JOIN US_Cities AS uc
    ON s.supplier_city = uc.city_name
    AND s.supplier_state = uc.state_abbr

),


calculate_customers_suppliers_distance AS (
    SELECT
        customer_id,
        customer_first_name,
        customer_last_name,
        customer_email,
        supplier_id,
        supplier_name,
        ST_DISTANCE(
            ST_MAKEPOINT(eligible_customers.long, eligible_customers.lat),
            ST_MAKEPOINT(suppliers_location.supplier_long, suppliers_location.supplier_lat)          
            )  / 1000 AS distance_km,
        ST_DISTANCE(
            ST_MAKEPOINT(eligible_customers.long, eligible_customers.lat),
            ST_MAKEPOINT(suppliers_location.supplier_long, suppliers_location.supplier_lat)          
            )  / 1609 AS distance_mi,
            ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY distance_mi) AS row_num
    FROM eligible_customers
    CROSS JOIN suppliers_location
    QUALIFY row_num = 1      
    ORDER BY customer_last_name, customer_first_name
    //LIMIT 50
)


SELECT *
FROM calculate_customers_suppliers_distance;



