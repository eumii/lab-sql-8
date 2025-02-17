USE sakila;

-- Write a query to display for each store its store ID, city, and country.
-- Write a query to display how much business, in dollars, each store brought in.
-- Which film categories are longest?

-- List the top five genres in gross revenue in descending order.
-- Is "Academy Dinosaur" available for rent from Store 1?
-- Get all pairs of actors that worked together.
-- Get all pairs of customers that have rented the same film more than 3 times.
-- For each film, list actor that has acted in more films.

# 1. Write a query to display for each store its store ID, city, and country.

SELECT store.*, city.city, country.country
FROM store
JOIN address
USING(address_id)
JOIN city
USING(city_id)
JOIN country
USING(country_id)
GROUP BY store.store_id;

# 2. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, sum(payment.amount) As "total revenues"
FROM store
JOIN staff
USING(store_id)
JOIN payment
USING(staff_id)
GROUP BY store.store_id;

# 3. Which film categories are longest?

SELECT category.name, avg(film.length) as "length of category"
FROM film
JOIN film_category
USING(film_id)
JOIN category
using(category_id)
GROUP BY film_category.category_id
ORDER BY film.length DESC
LIMIT 20;


# we assume here that taking the average to be sure that the category is the longest one and not one movie only.


-- 4. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.inventory_id) as nb_of_rentals
FROM inventory
JOIN rental
USING(inventory_id)
JOIN film
using(film_id)
GROUP BY film.film_id
ORDER by nb_of_rentals DESC;

-- 5. List the top five genres in gross revenue in descending order.

SELECT category.name, sum(payment.amount) AS gross_revenue
FROM payment
JOIN rental
using(rental_id)
JOIN inventory
USING(inventory_id)
JOIN film_category
USING(film_id)
JOIN category
using(category_id)
GROUP BY category.category_id
ORDER BY gross_revenue DESC
LIMIT 5;

-- 6. Is "Academy Dinosaur" available for rent from Store 1?

SELECT film.title AS "movie", store.store_id AS "store"
FROM inventory
JOIN store
USING(store_id)
JOIN film
using(film_id)
WHERE film.title = "Academy Dinosaur"
GROUP BY film.film_id
;

-- 7. Get all pairs of actors that worked together.

SELECT  a.first_name,a.last_name, fa2.actor_id, fa1.actor_id
FROM film_actor as fa1
JOIN film_actor as fa2
ON (fa1.film_id = fa2.film_id) AND (fa1.actor_id > fa2.actor_id)
JOIN actor as a
ON a.actor_id = fa1.actor_id
ORDER BY fa1.film_id ASC;

# other solutions 

SELECT *
FROM film_actor as fa1
JOIN film_actor as fa2
ON (fa1.film_id = fa2.film_id) AND (fa1.actor_id > fa2.actor_id)
ORDER BY fa1.film_id ASC;

# Final solution
SELECT
CONCAT(a1.first_name, " ", a1.last_name) AS actor_1,
CONCAT(a2.first_name, " ", a2.last_name) AS actor_2,
film.title
FROM film_actor AS fa1
JOIN
    film_actor AS fa2 ON (fa1.film_id = fa2.film_id)
        AND (fa1.actor_id > fa2.actor_id)
        JOIN
    actor a1 ON (fa1.actor_id = a1.actor_id)
        JOIN
    actor a2 ON (fa2.actor_id = a2.actor_id)
    join film on (fa1.film_id = film.film_id)
ORDER BY fa1.film_id ASC;





-- 8. Get all pairs of customers that have rented the same film more than 3 times.


CREATE TEMPORARY TABLE t1 AS (
SELECT i.film_id, r.rental_id, r.customer_id, r.inventory_id
FROM rental r
JOIN inventory i
USING(inventory_id));
CREATE TEMPORARY TABLE t2 AS (
SELECT i.film_id, r.rental_id, r.customer_id, r.inventory_id
FROM rental r
JOIN inventory i
USING(inventory_id));

SELECT count(t1.film_id), t1.customer_id AS customer1, t2.customer_id AS customer2
FROM t1
JOIN t2
ON t1.inventory_id = t2.inventory_id AND t1.customer_id > t2.customer_id
GROUP BY t1.customer_id, t2.customer_id
HAVING count(t1.film_id) > 3;


-- 9. For each film, list actor that has acted in more films.



-- SELECT actor_id FROM actor
-- where actor_id IN
--     (SELECT actor_id FROM film_actor
--     WHERE film_id IN
--     (SELECT film_id FROM film
--     GROUP BY film_id))
-- GROUP BY actor_id;

-- SELECT COUNT(fa.actor_id) AS "number of films performed", a.*
-- FROM film_actor fa
-- JOIN actor a
-- ON fa.actor_id = a.actor_id
-- GROUP BY fa.actor_id
-- ORDER BY COUNT(fa.actor_id) DESC;
-- -- actor who played the most films

-- SELECT actor_id FROM actor
-- where actor_id >
--     (SELECT count(actor_id) AS num_movies FROM film_actor
--     WHERE film_id like
--     (SELECT film_id FROM film
--     GROUP BY film_id)
--     )
-- GROUP BY actor_id;

CREATE TEMPORARY TABLE ta1 AS(
SELECT actor_id, count(film_id) AS acted
FROM film_actor
GROUP BY actor_id
);
CREATE TEMPORARY TABLE ta2 AS(
SELECT fa.film_id, max(ta1.acted) AS max_act
	FROM film_actor fa
	JOIN ta1
	USING(actor_id)
	GROUP BY film_id
	ORDER BY film_id
);

select * from ta1;
select * from ta2;

SELECT f.title, concat(a.first_name, " ",a.last_name) AS most_starred_actor
FROM film_actor
JOIN ta1
USING(actor_id)
JOIN ta2
USING(film_id)
JOIN film f
USING(film_id)
JOIN actor a
USING(actor_id)
WHERE acted = max_act;
