#' Merge dataframes of shapefiles by rounded longitude and latitude
#'
#' @param dat_new dataframe of new shapefiles
#' @param dat_old dataframe of old shapefiles
#'
#' @return data frame of joined shape dataframes
#'

merge_by_lonlat = function(dat_old, dat_new) {

    joined_df = merge(dat_old, dat_new, by = "lonlat", all = TRUE)

    joined_df = joined_df[, c("ISO.x", "ISO.y", "ID_1.x", "ID_1.y",
                              "NAME_1.x", "NAME_1.y", "lon.x", "lon.y",
                              "lat.x", "lat.y", "lonlat")]

    joined_df =  dplyr::arrange(joined_df, ISO.x)  # only arranged by one here

    return(joined_df)
}
