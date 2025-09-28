-- DATA CLEANING AND EDA ON LAPTOP DATASET
-- ---------------------------------------------------------------------


SELECT * FROM project2.laptopdata;

-- Creating backup of dataset before data cleaning

CREATE TABLE laptopdata_backup LIKE project2.laptopdata;

INSERT INTO laptopdata_backup
SELECT * FROM project2.laptopdata;

-- number of records
SELECT COUNT(*) FROM project2.laptopdata;  -- 1272

-- checking memory consumption of the table
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = "project2"
AND TABLE_NAME = "laptopdata";  -- 256 kB

-- if any, droping all those records where a record has all null values

DELETE FROM project2.laptopdata
WHERE `s_no` IN (
    SELECT `s_no` 
    FROM project2.laptopdata_backup
    WHERE `Company` IS NULL 
      AND `TypeName` IS NULL 
      AND `Inches` IS NULL 
      AND `ScreenResolution` IS NULL 
      AND `Cpu` IS NULL 
      AND `Ram` IS NULL 
      AND `Memory` IS NULL 
      AND `Gpu` IS NULL 
      AND `OpSys` IS NULL 
      AND `Weight` IS NULL 
      AND `Price` IS NULL
);

-- Droping Duplicates

DELETE FROM project2.laptopdata
WHERE `s_no` NOT IN
				(SELECT MIN(`s_no`)
				 FROM project2.laptopdata_backup
				 GROUP BY `Company`, `TypeName`, `Inches`, 
					       `ScreenResolution`, `Cpu`, `Ram`, 
                           `Memory`,`Gpu`, `OpSys`, `Weight`, `Price`);



-- Performing data cleaning 

DESCRIBE project2.laptopdata;

	-- `Company` column:
    
SELECT DISTINCT Company FROM project2.laptopdata;

	-- `TypeName` column:

SELECT DISTINCT TypeName FROM project2.laptopdata;

	-- `Inches` column:
		-- change datatype from text to float
    
SELECT DISTINCT Inches FROM project2.laptopdata;

ALTER TABLE project2.laptopdata
MODIFY COLUMN Inches DECIMAL(10,1);

	-- `Ram` column:
		-- remove "GB"
        -- change datatype from text to int
        -- rename column from Ram to Ram(Gb)
        
SELECT DISTINCT Ram FROM project2.laptopdata;

UPDATE project2.laptopdata
SET Ram = REPLACE(Ram, "GB", "");

ALTER TABLE project2.laptopdata
CHANGE COLUMN Ram `Ram(Gb)` INT;

	-- `Weight` column:
		-- at s_no 349 weight is 0.0002 kg (inaccurate data)
        -- at s_no 208 weight is "?" (invalid data)
        -- remove "kg" 
        -- change datatype from text to int
        -- rename column from Weight to Weight(kg)

SELECT DISTINCT Weight FROM project2.laptopdata order by weight;

UPDATE project2.laptopdata
SET Weight = REPLACE(Weight , "kg", "");

UPDATE project2.laptopdata
SET Weight = 1.22          -- checked from internet
WHERE `s_no` = 208;

UPDATE project2.laptopdata
SET Weight = 2.2          -- checked from internet
WHERE `s_no` = 349;

ALTER TABLE project2.laptopdata
CHANGE Weight `Weight(kg)` FLOAT;


	-- `Price` column:
		-- round off price column

UPDATE project2.laptopdata
SET Price = ROUND(Price);


	-- `OpSys` column:
		-- categorize in [ mac , windows , linux , no OS , others]

select distinct OpSys from laptopdata;

UPDATE project2.laptopdata
SET OpSys = CASE
    WHEN LOWER(OpSys) LIKE '%mac%' THEN 'macos'
    WHEN LOWER(OpSys) LIKE 'windows%' THEN 'windows'
    WHEN LOWER(OpSys) LIKE '%linux%' THEN 'linux'
    WHEN LOWER(OpSys) = 'N/A' THEN 'no OS'
    ELSE 'other'
END;


	-- `Gpu` column:
		-- we can extract two peice of information out of it
			-- Gpu brand column
            -- Gpu name column
		-- drop Gpu column

