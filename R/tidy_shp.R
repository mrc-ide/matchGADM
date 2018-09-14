# 

tidy_shp = function(shp1_new, shp1_old) {
    
    # collect countries
    shp1_new = shp1_new[shp1_new$ISO %in% shp1_old$ISO, ]
    
    # remove accents
    shp1_old$NAME_0 = stri_trans_general(shp1_old$NAME_0, "Latin-ASCII")
    shp1_old$NAME_1 = stri_trans_general(shp1_old$NAME_1, "Latin-ASCII")
    
    shp1_new$NAME_0 = stri_trans_general(shp1_new$NAME_0, "Latin-ASCII")
    shp1_new$NAME_1 = stri_trans_general(shp1_new$NAME_1, "Latin-ASCII")
    
    # remove special characters
    shp1_new$NAME_1 = gsub("!", "", shp1_new$NAME_1)
    
    return(list(shp1_new = shp1_new, shp1_old = shp1_old))
}
