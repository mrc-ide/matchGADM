
<!-- README.md is generated from README.Rmd. Please edit that file -->
matchGADM
=========

The goal of matchGADM is to create a map (a linking file) from old versions of gadm shapefiles to new ones.

Main approach
-------------

`match_gadm` is the main function which links old and new shapefile entries through 3 approaches:

-   It rounds the longitude and latitude of the centroid, turns this into a string and performs a full join based on this value.
-   The missing links are then matched either by name or, if that fails, by checking which polygon of the new version contains the centroid of the old version, and vice versa.
-   Finally, and this is optional, it matches the remaining entries to the nearest centroid of the new gadm version. This is the default but can be stopped by setting `match_nearest = FALSE`.

Matching by area
----------------

There are two functions to match by and quanitfy the amount of overlapping area between old and new shapefiles. The first, `grid_match`, produces a grid of points which are matched to the old shape files and then distributed among the new. If the grid is coarse, this is a fast and approximate quantification of shared errors. As the grid becomes finer, it may be better to use `area_match` as this will be more accurate and faster for very fine grids. Area match quatifies the area of the intersection of the polygons in each shapefile. This is highly accurate but given the uncertainty in the polygon edges, may lead to a lot of small area matches.

Installation
------------

You can install matchGADM from github with:

``` r
# install.packages("drat")
drat:::add("mrc-ide")
install.packages("matchGADM")
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
link_df = match_gadm(shp1_new, shp1_old, match_nearest = TRUE)
```

The first line of `link_df` woud then be:

| ID\_0\_old | ID\_0\_new |  ID\_1\_old| ID\_1\_new | NAME\_1\_old | NAME\_1\_new |  lon\_old|  lon\_new|   lat\_old|   lat\_new|
|:-----------|:-----------|-----------:|:-----------|:-------------|:-------------|---------:|---------:|----------:|----------:|
| AGO        | AGO        |           1| AGO.1\_1   | Bengo        | Bengo        |  13.88142|  13.88142|  -8.977751|  -8.977752|