Select distinct gpu from laptopdata;

ALTER TABLE project2.laptopdata
ADD COLUMN gpu_brand VARCHAR(255) AFTER `Gpu`,
ADD COLUMN gpu_name VARCHAR(255) AFTER `gpu_brand`;

UPDATE project2.laptopdata
SET `gpu_brand` = SUBSTRING_INDEX(Gpu, " ", 1);

UPDATE project2.laptopdata
SET `gpu_name` = REPLACE(Gpu, gpu_brand, "");

ALTER TABLE project2.laptopdata
DROP COLUMN `Gpu`;


	-- `Cpu` column:
		-- we can extract four peice of information:
			-- cpu_brand
            -- cpu_name
            -- cpu_speed
            -- cpu_series
		-- drop Cpu column

SELECT distinct Cpu from laptopdata order by cpu;

ALTER TABLE project2.laptopdata
ADD COLUMN `cpu_brand` VARCHAR(255) AFTER `Cpu`,
ADD COLUMN `cpu_name` VARCHAR(255) AFTER `cpu_brand`,
ADD COLUMN `cpu_speed` DECIMAL(10,2) AFTER `cpu_name`,
ADD COLUMN `cpu_series` VARCHAR(255) AFTER `cpu_speed`;

UPDATE project2.laptopdata
SET `cpu_brand` = SUBSTRING_INDEX(Cpu, " ", 1);

UPDATE project2.laptopdata
SET `cpu_speed` = REPLACE(SUBSTRING_INDEX(Cpu, " ", -1), "GHz", "");

UPDATE project2.laptopdata
SET `cpu_name` = REPLACE(REPLACE(Cpu, cpu_brand, ""),SUBSTRING_INDEX(Cpu, " ", -1),"");

UPDATE project2.laptopdata SET cpu_series = 
    CASE 
        WHEN Cpu LIKE '%Ryzen%' THEN 'Ryzen'
        WHEN Cpu LIKE '%Core i3%' THEN 'Core i3'
        WHEN Cpu LIKE '%Core i5%' THEN 'Core i5'
        WHEN Cpu LIKE '%Core i7%' THEN 'Core i7'
        WHEN Cpu LIKE '%Core i9%' THEN 'Core i9'
        WHEN Cpu LIKE '%Xeon%' THEN 'Xeon'
        WHEN Cpu LIKE '%Celeron%' THEN 'Celeron'
        WHEN Cpu LIKE '%Pentium%' THEN 'Pentium'
        WHEN Cpu LIKE '%Atom%' THEN 'Atom'
        WHEN Cpu LIKE '%A4%' THEN 'A4'
        WHEN Cpu LIKE '%A6%' THEN 'A6'
        WHEN Cpu LIKE '%A8%' THEN 'A8'
        WHEN Cpu LIKE '%A9%' THEN 'A9'
        WHEN Cpu LIKE '%A10%' THEN 'A10'
        WHEN Cpu LIKE '%A12%' THEN 'A12'
        WHEN Cpu LIKE '%E-Series%' THEN 'E-Series'
        WHEN Cpu LIKE '%FX%' THEN 'FX'
        ELSE 'Other'
    END;


ALTER TABLE project2.laptopdata
DROP COLUMN `Cpu`;


	-- `ScreenResolution` column:
		-- we can extract three peice of information
			-- resolution_width
            -- resolution_height
            -- is_touch_screen
		-- drop ScreenResolution column


ALTER TABLE project2.laptopdata
ADD COLUMN `resolution_width` INT AFTER `ScreenResolution`,
ADD COLUMN `resolution_height` INT AFTER `resolution_width`,
ADD COLUMN `is_touch_screen` INT AFTER `resolution_height`;


UPDATE project2.laptopdata
SET `resolution_width` = SUBSTRING_INDEX(substring_index(ScreenResolution, " ", -1),"x",1);
  
UPDATE project2.laptopdata
SET `resolution_height` = SUBSTRING_INDEX(substring_index(ScreenResolution, " ", -1),"x",-1);

