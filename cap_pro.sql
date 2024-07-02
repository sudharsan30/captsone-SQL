show databases;
use capstone;

select * from amazon ;
describe amazon;

select * from amazon;
 
#Feature Engineering - Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.

alter table amazon
add column timeofday varchar(20);
set sql_safe_updates = 0;
#Updating the timeofday based on the time column

UPDATE amazon
SET timeofday =
    CASE
        WHEN HOUR(time) >= 5 AND HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) >= 12 AND HOUR(time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END
WHERE time IS NOT NULL;
select * from amazon;
#Feature Engineering - Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 

ALTER TABLE amazon
add COLUMN dayweek varchar(10);

#Updating the dayweek based on the date column

update amazon
set dayweek = dayname (date) ;

#Feature Engineering - Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar)

ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(10);

#Updating the monthname

update amazon
set monthname = monthname(date);

select * from amazon;




-- 1.What is the count of distinct cities in the dataset?
  select  count( distinct city )  from amazon;
   -- 3
-- 2.For each branch, what is the corresponding city?
select  branch, City  from amazon group by branch, city order by branch;
-- A	Yangon
-- B	Mandalay
-- C	Naypyitaw

-- 3. What is the count of distinct product lines in the dataset?

select count(distinct`product line`) as no_of_product_lines from amazon; 


-- 4.Which payment method occurs most frequently?

select payment, count(*) from amazon group by payment
limit 1;
    -- Ewallet - 345
    
    
-- 5.Which product line has the highest sales?
SELECT `product line`, round(SUM(total)) AS total_sales
FROM amazon
GROUP BY `product line`
ORDER BY total_sales DESC
;

-- 6.How much revenue is generated each month?

 select `monthname`, sum(total) from amazon group by `monthname`  ;

-- 7. In which month did the cost of goods sold reach its peak?
select * from amazon;
select `monthname`, sum(cogs) from amazon group by `monthname`
limit 1;
  -- January


-- 8.Which product line generated the highest revenue?

select `product line` , sum(total) as revenue from amazon group by `product line`
order by `revenue` desc 
limit 1;
      -- Food & Beverages

-- 9.In which city was the highest revenue recorded?
 select city, sum(total) as revenue from amazon group by city order by revenue desc limit 1;
  -- Naypyitaw 
  
  
  -- 10. Which product line incurred the highest Value Added Tax?
select `product line`, sum(`tax 5%`) as vat from amazon group by `product line` order by vat desc limit 1;
 -- Food & Beverages

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
alter table amazon
 add column remarks varchar (10);
 update amazon 

set remarks = 
   case 
   when total >=
   (select avg(t.total) from (select total from amazon) as t) then 'good'
else 'bad'
 End;
 
 select remarks, count(*) from amazon group by remarks;
 -- good responses	404 
--   bad responses	596
select * from amazon;

-- 12.Identify the branch that exceeded the average number of products sold.
   select branch, sum(quantity) as sum_of_quantity from amazon 
   group by branch having sum_of_quantity 
   > (select avg(quantity) from amazon)
   order by sum_of_quantity desc
   limit 1 ;
     -- Branch A exceeded the average no. of product sold.
     
   -- 13. Which product line is most frequently associated with each gender?
   SELECT gender, `product line`, COUNT(*) AS frequency
FROM amazon 
GROUP BY gender, `product line`
order by frequency desc; 
  -- for female it is Fashion & accessories
  -- for male it is health & beauty
  
-- 14. Calculate the average rating for each product line.

select `product line` , round(avg(rating),2) as average from amazon 
group by `product line` order by average desc;
--  Food and beverages	   7.11
-- Fashion accessories	   7.03
-- Health and beauty	      7
-- Electronic accessories  6.92 
-- Sports and travel	   6.92
-- Home and lifestyle	   6.84

-- 15. Count the sales occurrences for each time of day on every weekday.
 
 select  timeofday , count(dayweek) as dw from amazon 
 group  by timeofday 
 order  by dw desc   ; 
  
 
-- 16.Identify the customer type contributing the highest revenue.

 select `customer type`, count(*) as count , round(sum(total),2) 
 as total from amazon
 group by `customer type`;
 
   --  Member	501	164223.44400000002
   -- Normal	499	158743.30500000005

-- 17.Determine the city with the highest VAT percentage.
 
 select city ,  sum(`Tax 5%`) as vat from amazon 
 group by city order by vat desc; 
    -- Naypyitaw is the city with highest vat percentage 

-- 18. Identify the customer type with the highest VAT payments.
 
 select `customer type`, sum(`tax 5%`) from amazon group by `customer type`;
  -- Member	7820.164000000002
  
  
-- 19. What is the count of distinct customer types in the dataset?
  select * from amazon;
  select count(distinct(`customer type`)) from amazon;
   -- 2

-- 20. What is the count of distinct payment methods in the dataset?
   select count(distinct(payment)) from amazon;
       -- 3
-- 21.Which customer type occurs most frequently?
       select `customer type`, count(`customer type`) from amazon 
       group by `customer type` 
       limit 1;
       -- member customer type appeared 501 times.
       
       
       
-- 22. Identify the customer type with the highest purchase frequency.

 select `customer type`, sum(total) as total from amazon group by `customer type` limit 1 ;

-- 23.Determine the predominant gender among customers.
  select gender , count(gender) from amazon group by gender
  limit 1;
   -- female are predominant among customers.
   
   
-- 24.Examine the distribution of genders within each branch.
select branch, gender , count(*) from
 amazon group by branch , gender order by branch, gender desc;
  
-- 25.Identify the time of day when customers provide the most ratings.

select timeofday , avg(rating) , count(*) as rating from amazon
 group by timeofday order by rating desc;
  --  TIMEOFDAY      AVERAGE RATNG             COUNTS
--    Afternoon	      7.002202643171808 	    454
--    Evening	      6.941408450704226	        355
--    Morning	      6.960732984293193	        191


-- 26. Determine the time of day with the highest customer ratings for each branch.

with rankedtimes as (
select branch, timeofday ,avg(rating) as highest_rating, row_number() over (partition by  branch  order by avg(rating) desc ) as ranking 
from amazon group by branch , timeofday
)
select branch, timeofday, highest_rating from rankedtimes  where ranking = 1;

-- A	Afternoon	7.093670886075955
-- B	Morning	    6.891525423728813
-- C	Evening	    7.113913043478257


--  27.Identify the day of the week with the highest average ratings.

select dayweek, round(avg(rating),2) as avg_rating from amazon 
group by dayweek order by avg_rating desc;

-- Monday	 7.15    - Highest 
-- Wednesday 6.81    - Lowest


-- 28. Determine the day of the week with the highest average ratings for each branch.
   with ranked_day as 
   (
     select branch, dayweek , avg(rating) as average_rating , row_number() over(partition by branch order by avg(rating) desc) as ranking
     from amazon group by branch ,dayweek 
     )
     select branch , dayweek, average_rating from ranked_day where ranking =1 ;
     
     
--     A	Friday	7.3119999999999985
--     B	Monday	7.335897435897434
--     C    Friday	7.278947368421051