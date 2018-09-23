#' Function that approximately matches shape file areas through a grid of points
#'
#'@param shp1_old Shape files of old gadm system
#'@param shp1_new Shape files of new gadm system
#'@param increment Width of the grid squares. Defaults to 0.15
#'
#'@return proportion of old shapefiles in new shapefiles (approximate)

grid_match = function(shp1_old,
                      shp1_new,
                      increment= 0.15){

  ### check increment is not too big ### ------------------------------------------------------ -------------------
  if(increment>0.5){message("Are you sure you want an increment this large, the results may be very inaccurate.")}

  ### MAKE DATAFRAMES ### -----------------------------------------------------------------------------------------
  out2 = make_shp_dataframes(shp1_new, shp1_old)
  dat_new = out2$dat_new
  dat_old = out2$dat_old

  ### get grid extent ### -----------------------------------------------------------------------------------------
  grid_min_x = grid_min_y = grid_max_x = grid_max_y = NA
  for( p in 1:nrow(dat_old)){
    grid_min_x = min( rbind( shp1_old@polygons[[p]]@Polygons[[1]]@coords[,1] , grid_min_x), na.rm = TRUE)
    grid_max_x = max( rbind( shp1_old@polygons[[p]]@Polygons[[1]]@coords[,1] , grid_max_x), na.rm = TRUE)
    grid_min_y = min( rbind( shp1_old@polygons[[p]]@Polygons[[1]]@coords[,2] , grid_min_y), na.rm = TRUE)
    grid_max_y = max( rbind( shp1_old@polygons[[p]]@Polygons[[1]]@coords[,2] , grid_max_y), na.rm = TRUE)
  }

  ### make grid ### -----------------------------------------------------------------------------------------------
  x_coords = seq(grid_min_x, grid_max_x+0.1, by = increment)
  y_coords = seq(grid_min_y, grid_max_y+0.1, by = increment)

  grid_coords = expand.grid(x_coords, y_coords)
  names(grid_coords) = c("x", "y")

  ### check points are in polygons ### ---------------------------------------------------------------------------
  grid_in_poly = sapply(1:nrow(dat_old),
                        FUN = function(p) {
                          tmp = sp::point.in.polygon(grid_coords$x,
                                                     grid_coords$y,
                                                     shp1_old@polygons[[p]]@Polygons[[1]]@coords[,1],
                                                     shp1_old@polygons[[p]]@Polygons[[1]]@coords[,2]) } )
  ### distribute in new polygons ### ------------------------------------------------------------------------------
  distribute_points = function(p,q){

    ind = which(grid_in_poly[,p]>0)

    tmp = sp::point.in.polygon(grid_coords[ind,"x"],
                               grid_coords[ind,"y"],
                               shp1_new@polygons[[q]]@Polygons[[1]]@coords[,1],
                               shp1_new@polygons[[q]]@Polygons[[1]]@coords[,2])

    sum(tmp, na.rm = TRUE)/ nrow(grid_coords[ind,])
  }

  proportions = sapply(1:nrow(dat_old), FUN=function(p){mapply(distribute_points, 1:nrow(dat_new), MoreArgs = list(p=p))})

  ### sort out proportions ### -----------------------------------------------------------------------------------------
  proportions_df = as.data.frame(proportions)
  rownames(proportions_df) = dat_new$NAME_1
  colnames(proportions_df) = dat_old$NAME_1

  propn_out = cbind( reshape2::melt(proportions_df, id.vars=NULL), "new" = rep(dat_new$NAME_1, nrow(dat_old)))

  propn_out = dplyr::filter(propn_out, value>0)

  propn_out = propn_out[,c(1,3,2)]

  names(propn_out) = c("old", "new", "proportion")

  propn_out$ISO = rep(dat_old$ISO[1], nrow(propn_out))

  return(propn_out)

}



#' grid match for multiple countries
#'
#'@param shp1_old Shape files of old gadm system
#'@param shp1_new Shape files of new gadm system
#'@param increment Width of the grid squares. Defaults to 0.15
#'
#'@return grid match for multiple countries and list of unmatched countries
#'
grid_match_multi = function(shp1_old,
                            shp1_new,
                            increment = 0.15){

  ### REMOVE ACCENTS FOR MATCHING and COLLECT COUNTRIES ### -------------------------------------------------------
  out = tidy_shp(shp1_new, shp1_old)
  shp1_new = out$shp1_new
  shp1_old = out$shp1_old

  ## number of countries
  countries = as.character( unique(shp1_old$ISO))

  tmp = lapply(1:length(countries),
               function(c){grid_match(subset(shp1_old, ISO == countries[c]),
                                      subset(shp1_new, ISO == countries[c]),
                                      increment)} )

  tmp = tmp[lapply(tmp, nrow)>0]

  output_df = data.table::rbindlist( tmp )

  missing = countries[which(!countries %in% unique(output_df$ISO))]

  return(list(proportions = output_df, missing = missing))
}