UPDATE project2.laptopdata
SET `is_touch_screen` = 
CASE
    WHEN ScreenResolution LIKE "%Touchscreen%" THEN 1
    ELSE 0
END ;

ALTER TABLE project2.laptopdata
DROP COLUMN ScreenResolution;


	-- `Memory` column:
		-- we can extract three columns out of it
			-- memory_type
            -- primary_storage
            -- secondary_storage
		-- record at s_no 770 has memory "?"
        -- drop memory column

UPDATE project2.laptopdata
SET memory = "256GB SSD" WHERE `s_no` = 770;  -- rectified from internet

ALTER TABLE project2.laptopdata
ADD COLUMN `memory_type` VARCHAR(255) AFTER memory,
ADD COLUMN `primary_storage` INTEGER AFTER `memory_type`,
ADD COLUMN `secondary_storage` INTEGER AFTER `primary_storage`;

UPDATE project2.laptopdata
SET `memory_type`=
CASE
	WHEN memory LIKE "%+%" THEN "Hybrid"
	WHEN memory LIKE "%SSD%" THEN "SSD"
    WHEN memory LIKE "%HDD%" THEN "HDD"
    WHEN memory LIKE "%flash%" THEN "Flash storage"
    WHEN memory LIKE "%hybrid%" THEN "Hybrid"
END;

UPDATE project2.laptopdata
SET `primary_storage` =   
replace(REPLACE(replace(REPLACE(REPLACE(replace(substring_index(memory,"+",1),"SSD",""),"HDD","")
		,"Flash Storage",""),"GB",""),"TB",""),"Hybrid","");      

UPDATE project2.laptopdata
SET `primary_storage` = 
CASE 
	WHEN `primary_storage` < 3 THEN `primary_storage`*1024
    ELSE `primary_storage`
END;

UPDATE project2.laptopdata
SET `secondary_storage` = 
CASE 
	WHEN Memory LIKE "%+%" THEN 
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(substring_index(memory,"+",-1)),"SSD",""),
    "HDD",""),"TB",""),"GB",""),"Hybrid","")
    ELSE 0
END;


UPDATE project2.laptopdata
SET `secondary_storage` = 
CASE
	WHEN secondary_storage < 3 THEN secondary_storage*1024
    ELSE secondary_storage
END;


ALTER TABLE project2.laptopdata
DROP COLUMN Memory;



-- Performing Feature Engineering


	-- creating a new feature as PPI(pixels per inch)
		-- PPI = sqrt(width² + height²) / Inches


ALTER TABLE project2.laptopdata
ADD COLUMN PPI INTEGER AFTER resolution_height;

UPDATE project2.laptopdata
SET PPI = 
ROUND((SQRT( (resolution_width)*(resolution_width) + (resolution_height)*(resolution_height) ))/Inches);
        


	-- creating a new feature as resolution_category
		-- categories in it:
			-- [ HD, Full HD, 2K, 3K, 4K ]

ALTER TABLE project2.laptopdata
ADD COLUMN `resolution` VARCHAR(255) AFTER resolution_height;

UPDATE project2.laptopdata
SET resolution = CONCAT(resolution_width , "x" , resolution_height);
            
ALTER TABLE project2.laptopdata
ADD COLUMN `resolution_category` VARCHAR(255) AFTER resolution;

UPDATE project2.laptopdata
SET resolution_category = 
    CASE 
        WHEN resolution IN ('1366x768', '1440x900', '1600x900') THEN 'HD'
        WHEN resolution IN ('1920x1080', '1920x1200') THEN 'Full HD'
        WHEN resolution IN ('2160x1440', '2256x1504', '2304x1440', '2400x1600', '2560x1440') THEN '2K'
        WHEN resolution IN ('2560x1600', '2736x1824', '2880x1800') THEN '3K'
        WHEN resolution IN ('3200x1800', '3840x2160') THEN '4K'
        ELSE 'Other'
    END;

ALTER TABLE project2.laptopdata
DROP COLUMN resolution ;



	-- creating a new feature as cpu_tier
		-- cpu_teir
			-- Essential
            -- Standard
            -- Performance
            -- Elite
            -- Uncategorized

