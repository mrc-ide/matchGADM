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
