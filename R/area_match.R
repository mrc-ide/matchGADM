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

  #Zero width buffer to fix overlapping issues
  shp1_old<-gBuffer(shp1_old, byid = T, width = 0)
  shp1_new<-gBuffer(shp1_new, byid = T, width = 0)

  #Intersecting points
  shp1shp2int = raster::intersect(shp1_old, shp1_new)
  row.names(shp1shp2int)<-as.character(1:nrow(shp1shp2int))

  #Extract areas from polygon objects then attach as attribute
  areas = data.frame(area=sapply(shp1shp2int@polygons, FUN=function(x) {slot(x, 'area')}))

  row.names(areas) = row.names(shp1shp2int)

  #Combine attributes info and areas
  attArea = spCbind(shp1shp2int, areas)

  #Now to apply this stuff
  df1 = data.frame(attArea)
  df1 = df1[order(df1[,1]),]

  #Fine areas
  shp1_areas = data.frame(ID_1 = as.character(shp1_old$SP_ID),
                          area = sapply(shp1_old@polygons, FUN = function(x) {slot(x, 'area')}),
                          stringsAsFactors = FALSE)

  shp1_areas$area = as.numeric(as.character(shp1_areas$area))

  shp1_areas = stats::aggregate(shp1_areas[, "area"], by=list(shp1_areas$ID_1), FUN=sum)

  names(shp1_areas) = c("ID_1", "area")

  df1$prop = sapply(1:nrow(df1), function(x){
    oldid1 = as.character(df1[, "SP_ID"][x])
    all_area = shp1_areas[which(shp1_areas$ID_1 %in% oldid1), "area"]
    df1[x, "area"]/all_area
  })

  ## output same as grid_match

  output_df = df1[, c("SP_ID", "ID_1.2", "prop")]
  output_df[, "ID_1.2"]<-gsub("\\.|_1", "", output_df[, "ID_1.2"])
  names(output_df) = c("old_id", "new_id", "proportion")
  output_df<-output_df[order(output_df$old_id, output_df$new_id), ]

  output_df

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

  #Zero width buffer to fix overlapping issues
  shp1_old<-gBuffer(shp1_old, byid = T, width = 0)
  shp1_new<-gBuffer(shp1_new, byid = T, width = 0)

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