ALTER TABLE project2.laptopdata
ADD COLUMN `cpu_tier` VARCHAR(255) AFTER cpu_series;

UPDATE project2.laptopdata
SET cpu_tier=
    CASE 
        WHEN cpu_series IN ('Atom', 'Celeron', 'E-Series', 'A4') THEN 'Essential'
        WHEN cpu_series IN ('Pentium', 'A6', 'A8', 'A9', 'A10', 'A12', 'Core i3') THEN 'Standard'
        WHEN cpu_series IN ('Core i5', 'Ryzen', 'FX') THEN 'Performance'
        WHEN cpu_series IN ('Core i7', 'Xeon') THEN 'Elite'
        ELSE 'Uncategorized'
    END;



-- Performing EDA on cleaned dataset

-- Total records:
SELECT COUNT(*) FROM project2.laptopdata; -- 1272 records

-- Columns in the dataset:
SHOW COLUMNS FROM project2.laptopdata; -- 23 columns

-- Data types and description:
DESCRIBE project2.laptopdata;


-- Univariate Analysis (Categorical Features)


	-- 1) Company

SELECT Company, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY Company
ORDER BY units DESC ;

	-- Insight from Company column
    		-- The top brands are Lenovo (290), Dell (286), and HP (266), together comprising ~68% 
			-- of the dataset. Asus (156) and Acer (103) follow.
            

	-- 2) TypeName
    
SELECT TypeName, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  TypeName
ORDER BY units DESC;

	-- Insight from TypeName column
		-- Most entries are Notebook (710), followed by Gaming (203), Ultrabook (191), 
        -- 2 in 1 Convertible (116), with a few Workstation (28) and Netbook (24) models. 
        -- Notebooks dominate (>55%).


	-- 3) resolution_category
    
SELECT resolution_category, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  resolution_category
ORDER BY units DESC;

		-- Insight from resolution_category column
			-- The majority (825, ~65%) are Full HD. 
            -- The next most common is HD at 328 records (~26%), then 4K (68), 
            -- 2K (40) and 3K (11).

            
	-- 4) is_touch_screen
    
SELECT is_touch_screen, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  is_touch_screen
ORDER BY units DESC;

		-- Insight from is_touch_screen column:
			-- 85% laptops are without touch screen
            -- rest 15% are touch enabled
            

	-- 5) cpu_brand
    
SELECT cpu_brand, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  cpu_brand
ORDER BY units DESC;

	-- Insight from cpu_brand column:
		-- Nearly all CPUs are Intel (1209), 
        -- with a smaller number of AMD (62) and one Samsung. 
        -- This shows Intel dominates the market.
        

	-- 6) cpu_tier

SELECT cpu_tier, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  cpu_tier
ORDER BY units DESC;

	-- Insight from cpu_tier column:
		-- The majority of laptops have high-tier CPUs: 
        -- Elite (518) or Performance (416), with fewer Standard (210) and Essential (108).
        

	-- 7) Ram(Gb)

SELECT `Ram(Gb)`, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  `Ram(Gb)`
ORDER BY units DESC;

	-- Insight from Ram(Gb) column:
		-- The most common RAM sizes are 8 GB (600 laptops) and 4 GB (367). 


	-- 8) memory_type
    
SELECT memory_type, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  memory_type
ORDER BY units DESC;

	-- Insight from memory_type column:
		-- There are 620 SSD-based laptops, 366 HDD, 214 Hybrid (SSD+HDD), 
        -- and 72 with Flash Storage


	-- 9) primary_storage        

SELECT primary_storage, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  primary_storage
ORDER BY units DESC;

	-- Insight from primary_storage column:
		-- Common values are 256 GB (495 units) and 1024 GB/1 TB (243). 
        -- Others include 128 GB, 512 GB, 500 GB HDD, etc.
        

	-- 10) gpu_brand
    
