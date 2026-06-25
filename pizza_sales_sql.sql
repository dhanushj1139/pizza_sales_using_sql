--Retrieve the total number of orders placed
select count(order_id) as total_orders
from orders

--Calculate the total revenue generated from pizza sales.
select round(sum(p.price*r.quantity),2) as total_pizza_sales
from pizzas p
join order_details r
on p.pizza_id=r.pizza_id

--Identify the highest-priced pizza.
select  top 1 pizza_types.name,p.price
from pizzas p
join pizza_types
on pizza_types.pizza_type_id=p.pizza_type_id
order by p.price desc;

--Identify the most common pizza size ordered.
select top 1 p.size,count(r.order_id) as no_of_orders
from pizzas p
join order_details r
on p.pizza_id=r.pizza_id
group by p.size
order by no_of_orders desc;

--List the top 5 most ordered pizza types along with their quantities.

select top 5 t.pizza_type_id,r.quantity,count(r.order_id) no_of_count
from pizzas p
join order_details r
on p.pizza_id=r.pizza_id
join pizza_types t
on p.pizza_type_id=t.pizza_type_id
group by t.pizza_type_id,r.quantity
order by no_of_count desc;

--Join the necessary tables to find the total quantity of each pizza category ordered.
select t.category,sum(r.quantity) as total_quantity
from pizzas p
join order_details r
on p.pizza_id=r.pizza_id
join pizza_types t
on p.pizza_type_id=t.pizza_type_id
group by t.category

--Determine the distribution of orders by hour of the day.

select datepart(hour,order_time) hour_of_the_day,count(order_id)as distribution_of_orders
from orders
group by datepart(hour,order_time);

--Join relevant tables to find the category-wise distribution of pizzas.

select t.category,count(p.pizza_id) as distribution_of_pizza
from pizzas p
join order_details r
on p.pizza_id=r.pizza_id
join pizza_types t
on p.pizza_type_id=t.pizza_type_id
group by t.category
order by t.category;

--Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(t) pizzas_ordered_per_day
from(
select order_date,count(order_id) t
from orders
group by order_date) a

--Determine the top 3 most ordered pizza types based on revenue.

create view transactions as  --created view
select p.pizza_id pizza_type,r.order_id,(r.quantity * p.price) revenue
from pizzas p
join order_details r
on p.pizza_id=r.pizza_id

select top 3 pizza_type,revenue from transactions
order by revenue desc;

--Calculate the percentage contribution of each pizza type to total revenue.

select t.category,round((sum(r.quantity * p.price)/(select round(sum(r.quantity * p.price),2)
from pizzas p
join order_details r
on p.pizza_id=r.pizza_id)*100),2) as peercentage_of_pizza
from pizzas p
join pizza_types t
on p.pizza_type_id=t.pizza_type_id
join order_details r
on p.pizza_id=r.pizza_id
group by t.category
order by sum(r.quantity * p.price) desc;


-- Analyze the cumulative revenue generated over time.

with cumulative as(select DATEPART(hour,r.order_time) as houre,sum(t.revenue) as total_revenue
from transactions t
join orders r
on t.order_id=r.order_id
group by DATEPART(hour,r.order_time) )

select houre,sum(total_revenue) over(order by houre) as cummulative_revenue
from cumulative

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name
from
(select category,name,revenue,rank() over(partition by category order by revenue desc) as rn
from
(select t.category,t.name,sum(r.quantity * p.price)as revenue
from pizza_types t
join pizzas p
on t.pizza_type_id=p.pizza_type_id
join order_details r
on p.pizza_id=r.pizza_id
group by t.category,t.name) as a)as b
where rn<=3;



