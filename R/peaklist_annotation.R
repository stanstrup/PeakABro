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
#' @importFrom massageR is_between
#' @importFrom dplyr filter mutate
#' @importFrom magrittr %<>%
#'

cmp_mz_filter <- function(mz, ref_tbl, mz_col = "mz", ppm=30){
    
    search_mz <- mz # to avoid confusion with the ref_tbl column
    
    is_between <- is_between(ref_tbl[,mz_col], search_mz-search_mz*ppm*1E-6, search_mz+search_mz*ppm*1E-6)
    
    ref_tbl %<>% 
        filter(is_between) %>% 
        mutate(ppm = ((mz-search_mz)/search_mz)*1E6)
    
    return(ref_tbl)
}
