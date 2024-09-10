--Bangkok Renting Data Cleaning----

--Explore Data 

SELECT *
FROM [Bangkok Renting Data].dbo.calendar


--Note Down Required Area to clean and Develop
--Error Comma Separated miss leading to wrong column

1. Price
2. Adjusted 
3. Minimum_nights
4. Maximum_nights

------------///---------------

--First Clean Price Column

SELECT price, CASE 
	WHEN price LIKE '"%' THEN price + adjusted_price 
	ELSE price
END CleanedPrice
FROM [Bangkok Renting Data].dbo.calendar
WHERE price LIKE '"%' 
ORDER BY date

--Add Created Column to Table 

ALTER TABLE calendar
ADD CleanedPrice Nvarchar(225);

--Add Cleaned Data to Table

UPDATE calendar
SET CleanedPrice =  CASE 
	WHEN price LIKE '"%' THEN price + adjusted_price 
	ELSE price
END
FROM [Bangkok Renting Data].dbo.calendar

--Remove (") from data "$xxx"

UPDATE calendar
SET CleanedPrice = REPLACE(CleanedPrice, '"', ' ')

UPDATE calendar
SET CleanedPrice = REPLACE(CleanedPrice, '$', ' ')


--Check Performed Data Work

SELECT *
FROM [Bangkok Renting Data].dbo.calendar
ORDER BY CleanedPrice


------------////-----------------------------

2.Adjuest_price

SELECT adjusted_price, minimum_nights
FROM [Bangkok Renting Data].dbo.calendar
ORDER BY date

SELECT  adjusted_price, minimum_nights, maximum_nights,
		SUBSTRING(maximum_nights, 1, CHARINDEX(',',maximum_nights)-1),
		SUBSTRING(maximum_nights, CHARINDEX(',', maximum_nights) + 1, LEN(maximum_nights))
FROM [Bangkok Renting Data].dbo.calendar
WHERE minimum_nights LIKE '"%'


--Divided Datemixed column into single column

--Create Column/ Data to Table

ALTER TABLE calendar
ADD Ad_price Nvarchar(225);

UPDATE calendar
SET Ad_price =  CASE WHEN minimum_nights LIKE '"%' THEN LEFT(maximum_nights, CHARINDEX(',', maximum_nights)) 
ELSE Ad_price
END
FROM [Bangkok Renting Data].dbo.calendar

SELECT *
FROM [Bangkok Renting Data].dbo.calendar
WHERE Ad_price is not NULL


--Created and Cleaned Adjuested_price

ALTER TABLE calendar
ADD Adjusted_price_cleaned Nvarchar(225);

UPDATE calendar
SET Adjusted_price_cleaned =  CASE WHEN Ad_price is not NULL THEN minimum_nights+ Ad_price
ELSE Adjusted_price_cleaned
END
FROM [Bangkok Renting Data].dbo.calendar


UPDATE calendar
SET Adjusted_price_cleaned = REPLACE(Adjusted_price_cleaned, '"', ' ')

UPDATE calendar
SET Adjusted_price_cleaned = REPLACE(Adjusted_price_cleaned, '$', ' ')

UPDATE calendar
SET Adjusted_price_cleaned = REPLACE(Adjusted_price_cleaned, ',', ' ')



--Check Created Column Work


SELECT *
FROM [Bangkok Renting Data].dbo.calendar
WHERE minimum_nights LIKE '"%'
--WHERE maximum_nights LIKE '%"%'


-----////////----------------------

3.Minimum_nights
4.Maximum_nights

SELECT minimum_nights, maximum_nights
FROM [Bangkok Renting Data].dbo.calendar
WHERE minimum_nights LIKE ''
--WHERE maximum_nights LIKE '%"%'


---Cleaned Price and length of rent period
ALTER TABLE calendar
ADD Length_nights Nvarchar(225);


UPDATE calendar
SET Length_nights =  CASE WHEN maximum_nights LIKE '%"%' THEN RIGHT(maximum_nights,  CHARINDEX('"', maximum_nights)-3) 
ELSE maximum_nights
END
FROM [Bangkok Renting Data].dbo.calendar

SELECT *
FROM [Bangkok Renting Data].dbo.calendar
WHERE maximum_nights LIKE '%,%'

---Created Minimum_nights

ALTER TABLE calendar
ADD Min_nights Nvarchar(225);

UPDATE calendar
SET Min_nights =  CASE WHEN minimum_nights LIKE '' THEN PARSENAME(REPLACE(Length_nights,',','.'),2)
					   WHEN minimum_nights LIKE '"%' THEN PARSENAME(REPLACE(Length_nights,',','.'),2)
					   ELSE minimum_nights
					   END
	FROM [Bangkok Renting Data].dbo.calendar

---Created Maximum_nights


ALTER TABLE calendar
ADD Max_nights Nvarchar(225);

UPDATE calendar
SET Max_nights =  CASE WHEN minimum_nights LIKE '' THEN PARSENAME(REPLACE(Length_nights,',','.'),1)
					   WHEN minimum_nights LIKE '"%' THEN PARSENAME(REPLACE(Length_nights,',','.'),1)
					   ELSE maximum_nights
					   END
FROM [Bangkok Renting Data].dbo.calendar





----Data Clean on "available" column
--- t = taken , f = free
--- t should include price while f not have pirce


SELECT *,CASE WHEN available LIKE 'f' THEN RIGHT(CleanedPrice,1) 
						ELSE CleanedPrice
						END
FROM [Bangkok Renting Data].dbo.calendar
WHERE available LIKE 't'
AND Adjusted_price_cleaned IS NOT NULL




UPDATE calendar
SET CleanedPrice = CASE WHEN available LIKE 'f' THEN RIGHT(CleanedPrice,1) 
						ELSE CleanedPrice
						END
FROM [Bangkok Renting Data].dbo.calendar

---Error Refix


SELECT *, CASE WHEN Length_nights NOT LIKE '%,%' THEN Length_nights ELSE Max_nights END
FROM [Bangkok Renting Data].dbo.calendar
WHERE Length_nights NOT LIKE '%,%'

UPDATE calendar
SET Max_nights = CASE WHEN Length_nights NOT LIKE '%,%' THEN Length_nights ELSE Max_nights END
FROM [Bangkok Renting Data].dbo.calendar




--------Tiding Up Delete Unused Columns

ALTER TABLE calendar
DROP COLUMN CleanedPrice


-----THANK U!!!

------Recheck Explore Again 

SELECT *
FROM [Bangkok Renting Data].dbo.calendar
WHERE Bath_price IS NOT NULL
