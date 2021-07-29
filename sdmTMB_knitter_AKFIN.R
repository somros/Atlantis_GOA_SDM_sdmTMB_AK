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
# knots <- 450 # n of knots for the SPDE mesh
cutoff <- 20 # 20 spatial units - 20 km in our case because of the transformtion

## read in objects we will need#########################################################

# coast for plotting
coast <- map("worldHires", regions = c("Canada", "USA"), plot = FALSE, fill = TRUE)
coast <- coast %>% st_as_sf() 

# haul info
load("data/hauls.Rdata") # as accessible on AKFIN Answers with no further modifications

# atlantis bgm
atlantis_bgm <- read_bgm("data/GOA_WGS84_V4_final.bgm")

# prediciton grid, make the depth positive for consistency with RACE data. Also append coordinates, and add time dimension
load("data/atlantis_grid_depth.Rdata")
atlantis_coords <- atlantis_grid_depth %>% st_as_sf(coords = c("x", "y"), crs = atlantis_bgm$extra$projection) %>%
  st_transform(crs = "+proj=longlat +datum=WGS84") %>% dplyr::select(geometry)

atlantis_grid_template <- cbind(atlantis_grid_depth, do.call(rbind, st_geometry(atlantis_coords)) %>%
                         as_tibble() %>% setNames(c("lon","lat")))
#######################################################################################

# load RACE data

load("catch_to_cpue_AKFIN/cpue.Rdata")

# loop over groups
all_groups <- cpue %>% select(CN) %>% distinct() %>% pull()

cpue_knitter <- function(this_group){
  race_data <- cpue %>% filter(CN == this_group)
  
  rmarkdown::render(
    'GOA_sdmTMB_template_AKFIN.Rmd', 
    output_file = paste0("output/", this_group, "_", cutoff, '.html')
  )
}

# run for all groups, start for next group if the model will not converge
purrr::map(all_groups, possibly(cpue_knitter, NA))
