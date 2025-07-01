WITH CustomerStats AS (
    SELECT
        c.ID_customer,
        c.name,
        COUNT(DISTINCT b.ID_booking) AS total_bookings,
        COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
        SUM(r.price * (b.check_out_date - b.check_in_date)) AS total_spent
    FROM
        Customer c
        JOIN Booking b ON c.ID_customer = b.ID_customer
        JOIN Room r ON b.ID_room = r.ID_room
        JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY
        c.ID_customer, c.name
    HAVING
        COUNT(DISTINCT h.ID_hotel) > 1 AND COUNT(DISTINCT b.ID_booking) > 2
),
BigSpenders AS (
    SELECT
        c.ID_customer,
        c.name,
        COUNT(DISTINCT b.ID_booking) AS total_bookings,
        SUM(r.price * (b.check_out_date - b.check_in_date)) AS total_spent
    FROM
        Customer c
        JOIN Booking b ON c.ID_customer = b.ID_customer
        JOIN Room r ON b.ID_room = r.ID_room
    GROUP BY
        c.ID_customer, c.name
    HAVING
        SUM(r.price * (b.check_out_date - b.check_in_date)) > 500
)
SELECT
    cs.ID_customer,
    cs.name,
    cs.total_bookings,
    cs.total_spent,
    cs.unique_hotels
FROM
    CustomerStats cs
    JOIN BigSpenders bs ON cs.ID_customer = bs.ID_customer
ORDER BY
    cs.total_spent ASC;