WITH CarStats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
MinAvgPositions AS (
    SELECT
        car_class,
        MIN(average_position) AS min_avg_position
    FROM CarStats
    GROUP BY car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count
FROM CarStats cs
JOIN MinAvgPositions m ON cs.car_class = m.car_class AND cs.average_position = m.min_avg_position
ORDER BY cs.average_position;