#' Prepare compound table for interactive display
#' 
#' This function modifies some of the columns in a compound table to be displayed better in an interactive table.
#' To the inchi column code to crop very long strings will be added.
#' To the name column "; " separater will be changed to a line break.
#' This is mainly used internally.
#'
#' @param cmp_tbl \code{\link{tibble}} of compounds.
#'
#' @return A \code{\link{tibble}} containing the same columns as the input table.
#'
#' @export
#'
#' @importFrom dplyr %>% mutate filter select
#' @importFrom magrittr %<>%
#'
#'

cmp_tbl_pretty <- function(cmp_tbl){
        
    # make check happy
        inchi <-
        name <-
        NULL
    
    cmp_tbl %<>% 
                    mutate(inchi = paste0('<div style= "-o-text-overflow: ellipsis; text-overflow: ellipsis;  overflow:hidden;  white-space:nowrap;   width: 20em;">',inchi,'</div>')) %>% 
                    mutate(name = gsub("; ","<br>",name))
}
