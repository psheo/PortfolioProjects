/*

Cleaning Data in SQl Format

*/

select *
from [Housing Dataset].dbo.NashvilleHousing

----------------------Standardize  the Data format------------------------------------------------------

select SaleDate, CONVERT (date,SaleDate)
from [Housing Dataset].dbo.NashvilleHousing

Alter table NashvilleHousing
add ConvertedSalesDate date

Update NashvilleHousing
Set ConvertedSalesDate = CONVERT (date,SaleDate)

----------------------Populate Property Address Data------------------------------------------------------

select *
from [Housing Dataset].dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

select X.ParcelID, X.PropertyAddress, Y.ParcelID,Y.PropertyAddress, isnull (X.PropertyAddress,Y.PropertyAddress)
from [Housing Dataset].dbo.NashvilleHousing X
Join [Housing Dataset].dbo.NashvilleHousing Y
on X.ParcelID = Y.ParcelID
and X.[UniqueID ] <> Y.[UniqueID ]
where X.PropertyAddress is null

Update X
Set PropertyAddress = isnull (X.PropertyAddress,Y.PropertyAddress)
from [Housing Dataset].dbo.NashvilleHousing X
Join [Housing Dataset].dbo.NashvilleHousing Y
on X.ParcelID = Y.ParcelID
and X.[UniqueID ] <> Y.[UniqueID ]
where X.PropertyAddress is null

----------------------Breaking address into city, state and address------------------------------------------------------

select PropertyAddress
from [Housing Dataset].dbo.NashvilleHousing

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
-- CHARINDEX(',', PropertyAddress)
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from [Housing Dataset].dbo.NashvilleHousing

Alter table NashvilleHousing
add PropertySplitAddress Nvarchar (255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

Alter table NashvilleHousing
add SplitCity Nvarchar (255)

Update NashvilleHousing
Set SplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-------------------------------Owner's address------------------------------------------------------

select OwnerAddress
from NashvilleHousing

select 
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1) as OwnerSplitState
from NashvilleHousing

Alter table NashvilleHousing
add OwnerSplitAddress Nvarchar (255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
add OwnerSplitCity Nvarchar (255)

Update NashvilleHousing
Set OwnerSplitCity =PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2) 

Alter table NashvilleHousing
add OwnerSplitState Nvarchar (255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1) 

-----------------Changing Y and N to Yes and No in "Sold as vacant" field using CASE Statement---------

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'YES'
     when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 End
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'YES'
     when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 End

----------------------------Remove duplicates------------------------------------------------------

with RowNumCTE as (
select *,
           ROW_NUMBER() Over(
		   Partition by ParcelID,
		                PropertyAddress,
						Saleprice,
						SaleDate,
						LegalReference
						Order by 
						UniqueID
						) row_num

from NashvilleHousing
)

Select*
from RowNumCTE
where row_num >1
order by PropertyAddress

----------------------------Delete Unused Columns ---------------------------------------------

select *
from NashvilleHousing

Alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate