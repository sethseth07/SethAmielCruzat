-- Create NEW Schema for world_layoffs --
-- Right Click on Table to Import Data from layoffs file --

-- Create a staging prompt for the imported file --
create table layoffs_staging like layoffs;
select * from layoffs_staging;
insert layoffs_staging select * from layoffs;
select * from layoffs_staging;

-- DATA CLEANING --


-- 1. Remove Duplicates --
-- a. Select Everything and add a row_number with columns similar to the original --
select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) from layoffs_staging;

-- b. Create a separate table with the inlucsion of row_num --
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- c. insert the information from previous table with the addition of row number --
insert layoffs_staging2 select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num from layoffs_staging;

-- d. check if everything is correct --
select * from layoffs_staging2;
select * from layoffs_staging2 where row_num > 1;

-- e. delete everything with the duplicate row_num --
set sql_safe_updates = 0;
delete from layoffs_staging2 where row_num >1;
select * from layoffs_staging2 where row_num > 1;


-- 2. Standardize the Data --
-- a. Trim any extra Characters --
select * from layoffs_staging2;
select company, trim(company) from layoffs_staging2;
update layoffs_staging2 set company = trim(company);

-- b. Update any repeating value with the same meaning or value --
select * from layoffs_staging2;
select * from layoffs_staging2 where industry like 'Crypto%';
update layoffs_staging2 set industry = 'Crypto' where industry like 'Crypto%';
select * from layoffs_staging2 where industry like 'Crypto%';

select * from layoffs_staging2;
select distinct country from layoffs_staging2 order by 1;
update layoffs_staging2 set country = 'United States' where country like 'United States%';
select distinct country from layoffs_staging2 order by 1;

-- c. Change the Date Format --
select * from layoffs_staging2;
select `date`, str_to_date(`date`, '%m/%d/%Y') from layoffs_staging2;
update layoffs_staging2 set `date` = str_to_date(`date`, '%m/%d/%Y');
select * from layoffs_staging2;


-- 3. Null Values or Blank Values --
-- a. Determine the rows or columns with null values and update or populate them from existing data --
select * from layoffs_staging2;
select * from layoffs_staging2 where industry is null or industry = '';
select * from layoffs_staging2 where company like 'AirBnB%';
select * from layoffs_staging2 as t1 join layoffs_staging2 as t2 on t1.company = t2.company where (t1.industry is null or t1.industry = '') and t2.industry is null;
update layoffs_staging2 set industry = null where industry = '';
update layoffs_staging2 as t1 join layoffs_staging2 as t2 on t1.company = t2.company set t1.industry = t2.industry where t1.industry is null and t2.industry is not null;
select * from layoffs_staging2 where company like 'AirBnB%';


-- 4. Remove Unnecessary Rows/Columns --
-- a. Remove the rows with many null values not needed for the data set --
select * from layoffs_staging2;
select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;
delete from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;
select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

-- b. Remove the columns not needed --
alter table layoffs_staging2 drop row_num;
select * from layoffs_staging2;