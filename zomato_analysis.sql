use zomato_analysis;

create table goldusers_signup(
userid int,
gold_signup_date date);

insert into goldusers_signup
values(1,'2017-09-22'),
(3,'2017-04-21');

--------users tabl----

create table users(
userid int,
signup_date date); 

insert into users
values(2,'2015-01-15'),
(3,'2014-04-11'); 

----------sales tbl-----

create table sales(
userid int, 
created_date date,
product_id int);

insert into sales
values (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2017-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);

-------product tbl---

create table product(
product_id int,
product_name varchar(100),
price int);

insert into product
values (1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from product;
select * from sales;
select * from users;
select * from goldusers_signup;


------what is the total amount each customer spent on zomato?----

select s.userid, sum(p.price) as total_price
from sales as s 
join product as p
on s.product_id= p.product_id
group by s.userid;

------how many days has each customer visited zomato?---
select userid, count(created_date) as visited_count
from sales
group by userid
order by userid; 

---------when was first product purchased by each customer?----
select *
from (select *, rank() over( partition by userid order by created_date) as rank_prdt
from sales)
a where rank_prdt = 1; 


---what is the most purchased item and how  many times was it purchased by all customers?---


 with most_purchased_item as (select product_id, count(product_id) as times from sales
group by product_id)
select s.userid, m.product_id, count(m.product_id)
from sales as s
join most_purchased_item as m 
on s.product_id = m.product_id
where m.product_id = 2
group by s.userid, m.product_id
order by s.userid;


-----which item was most popular for each customer?------
with mst_popular as (select userid, product_id, count(product_id) as count_prdt
from sales 
group by userid, product_id)
select userid, product_id from(select * , rank() over (partition by userid order by count_prdt desc) as rnk
from mst_popular) as c
 where rnk = 1
 group by userid, product_id; 
 
 -------which item was first purchased by the customer after they became a member?-----
 
select * from goldusers_signup;
select * from sales;
  
  
 select * from ( select*, rank() over (partition by userid order by created_date ) as rnk 
  from ( select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales as s
  inner join goldusers_signup as g 
  on s.userid = g.userid and created_date >= gold_signup_date) as t) as a where rnk = 1;
  
  -------which item was purchased just before the customer became a member?------
  select * from goldusers_signup;
select * from sales;
  
 select * from ( select *, rank() over (partition by userid order by created_date desc ) as rnk from (select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales as s
  inner join goldusers_signup as g 
  on s.userid = g.userid and created_date <= gold_signup_date) as t) as g where rnk = 1;

-------what is the total orders and amount spend by each customer before they became a member on each product?-----
select * from goldusers_signup;
select * from sales; 

with cte as (select userid, product_id, sum(cnt) as total_cnt from(select s.userid, s.product_id, s.created_date, (count(s.created_date)) as cnt, g.gold_signup_date
from sales as s
inner join goldusers_signup as g
on s.userid = g.userid and created_date <= gold_signup_date
group by s.userid, s.product_id, s.created_date, g.gold_signup_date) as t
group by userid, product_id)
select c.userid, c.product_id, c.total_cnt, p.price from cte as c 
inner join product as p 
on c.product_id = p.product_id;


------what is the total orders and total amount placed by customer before becoming a member?------
select * from goldusers_signup;
select * from sales; 
select * from product;

    select userid, count(created_date) as total_order, sum(price) as total_amount from (select s.userid, s.created_date, g.gold_signup_date, p.price from sales as s
      inner join goldusers_signup as g
      on s.userid = g.userid and created_date <= gold_signup_date 
      inner join product as p 
      on p.product_id = s.product_id) as t
      group by userid;
      
      
      -------if buying each product generates points for ex 5rs- 2 zomato points and each product has different purchasing points for ex for p1 5rs-2points, for p2 10rs-5points and p3 5rs-1point
   calculate points collected by each customer and for which product most points have been given till now?
select * from product;
select * from sales;
      points collected by each customer---                     
   
   select userid , sum(ceiling(points)) as total_points from(select *, ceiling(points) from (select c.*, case when product_id = 1 then total_price/5*2 
    when product_id = 2 then total_price/10*5
    when product_id = 3 then total_price/5*1
    else 0 end as points from
    (select userid, product_id, sum(price) as total_price from (select s.userid, s.product_id, p.product_name, p.price 
     from sales as s 
     inner join product as p
     on s.product_id = p.product_id) as t
     group by userid, product_id) as c ) as e) as f 
     group by userid; 

product with most points==

select * from (select *, rank() over(order by total_points desc) as rnk from (select product_id , sum(ceiling(points)) as total_points from(select *, ceiling(points) from (select c.*, case when product_id = 1 then total_price/5*2 
    when product_id = 2 then total_price/10*5
    when product_id = 3 then total_price/5*1
    else 0 end as points from
    (select userid, product_id, sum(price) as total_price from (select s.userid, s.product_id, p.product_name, p.price 
     from sales as s 
     inner join product as p
     on s.product_id = p.product_id) as t
     group by userid, product_id) as c ) as e) as f 
     group by product_id) as o) as p
     where rnk= 1; 






 


































































