SELECT gpu_brand, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  gpu_brand
ORDER BY units DESC;

	-- Insight from gpu_brand column:
		-- Intel-integrated (703), NVIDIA (392), AMD (176), ARM (1). 
        -- Many low-end/office laptops use Intel integrated graphics,
        -- gaming/workstation models more often use NVIDIA or AMD dedicated GPUs.
        

	-- 11) OpSys

SELECT OpSys, COUNT(*) AS units
FROM project2.laptopdata
GROUP BY  OpSys
ORDER BY units DESC;

	-- Insight from OpSys column:
		-- Most laptops has Windows (1099, 85% +). 
        -- Fewer have No OS (63), Linux (61), macOS (21), or other OS (28). 
        -- MacBooks (Apple) only 21 records (all macOS), reflecting Apple’s smaller market share here.
        

	-- 12) Inches (screen size)
    
SELECT Inches , COUNT(*) AS units
FROM project2.laptopdata 
GROUP BY Inches
ORDER BY units;

		-- Insights from Inches column:
			-- Most common screen size is 15.6″ (640 laptops, ~50% of data)


-- Univariate Analysis (Numerical Features)


	-- 13) Price

SELECT 
MIN(Price) AS min_price,
MAX(Price) AS max_price,
AVG(Price) AS avg_price,
STDDEV(Price) AS std_price
FROM project2.laptopdata;

-- Q1 (Quartile 1)
SELECT Price 
FROM
(SELECT Price,
ROW_NUMBER() OVER(ORDER BY Price) AS row_num,
COUNT(*) OVER() AS total_units
FROM project2.laptopdata)tab
WHERE row_num = (FLOOR(total_units/4) + 1);

-- median_price
SELECT AVG(Price) AS median_price
FROM(
SELECT Price,
ROW_NUMBER() OVER(ORDER BY Price) AS row_num,
COUNT(*) OVER() AS total_units
FROM project2.laptopdata)tab
WHERE tab.row_num IN (FLOOR((total_units+1)/2) , CEIL((total_units+1)/2)) ;

-- Q3 (Quartile 3)
SELECT Price 
FROM
(SELECT Price,
ROW_NUMBER() OVER(ORDER BY Price) AS row_num,
COUNT(*) OVER() AS total_units
FROM project2.laptopdata)tab
WHERE row_num = (FLOOR(3*total_units/4) + 1);

-- detecting outliers in price column:

SET @Q1 = 31915;
SET @Q3 = 79333;
SET @IQR = @Q3 - @Q1;

SET @upper_whisker = @Q3 + 1.5*@IQR;
SET @lower_whisker = @Q1 - 1.5*@IQR;

-- OUTLIERS
SELECT * FROM project2.laptopdata
WHERE Price < @lower_whisker OR
	  Price > @upper_whisker;



		-- Insight from Price column:
			-- min price = 9271
            -- Q1 (25 percentile) = 31915
            -- average price = 59900
            -- median price = 52108
            -- Q3 (75 percentile) = 79333
            -- std = 37283
            
            -- mean being greater than median indicates that the price column is right skewed. 
            -- std being 37283 indicates prices are widely spread.
            -- upper whisker = Q3 + 1.5*(Q3-Q1) ~ 150K
            -- lower whisker = Q1 - 1.5*(Q3-Q1) 
            -- Outliers price can be omitted for data modelling.
            
            -- using this summary we can perform feature engineering on Price column:
				-- Budget: < 32k
				-- Mid-range: 32k – 52k
				-- Upper mid-range: 52k – 80k
				-- Premium: 80k – 150k
				-- Ultra-premium (outliers): > 150k

ALTER TABLE project2.laptopdata
ADD COLUMN `price_segment` VARCHAR(255) AFTER Price;

UPDATE project2.laptopdata
SET price_segment =
CASE 
	WHEN Price < 32000 THEN "budget"
    WHEN Price >= 32000 AND PRICE < 52000 THEN "mid_range"
    WHEN Price >= 52000 AND PRICE < 80000 THEN "upper_mid_range"
    WHEN Price >= 80000 AND PRICE < 150000 THEN "premium"
    WHEN Price >= 150000  THEN "ultra_premium"
    ELSE null
END;


	-- 14) Weight
    
