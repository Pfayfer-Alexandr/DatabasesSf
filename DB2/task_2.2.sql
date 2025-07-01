WITH CarStats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cl.country AS car_country
FROM CarStats cs
JOIN Classes cl ON cs.car_class = cl.class
WHERE cs.average_position = (SELECT MIN(average_position) FROM CarStats)
ORDER BY cs.car_name
LIMIT 1;