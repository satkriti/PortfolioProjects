SELECT * FROM nashvillehousing;
SELECT count(UniqueID) FROM nashvillehousing;

/* Cleaning in SQL queries*/

SELECT SaleDate FROM nashvillehousing;

SELECT cast(str_to_date(SaleDate, "%m/%d/%y") as datetime) 
FROM nashvillehousing;

UPDATE nashvillehousing 
SET SaleDate = cast(str_to_date(SaleDate, "%m/%d/%Y") as datetime) ;
-- Error Code: 1292. Truncated incorrect date value: '04/09/2013'

ALTER TABLE nashvillehousing 
ADD saleDateConverted DATETIME;

UPDATE nashvillehousing
SET saleDateConverted = cast(str_to_date(SaleDate, "%m/%d/%Y") as datetime);
-- UPDATE nashvillehousing SET saleDateConverted = cast(str_to_date(SaleDate, "%m/%d/%y") as datetime)
-- Error Code: 1292. Truncated incorrect date value: '04/09/2013'


-- finally converted SaleDate

SELECT PropertyAddress FROM nashvillehousing;

SELECT * FROM nashvillehousing
WHERE PropertyAddress <> '' -- there are null values in the propertyAddress column
ORDER BY ParcelID;  -- Where parcel id are same, propertyaddress is also same

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(b.PropertyAddress, a.PropertyAddress)
FROM nashvillehousing a
JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
    WHERE a.PropertyAddress = '';

UPDATE nashvillehousing a
JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = ifnull(b.PropertyAddress, a.PropertyAddress) 
WHERE a.PropertyAddress = '';

-- Error Code: 1146. Table 'nashville_housing.a' doesn't exist
-- Error Code: 1052. Column 'PropertyAddress' in field list is ambiguous
-- 29 rows affected

-- cleaning the PropertyAddress Column

SELECT PropertyAddress FROM Nashvillehousing;

SELECT 
	substring_index(PropertyAddress, ',', 1) AS Address, 
	substring_index(PropertyAddress, ',', -1) AS Address2
FROM Nashvillehousing;

-- spliting PropertyAddress Column into street and city

ALTER TABLE nashvillehousing 
ADD AddressStreet text;

UPDATE nashvillehousing
SET AddressStreet = substring_index(PropertyAddress, ',', 1);

SELECT AddressStreet FROM nashvillehousing;

ALTER TABLE nashvillehousing 
ADD AddressCity text;

UPDATE nashvillehousing
SET AddressCity = substring_index(PropertyAddress, ',', -1);

SELECT AddressCity FROM nashvillehousing;

-- changing Owner Address

SELECT OwnerAddress FROM nashvillehousing;

SELECT 
	substring_index(OwnerAddress, ',', 1) AS Address1,
    substring_index(substring_index(OwnerAddress, ',', 2), ',', -1) AS Address2,
	substring_index(OwnerAddress, ',', -1) AS Address3
FROM Nashvillehousing;

-- spliting PropertyAddress Column into street and city

ALTER TABLE nashvillehousing 
ADD OwnerStreet text, 
ADD OwnerCity text, 
ADD OwnerState text;

UPDATE nashvillehousing
SET OwnerStreet = substring_index(OwnerAddress, ',', 1);

UPDATE nashvillehousing
SET OwnerCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1);

UPDATE nashvillehousing
SET OwnerState = substring_index(OwnerAddress, ',', -1);

SELECT * FROM nashvillehousing;

-- SoldAsVacant column

SELECT DISTINCT(SoldAsVacant)
FROM nashvillehousing; -- values are N, No, Y and, Yes; 

-- changing values to No and Yes

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant; 

SELECT SoldAsVacant, CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
    END;
    
SELECT DISTINCT(SoldAsVacant)
FROM nashvillehousing; 

-- removing duplicates

SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
    SaleDate,
    LegalReference
    ORDER BY UniqueID) row_num
 FROM nashvillehousing 
 ORDER BY ParcelID;
 
 WITH RowNumCTE AS(
 SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
    SaleDate,
    LegalReference
    ORDER BY UniqueID) row_num
 FROM nashvillehousing 
 )
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress; -- 104 ROWS NEED TO BE DELETED

 WITH RowNumCTE AS(
 SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
    SaleDate,
    LegalReference
    ORDER BY UniqueID) row_num
 FROM nashvillehousing 
 )
DELETE FROM RowNumCTE
WHERE row_num > 1; -- UNABLE TO RUN THIS

 WITH RowNumCTE AS(
 SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
    SaleDate,
    LegalReference
    ORDER BY UniqueID) row_num
 FROM nashvillehousing 
 )
DELETE FROM nashvillehousing
USING nashvillehousing
JOIN RowNumCTE ON 
nashvillehousing.UniqueID = RowNumCTE.UniqueID
WHERE row_num > 1
; -- 104 ROWS AFFECTED :)

-- RUNNING THE BELOW CODE AGAIN TO CHECK FOR DUP VALUES : 
 WITH RowNumCTE AS(
 SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
    SaleDate,
    LegalReference
    ORDER BY UniqueID) row_num
 FROM nashvillehousing 
 )
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress; -- NONE


-- Deleting unused Columns

SELECT * FROM nashvillehousing; 

ALTER TABLE nashvillehousing
DROP COLUMN PropertyAddress, 
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN SaleDate;






