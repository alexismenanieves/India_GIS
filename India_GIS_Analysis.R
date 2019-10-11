# Load libraries
library(tidyverse)
library(sf)
library(sp)
library(GADMTools)
library(lwgeom)

# Load sf file
my_sf <- st_read("india_states_2014/india_states.shp")
india_wrapper <- gadm_sf.loadCountries("IND", level = 1, basefile = "./")
# See info structure as sp and sf files
my_spdf <- as(my_sf,"Spatial")
class(my_spdf)
str(my_spdf, max.level = 2)
glimpse(my_spdf@data)
ind_sf <- st_as_sf(my_spdf)
head(ind_sf, 3)
glimpse(ind_sf)

# Using sf as dataframe for dplyr
uts <- c("Delhi", "Andaman & Nicobar Islands", "Puducherry", "Lakshadweep", 
        "Dadra & Nagar Haveli", "Daman & Diu", "Chandigarh")
# sf can be used with dplyr, but sp can not
ind_sf <- ind_sf %>% select(name,abbr) %>% 
  mutate(type = ifelse(name %in% uts,"Union Territory", "State")) %>% 
  rename(abb = abbr, state_ut = name)

class(ind_sf)

# Loading attributes
attributes_df <- readRDS("attributes.rds")
ind_sf <- ind_sf %>% left_join(attributes_df, by = "state_ut") %>% 
  mutate(
    per_capita_GDP_inr = nominal_gdp_inr / pop_2011,
    per_capita_GDP_usd = nominal_gdp_usd / pop_2011)

head(ind_sf,3)

# Converting the units
library(units)
ind_sf <- ind_sf %>% mutate(my_area = st_area(.))
units(ind_sf$my_area) <- with(ud_units, km^2)
ind_sf <- ind_sf %>% mutate(GDP_density_usd_km2 = nominal_gdp_usd / my_area)
class(ind_sf$area_km2)
class(ind_sf$my_area)

ind_sf <- ind_sf %>% mutate(my_area = as.vector(my_area),
                            GDP_density_usd_km2 = as.vector(GDP_density_usd_km2))
original_geometry <- st_geometry(ind_sf)
library(rmapshaper)
simp_sf <- ms_simplify(ind_sf, keep = 0.01, keep_shapes = TRUE)
simple_geometry <- st_geometry(simp_sf)
par(mfrow = c(1,2))
plot(original_geometry, main = "Original geometry")
plot(simple_geometry, main = "Simplified geometry")

# Lets see the size of units
library(pryr)
object_size(original_geometry)
object_size(simple_geometry)
saveRDS(simp_sf,"simp_sf.rds")
