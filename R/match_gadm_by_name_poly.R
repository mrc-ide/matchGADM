#' Match gadm by name and polygon
#'
#' @param joined_df data frame of joined shape dataframes
#' @param from which way to match from
#' @param to which way to match to
#' @dat dataframe to be matched to
#' @shp1 shape to be matched to
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
        tmp = point.in.polygon(joined_df[i, paste0("lon.",from)],
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
