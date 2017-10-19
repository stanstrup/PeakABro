
<!-- README.md is generated from README.Rmd. Please edit that file -->
PeakABro
========

Peaklist Annotator and Browser

The purpose of this package is to help identification in metabolomics by: 1) extracting tables of compounds with their relevant info from different compound database formats 2) annotating an XCMS (or other) peaklist with the compounds from the compound databases 3) displaying an interactive browseable peaktable with the annotated compounds in nested tables

Get compound tables from databases
----------------------------------

Several compound databases can be downloaded and from and their database format we can extract a table of relevant information. So far I have added functions to extract in from the downloadable LipidMaps and LipidBlast.

-   Download the LipidMaps SDF from: <http://www.lipidmaps.org/resources/downloads/>
-   Download the LipidBlast json from: <http://mona.fiehnlab.ucdavis.edu/downloads>
-   Adjust path to where you have downloaded the files.

``` r
library(PeakABro)
lipidmaps_tbl <- generate_lipidmaps_tbl("inst/extdata/LMSDFDownload6Dec16FinalAll.sdf")
## Warning in read.SDFset(sdf_path): 424 invalid SDFs detected. To fix, run:
## valid <- validSDF(sdfset); sdfset <- sdfset[valid]
lipidblast_tbl <- generate_lipidblast_tbl("inst/extdata//MoNA-export-LipidBlast.json")
```

``` r
lipidmaps_tbl
## # A tibble: 40,772 x 5
##              id
##           <chr>
##  1 LMFA00000001
##  2 LMFA00000002
##  3 LMFA00000003
##  4 LMFA00000004
##  5 LMFA00000005
##  6 LMFA00000006
##  7 LMFA00000007
##  8 LMFA00000008
##  9 LMFA00000009
## 10 LMFA00000014
## # ... with 40,762 more rows, and 4 more variables: name <chr>,
## #   inchi <chr>, formula <chr>, mass <dbl>
```

``` r
lipidblast_tbl
## # A tibble: 135,456 x 5
##                  id                             name
##               <chr>                            <chr>
##  1 LipidBlast000001      CerP 24:0; CerP(d14:0/10:0)
##  2 LipidBlast000002      CerP 26:0; CerP(d14:0/12:0)
##  3 LipidBlast000003      CerP 28:0; CerP(d14:0/14:0)
##  4 LipidBlast000004      CerP 30:0; CerP(d14:0/16:0)
##  5 LipidBlast000005      CerP 32:0; CerP(d14:0/18:0)
##  6 LipidBlast000006  CerP 32:1; CerP(d14:0/18:1(9Z))
##  7 LipidBlast000007      CerP 34:0; CerP(d14:0/20:0)
##  8 LipidBlast000008      CerP 36:0; CerP(d14:0/22:0)
##  9 LipidBlast000009      CerP 38:0; CerP(d14:0/24:0)
## 10 LipidBlast000010 CerP 38:1; CerP(d14:0/24:1(15Z))
## # ... with 135,446 more rows, and 3 more variables: inchi <chr>,
## #   formula <chr>, mass <dbl>
```

This takes rather long because the databases are quite large. Therefore I have configured

Alternatively get pre-made table from the package
=================================================

``` r
lipidmaps_tbl2 <-  readRDS(system.file("extdata", "lipidmaps_tbl.rds",  package="PeakABro"))
lipidblast_tbl2 <- readRDS(system.file("extdata", "lipidblast_tbl.rds", package="PeakABro"))
```
