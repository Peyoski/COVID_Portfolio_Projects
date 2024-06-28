/*

Cleaning Data in SQL Queries

*/

-- Creating the table --
DROP TABLE IF EXISTS Nashville_housing_data;

CREATE TABLE Nashville_housing_data (
    UniqueID INTEGER,
    ParcelID VARCHAR(255),
    Landuse VARCHAR(255),
    ProperyAddress VARCHAR(255),
    SaleDate VARCHAR(255),
    salePrice INT,
    LegalReference VARCHAR(255),
    SoldAsVacant VARCHAR(255),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage FLOAT,
    TaxDistrict VARCHAR(255),
    LandValue INT,
    BuildingValue INT,
    TotalValue INT,
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

SELECT saleprice FROM Nashville_housing_data;

UPDATE Nashville_housing_data
SET saleprice = TRIM(REPLACE(REPLACE(REPLACE(saleprice, ',', ''), '$', ''), ' ', ''));

ALTER TABLE Nashville_housing_data ALTER COLUMN saleprice TYPE INT USING saleprice::INT;

ALTER TABLE Nashville_housing_data RENAME COLUMN properyaddress TO propertyaddress;

SELECT * FROM Nashville_housing_data;


-- Standardize Date Format

ALTER TABLE Nashville_housing_data ALTER COLUMN saledate TYPE DATE USING saledate::date;

SELECT saledate FROM Nashville_housing_data;

SELECT saledate, CAST(saledate AS DATE)
FROM Nashville_housing_data;

UPDATE Nashville_housing_data
SET saledate = CAST(saledate AS DATE);

SELECT * FROM Nashville_housing_data;

-- Populate Property Address

SELECT * 
FROM Nashville_housing_data
WHERE propertyaddress IS NULL
ORDER BY parcelid;

SELECT table1.parcelid, table1.propertyaddress, table2.parcelid, table2.propertyaddress
FROM Nashville_housing_data AS table1
JOIN Nashville_housing_data AS table2
ON table1.parcelid = table2.parcelid
AND table1.uniqueid != table2.uniqueid
WHERE table1.propertyaddress IS NULL;


SELECT table1.parcelid, table1.propertyaddress, table2.parcelid, table2.propertyaddress, COALESCE(table1.propertyaddress, table2.propertyaddress)
FROM Nashville_housing_data AS table1
JOIN Nashville_housing_data AS table2
ON table1.parcelid = table2.parcelid
AND table1.uniqueid != table2.uniqueid
WHERE table1.propertyaddress IS NULL;

UPDATE Nashville_housing_data AS table1
SET propertyaddress = COALESCE(table1.propertyaddress, table2.propertyaddress)
FROM Nashville_housing_data AS table2
WHERE table1.parcelid = table2.parcelid
AND table1.uniqueid != table2.uniqueid
AND table1.propertyaddress IS NULL;

SELECT propertyaddress FROM Nashville_housing_data;

		  
SELECT
SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) - 1) AS address,
SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1) AS address
FROM Nashville_housing_data;

ALTER TABLE Nashville_housing_data
ADD COLUMN propertysplitaddress VARCHAR(255);

UPDATE Nashville_housing_data
SET propertysplitaddress = SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) - 1);

ALTER TABLE Nashville_housing_data
ADD COLUMN propertysplitcity VARCHAR(255);

UPDATE Nashville_housing_data
SET propertysplitcity = SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1);


SELECT * FROM Nashville_housing_data;

SELECT 	owneraddress FROM Nashville_housing_data;

SELECT 
PARSENAME(REPLACE(',', '.'), 1),
PARSENAME(REPLACE(',', '.'), 2),
PARSENAME(REPLACE(',', '.'), 3)
FROM Nashville_housing_data;

SELECT
  SPLIT_PART(owneraddress, ',', 1) AS part_1,
  SPLIT_PART(owneraddress, ',', 2) AS part_2,
  SPLIT_PART(owneraddress, ',', 3) AS part_3
FROM Nashville_housing_data;

ALTER TABLE Nashville_housing_data
ADD COLUMN ownersplitaddress VARCHAR(255);

UPDATE Nashville_housing_data
SET ownersplitaddress =   SPLIT_PART(owneraddress, ',', 1);

ALTER TABLE Nashville_housing_data
ADD COLUMN ownersplitcity VARCHAR(255);

UPDATE Nashville_housing_data
SET ownersplitcity = SPLIT_PART(owneraddress, ',', 2);

ALTER TABLE Nashville_housing_data
ADD COLUMN ownersplitstate VARCHAR(255);

UPDATE Nashville_housing_data
SET ownersplitstate = SPLIT_PART(owneraddress, ',', 3);


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT soldasvacant FROM Nashville_housing_data;

SELECT DISTINCT soldasvacant, COUNT(soldasvacant)
FROM Nashville_housing_data
GROUP BY soldasvacant
ORDER BY COUNT(soldasvacant);

SELECT soldasvacant,
CASE
    WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END AS Vacantsales
FROM Nashville_housing_data;

UPDATE Nashville_housing_data
SET soldasvacant = CASE
    WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END;


-- Remove Duplicates

SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID)
FROM Nashville_housing_data
ORDER BY parcelid;

WITH RowNumCte AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID)
FROM Nashville_housing_data
ORDER BY parcelid
)
SELECT *
FROM RowNumCte
WHERE row_number > 1
ORDER BY propertyaddress;

WITH RowNumCte AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY ParcelID,
                                             PropertyAddress,
                                             SalePrice,
                                             SaleDate,
                                             LegalReference
                            ORDER BY
                                UniqueID) AS row_number
    FROM Nashville_housing_data
)
DELETE FROM Nashville_housing_data
WHERE UniqueID IN (
    SELECT UniqueID
    FROM RowNumCte
    WHERE row_number > 1
);


-- Delete Unused Columns

SELECT * FROM Nashville_housing_data;

ALTER TABLE Nashville_housing_data
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;



