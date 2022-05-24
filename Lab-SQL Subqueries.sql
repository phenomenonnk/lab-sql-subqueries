use sakila;

-- 1. 
-- How many copies of the film Hunchback Impossible exist in the inventory system?
select * from sakila.inventory;

select * from sakila.film;

select film_id from sakila.film where title = 'Hunchback Impossible';

select count(film_id) as quantity_of_Hunchback_Impossible from sakila.inventory
where film_id = (
	select film_id from sakila.film where title = 'Hunchback Impossible'
);

-- List all films whose length is longer than the average of all the films.
select * from sakila.film;

select avg(length) from sakila.film;

select film_id, title, length from sakila.film
where length > (
	select avg(length) from sakila.film
)
order by length asc;

-- 3. 
-- Use subqueries to display all actors who appear in the film Alone Trip.
select film_id from sakila.film
where title = 'Alone Trip';

select actor_id from sakila.film_actor
where film_id = (
	select film_id from sakila.film where title = 'Alone Trip'
);

select fa.film_id, fa.actor_id, a.first_name, a.last_name from sakila.film_actor as fa
join actor as a on a.actor_id = fa.actor_id
where film_id = (
	select film_id from sakila.film where title = 'Alone Trip'
)
order by actor_id;

-- 4.
-- Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.
select * from sakila.category;

select category_id from sakila.category
where name = 'family';

select f.film_id, f.title, fc.category_id from sakila.film as f
join film_category as fc on fc.film_id = f.film_id
where category_id = (
	select category_id from sakila.category
	where name = 'family'
);

-- 5. 
-- Get name and email from customers from Canada using subqueries. Do the same with joins.
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys,
-- that will help you get the relevant information.
-- with subqueries
select * from sakila.customer;

select country_id from sakila.country
where country = 'Canada';

select city_id from sakila.city
where country_id = (
	select country_id from sakila.country
	where country = 'Canada'
);

select address_id from sakila.address
where city_id in (
	select city_id from sakila.city
	where country_id = (
		select country_id from sakila.country
		where country = 'Canada'
));

select first_name, last_name, email from sakila.customer
where address_id in (
	select address_id from sakila.address
	where city_id in (
		select city_id from sakila.city
		where country_id = (
			select country_id from sakila.country
			where country = 'Canada'
)));

-- with join
select c.first_name, c.last_name, c.email from sakila.customer as c
join sakila.address as a on c.address_id = a.address_id
join sakila.city as ci on ci.city_id = a.city_id
join sakila.country as co on co.country_id = ci.country_id
where country = 'Canada';

-- 6. 
-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films.
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
select actor_id, count(film_id) as number_of_films from sakila.film_actor
group by actor_id
order by number_of_films desc
limit 1;

select f.title from sakila.film as f
join film_actor as fa on fa.film_id = f.film_id
where actor_id = 107;
-- or
create temporary table sub1 (
	select actor_id, count(film_id) as number_of_films from sakila.film_actor
	group by actor_id
	order by number_of_films desc
	limit 1
);
select title from sakila.film
where film_id in (
	select film_id from sakila.film_actor
    where actor_id = (
		select actor_id from sub1
));

-- 7.
-- Films rented by most profitable customer.
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
create temporary table sub2 (
	select customer_id, sum(amount) as total_amount from sakila.payment
    group by customer_id
    order by total_amount desc
    limit 1
);
select title from sakila.film
where film_id in (
	select film_id from sakila.inventory
    where inventory_id in (
		select inventory_id from sakila.rental
        where  customer_id = (
			select customer_id from sub2
)));
        
-- 8. 
-- Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

create temporary table sub_1 (
	select customer_id, sum(amount) as total_amount from sakila.payment
	group by customer_id
    order by total_amount desc
);

create temporary table sub_2 (
	select customer_id, sum(amount) as total_amount from sakila.payment
	group by customer_id
    order by total_amount desc
);

select customer_id, first_name, last_name from  sakila.customer
where customer_id in (
	select customer_id from sub_1
	where total_amount > (
		select avg(total_amount) from sub_2
	)
	group by customer_id
	order by total_amount desc
);