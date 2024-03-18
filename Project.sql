SELECT *
FROM
Housingdata..NationalHousing

-------------------------------------------------------------------------------------------------------------
--CHANGE DATE FORMAT
SELECT *
FROM
Housingdata..NationalHousing

ALTER TABLE NationalHousing
Drop Column SaleDate

UPDATE NationalHousing
SET DateSale=CONVERT(date,SaleDate)

-------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

SELECT PropertyAddress
FROM
Housingdata..NationalHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
--ISNULL is used to Copy One Column to another Column if First Column has Null value 
-- We can Update Null to Any string values
ISNULL (a.PropertyAddress,b.PropertyAddress) UpdatedPropertyAddress
FROM NationalHousing a
JOIN NationalHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ] --IF UniqueID is not equal

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NationalHousing a
JOIN NationalHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
------------------------------------------------------------------------------------------------------------
--BREAKING COLUMN TO THREE SEPERATE COLUMNS (Address,State,City)

SELECT PropertyAddress,
--Substring is used to seperate one string to different column
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS StreetName,
-- in this after comma the sentence is break from perticular column_namae
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
--LEN is used to calculate the length of String
FROM
Housingdata..NationalHousing

ALTER TABLE NationalHousing
ADD StreetName Nvarchar(255)

ALTER TABLE NationalHousing
ADD Country nvarchar(255)

UPDATE NationalHousing
SET StreetName = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE NationalHousing
SET City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

ALTER TABLE NationalHousing
DROP COLUMN PropertyAddress

------------------------------------------------------------------------------------------------------------
--Another Way to Seperate into Another Column

SELECT OwnerAddress,

--Replaced , into . on 1,2 or 3 Position
PARSENAME(REPLACE( OwnerAddress,',','.'),3) AS Street_Name,
PARSENAME(REPLACE( OwnerAddress,',','.'),2) AS City_Name,
PARSENAME(REPLACE( OwnerAddress,',','.'),1) AS Area
FROM 
NationalHousing

ALTER TABLE NationalHousing
ADD Area nvarchar(255)

ALTER TABLE NationalHousing
DROP Column Country

UPDATE NationalHousing
SET Area=PARSENAME(REPLACE( OwnerAddress,',','.'),1)

SELECT * 
FROM 
NationalHousing

------------------------------------------------------------------------------------------------------------
-- SEPERATE OwnerName to Two Column
SELECT FirstName,LastName
--PARSENAME(REPLACE (OwnerName,'&','.'),1) LastName,
--PARSENAME(REPLACE (OwnerName,'&','.'),2) FirstName
FROM 
NationalHousing
WHERE FirstName IS NOT NULL


ALTER TABLE NationalHousing
ADD LastName nvarchar(255)

ALTER TABLE NationalHousing
ADD FirstName nvarchar(255)

UPDATE NationalHousing
SET LastName=PARSENAME(REPLACE (OwnerName,'&','.'),1)

UPDATE NationalHousing
SET FirstName=PARSENAME(REPLACE(OwnerName,'&','.'),2)

------------------------------------------------------------------------------------------------------------

--CASE statement in SQL
SELECT *
--SoldAsVacant, COUNT (SoldAsVacant)
--CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
--	 WHEN SoldAsVacant = 'N' THEN 'NO'
--	 WHEN SoldAsVacant = 'Yes' THEN 'YES'
--	 WHEN SoldAsVacant = 'no' THEN 'NO'
--	 ELSE SoldAsVacant
--END
FROM 
NationalHousing
GROUP BY SoldAsVacant

UPDATE NationalHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 WHEN SoldAsVacant = 'Yes' THEN 'YES'
	 WHEN SoldAsVacant = 'no' THEN 'NO'
	 ELSE SoldAsVacant
END

------------------------------------------------------------------------------------------------------------

--Remove Duplicate Values
SELECT *
FROM
NationalHousing

WITH RowNumCTE AS 
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY UniqueID,
			 ParcelId,
			 SalePrice,
			 OwnerAddress,
			 LegalReference,
			 LandUse
			 ORDER BY UniqueID
) row_num
FROM NationalHousing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY OwnerAddress