
merge_by_lonlat = function(dat_old, dat_new) {
    
    exp_df = merge(dat_old, dat_new, by = "lonlat", all = TRUE)
    
    exp_df = exp_df[, c("ISO.x", "ISO.y", "ID_1.x", "ID_1.y", "NAME_1.x", "NAME_1.y", "lon.x", "lon.y", "lat.x", 
        "lat.y", "lonlat")]
    
    exp_df = exp_df %>% arrange(ISO.x)  # only arranged by one here
    
    return(exp_df)
}
