#' Tidy shapefiles
#'
#' @param shp1_new Shape files of new gadm system
#' @param shp1_old Shape files of old gadm system
#'
#' @return Cleaned versions of the shapefiles

tidy_shp = function(shp1_new, shp1_old) {

  # collect countries
  shp1_new = shp1_new[shp1_new$ISO %in% shp1_old$ISO, ]

  # remove accents
  shp1_old$NAME_0 = stringi::stri_trans_general(shp1_old$NAME_0, "Latin-ASCII")
  shp1_old$NAME_1 = stringi::stri_trans_general(shp1_old$NAME_1, "Latin-ASCII")

  shp1_new$NAME_0 = stringi::stri_trans_general(shp1_new$NAME_0, "Latin-ASCII")
  shp1_new$NAME_1 = stringi::stri_trans_general(shp1_new$NAME_1, "Latin-ASCII")

  # remove special characters
  shp1_new$NAME_1 = gsub("!", "", shp1_new$NAME_1)

  #check names
  if(!"ISO" %in% names(shp1_new)){ stop("Check names of new shape file- should include ISO")}
  if(!"ISO" %in% names(shp1_old)){ stop("Check names of old shape file- should include ISO")}

  return(list(shp1_new = shp1_new, shp1_old = shp1_old))
}
