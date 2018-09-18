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






#' Make dataframes of shape files
#'
#' @param shp1_new Shape files of new gadm system
#' @param shp1_old Shape files of old gadm system
#'
#' @return dataframes of shape file info

make_shp_dataframes = function(shp1_new, shp1_old) {

  ### ATTACH LON LAT ### --------------------------------------------------------------------------------------
  dat_old = cbind(shp1_old@data, lon = sp::coordinates(shp1_old)[, 1],
                  lat = sp::coordinates(shp1_old)[, 2])

  dat_new = cbind(shp1_new@data, lon = sp::coordinates(shp1_new)[, 1],
                  lat = sp::coordinates(shp1_new)[, 2])

  dat_new$lonlat = paste0(format(round(dat_new$lon, 2), nsmall = 2), "_", format(round(dat_new$lat, 2), nsmall = 2))
  dat_old$lonlat = paste0(format(round(dat_old$lon, 2), nsmall = 2), "_", format(round(dat_old$lat, 2), nsmall = 2))


  ### GET NAMES ### -------------------------------------------------------------------------------------
  namevec = c("ISO", "ID_1", "NAME_1", "lon", "lat", "lonlat")

  dat_new = dat_new[, namevec]
  dat_old = dat_old[, namevec]

  dat_old$ISO = as.character(dat_old$ISO)
  dat_new$ISO = as.character(dat_new$ISO)

  return(list(dat_new = dat_new, dat_old = dat_old))
}