SELECT 
MIN(`Weight(kg)`) AS min_weight,
MAX(`Weight(kg)`) AS max_weight,
AVG(`Weight(kg)`) AS avg_weight,
STDDEV(`Weight(kg)`) AS std_weight
FROM project2.laptopdata;

		-- Insight from Weight column
			-- We find a mean weight ~2.08 kg, with values from 0.69 kg to 11.10 kg
            -- typical weights are 1.2–3.0 kg.
            


	-- 15) PPI

SELECT
MIN(PPI) AS min_ppi,
MAX(PPI) AS max_ppi,
AVG(PPI) AS avg_ppi
FROM project2.laptopdata;

-- median ppi
SELECT AVG(PPI)
FROM 
(SELECT PPI , ROW_NUMBER() OVER(ORDER BY PPI) AS row_num,
COUNT(*) OVER() AS total_units
FROM project2.laptopdata)tab
WHERE row_num IN (FLOOR((total_units+1)/2) , CEIL((total_units+1)/2)) ;

		-- Insights from PPI column:
			-- Pixel density ranges from 44 (very low) to 352 (very high, e.g. 4K on small screen).
            -- Median PPI is ~141 (corresponding to 1080p on 15.6″).
            

	-- 16) cpu_speed
    
SELECT
MIN(cpu_speed) AS min_cpu_speed,
MAX(cpu_speed) AS max_cpu_speed,
AVG(cpu_speed) AS avg_cpu_speed
FROM project2.laptopdata;

		-- Insights from cpu_speed column
			-- CPU clock speeds range roughly 0.9–3.6 GHz (mean ~2.30 GHz). 
            -- Most CPUs are in the 2.0–2.7 GHz range (60%).
            



-- Bivariate and Multivariate Analysis


	-- Price by Company:

SELECT Company, AVG(Price) AS avg_price
FROM project2.laptopdata
GROUP BY Company
ORDER BY avg_price DESC;

		-- Insights:
			-- We find that Razer laptops have the highest mean price (₹178k, 7 units), 
            -- followed by MSI (₹91k), LG (₹111k, but only 3 units), Google (₹89k, 3 units), 
            -- and Apple (~₹83k, median ₹71k, 21 units). 
		 -- but these laptops are present in very less volume

  -- Price by Company for volume laptops:
  
SELECT Company, AVG(Price) AS avg_price
FROM project2.laptopdata
GROUP BY Company
HAVING COUNT(*) > 100
ORDER BY avg_price DESC;  
  
  
			-- Insights:
              -- The volume leaders
              -- (Lenovo, Dell, HP, Asus, Acer) have average prices in the 33k–63k range, 
              


	-- Price by TypeName:

SELECT TypeName, AVG(Price) AS avg_price
FROM project2.laptopdata
GROUP BY TypeName
ORDER BY avg_price DESC;

		-- Insights
			-- Workstations have the highest mean price (121k, 28 units), 
              -- followed by Gaming (92k) and Ultrabook (83k). 
              -- More budget categories like plain Notebook (41k mean) and Netbook (35k) 
              -- are much cheaper. 
            -- This is expected: gaming and workstation laptops have high-end CPUs/GPUs 
              -- and thus cost more.



	-- Price by CPU Tier:
    
SELECT cpu_tier, AVG(Price) AS avg_price
FROM project2.laptopdata
GROUP BY cpu_tier
ORDER BY avg_price DESC;

		-- Insights:
			  -- Essential CPUs (entry-level) average only ~₹17k, 
              -- Standard ~₹27.6k, 
              -- Performance ~₹54.5k, and 
              -- Elite ~₹85.9k. 
		   -- Higher-tier CPUs have much higher prices. 
		   -- This matches prior analyses showing that CPU performance positively 
              -- influences laptop price
              

	-- Price by resolution_category:

