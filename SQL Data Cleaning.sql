SELECT * FROM Portfolio..NashvilleHousing



--Standardizing Date Format

SELECT SaleDate FROM Portfolio..NashvilleHousing

SELECT SaleDate, CONVERT(Date, Saledate) FROM Portfolio..NashvilleHousing

Update Portfolio..NashvilleHousing 
SET SaleDate = CONVERT(Date, Saledate)

ALTER TABLE Portfolio..NashvilleHousing 
Add SalesDateConverted DATE

Update Portfolio..NashvilleHousing 
SET SalesDateConverted = CONVERT(Date, Saledate)

SELECT SalesDateConverted, CONVERT(Date, Saledate) FROM Portfolio..NashvilleHousing

-- Populate Property Data

SELECT * 
FROM Portfolio..NashvilleHousing 
--Where PropertyAddress is null
order by ParcelID

SELECT a.PropertyAddress, a.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing 
a Join Portfolio..NashvilleHousing b 
on a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
set PropertyAddress = 
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing 
a Join Portfolio..NashvilleHousing b 
on a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Separating Address into Differet Columns (Address, City, & State)

SELECT PropertyAddress 
FROM Portfolio..NashvilleHousing 
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As Address
FROM Portfolio..NashvilleHousing 

--Creating New Columns

ALTER TABLE Portfolio..NashvilleHousing 
Add PropertySplitAddress nvarchar(255)

Update Portfolio..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Portfolio..NashvilleHousing 
Add PropertySplitCity nvarchar(255)

Update Portfolio..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT SalesDateConverted, CONVERT(Date, Saledate) FROM Portfolio..NashvilleHousing


SELECT * FROM Portfolio..NashvilleHousing


SELECT OwnerAddress FROM Portfolio..NashvilleHousing

SELECT PARSENAME(replace(OwnerAddress, ',', '.') , 3),
PARSENAME(replace(OwnerAddress, ',', '.') , 2),
PARSENAME(replace(OwnerAddress, ',', '.') , 1)
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing 
Add OwnerSplitAddress nvarchar(255)

Update Portfolio..NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.') , 3)

ALTER TABLE Portfolio..NashvilleHousing 
Add OwnerSplitCity nvarchar(255)

Update Portfolio..NashvilleHousing 
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.') , 2)

ALTER TABLE Portfolio..NashvilleHousing 
Add OwnerSplitState nvarchar(255)

Update Portfolio..NashvilleHousing 
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.') , 1)

SELECT * FROM Portfolio..NashvilleHousing

-- Change Y and N to Yes and No

select distinct(SoldAsVacant), count(SoldAsVacant) from Portfolio..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant, case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from Portfolio..NashvilleHousing

Update Portfolio..NashvilleHousing 
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


--I want to remove duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice,
SaleDate, LegalReference
Order by UniqueID) ROW_NUMBER
FROM Portfolio..NashvilleHousing 
--Order by ParcelID
)
SELECT * FROM RowNumCTE where
ROW_NUMBER > 1
Order by PropertyAddress

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice,
SaleDate, LegalReference
Order by UniqueID) ROW_NUMBER
FROM Portfolio..NashvilleHousing 
--Order by ParcelID
)
Delete FROM RowNumCTE where
ROW_NUMBER > 1
--Order by PropertyAddress

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice,
SaleDate, LegalReference
Order by UniqueID) ROW_NUMBER
FROM Portfolio..NashvilleHousing 
--Order by ParcelID
)
SELECT * FROM RowNumCTE where
ROW_NUMBER > 1
Order by PropertyAddress

SELECT * FROM Portfolio..NashvilleHousing

--Deleting unused columns

Alter Table Portfolio..NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

Alter Table Portfolio..NashvilleHousing
Drop Column SaleDate

SELECT * FROM Portfolio..NashvilleHousing