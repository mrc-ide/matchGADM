#' Make dataframes of shape files
#'
#' @param shp1_new Shape files of new gadm system
#' @param shp2_new Shape files of old gadm system
#'
#' @return dataframes of shape file info

make_shp_dataframes = function(shp1_new, shp1_old) {

    ### ATTACH LON LAT ### --------------------------------------------------------------------------------------
    dat_old = cbind(shp1_old@data, lon = coordinates(shp1_old)[, 1], lat = coordinates(shp1_old)[, 2])

    dat_new = cbind(shp1_new@data, lon = coordinates(shp1_new)[, 1], lat = coordinates(shp1_new)[, 2])

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
