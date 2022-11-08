
-- Data Cleaning SQL
Select * 
From DataCleaningSQL.dbo.NashvilleHousing

------------------------------------------------------------

-- Standardize Date Format
select SaleDate, CONVERT(Date,SaleDate)
From DataCleaningSQL.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)
------------------------------------------------------------

-- Populate Property Address data

Select *
From DataCleaningSQL.dbo.NashvilleHousing
--WHERE PropertyAddress is NOT NULL
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningSQL.dbo.NashvilleHousing a
JOIN DataCleaningSQL.dbo.NashvilleHousing b
	on a.ParcelID  = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] -- <> = NOT EQUAL
Where a.PropertyAddress is NULL

-- Replace NULL address  with the b.PropertyAddress
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningSQL.dbo.NashvilleHousing a
JOIN DataCleaningSQL.dbo.NashvilleHousing b
	on a.ParcelID  = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] -- <> = NOT EQUAL
WHERE a.PropertyAddress is NULL

------------------------------------------------------------------------------------------------------------------------

-- Break Address Into Individual Columns( Address, City, State)


Select PropertyAddress
From DataCleaningSQL.dbo.NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From DataCleaningSQL.dbo.NashvilleHousing

--Create 2 new columns
Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

--- Check the columns that we created
Select *
From DataCleaningSQL.dbo.NashvilleHousing


-- Owneraddress

select OwnerAddress
From DataCleaningSQL.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)   --Replace , with .
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
From DataCleaningSQL.dbo.NashvilleHousing



-- Add and update 3 new columns, (Address, City, State)

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);


Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)



Select *
From DataCleaningSQL.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------------------

--Change Y and N as 'Yes' and 'No' in	"Sold as Vacant" field

--Return only different values in "Sold as Vacant" Columns
select Distinct(SoldAsVacant), Count(SoldAsVacant) as TotalNumber
From DataCleaningSQL.dbo.NashvilleHousing
Group By SoldAsVacant
Order By TotalNumber


Select SoldAsVacant ,
Case 
	When SoldAsVacant	= 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant --Nothing happend, just keep it as original
	END
From DataCleaningSQL.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case 
	When SoldAsVacant	= 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant --Nothing happend, just keep it as original
	END	

--Check the updated column SoldAsVacant. Supposedly no more 'Y' and 'N'
select Distinct(SoldAsVacant), Count(SoldAsVacant) as TotalNumber
From DataCleaningSQL.dbo.NashvilleHousing
Group By SoldAsVacant
Order By TotalNumber

--------------------------------Remove Duplicate----------------------------------------------------------------------------------------
--Remove Duplicate

WITH RowNumCTE AS  -- Creating Temporary Table
 (
select *, 
	Row_number() OVER 
	(
	Partition BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order BY	 UniqueID
	)
	row_num
From DataCleaningSQL.dbo.NashvilleHousing
--order by ParcelID
 )

select *
from RowNumCTE
where row_num > 1
ORDER BY PropertyAddress



-- Delete/remove the duplicates

WITH RowNumCTE AS  -- Creating Temporary Table
 (
select *, 
	Row_number() OVER 
	(
	Partition BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order BY	 UniqueID
	)
	row_num
From DataCleaningSQL.dbo.NashvilleHousing
--order by ParcelID
 )

delete
from RowNumCTE
where row_num > 1
--ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

select *
From DataCleaningSQL.dbo.NashvilleHousing

Alter Table DataCleaningSQL.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

