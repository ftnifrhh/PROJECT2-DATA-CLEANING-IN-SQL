--| PROJECT : DATA CLEANING IN SQL |---------------------------

---- aim : we want to standardized date format and make new column of it -------------
---( then nanti kita buang column sale date yang lama )--
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select saleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing

---- aim : we want to betulkan address yang sama--------
---- explanation : kita dapat ID parcel untuk setiap data yang kita ada tapi ada ada id parcel yang sama tapi address untuk kedua dua id tu
-----------------  satu null, satu property address. so untuk selarikan , kita mesti letak null address kepada address yang sepatutnya. ---

select * 
From NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) as 'Nama Property Yang Null (Sepatutnya)'
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---- aim : we want to breaking out the property address into individual columns --------



SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress) ) as Address
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select PropertyAddress,PropertySplitAddress, PropertySplitCity
from NashvilleHousing




---- aim : we want to breaking out the owner address into individual columns --------

Select OwnerAddress
From NashvilleHousing

Select OwnerAddress,
REPLACE(OwnerAddress, ',', '.') 
From NashvilleHousing

Select OwnerAddress, REPLACE(OwnerAddress, ',', '.') ,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From NashvilleHousing


--- aim : we want to  Change Y and N to Yes and No in "Sold as Vacant" field ---

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select SoldAsVacant
from NashvilleHousing


--- aim : we want to remove duplicates--

WITH RowNumCTE AS
(Select *,
	ROW_NUMBER() OVER 
	(PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID)  as row_num

From NashvilleHousing)

DELETE 
From RowNumCTE
Where row_num > 1




Select *
From NashvilleHousing

--- aim : we want to delete useless column

Select *
From NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
