--Column Names
SELECT TOP 0 * 
FROM PorfolioProject..NashvilleHousing;

-- Nashville Housing Data Cleaning Project Using Microsoft SQL

select *
from PorfolioProject..NashvilleHousing

-- Standardize datetime format to just date 
select CONVERT(date, SaleDate)
from PorfolioProject..NashvilleHousing;

-- This runs fine but is not updating to the desired format
Update PorfolioProject..NashvilleHousing
set SaleDate = convert(Date, SaleDate)

-- So Alter then Update will work
alter table PorfolioProject..NashvilleHousing
add SaleDateConverted Date;

Update PorfolioProject..NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)


-- Populate property address data
--(Basically there are NULL data in property address, which we can fill by looking at Parcel ID's which have an address.
-- So in this case let's say there are two Parcel ID's with the same number, one with address and one without. 
-- Then the one with address is going to fill the address of the one without on the condition they have the same parcel ID)

UPDATE nh
SET nh.PropertyAddress = source.PropertyAddress
FROM PorfolioProject..NashvilleHousing AS nh
JOIN PorfolioProject..NashvilleHousing AS source
    ON nh.ParcelID = source.ParcelID
WHERE nh.PropertyAddress IS NULL 
  AND source.PropertyAddress IS NOT NULL;

-- Check if there are any remaing null
select PropertyAddress
from PorfolioProject..NashvilleHousing
where PropertyAddress is null

-- double check using a known null and see if it has filled
select *
FROM PorfolioProject..NashvilleHousing
where [UniqueID ]  = 22721 OR [UniqueID ] = 39432

-- Another way to do it is
select NashA.ParcelID, NashB.ParcelID, NashA.PropertyAddress, NashA.PropertyAddress,
ISNULL(NashA.PropertyAddress, NashB.PropertyAddress)
from PorfolioProject..NashvilleHousing as NashA
Join PorfolioProject..NashvilleHousing as NashB
	on NashA.ParcelID = NashB.ParcelID
	AND NashA.[UniqueID ] <> NashB.[UniqueID ]
	where NashA.PropertyAddress is null

update NashA
Set PropertyAddress = ISNULL(NashA.PropertyAddress, NashB.PropertyAddress)
from PorfolioProject..NashvilleHousing NashA
Join PorfolioProject..NashvilleHousing as NashB
	on NashA.ParcelID = NashB.ParcelID
	AND NashA.[UniqueID ] <> NashB.[UniqueID ]
	where NashA.PropertyAddress is null


---Breaking Property Adress and Owner Address into seperate columns into (Address, City, State) [PARSENAME is simple to use compared to Substring]

-- Property Address
select *
from PorfolioProject..NashvilleHousing

ALTER TABLE PorfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255), 
    PropertySplitCity NVARCHAR(255);

-- Change the separator in your dataset to "." if possible
UPDATE PorfolioProject..NashvilleHousing
SET PropertyAddress = REPLACE(PropertyAddress, ',', '.');

-- Then use PARSENAME to split
UPDATE PorfolioProject..NashvilleHousing
SET 
    PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),  -- Extracts "Address" before the first period
    PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)      -- Extracts "City" after the period
WHERE PropertyAddress IS NOT NULL;
 
 select PropertyAddress, PropertySplitAddress, PropertySplitCity
from PorfolioProject..NashvilleHousing

-- Owner Address
Select * 
from NashvilleHousing

Select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3) as SplitOwnerAddress,
PARSENAME(replace(OwnerAddress, ',', '.'), 2) as SplitOwnerState,
PARSENAME(replace(OwnerAddress, ',', '.'), 1) as SplitOwnerCity
from NashvilleHousing

Alter table PorfolioProject..NashvilleHousing
ADD SplitOwnerAddress NVARCHAR(255), 
    SplitOwnerCity NVARCHAR(255),
	SplitOwnerState NVARCHAR(255);

update PorfolioProject..NashvilleHousing
SET 
    SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
    SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
WHERE OwnerAddress IS NOT NULL;
 
select *
from PorfolioProject..NashvilleHousing

-- Change Y and N to yes and no in SoldAsVacant column

select distinct SoldAsVacant, count(SoldAsVacant) as TotalSoldAsVacant
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END
from NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = 
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END
from NashvilleHousing

--check
select distinct SoldAsVacant, count(SoldAsVacant) as TotalSoldAsVacant
from NashvilleHousing
group by SoldAsVacant
order by 2


-- Remove Duplicates

--Checking if we got the correct rows to remove
SELECT TOP 0 * 
FROM PorfolioProject..NashvilleHousing;

SELECT 
    ParcelID,
	SalePrice,
	SaleDate,
	LegalReference,
    COUNT(*) AS DuplicateCount
FROM 
    PorfolioProject..NashvilleHousing
GROUP BY 
    ParcelID,
	SalePrice,
	SaleDate,
	LegalReference
HAVING 
    COUNT(*) > 1;

-- Deleting the rows 
with DuplicatesCTE as 
(
select 
	ParcelID,
	SalePrice,
	SaleDate,
	LegalReference,
	ROW_NUMBER() over(partition by 
	ParcelID,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID
) as dup_row_num
from NashvilleHousing
)
-- select *
DELETE from DuplicatesCTE
WHERE dup_row_num > 1;



-- DELETING THE UNUSED COLUMNS

SELECT TOP 0 *
FROM NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, PropertyAddress, SaleDate	