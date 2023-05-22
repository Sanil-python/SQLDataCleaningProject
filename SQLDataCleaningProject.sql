--Standardize Date Format

select saledateconverted, convert(date, saledate) from PortfolioProject.dbo.SaiDhamHousing

alter table saidhamhousing
add saledateconverted date

update SaiDhamHousing
set saledateconverted = convert(date, SaleDate)

---------------------------------------------------------------------------------------------------
--Populate Property Address Data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..SaiDhamHousing a
join PortfolioProject..SaiDhamHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..SaiDhamHousing a
	join PortfolioProject..SaiDhamHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

-----------------------------------------------------------------------------------------
--Breaking out PropertAddress into Indivisual column(Address, City, State)

select PropertyAddress from PortfolioProject..SaiDhamHousing

select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, len(propertyaddress)) as Address
from PortfolioProject..SaiDhamHousing

alter table saidhamhousing
add PropertySplitAddress nvarchar(255)

update SaiDhamHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress) - 1)

alter table saidhamhousing
add PropertySplitCity nvarchar(255)

update SaiDhamHousing
set PropertySplitCity = SUBSTRING(propertyaddress, charindex(',', propertyaddress) + 1, len(propertyaddress))

------------------------------------------------------------------------------------------------------------------
--Breaking out OwnerAddress into Indivisual column(Address, City, State)

select
PARSENAME(replace(owneraddress, ',', '.'), 3),
PARSENAME(replace(owneraddress, ',', '.'), 2),
PARSENAME(replace(owneraddress, ',', '.'),1)
from SaiDhamHousing

alter table saidhamhousing
add OwnerSplitAddress nvarchar(255)

update SaiDhamHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',', '.'), 3)

alter table saidhamhousing
add OwnerSplitCity nvarchar(255)

update SaiDhamHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'), 2)

alter table saidhamhousing
add OwnerSplitState nvarchar(255)

update SaiDhamHousing
set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant), COUNT(soldasvacant)
from SaiDhamHousing
group by SoldAsVacant

select soldasvacant,
case
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else SoldAsVacant
end
from SaiDhamHousing

update SaiDhamHousing
set SoldAsVacant = case
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
					end

------------------------------------------------------------------------------------------------------------
--Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by parcelid,
		propertyaddress,
		saleprice,
		saledate,
		legalreference
		order by
			uniqueid) row_num
from SaiDhamHousing)
select *
from RowNumCTE
where row_num > 1

---------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

select * from PortfolioProject.dbo.SaiDhamHousing

alter table saidhamhousing
drop column propertyaddress, saledate, owneraddress, taxdistrict