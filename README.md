
<!-- README.md is generated from README.Rmd. Please edit that file -->
matchGADM
=========

The goal of matchGADM is to create a map (a linking file) from old versions of gadm shapefiles to new ones.

Installation
------------

You can install matchGADM from github with:

``` r
# install.packages("devtools")
devtools::install_github("mrc-ide/matchGADM")
```

Example
-------

``` r
library(maptools)
library(matchGADM)
library(rgdal)

### VERSIONS ### --------------------------------------------------------------------------------------------
old_version = "2"
new_version = "36"

### IMPORT ###  ---------------------------------------------------------------------------------------------
shp1_old = readShapePoly(paste0("../gadm", old_version, "/Africa_adm1.shp"))
shp1_new = readOGR(paste0("../gadm", new_version, "/Africa_adm1.shp"),
                   use_iconv = TRUE, encoding = "UTF-8")

#make sure names are in the right format
names(shp1_new)[1] = "ISO"
names(shp1_new)[3] = "ID_1"

#run to get the linking dataframe
comb_df = match_gadm(shp1_new, shp1_old, match_nearest = TRUE)
```

The first line of `comb_df` woud then be:

    #>   ID_0_old ID_0_new ID_1_old ID_1_new NAME_1_old NAME_1_new  lon_old
    #> 1      AGO      AGO        1  AGO.1_1      Bengo      Bengo 13.88142
    #>    lon_new   lat_old   lat_new
    #> 1 13.88142 -8.977751 -8.977751
