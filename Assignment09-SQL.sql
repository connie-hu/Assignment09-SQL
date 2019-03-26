USE sakila


-- 1a. Display the first and last names of all actors from the table `actor`.
select * from actor
select first_name, last_name from actor

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name,' ' ,last_name) as actor_name from actor

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select * from actor
where first_name = 'Joe';

--  2b. Find all actors whose last name contain the letters `GEN`:
select * from actor
where
	last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select * from actor
where
	last_name like '%LI%'
order by last_name asc , first_name asc;


-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select * from country;

select country_id, country from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table sakila.actor
add column description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table sakila.actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name)
from sakila.actor
group by last_name
;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name)
from sakila.actor
group by last_name
having count(last_name) > 1
;
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS'
;

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO' and last_name = 'WILLIAMS'
;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
show create table address

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select s.first_name, s.last_name, a.address
from staff s
join address a
	using(address_id)
;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select s.first_name, s.last_name, sum(p.amount)
from staff s
join payment p
	using(staff_id)
where p.payment_date between '2005-08-01' and '2005-08-31'
group by staff_id
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select fa.film_id, fa.actor_id, f.film_id, f.title, count(f.title) as number_of_actors
from film_actor fa
inner join film f
	using(film_id)
group by title
;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select f.title, count(i.film_id) as inventory_total
from film f
inner join inventory i
	using(film_id)
where title = 'Hunchback Impossible'
;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select p.customer_id, c.last_name, c.first_name, sum(p.amount)
from payment p
join customer c
using(customer_id)
group by p.customer_id
order by last_name asc
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title
from film
where 
	(title like 'K%' or title like'Q%')
and 
	language_id in
(select language_id
from language
where language_id = '1')
;

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name
from actor
where actor_id in
(
select actor_id
from film_actor
where film_id in
(
select film_id
from film
where title = 'Alone Trip'
)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select c.first_name, c.last_name, c.email, ctry.country
from customer c
inner join address a
using(address_id)
inner join city cty
using(city_id)
inner join country ctry
using(country_id)
where ctry.country = 'Canada'
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
select f.title -- , fc.category_id, c.category_id, c.name
from film f
inner join film_category fc
using(film_id)
inner join category c
using(category_id)
where c.name = 'Family'
;

-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(f.title) as total_No_rented
from film f
join inventory
using(film_id)
join rental
using(inventory_id)
group by f.title
order by total_No_rented desc
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, concat('$', format(sum(p.amount),2)) as total_revenue
from store s -- 2
inner join inventory i -- 4581
using(store_id)
inner join rental r -- 16044
using(inventory_id)
join payment p -- 16044
using(rental_id)
group by s.store_id

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, cty.city, ctry.country
from store s
join address a
using(address_id)
join city cty
using(city_id)
join country ctry
using(country_id)
;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select cat.name, sum(p.amount) as gross_revenue
from category cat
join film_category fc
using(category_id)
join inventory i
 using(film_id)
 join rental r
 using(inventory_id)
 join payment p
 using(rental_id)
 group by cat.name
 order by gross_revenue desc
 limit 5
 ;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five as
	select
		cat.name,
		sum(p.amount) as gross_revenue
from 
	category cat
		join film_category fc
			using(category_id)
		join inventory i
			using(film_id)
		join rental r
			using(inventory_id)
		join payment p
			using(rental_id)
 group by cat.name
 order by gross_revenue desc
 limit 5
 ;

-- 8b. How would you display the view that you created in 8a?
select * from top_five;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_five;

