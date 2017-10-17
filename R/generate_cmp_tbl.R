#' Generate table with LipidMaps compounds
#'
#' @param sdf_path Path to the Lipidmaps SDF file available at: http://www.lipidmaps.org/resources/downloads/
#'
#' @return tbl A \code{\link{tibble}} containing the columns: id, name, inchi, formula, and mass.
# '
#' @export
#'
#' @importFrom ChemmineR read.SDFset datablock datablock2ma
#' @importFrom tibble as_data_frame
#' @importFrom tidyr replace_na unite
#' @importFrom dplyr mutate select %>%
#' @examples
#' \dontrun{
#' lipidmaps_tbl <- generate_lipidmaps_tbl("path/to/LMSDFDownload6Dec16FinalAll.sdf")
#' }
#'
#' 

generate_lipidmaps_tbl <- function(sdf_path){
    
    # make check happy
    COMMON_NAME <- 
    SYNONYMS <- 
    SYSTEMATIC_NAME <- 
    INCHI <- 
    FORMULA <- 
    EXACT_MASS <- 
    LM_ID <- 
    name <- 
    mass <- 
        NULL
    
    SDF <- read.SDFset(sdf_path)
    
    SDF_table <- datablock2ma(datablock(SDF))

    lipidmaps_tbl <- SDF_table %>% 
                     as_data_frame %>% 
                     replace_na(list(COMMON_NAME = "", SYNONYMS = "", SYSTEMATIC_NAME = "")) %>%
                     unite(name,COMMON_NAME, SYNONYMS, SYSTEMATIC_NAME, sep="; ") %>%
                     mutate(name = sub("^; .{1}", "", name)) %>%
                     mutate(name = sub("; $", "", name)) %>%
                     mutate(name = gsub("; ; ", "; ", name)) %>%
                     select(id = LM_ID, name, inchi = INCHI, formula = FORMULA, mass = EXACT_MASS) %>% 
                     mutate(mass=as.numeric(mass))
    
    return(lipidmaps_tbl)
}
