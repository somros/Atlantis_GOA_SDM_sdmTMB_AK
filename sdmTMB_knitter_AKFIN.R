# sdmTMB knitter for invertebrates

# load packages
library(tidyverse)
library(sdmTMB)
library(sf)
library(rbgm)
library(viridis)
library(kableExtra)
library(maps)
library(mapdata)

# setup
select <- dplyr::select
cutoff <- 20 # 20 spatial units - 20 km in our case because of the transformtion

## read in objects we will need#########################################################

# coast for plotting
coast <- map("worldHires", regions = c("Canada", "USA"), plot = FALSE, fill = TRUE)
coast <- coast %>% st_as_sf() 

# haul info
hauls <- read.csv("catch_to_CPUE_AKFIN/Haul Descriptions.csv", fileEncoding = "UTF-8-BOM") # as accessible on AKFIN Answers with no further modifications

# atlantis bgm
atlantis_bgm <- read_bgm("data/GOA_WGS84_V4_final.bgm")

# prediction grid, make the depth positive for consistency with RACE data. Also append coordinates, and add time dimension
load("data/atlantis_grid_depth.Rdata")
atlantis_coords <- atlantis_grid_depth %>% st_as_sf(coords = c("x", "y"), crs = atlantis_bgm$extra$projection) %>%
  st_transform(crs = "+proj=longlat +datum=WGS84") %>% dplyr::select(geometry)

atlantis_grid_template <- cbind(atlantis_grid_depth, do.call(rbind, st_geometry(atlantis_coords)) %>%
                         as_tibble() %>% setNames(c("lon","lat")))
#######################################################################################
# load RACE data

load("catch_to_cpue_AKFIN/cpue_by_stage.Rdata")

# loop over groups
all_groups <- cpue %>% select(CN,STAGE) %>% distinct()

cpue_knitter <- function(this_group,this_stage){
  
  race_data <- cpue %>% filter(CN == this_group & STAGE==this_stage)
  
  n_knots <- ifelse(this_group=='Flatfish_shallow',5,3) # flatfish shallow is one of the notable ones that benefit from 5 knots in AK
  
  rmarkdown::render(
    'GOA_sdmTMB_template_AKFIN.Rmd', 
    output_file = paste0("output/", this_group, this_stage, "_", cutoff, '.html')
  )
}

# run for all groups, start for next group if the model will not converge
purrr::map2(all_groups$CN, all_groups$STAGE, possibly(cpue_knitter, NA))
