#' Match gadm main function
#'
#' @param shp1_new Shape files of new gadm system
#' @param shp1_old Shape files of old gadm system
#' @param match_nearest whether to match the remaining entries to nearest centroid
#'
#' @return dataframe of old to new adm translation
#'
match_gadm = function(shp1_new, shp1_old, match_nearest){

  ### REMOVE ACCENTS FOR MATCHING and COLLECT COUNTRIES ### ---------------------------------------------------------------
  out = tidy_shp(shp1_new, shp1_old)

  ### MAKE DATAFRAMES ### ----------------------------------------------------------------------------------------
  out = make_shp_dataframes(out$shp1_new, out$shp1_old)

  ### COMBINE lon lat ### -------------------------------------------------------------------------------------
  comb_df = merge_by_lonlat(out$dat_old, out$dat_new)

  ### CHECK POLYGONS ### -------------------------------------------------------------------------------------
  ## FIRST: old to new ###
  comb_df = match_gadm_by_name_and_poly(comb_df, from = "x", to = "y", out$dat_new, shp1_new)

  ## SECOND: new to old ###
  comb_df = match_gadm_by_name_and_poly(comb_df, from = "y", to = "x", out$dat_old, shp1_old)

  ### Matching to nearest centroid ### --------------------------------------------------------------
  if(match_nearest){
    print("Matching to nearest centroid for remaining entries. This is approximate.")

    comb_df = match_gadm_to_nearest_centroid(comb_df, from = "x", to = "y", out$dat_new)

    comb_df = match_gadm_to_nearest_centroid(comb_df, from = "y", to = "x", out$dat_old)
  }

  ### ORDER ### -------------------------------------------------------------------------------------
  comb_df = comb_df[order(comb_df$ID_1.y),]

  comb_df = comb_df[!duplicated(comb_df[, 1:4]),]

  ### FORMAT ### ------------------------------------------------------------------------------------
  comb_df = comb_df[, -ncol(comb_df)]

  names(comb_df) = c("ID_0_old", "ID_0_new", "ID_1_old", "ID_1_new", "NAME_1_old",
                     "NAME_1_new", "lon_old", "lon_new", "lat_old", "lat_new")

  ### RETURN ### ------------------------------------------------------------------------------------
  return(comb_df)
}
