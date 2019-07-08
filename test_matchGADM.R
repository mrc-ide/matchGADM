
library(maptools)
library(matchGADM)
library(rgdal)

### VERSIONS ### --------------------------------------------------------------------------------------------
old_version = "2"
new_version = "36"

### IMPORT ###  ---------------------------------------------------------------------------------------------
shp1_old = readShapePoly(paste0("data/gadm", old_version, "/Africa_adm1.shp"))
shp1_new = readOGR(paste0("data/gadm", new_version, "/Africa_adm1.shp"),
                   use_iconv = TRUE, encoding = "UTF-8")

names(shp1_new)[1] = "ISO"
names(shp1_new)[3] = "ID_1"

comb_df = match_gadm(shp1_new, shp1_old, match_nearest = TRUE)

#documentation
package?matchGADM

#------------------------------------------------------------------------------------------------------------

### VERSIONS ### --------------------------------------------------------------------------------------------
old_version = "2"
new_version = "28"

### IMPORT ###  ---------------------------------------------------------------------------------------------
BFA_shp1_old = readShapePoly(paste0("../gadm", old_version, "/BFA_adm/BFA_adm1.shp"))
BFA_shp1_new = readShapePoly(paste0("../gadm", new_version, "/BFA_adm/BFA_adm1.shp"))

BFA_comb_df = match_gadm(BFA_shp1_new, BFA_shp1_old, match_nearest = TRUE)

#------------------------------------------------------------------------------------------------------------

# more accurate ish
BFA_proportions = grid_match_multi(shp1_new = BFA_shp1_new, shp1_old = BFA_shp1_old, increment = 0.1)$proportions

#out = grid_match_multi(shp1_new = shp1_new, shp1_old = shp1_old, increment = 0.1)
