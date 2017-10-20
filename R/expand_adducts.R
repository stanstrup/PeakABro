#' Expand mass to list of adducts
#' 
#' Expand a table with masses to a table with selected adducts and fragments and their mz values.
#' This function takes a table with a column mass and calculates the mz value of all selected adducts and fragments.
#'
#' @param cmp_tbl \code{\link{tibble}} of compounds. The tables should contain a column named "mass".
#' @param mode A string. Either "pos", "neg" or "ei".
#' @param adducts Character vector. Any adduct listed in the adduct list found here: https://github.com/stanstrup/chemhelper/tree/master/inst/extdata. Examples: "[M+H]+", "[M+Na]+", "[M-H]-", "[M+Cl]-".
#'
#' @return A \code{\link{tibble}} containing the same columns as the input table but with added columns: adduct, charge, nmol, mz, mode.
#' 
#' @export
#'
#' @importFrom chemhelper load.camera.rules
#' @importFrom tibble data_frame
#' @importFrom tidyr unnest
#' @importFrom dplyr filter select bind_cols mutate
#' @importFrom magrittr %<>%
#'
#'

expand_adducts <- function(cmp_tbl, mode = "pos", adducts = c("[M+H]+", "[M+Na]+", "[2M+H]+", "[M+K]+", "[M+H-H2O]+")){

    # make check happy
    name <-
        massdiff <-
        charge <-
        nmol <-
        mass <-
        NULL
        
    rules <- load.camera.rules(mode)
    rules %<>% filter(name %in% adducts) %>% 
               select(adduct = name, massdiff, charge, nmol)
    
    
    cmp_tbl_exp <- bind_cols(cmp_tbl, data_frame(adducts = rep(list(rules), nrow(cmp_tbl))) ) %>% 
                   unnest(adducts) %>% 
                   mutate(mz = abs((mass*nmol+massdiff)/charge)) %>% 
                   select(-massdiff) %>% 
                   mutate(mode=mode)

    return(cmp_tbl_exp)
}