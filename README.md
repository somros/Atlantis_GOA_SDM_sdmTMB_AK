# sdmTMB_AFSC_stages

This code produces distribution maps of GOA species from RACE-GAP bottom trawl surveys and the `sdmTMB` package (Anderson et al. 2022), to inform Atlantis GOA initial conditions and seasonal distributions. 

The code calculates stage-specific CPUE from catch and effort data downloaded from AKFIN. The workflow consists of a knitter file that knits .Rmd files for species and stages, and produces tables of long-term (1984-2021) CPUE averages by Atlantis box in Alaska (i.e., British Columbia not handled here). Validation tables are also produced, containing metrics of model convergence and fit. 

For full documentation and for how this approach fits in the development of Atlantis GOA, contact Alberto Rovellini (arovel@uw.edu).
