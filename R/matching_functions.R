
#' Match gadm by name and polygon
#'
#' @param joined_df data frame of joined shape dataframes
#' @param from which way to match from
#' @param to which way to match to
#' @param dat dataframe to be matched to
#' @param shp1 shape to be matched to
#'
#' @return updated dataframe

match_gadm_by_name_and_poly = function(joined_df,
                                       from = "x",
                                       to = "y",
                                       dat, #dat_new
                                       shp1 #shp1_new
){



  missing_ind = which( is.na(joined_df[,paste0("ISO.",to)]) )

  for(i in missing_ind){

    #we need to check which new polygon the old points lie in
    country_ind = which(dat$ISO == joined_df[i, paste0("ISO.",from)])

    #try matching on name first
    name_ind = match(joined_df[i, paste0("NAME_1.",from)], dat$NAME_1[country_ind])
    dat_ind = country_ind[name_ind]

    #if that fails, match on polygons
    if(is.na(dat_ind)){
      inpoly = NULL
      for(p in country_ind){
        tmp = sp::point.in.polygon(joined_df[i, paste0("lon.",from)],
                                   joined_df[i, paste0("lat.",from)],
                                   shp1@polygons[[p]]@Polygons[[1]]@coords[,1],
                                   shp1@polygons[[p]]@Polygons[[1]]@coords[,2])
        inpoly = rbind(inpoly, tmp)
      }

      # where inpoly is greater than zero, the point lies in the polygon
      if(sum(inpoly>0)){
        inpoly_ind = which(inpoly>0)
      } else{
        inpoly_ind = NA
      }
      dat_ind = country_ind[inpoly_ind]
    }

    if(!is.na(dat_ind)){
      joined_df[i, c(paste0("ISO.",to),paste0("NAME_1.",to),paste0("ID_1.",to),paste0("lon.",to),paste0("lat.",to))] =
        dat[dat_ind, c("ISO","NAME_1","ID_1","lon","lat")]
    }
  }

  return(joined_df)
}




#' Match gadm to the nearest centroid
#'
#' @param joined_df data frame of joined shape dataframes
#' @param from which way to match from
#' @param to which way to match to
#' @param dat dataframe to be matched to
#'
#' @return updated dataframe

match_gadm_to_nearest_centroid = function(joined_df,
                                          from = "x",
                                          to = "y",
                                          dat #dat_new
){

  #SHOULD BE RUN LAST ALWAYS
  #print("Have you tried all other matching functions? This is a last resort.")

  missing_ind = which( is.na(joined_df[,paste0("ISO.",to)]) )

  for(i in missing_ind){

    #we need to check which new polygon the old points lie in
    country_ind = which(dat$ISO == joined_df[i, paste0("ISO.",from)])


    #calculate euclidean distance to each centroid and match to nearest
    centroid_distance = NULL
    for(p in country_ind){
      tmp = dist( rbind(as.numeric(joined_df[i, c(paste0("lon.",from), paste0("lat.",from))]),
                        as.numeric(dat[p, c("lon", "lat")]) ) )
      centroid_distance = rbind(centroid_distance, tmp)
    }

    # find the minimum centroid_distance
    centroid_distance_ind = which(centroid_distance == min(centroid_distance))

    dat_ind = country_ind[centroid_distance_ind]

    if(!is.na(dat_ind)){
      joined_df[i, c(paste0("ISO.",to),paste0("NAME_1.",to),paste0("ID_1.",to),paste0("lon.",to),paste0("lat.",to))] =
        dat[dat_ind, c("ISO","NAME_1","ID_1","lon","lat")]
    }
  }


  return(joined_df)
}





#' Match gadm by their address
#'
#' @param joined_df data frame of joined shape dataframes
#' @param from which way to match from
#' @param to which way to match to
#' @param dat dataframe to be matched to
#'
#' @return updated dataframe of match and list of unmatched names

match_gadm_by_address = function(joined_df,
                                 from = "x",
                                 to = "y",
                                 dat #dat_new
){

  missing_ind = which(is.na(joined_df[,paste0("ISO.",to)]))

  unmatch_name = NULL
  for (i in missing_ind){

    location = as.numeric(joined_df[i, c(paste0("lon.",from), paste0("lat.",from))])

    tmp = NA
    infloopbreak = 0
    while(is.na(tmp) & infloopbreak<10){ #try 10 times to get an answer
      tmp = ggmap::revgeocode(location, output="more", messaging = FALSE)
      infloopbreak = infloopbreak + 1
    }

    match_ind = which(dat$NAME_1 == strsplit(as.character(tmp$administrative_area_level_1), " +")[[1]][1] )

    if(sum(match_ind)>0){
      joined_df[i, c(paste0("ISO.",to),paste0("NAME_1.",to),paste0("ID_1.",to),paste0("lon.",to),paste0("lat.",to))] =
        dat[match_ind, c("ISO","NAME_1","ID_1","lon","lat")]
    } else {
      unmatch_name = rbind(unmatch_name, cbind(joined_df[i, paste0("NAME_1.",from)],
                                               as.character(tmp$administrative_area_level_1) ) )
    }
  }

  return(list(joined_df = joined_df, unmatch_name = unmatch_name))
}
