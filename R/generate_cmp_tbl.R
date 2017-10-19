# Helper functions --------------------------------------------------------

#' Robust helper functions to process structures with rcdk
#' 
#' Some helper functions modified from rcdk to return NA on failure.
#' This makes it easier to process many compounds where some might behave unexpected.
#' 
#' @importFrom rcdk do.aromaticity do.typing do.isotopes get.exact.mass
#' @importFrom purrr possibly
#' @importFrom rinchi parse.inchi
#' @return Returns functions equavalent of \code{\link{do.aromaticity}}, \code{\link{do.typing}}, \code{\link{do.isotopes}}, \code{\link{get.exact.mass}} but made robust with \code{\link{possibly}}.
#' 
#' @keywords internal
#' 
#' @describeIn do.aromaticity_p Robust version of \code{\link{do.aromaticity}}
do.aromaticity_p <- possibly(do.aromaticity, NA)

#' @describeIn do.aromaticity_p Robust version of \code{\link{do.typing}} 
do.typing_p <-  possibly(do.typing, NA)

#' @describeIn do.aromaticity_p Robust version of \code{\link{do.isotopes}}
do.isotopes_p <-  possibly(do.isotopes, NA)

#' @describeIn do.aromaticity_p Robust version of \code{\link{get.exact.mass}}
get.exact.mass_p <- possibly(get.exact.mass, NA)

#' @describeIn do.aromaticity_p Robust version of \code{\link{parse.inchi}}
parse.inchi_p <- possibly(parse.inchi, NA)



#' Helper functions to extract info from LipidBlast json.
#'
#' Some helper functions to extract info from LipidBlast json.
#'
#' @param json LipidBlast json
#'
#' @importFrom dplyr %>%
#' @importFrom rlist list.select list.flatten
#' @return Returns character vector with the relevant info.
#'
#' @keywords internal
#'
#' @describeIn LB_getname Extracts the compound name from LipidBlast json
LB_getname <- function(json){
    # make check happy
     . <- name <- NULL
     
    json %>% 
        {.$compound[[1]]$names} %>% 
        list.select(name) %>% 
        list.flatten %>% 
        paste(collapse="; ")
    }

#' @describeIn LB_getname Extracts the inchi from LipidBlast json
LB_get_inchi <- function(json){
    # make check happy
    . <- NULL
     
    json %>% 
        {.$compound[[1]]$inchi}
}

#' @describeIn LB_getname Extracts the id name from LipidBlast json
LB_get_id <- function(json){
    # make check happy
    . <- NULL
     
    json %>% 
    {.$id}
}



#' Inchi to formula
#'
#' @param inchi Character vector with inchis
#'
#' @return Character vector
# '
#' @export
#'
#' @importFrom stringr str_split_fixed
#'
inchi2formula <- function(inchi){
    str_split_fixed(inchi,"/",3)[,2]
}



#' Inchi to mass
#'
#' @param inchi Character vector with inchis
#'
#' @return Numeric vector
# '
#' @export
#'
#'

inchi2mass <- function(inchi){

    mol <- parse.inchi_p(inchi)[[1]]

    do.aromaticity_p(mol)
    do.typing_p(mol)
    do.isotopes_p(mol)
    mass <- get.exact.mass_p(mol)

    return(mass)
}



# formula2mass  <- . %>% {map_chr(., ~getMass(getMolecule(..1)))} #  rdisop is crashy on windows 10



# Functions to extract a table of data from different database for --------


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
#' 
#' # Alternatively get pre-made table from the package
#' lipidmaps_tbl2 <- readRDS(system.file("extdata", "lipidmaps_tbl.rds", package="PeakABro"))
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



#' Generate table with LipidBlast compounds
#'
#' @param json_path Path to the LipidBlast json file available at: http://mona.fiehnlab.ucdavis.edu/downloads
#'
#' @return tbl A \code{\link{tibble}} containing the columns: id, name, inchi, formula, and mass.
# '
#' @export
#'
#' @importFrom jsonlite read_json
#' @importFrom tibble data_frame
#' @importFrom purrr map_chr map_dbl
#' @importFrom dplyr %>% mutate
#' @importFrom magrittr %<>%
#' @examples
#' \dontrun{
#' lipidblast_tbl <- generate_lipidblast_tbl("path/to/MoNA-export-LipidBlast.json")
#' 
#' # Alternatively get pre-made table from the package
#' lipidblast_tbl2 <- readRDS(system.file("extdata", "lipidblast_tbl.rds", package="PeakABro"))
#' }
#'
#'

generate_lipidblast_tbl <- function(json_path){

    # make check happy
    . <-
        inchi <-
        NULL

    lipidblast <- read_json(json_path)

    lipidblast_tbl <- lipidblast %>% {data_frame(
                                                  id = map_chr(.,LB_get_id),
                                                  name = map_chr(.,LB_getname),
                                                  inchi = map_chr(.,LB_get_inchi)
                                                )
                                     }


    lipidblast_tbl %<>% mutate(formula = inchi2formula(inchi)) %>%
                        # mutate(mass = formula2mass(formula)) %>%
                        mutate(mass = map_dbl(inchi, inchi2mass)) # slow but rdisop is crashy on windows 10

}

