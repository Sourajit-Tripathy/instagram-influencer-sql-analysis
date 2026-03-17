-- Instagram Analysis: SQL

-- 1. How many unique post types are found in the 'fact_content' table?

select * from fact_content;

select distinct(post_type) from fact_content ;

-- 2. What are the highest and lowest recorded impressions for each post type?

SELECT 
    post_type,
    MAX(impressions) AS highest_impressions,
    MIN(impressions) AS lowest_impressions
FROM fact_content
GROUP BY post_type
ORDER BY highest_impressions desc;

-- 3.  Filter all the posts that were published on a weekend in the month of March and April 

SELECT 
    fc.*
FROM fact_content fc
JOIN dim_dates dd 
    ON fc.date = dd.date
WHERE dd.weekday_or_weekend = 'Weekend'
AND dd.month_name IN ('March', 'April');

-- 4 Create a report to get the statistics for the account. The final output includes the following fields:
-- • month_name
-- • total_profile_visits
-- • total_new_followers

SELECT 
    dd.month_name,
    SUM(fa.profile_visits) AS total_profile_visits,
    SUM(fa.new_followers) AS total_new_followers
FROM fact_account fa
JOIN dim_dates dd 
    ON fa.date = dd.date
GROUP BY dd.month_name
ORDER BY MIN(fa.date);

-- 5  Write a CTE that calculates the total number of 'likes’ for each
-- 'post_category' during the month of 'July' and subsequently, arrange the
-- 'post_category' values in descending order according to their total likes.

WITH category_likes AS (
    SELECT 
        fc.post_category,
        SUM(fc.likes) AS total_likes
    FROM fact_content fc
    JOIN dim_dates dd
        ON fc.date = dd.date
    WHERE dd.month_name = 'July'
    GROUP BY fc.post_category
)

SELECT 
    post_category,
    total_likes
FROM category_likes
ORDER BY total_likes DESC;

-- 6. Create a report that displays the unique post_category names alongside
-- their respective counts for each month. The output should have three
-- columns:
 -- • month_name
--  • post_category_names
--  • post_category_count

SELECT 
    dd.month_name,
    GROUP_CONCAT(DISTINCT fc.post_category ORDER BY fc.post_category SEPARATOR ',') 
        AS post_category_names,
    COUNT(DISTINCT fc.post_category) AS post_category_count
FROM fact_content fc
JOIN dim_dates dd
    ON fc.date = dd.date
GROUP BY dd.month_name
ORDER BY MIN(fc.date);

-- 7.  What is the percentage breakdown of total reach by post type? 

SELECT 
    post_type,
    SUM(reach) AS total_reach,
    ROUND((SUM(reach) * 100.0 / SUM(SUM(reach)) OVER()),2) AS reach_percentage
FROM fact_content
GROUP BY post_type;

-- 8. Create a report that includes the quarter, total comments, and total saves recorded for each post category.

SELECT 
    fc.post_category,
    CASE 
        WHEN dd.month_name IN ('January','February','March') THEN 'Q1'
        WHEN dd.month_name IN ('April','May','June') THEN 'Q2'
        WHEN dd.month_name IN ('July','August','September') THEN 'Q3'
    END AS quarter,
    SUM(fc.comments) AS total_comments,
    SUM(fc.saves) AS total_saves
FROM fact_content fc
JOIN dim_dates dd
    ON fc.date = dd.date
GROUP BY fc.post_category, quarter
ORDER BY fc.post_category, quarter;

-- . List the top three dates in each month with the highest number of new followers. 

SELECT 
    month_name,
    date,
    new_followers
FROM (
    SELECT 
        dd.month_name,
        fa.date,
        fa.new_followers,
        ROW_NUMBER() OVER(
            PARTITION BY dd.month_name 
            ORDER BY fa.new_followers DESC
        ) AS rank_no
    FROM fact_account fa
    JOIN dim_dates dd
        ON fa.date = dd.date
) t
WHERE rank_no <= 3;

-- Create a stored procedure that takes the 'Week_no' as input and generates a report displaying the total shares for each 'Post_type'. T

CALL Get_Total_Shares_By_Week('W1');
