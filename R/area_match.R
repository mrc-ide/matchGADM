#' Function that approximately matches shape file areas through area. From Arran's area match function
#'
#'@param shp1_old Shape files of old gadm system
#'@param shp1_new Shape files of new gadm system
#'@param increment Width of the grid squares. Defaults to 0.15
#'
#'@return proportion of old shapefiles in new shapefiles

area_match = function(shp1_old,
                      shp1_new){

  #Make sure projections are the same
  raster::projection(shp1_new) = raster::projection(shp1_old)

  #Intersecting points
  shp1shp2int = raster::intersect(shp1_old, shp1_new)

  #Extract areas from polygon objects then attach as attribute
  areas = data.frame(area=sapply(shp1shp2int@polygons, FUN=function(x) {slot(x, 'area')}))
  row.names(areas) = sapply(shp1shp2int@polygons, FUN=function(x) {slot(x, 'ID')})

  #Combine attributes info and areas
  attArea = spCbind(shp1shp2int, areas)

  #Now to apply this stuff
  df1 = data.frame(attArea)
  df1 = df1[order(df1[,1]),]

  #Fine areas
  shp1_areas = data.frame(ID_1=shp1_old$ID_1,
                          area=sapply(shp1_old@polygons, FUN=function(x) {slot(x, 'area')}),
                          stringsAsFactors = FALSE)

  shp1_areas$area = as.numeric(as.character(shp1_areas$area))

  shp1_areas = stats::aggregate(shp1_areas, by=list(shp1_areas$ID_1), FUN=sum)[,c(1,3)]

  names(shp1_areas) = c("ID_1","area")

  df1$prop = sapply(1:dim(df1)[1],
                    function(x){oldid1 = df1[,"ID_1.1"][x]
                    all_area = shp1_areas[which(shp1_areas$ID_1 %in% oldid1),"area"]
                    df1[x,"area"]/all_area
                    })

  ## output same as grid_match

  output_df = df1[, c("ID_1.1", "ID_1.2", "prop")]
  names(output_df) = c("old", "new", "proportion")

  return(output_df)
}



#' area match for multiple countries
#'
#'@param shp1_old Shape files of old gadm system
#'@param shp1_new Shape files of new gadm system
#'@param increment Width of the grid squares. Defaults to 0.15
#'
#'@return grid match for multiple countries and list of unmatched countries
#'
area_match_multi = function(shp1_old,
                            shp1_new){

  ### REMOVE ACCENTS FOR MATCHING and COLLECT COUNTRIES ### -------------------------------------------------------
  out = tidy_shp(shp1_new, shp1_old)
  shp1_new = out$shp1_new
  shp1_old = out$shp1_old

  ## number of countries
  countries = as.character( unique(shp1_old$ISO))

  tmp = lapply(1:length(countries),
               function(c){area_match(subset(shp1_old, ISO == countries[c]),
                                      subset(shp1_new, ISO == countries[c]))} )

  tmp = tmp[lapply(tmp, nrow)>0]

  output_df = data.table::rbindlist( tmp )

  missing = countries[which(!countries %in% unique(output_df$ISO))]

  return(list(proportions = output_df, missing = missing))
}