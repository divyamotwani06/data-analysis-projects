
USE swiggy;

-- 1. Select all columns from the restaurant table.
SELECT * FROM restaurants ;

-- 2. Display the names and cities of all restaurants.
SELECT name , city FROM restaurants;

-- 3. Find all restaurants located in Bangalore.
SELECT name FROM restaurants
WHERE city = "Bangalore";

-- 4. List the names and ratings of restaurants with a rating greater than 4.0.
SELECT name, rating FROM restaurants
WHERE rating > "4.0" ;

-- 5. Find restaurants where the cost is less than or equal to 300.
SELECT name, cost FROM  restaurants
WHERE cost <= "300" ;

-- 6. Display all distinct cuisine types available in the dataset.
SELECT DISTINCT cuisine FROM restaurants ;

-- 7. Find all restaurants serving Biryani cuisine.
SELECT name, cuisine FROM restaurants 
WHERE cuisine = "Biryani" ;

-- 8. Show the top 5 restaurants with the highest ratings.
SELECT name, rating FROM restaurants  
ORDER BY rating DESC
LIMIT 5 ;

-- 2ND HIGHEST
SELECT name , rating FROM restaurants 
ORDER BY rating DESC
LIMIT 1 OFFSET 1;

-- 9. List restaurants with a rating count greater than 1000.
SELECT name , rating_count FROM restaurants
WHERE rating_count > "1000" ;

-- 10. Count the total number of restaurants in the dataset.
SELECT COUNT(*)FROM restaurants ;

-- 11. Find the average cost of all restaurants.
SELECT AVG(cost) AS average_cost
FROM restaurants;

-- 12. Display restaurant names and costs ordered by cost in ascending order.
SELECT name , cost FROM restaurants 
WHERE cost > 49
ORDER BY cost ASC ;

-- 13. Find the average rating of restaurants for each city.
SELECT city , AVG(rating) AS average_rating
FROM restaurants 
GROUP BY city ;

-- 14. Count the number of restaurants available in each city.
SELECT city,
COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY city
ORDER BY restaurant_count DESC; 

-- 15. Find the maximum and minimum cost of restaurants for each cuisine.
SELECT cuisine,
    MAX(cost) AS max_cost,
    MIN(cost) AS min_cost
FROM restaurants
GROUP BY cuisine;

-- 16. List cuisines that have more than 10 restaurants.
SELECT cuisine,
    COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY cuisine
HAVING COUNT(*) > 10;

-- 17. Find the top 3 cities with the highest number of restaurants.
SELECT city,
    COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY city
ORDER BY restaurant_count DESC
LIMIT 3;

-- 18. Display the average cost of restaurants for each cuisine.
SELECT cuisine,
    AVG(cost) AS avg_cost
FROM restaurants
GROUP BY cuisine;

-- 19. Find cities where the average restaurant rating is greater than 4.0.
SELECT city,
    AVG(rating) AS avg_rating
FROM restaurants
GROUP BY city
HAVING AVG(rating) > 4.0;
-- 20. List restaurants whose cost is higher than the average cost of all restaurants.
SELECT
    restaurant_name,
    city,
    cuisine,
    cost
FROM restaurants
WHERE cost > (
    SELECT AVG(cost)
    FROM restaurants );
    
-- 21. Find the total number of ratings (rating_count) for each city.
SELECT city,
    SUM(rating_count) AS total_ratings
FROM restaurants
GROUP BY city;

-- 22. Display cuisines ordered by their average rating in descending order.
SELECT cuisine,
AVG(rating) AS avg_rating
FROM restaurants
GROUP BY cuisine
ORDER BY avg_rating DESC;

-- 23. Find restaurants that have the highest rating within their city.
SELECT name, city, rating
FROM restaurants r
WHERE rating = (
    SELECT MAX(rating)
    FROM restaurants
    WHERE city = r.city
    );

-- 24. List cities that have more than one cuisine type available.
SELECT city,
    COUNT(DISTINCT cuisine) AS cuisine_types
FROM restaurants
GROUP BY city
HAVING COUNT(DISTINCT cuisine) > 1;

-- 25. Find the restaurant(s) with the maximum rating_count in the dataset.
SELECT name, city, cuisine, rating_count
FROM restaurants
WHERE rating_count = ( SELECT MAX(rating_count) FROM restaurants );
