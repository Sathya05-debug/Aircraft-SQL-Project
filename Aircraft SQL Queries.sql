/* Question 1: Calculate the Average Delay in Departures for Delayed Flights Overall */
SELECT 
    AVG(TIMESTAMPDIFF(MINUTE, scheduled_departure, actual_departure)) AS avg_departure_delay_mins
FROM FLIGHTS
WHERE actual_departure > scheduled_departure; -- Only consider flights that actually departed late


/* Question 2: Count Flights per Aircraft to See Usage Frequency */
SELECT 
    aircraft_code, 
    COUNT(flight_id) AS flight_count
FROM FLIGHTS
GROUP BY aircraft_code
ORDER BY flight_count DESC; -- Sorting to see the most frequently used aircraft first

/* Question 3: Calculate Total Revenue per Flight */
SELECT 
    flight_id, 
    SUM(amount) AS total_revenue
FROM TICKET_FLIGHTS
GROUP BY flight_id
ORDER BY total_revenue DESC; -- Sorting to find the highest revenue-generating flights

/* Question 4: Analyze Boarding Numbers per Flight */
SELECT 
    flight_id,
    AVG(boarding_no) AS avg_boarding_number 
FROM BOARDING_PASSES
GROUP BY flight_id
ORDER BY avg_boarding_number DESC; -- Sorting to check trends in boarding pass allocation

/* Question 5: Determine Occupancy and Fare Conditions per Aircraft */
SELECT s.aircraft_code,s.fare_conditions,count(DISTINCT s.seat_no) AS total_seats,
count(DISTINCT bp.seat_no) AS occupied_seats,
((count(DISTINCT bp.seat_no)/count(DISTINCT s.seat_no))*100) AS occupancy_rate
FROM seats AS s 
LEFT JOIN boarding_passes AS bp
ON s.seat_no=bp.seat_no 
GROUP BY  s.aircraft_code,s.fare_conditions;

/* Question 6: Top 3 Flights by Revenue */
SELECT 
    flight_id,
    SUM(amount) AS Revenue_Per_Flight
FROM ticket_flights 
GROUP BY flight_id
ORDER BY Revenue_Per_Flight DESC
LIMIT 3; -- Only the top 3 flights with the highest revenue

/* Question 7: Average Flight Duration by Aircraft Model */
SELECT 
    a.model, 
    AVG(TIMESTAMPDIFF(MINUTE, f.actual_departure, f.actual_arrival)) AS avg_flight_duration
FROM flights f
JOIN aircrafts a ON f.aircraft_code = a.aircraft_code
GROUP BY a.model
ORDER BY avg_flight_duration DESC; -- Sorting to see the longest average flight durations first

/* Question 8: Flight Count per Airport (Departures and Arrivals) */
SELECT airport_code, 
       SUM(departure_count) AS total_departures, 
       SUM(arrival_count) AS total_arrivals
FROM (
    -- Count departures per airport
    SELECT departure_airport AS airport_code, COUNT(*) AS departure_count, 0 AS arrival_count
    FROM flights GROUP BY departure_airport
    UNION ALL
    -- Count arrivals per airport
    SELECT arrival_airport AS airport_code, 0 AS departure_count, COUNT(*) AS arrival_count
    FROM flights GROUP BY arrival_airport
) AS flight_counts
GROUP BY airport_code 
ORDER BY total_departures + total_arrivals DESC; -- Sorting by total flight activity

/* Question 9: Daily Booking Trends */
SELECT 
    DATE(b.book_date) AS book_date, 
    COUNT(DISTINCT t.ticket_no) AS Booking_Per_Day, 
    SUM(b.total_amount) AS Revenue_Per_Day 
FROM bookings b 
INNER JOIN tickets t ON b.book_ref = t.book_ref 
GROUP BY DATE(b.book_date)
ORDER BY Revenue_Per_Day DESC; -- Sorting by highest revenue days

/* Question 10: Frequent Routes Analysis */
SELECT 
    CONCAT(departure_airport, ' - ', arrival_airport) AS route,
    COUNT(DISTINCT flight_id) AS number_of_flights
FROM flights
GROUP BY route
ORDER BY number_of_flights DESC; -- Sorting to identify the most frequent routes

/* Question 11: Passenger Boarding Summary per Flight */
SELECT 
    flight_id,
    COUNT(ticket_no) AS Passengers_Count
FROM boarding_passes
GROUP BY flight_id
ORDER BY Passengers_Count DESC; -- Sorting by flights with the most passengers

/* Question 12: Average Boarding Number per Flight */
SELECT 
    flight_id,
    AVG(boarding_no) AS Average_Boarding_Number
FROM boarding_passes
GROUP BY flight_id
ORDER BY Average_Boarding_Number DESC; -- Sorting by highest boarding numbers

/* Question 13: Seat Occupancy Rate per Flight */
SELECT f.flight_id,count(DISTINCT s.seat_no) AS total_seats,
count(DISTINCT bp.seat_no) AS occupied_seats,
((count(DISTINCT bp.seat_no)/count(DISTINCT s.seat_no))*100) AS occupancy_rate
FROM seats AS s 
LEFT JOIN boarding_passes AS bp
ON s.seat_no=bp.seat_no 
LEFT JOIN flights AS f
ON  bp.flight_id=f.flight_id
GROUP BY f.flight_id;