SELECT resolution_category, AVG(Price) AS avg_price
FROM project2.laptopdata
GROUP BY resolution_category
ORDER BY avg_price DESC;


            -- Insights:
				-- Higher-resolution models are more expensive: 
					-- HD (low-res) models average ~₹29.9k, 
                    -- Full HD ~₹65k, 
                    -- 3K/2K around ₹99k, and 
                    -- 4K ~₹112k. 
				-- laptops with 4K screens cost roughly 4× more than basic HD models. 
                -- This reinforces that display quality is a positive price driver


	-- Price by GPU Brand:

SELECT gpu_brand, AVG(Price) AS avg_price
FROM project2.laptopdata
GROUP BY gpu_brand
ORDER BY avg_price DESC;

		-- Insights:
			    -- laptops with NVIDIA GPUs average ~₹79.1k, 
                -- whereas those with Intel-integrated GPUs average ~₹53.8k, and 
                -- AMD GPUs ~₹41.5k. 
		  -- Dedicated NVIDIA GPUs are primarily in gaming/performance laptops, 
		        -- explaining their higher prices. 
		  -- This aligns with research noting GPU (dedicated vs integrated) as a 
                -- positive factor in pricing.



	-- Price by Memory Type:
    
SELECT memory_type, AVG(Price) AS avg_price
FROM project2.laptopdata
GROUP BY memory_type
ORDER BY avg_price DESC;

		-- Insights:
			   -- Hybrid storage systems (SSD+HDD) are most expensive (~₹84.6k), 
               -- SSD ~₹69.9k, 
               -- HDD ~₹34.9k and 
               -- Flash ~₹27.4k. 
            -- This shows SSD-equipped laptops are costlier than HDD ones, 
               -- consistent with SSD being a premium feature.



	-- Price by Operating System:

SELECT OpSys, AVG(Price) AS avg_price
FROM project2.laptopdata
GROUP BY OpSys
ORDER BY avg_price DESC;

		-- Insights:
			-- We find macOS laptops (Apple) have the highest mean (₹83.3k), 
            -- Windows about ₹63.3k, 
            -- while models with no OS, Linux, or other are much cheaper (₹29k–₹33k).
            


	-- Price by Ram(Gb):

-- coorelation b/w Price and RAM

SET @price_mean = (SELECT AVG(Price) FROM project2.laptopdata);
SET @ram_mean = (SELECT AVG(`Ram(Gb)`) FROM project2.laptopdata);
SET @total_observation = (SELECT COUNT(*) FROM project2.laptopdata);
SET @covariance_price_ram = 
		(SELECT 
		(SUM((price - @price_mean) * (`Ram(Gb)` - @ram_mean)) ) / @total_observation
		FROM project2.laptopdata) ;
        
SET @price_std = (SELECT STDDEV(Price) FROM project2.laptopdata);
SET @ram_std = (SELECT STDDEV(`Ram(Gb)`) FROM project2.laptopdata);

SET @coorelation_price_ram = (SELECT (@covariance_price_ram) / (@price_std * @ram_std));
SELECT @coorelation_price_ram; -- ~ 0.69

-- cofficient of determination (r^2)
SELECT (@coorelation_price_ram)*(@coorelation_price_ram); --  ~ 0.476

		-- Insights from Prive Vs Ram:
			-- Direction: positive - as RAM increases, price generally increases.
			-- Strength: r = 0.69 - moderate to strong positive correlation.
			-- cofficient of determination - About 47.6% of the variation in price is explained by RAM 
										  -- alone (substantial for a single feature).



	-- Price by cpu_speed:
    
-- coorelation b/w Price and cpu_speed

SET @cpu_speed_mean = (SELECT AVG(cpu_speed) FROM project2.laptopdata);
SET @covariance_price_cpu_speed = 
		(SELECT 
		(SUM((price - @price_mean) * (cpu_speed - @cpu_speed_mean)) ) / @total_observation
		FROM project2.laptopdata) ;
        
SET @price_std = (SELECT STDDEV(Price) FROM project2.laptopdata);
SET @cpu_speed_std = (SELECT STDDEV(cpu_speed) FROM project2.laptopdata);

SET @coorelation_price_cpu_speed = (SELECT (@covariance_price_cpu_speed) / (@price_std * @cpu_speed_std));
SELECT @coorelation_price_cpu_speed; -- ~ 0.43

