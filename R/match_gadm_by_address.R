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