/* Question 14: Total Spend per Passenger */
SELECT 
    t.passenger_id, 
    SUM(tf.amount) AS Revenue_Per_Passenger
FROM tickets t
JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
GROUP BY t.passenger_id
ORDER BY Revenue_Per_Passenger DESC; -- Sorting by highest spending passengers

-- Flight Performance Analysis

-- 1. On-time vs. Delayed Flights
SELECT 
    COUNT(CASE WHEN actual_departure > scheduled_departure THEN 1 END) 
    AS delayed_flights,
    COUNT(*) AS total_flights,
 (COUNT(CASE WHEN actual_departure > scheduled_departure THEN 1 END) * 100.0 / COUNT(*))
 AS delay_percentage
FROM flights;

-- 2. Average Delay Time
SELECT 
    departure_airport, 
    AVG(TIMESTAMPDIFF(MINUTE, scheduled_departure, actual_departure)) AS avg_delay_mins
FROM flights
WHERE actual_departure > scheduled_departure
GROUP BY departure_airport
ORDER BY avg_delay_mins DESC;

-- 3. Delay Trends Over Time
SELECT 
    DATE(scheduled_departure) AS flight_date,
    COUNT(flight_id) AS total_flights,
    COUNT(CASE WHEN actual_departure > scheduled_departure THEN 1 END) AS delayed_flights
FROM flights
GROUP BY flight_date
ORDER BY flight_date;

-- Revenue & Financial Analysis

-- 4. Total Revenue per Flight
SELECT 
    flight_id, 
    SUM(amount) AS total_revenue
FROM ticket_flights
GROUP BY flight_id
ORDER BY total_revenue DESC;

-- 5. Revenue Trends Over Time
SELECT 
    DATE(book_date) AS booking_date,
    SUM(total_amount) AS daily_revenue
FROM bookings
GROUP BY booking_date
ORDER BY booking_date;

-- 6. Top Revenue-Generating Routes
SELECT 
    CONCAT(departure_airport, ' - ', arrival_airport) AS route,
    SUM(amount) AS total_revenue
FROM flights f
JOIN ticket_flights tf ON f.flight_id = tf.flight_id
GROUP BY route
ORDER BY total_revenue DESC;

-- Passenger & Booking Analysis

-- 7. Frequent Flyers
SELECT 
    t.passenger_id, 
    COUNT(t.ticket_no) AS total_flights
FROM tickets t
GROUP BY t.passenger_id
ORDER BY total_flights DESC
LIMIT 10;

-- 8. Peak Booking Periods
SELECT 
    DATE(book_date) AS booking_date, 
    COUNT(book_ref) AS total_bookings
FROM bookings
GROUP BY booking_date
ORDER BY total_bookings DESC;

-- Seat Utilization & Occupancy Analysis

-- 9. Seat Occupancy Rate
SELECT 
    f.flight_id, 
    COUNT(DISTINCT s.seat_no) AS total_seats,
    COUNT(DISTINCT bp.seat_no) AS occupied_seats,
    (COUNT(DISTINCT bp.seat_no) * 100.0 / COUNT(DISTINCT s.seat_no)) AS occupancy_rate
FROM seats s
LEFT JOIN boarding_passes bp ON s.seat_no = bp.seat_no
LEFT JOIN flights f ON bp.flight_id = f.flight_id
GROUP BY f.flight_id;

-- Route & Airport Performance

-- 10. Busiest Airports
SELECT 
    airport_code,
    SUM(departure_count) AS total_departures,
    SUM(arrival_count) AS total_arrivals
FROM (
    SELECT departure_airport AS airport_code, COUNT(*) AS departure_count, 0 AS arrival_count FROM flights GROUP BY departure_airport
    UNION ALL
    SELECT arrival_airport AS airport_code, 0 AS departure_count, COUNT(*) AS arrival_count FROM flights GROUP BY arrival_airport
) AS flight_counts
GROUP BY airport_code
ORDER BY total_departures + total_arrivals DESC;

-- 11. Most Popular Routes
SELECT 
    CONCAT(departure_airport, ' - ', arrival_airport) AS route,
    COUNT(flight_id) AS flight_count
FROM flights
GROUP BY route
ORDER BY flight_count DESC;

-- Aircraft Utilization & Maintenance

-- 12. Flight Frequency per Aircraft
SELECT 
    aircraft_code, 
    COUNT(flight_id) AS flight_count
FROM flights
GROUP BY aircraft_code
ORDER BY flight_count DESC;

-- 13. Average Flight Duration per Aircraft
SELECT 
    a.model,
    AVG(TIMESTAMPDIFF(MINUTE, f.actual_departure, f.actual_arrival)) AS avg_flight_duration
FROM flights f
JOIN aircrafts a ON f.aircraft_code = a.aircraft_code
GROUP BY a.model
ORDER BY avg_flight_duration DESC;

-- Passenger Boarding & Check-in Trends

-- 14. Average Boarding Time per Flight
SELECT 
    flight_id,
    AVG(boarding_no) AS avg_boarding_number
FROM boarding_passes
GROUP BY flight_id
ORDER BY avg_boarding_number DESC;

