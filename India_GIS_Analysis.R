# Load libraries
library(tidyverse)
library(sf)
library(sp)
library(GADMTools)
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



