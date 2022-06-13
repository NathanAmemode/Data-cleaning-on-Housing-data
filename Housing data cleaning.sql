--Cleaning data in sql queries

select *
from [Housing Data]..NashvilleHousing;

--standardize date time format: SaleDate column

select SaleDate, SaleDateConverted 
from [Housing Data]..NashvilleHousing;

alter table [Housing Data]..NashvilleHousing
add SaleDateConverted Date;

update [Housing Data]..NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate);

--Populate property address

select *
from [Housing Data]..NashvilleHousing
--where PropertyAddress is null;
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Housing Data]..NashvilleHousing a
join [Housing Data]..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Housing Data]..NashvilleHousing a
join [Housing Data]..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns (Address, city, state)

/* Testing code
select PropertyAddress
SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from [Housing Data]..NashvilleHousing
*/

alter table [Housing Data]..NashvilleHousing
add PropertyADD NVARCHAR(255);

update [Housing Data]..NashvilleHousing
set PropertyADD = SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1);

alter table [Housing Data]..NashvilleHousing
add PropertyCITY NVARCHAR(255);

update [Housing Data]..NashvilleHousing
set PropertyCITY = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

--Owner Address

--testing
select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from [Housing Data]..NashvilleHousing;

--Actual working
alter table [Housing Data]..NashvilleHousing
add OwnerADD NVARCHAR(255);

update [Housing Data]..NashvilleHousing
set OwnerADD = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

alter table [Housing Data]..NashvilleHousing
add OwnerCITY NVARCHAR(255);

update [Housing Data]..NashvilleHousing
set OwnerCITY = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);

alter table [Housing Data]..NashvilleHousing
add OwnerSTATE NVARCHAR(255);

update [Housing Data]..NashvilleHousing
set OwnerSTATE = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);

select *
from [Housing Data]..NashvilleHousing

--CHANGE Y AND N TO YES AND NO IN 'SoldAsVacant

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from [Housing Data]..NashvilleHousing
group by SoldAsVacant
order by 2

--testing
select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from [Housing Data]..NashvilleHousing

--work

update [Housing Data]..NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End


-- REMOVE DUPLICATES
--N/B never delete data from database, make copies before making alteriations or filter only data you need.

WITH rowNumCTE AS(
select *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num

from [Housing Data]..NashvilleHousing
--order by ParcelID
)
Select *
from rowNumCTE
where row_num > 1
--order by PropertyAddress

--DELETE UNUSED COLUMNS
--N/B don't delete from raw data.

select * 
from [Housing Data]..NashvilleHousing;

alter table [Housing Data]..NashvilleHousing 
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict;