
<!-- README.md is generated from README.Rmd. Please edit that file -->

# matchGADM

The goal of matchGADM is to create a map (a linking file) from old
versions of gadm shapefiles to new ones.

# Example usage

We load some example data to show potential usage for the main
functions, `area_match` and `area_match_multi`.

``` r

library(maptools)
library(matchGADM)
library(rgdal)
library(rgeos)

### VERSIONS ### --------------------------------------------------------------------------------------------
old_version = "2"
new_version = "36"

### IMPORT ###  ---------------------------------------------------------------------------------------------
shp1_old = readShapePoly(paste0("data/gadm", old_version, "/Africa_adm1.shp"))
shp1_new = readOGR(paste0("data/gadm", new_version, "/Africa_adm1.shp"),
                   use_iconv = TRUE, encoding = "UTF-8")

names(shp1_new)[1] = "ISO"
names(shp1_new)[3] = "ID_1"

ptm <- proc.time()
comb_df = area_match_multi(shp1_old, shp1_new)
proc.time() - ptm
```

One could also use `area_match` in the same way if the boundaries of
countries are known to have changed; however, this will be slower to
implement.