-- cofficient of determination (r^2)
SELECT (@coorelation_price_cpu_speed)*(@coorelation_price_cpu_speed); --  ~ 18.35%

		-- Insights
			-- Correlation (r ~ 0.43): Moderate positive relationship between CPU speed and Price.
			-- Coefficient of determination (r² ~ 0.1835 = 18.35%):
						-- CPU speed explains about 18% of the variation in price.



	-- Price by PPI:
    
-- coorelation b/w Price and PPI

SET @ppi_mean = (SELECT AVG(PPI) FROM project2.laptopdata);
SET @covariance_price_ppi = 
		(SELECT 
		(SUM((price - @price_mean) * (PPI - @ppi_mean)) ) / @total_observation
		FROM project2.laptopdata) ;
        
SET @price_std = (SELECT STDDEV(Price) FROM project2.laptopdata);
SET @ppi_std = (SELECT STDDEV(PPI) FROM project2.laptopdata);

SET @coorelation_price_ppi = (SELECT (@covariance_price_ppi) / (@price_std * @ppi_std));
SELECT @coorelation_price_ppi; -- ~ 0.47

-- cofficient of determination (r^2)
SELECT (@coorelation_price_ppi)*(@coorelation_price_ppi); --  ~ 0.22


		-- Insights from Price by PPI:
			-- Correlation (r ~ 0.47) between Price and PPI indicates a moderate positive relationship.
			-- As display sharpness (PPI) increases, laptop prices tend to increase.
			-- The relationship is not as strong as RAM (0.69), but it’s noticeable.
			-- Coefficient of determination (r² ~ 0.22 = ~22%):
			-- About 22% of the variation in laptop prices can be explained by differences in PPI.




-- ----------------------------------------------------------------------
-- Key Insights after EDA:
-- ----------------------------------------------------------------------

-- 1) RAM is the strongest single price driver.
-- 	  Correlation: r ~ 0.69, r² ~ 0.476 → RAM alone explains ~47.6% of price variance.
--    Practical: higher-RAM models are consistently more expensive.

-- 2) Storage type strongly affects price.
--    Hybrid / SSD laptops command premium prices (Hybrid ≈ ₹84.6k, SSD ≈ ₹69.9k vs HDD ≈ ₹34.9k).
--    Practical: SSD/hybrid = premium positioning; HDD = budget.

-- 3) CPU matters, but less than RAM/storage.
--    Correlation with price: r ~ 0.43, r² ~ 0.1835 → CPU speed explains ~18% of price variance.

-- 4) CPU tier (Essential to Elite) aligns with large step increases in average price.

-- 5) GPU separates price tiers.
--    NVIDIA-equipped laptops have notably higher mean prices (≈₹79k) vs integrated Intel (≈₹54k).
--    Practical: dedicated GPU => gaming/performance segment.

-- 6) Display sharpness (PPI) moderately drives price.
--    Correlation: r ~ 0.47, r² ~ 0.22 = ~22% of price variance explained by PPI.
--    Practical: higher-PPI (sharper) displays are generally priced higher, 
--    but RAM and storage remain stronger drivers.

-- 7) Display sharpness (PPI) is not a price driver overall.
--    Correlation: r ~ 0.087, r² ~ 0.0077 , PPI explains <1% of price variance.

-- 8) Price distribution is right-skewed, outliers exist.

-- 9) Dominant Brands: Lenovo, Dell, and HP comprise ~70% of the dataset. 

-- 10) Display Trends: Over 64% of laptops have 1920×1080 “Full HD” resolution, 
--    reaffirming that Full HD is the current standard laptop resolution

-- 11) Laptops with macOS are high priced compared to windows and linux.

-- 12) Windows vs Linux/No OS: Windows machines (86% of data) are mid-priced (₹63k average). 
--     Laptops sold without an OS or with Linux/“other” are substantially cheaper (₹30k)

-- 13) Storage and Memory: Over 60% of laptops use SSDs, reflecting modern trends. 

-- 14) RAM and Other Factors: Most laptops have 8 GB RAM (47% of models). 







