
#' @rdname is_between
#' 

.is_between_1range <- function(x,a,b) {
    
    if(!is.na(a) & !is.na(b)) return(x>=a & x<=b)
    if(is.na(a) & is.na(b))   return(rep(TRUE,length(x))) 
    if(is.na(a)) return(x<=b)
    if(is.na(b)) return(x>=a)
    
}

#' is_between
#' 
#' @rdname is_between
#' 
#' @param x numeric vector to check.
#' @param a lower limit of interval. Scalar for is_between_1range. Can be a vector for is_between.
#' @param b upper limit of interval. Scalar for is_between_1range. Can be a vector for is_between.
#'
#' @return Logical vector (is_between_1range) of length x or 
#' logical matrix (is_between) of dimensions x times length of a (== length of b).
#'

.is_between <- function(x,a,b) {
    
    apply(cbind(a,b),1,function(y) .is_between_1range(x,y[1],y[2]))
    
}



#' Compound list filter
#' 
#' This function filters a compound list based on mz value.
#' It is meant to be used to annotate a peaklist by running through (with \code{\link{map}}) 
#' each mz in the peaklist and adding a nested table of hits to the peaklist.
#'
#' @param mz Query mz to filter by
#' @param ref_tbl A \code{\link{tibble}} with compound mz values. Can be generated with expand_adducts.
#' @param mz_col Character string. Column name of the column containing the mz values.
#' @param ppm Maximum ppm value between query mass and database mz.
#'
#' @return A \code{\link{tibble}} containing the same columns as the input table but having add a ppm column for the deviation between compound mz and query mass.
#' 
#' @export
#'
#' @importFrom dplyr filter mutate
#' @importFrom magrittr %<>%
#'

cmp_mz_filter <- function(mz, ref_tbl, mz_col = "mz", ppm=30){
    
    search_mz <- mz # to avoid confusion with the ref_tbl column
    
    is_between <- .is_between(ref_tbl[,mz_col], search_mz-search_mz*ppm*1E-6, search_mz+search_mz*ppm*1E-6)
    
    ref_tbl %<>% 
        filter(is_between) %>% 
        mutate(ppm = ((mz-search_mz)/search_mz)*1E6)
    
    return(ref_tbl)
}
