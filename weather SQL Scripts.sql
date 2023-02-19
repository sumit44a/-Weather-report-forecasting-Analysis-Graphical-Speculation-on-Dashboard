Create database Weather_forcast;
use Weather_forcast;

create table WeatherData(
id INT AUTO_INCREMENT PRIMARY KEY,
`Date` Date,
temperature_F	decimal,
Average_humidity_pc	int,
Average_dewpoint_F decimal,
Average_barometer_in	decimal,
Average_windspeed_mph	decimal,
Average_gustspeed_mph	decimal,
Average_direction_deg	decimal,
Rainfall_for_month_in	decimal,
Rainfall_for_year_in	decimal,
Maximum_temperature_F	decimal,
Minimum_temperature_F	decimal,
Maximum_humidity_pc	decimal,
Minimum_humidity_pc	decimal,
Maximum_pressure	decimal,
Minimum_pressure	decimal,
Maximum_windspeed_mph	decimal,
Maximum_gust_speed_mph	decimal,
Maximum_heat_index_F	decimal
);

LOAD DATA INFILE "D:\Weatherdata2.csv"
INTO TABLE WeatherData
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

select * from WeatherData;


##Question 1.	Give the count of the minimum number of days for the time when temperature reduced 

SELECT COUNT(*) as minimum_days
FROM (
  SELECT date, temperature_F,
         (@temp_diff := temperature_F - @prev_temp) AS temp_diff,
         (@prev_temp := temperature_F)
  FROM WeatherData, (SELECT @prev_temp := 0) vars
  ORDER BY date
) t
WHERE temp_diff < 0;

##Question 2.	Find the temperature as Cold / hot by using the case and avg of values of the given data set

------------#1-------------
SELECT Date, temperature_F,
       CASE WHEN temperature_F < 50 THEN 'COLD'
            WHEN temperature_F > 50 AND (temperature_F) <= 80 THEN 'Moderate' 
            ELSE 'Hot' END AS temperature_status
FROM WeatherData;

##Question 3.	Can you check for all 4 consecutive days when the temperature was below 30 Fahrenheit

with w as
        (select *, row_number() over(ORDER BY Date) as Weather_id
          from WeatherData),
      t1 as
         (select Date , temperature_F,
          Row_number() OVER (ORDER BY id) as Rn,
          id - ( Row_number() OVER (ORDER BY id)) as diff
          FROM w
          where temperature_F < 30),
      t2 as 
          (select Date, temperature_F, count(*) over (partition by diff) as No_of_record from t1)
select * from t2
where No_of_record = 4;

##Question 4.	Can you find the maximum number of days for which temperature dropped

SELECT COUNT(*) as Max_days
FROM WeatherData t1
JOIN WeatherData t2
ON t1.date + INTERVAL 1 DAY = t2.date
WHERE t1.temperature_F > t2.temperature_F;

##Question 5.	Can you find the average of average humidity from the dataset 
             #( NOTE: should contain the following clauses: group by, order by, date )

SELECT AVG(Average_humidity_pc), date
FROM WeatherData
GROUP BY date
ORDER BY date;

##Question 6. Use the GROUP BY clause on the Date column and make a query to fetch details for average windspeed ( which is now windspeed done in task 3 )

SELECT Date, AVG(Average_windspeed_mph) AS avg_windspeed
FROM WeatherData
GROUP BY Date;



##Question 8.	If the maximum gust speed increases from 55mph, fetch the details for the next 4 days

WITH gust_data AS (
  SELECT date, Maximum_gust_speed_mph,
         (@gust_diff := Maximum_gust_speed_mph - @prev_gust) AS gust_diff,
         (@prev_gust := Maximum_gust_speed_mph)
  FROM WeatherData, (SELECT @prev_gust := 0) vars
  ORDER BY date
)
SELECT date, Maximum_gust_speed_mph
FROM gust_data
WHERE gust_diff > 0 AND Maximum_gust_speed_mph > 55
LIMIT 4;


##Question 9. Find the number of days when the temperature went below 0 degrees Celsius 
SELECT COUNT(*) as days_below_0_C
FROM WeatherData
WHERE temperature_F < 32;

##Question 10.	 Create another table with a “Foreign key” relation with the existing given data set.
CREATE TABLE WeatherStats(
id INT AUTO_INCREMENT,
diff_pressure decimal,
FOREIGN KEY (id) REFERENCES WeatherData(id)
);


select * from WeatherData;
select * from WeatherStats;

desc WeatherStats;
desc WeatherData;
