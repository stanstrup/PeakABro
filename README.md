Peaklist Annotator and Browser
================

-   [Get compound tables from databases](#get-compound-tables-from-databases)
-   [Expand adducts](#expand-adducts)
-   [Annotate peaklist](#annotate-peaklist)
-   [Interactive Browser](#interactive-browser)
    -   [Prepare the table for interactive browser](#prepare-the-table-for-interactive-browser)
    -   [Interactively browse peaklist](#interactively-browse-peaklist)
-   [Sources and licenses](#sources-and-licenses)
-   [Journal References](#journal-references)

<!-- README.md is generated from README.Rmd. Please edit that file -->
<title>
Peaklist Annotator and Browser
</title>
The purpose of this package is to help identification in metabolomics by:

1.  extracting tables of compounds with their relevant info from different compound database formats
2.  annotating an XCMS (or other) peaklist with the compounds from the compound databases
3.  displaying an interactive browseable peaktable with the annotated compounds in nested tables

<br> <br>

Get compound tables from databases
==================================

Several compound databases can be downloaded and from and their database format we can extract a table of relevant information. So far I have added functions to extract in from the downloadable LipidMaps and LipidBlast.

-   Download the LipidMaps SDF from: <http://www.lipidmaps.org/resources/downloads/>
-   Download the LipidBlast json from: <http://mona.fiehnlab.ucdavis.edu/downloads> (see below; data supplied with package)
-   Adjust path to where you have downloaded the files

``` r
library(dplyr)
library(PeakABro)
```

``` r
lipidmaps_tbl <- generate_lipidmaps_tbl("inst/extdata/LMSDFDownload6Dec16FinalAll.sdf")
# lipidblast_tbl <- generate_lipidblast_tbl("inst/extdata//MoNA-export-LipidBlast.json")
```

``` r
lipidmaps_tbl %>% slice(1:3) %>% kable
```

| id           | name                                                                | inchi                                                                                                                                                                                                        | formula    |      mass|
|:-------------|:--------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------|---------:|
| LMFA00000001 | cetylenic acids; 2-methoxy-12-methyloctadec-17-en-5-ynoyl anhydride | InChI=1S/C40H66O5/c1-7-9-11-23-29-35(3)31-25-19-15-13-17-21-27-33-37(43-5)39(41)45-40(42)38(44-6)34-28-22-18-14-16-20-26-32-36(4)30-24-12-10-8-2/h7-8,35-38H,1-2,9-16,19-20,23-34H2,3-6H3                    | C40H66O5   |  626.4910|
| LMFA00000002 | Serratamic acid; N-(3S-hydroxydecanoyl)-L-serine                    | InChI=1S/C13H25NO5/c1-2-3-4-5-6-7-10(16)8-12(17)14-11(9-15)13(18)19/h10-11,15-16H,2-9H2,1H3,(H,14,17)(H,18,19)/t10-,11-/m0/s1                                                                                | C13H25NO5  |  275.1733|
| LMFA00000003 | N-(3-(hexadecanoyloxy)-heptadecanoyl)-L-ornithine                   | InChI=1S/C38H74N2O5/c1-3-5-7-9-11-13-15-17-19-21-23-25-27-31-37(42)45-34(33-36(41)40-35(38(43)44)30-28-32-39)29-26-24-22-20-18-16-14-12-10-8-6-4-2/h34-35H,3-33,39H2,1-2H3,(H,40,41)(H,43,44)/t34?,35-/m0/s1 | C38H74N2O5 |  638.5598|

This takes rather long because the databases are quite large. Therefore I try to supply pre-parsed data. So far only LipidBlast is available.

``` r
lipidblast_tbl <- readRDS(system.file("extdata", "lipidblast_tbl.rds", package="PeakABro"))
```

``` r
lipidblast_tbl %>% slice(1:3) %>% kable
```

| id               | name                        | inchi                                                                                                                                                                                 | formula    |      mass|
|:-----------------|:----------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------|---------:|
| LipidBlast000001 | CerP 24:0; CerP(d14:0/10:0) | InChI=1S/C24H50NO6P/c1-3-5-7-9-11-12-14-15-17-19-23(26)22(21-31-32(28,29)30)25-24(27)20-18-16-13-10-8-6-4-2/h22-23,26H,3-21H2,1-2H3,(H,25,27)(H2,28,29,30)/t22-,23+/m0/s1             | C24H50NO6P |  479.3376|
| LipidBlast000002 | CerP 26:0; CerP(d14:0/12:0) | InChI=1S/C26H54NO6P/c1-3-5-7-9-11-13-15-17-19-21-25(28)24(23-33-34(30,31)32)27-26(29)22-20-18-16-14-12-10-8-6-4-2/h24-25,28H,3-23H2,1-2H3,(H,27,29)(H2,30,31,32)/t24-,25+/m0/s1       | C26H54NO6P |  507.3689|
| LipidBlast000003 | CerP 28:0; CerP(d14:0/14:0) | InChI=1S/C28H58NO6P/c1-3-5-7-9-11-13-14-16-18-20-22-24-28(31)29-26(25-35-36(32,33)34)27(30)23-21-19-17-15-12-10-8-6-4-2/h26-27,30H,3-25H2,1-2H3,(H,29,31)(H2,32,33,34)/t26-,27+/m0/s1 | C28H58NO6P |  535.4002|

<br> <br>

Expand adducts
==============

First we can merge the databases we have.

``` r
cmp_tbl <- bind_rows(lipidblast_tbl, lipidmaps_tbl)
```

We can then generate tables (positive and negative mode) that has all adducts and fragments we have selected.

``` r
cmp_tbl_exp_pos <- expand_adducts(cmp_tbl, mode = "pos", adducts = c("[M+H]+", "[M+Na]+", "[2M+H]+", "[M+K]+", "[M+H-H2O]+"))
cmp_tbl_exp_neg <- expand_adducts(cmp_tbl, mode = "neg", adducts = c("[M-H]-", "[2M-H]-", "[M-2H+Na]-", "[M+Cl]-", "[M-H-H2O]-"))

cmp_tbl_exp <- bind_rows(cmp_tbl_exp_pos, cmp_tbl_exp_neg)

cmp_tbl_exp %>% slice(1:3) %>% kable
```

| id               | name                        | inchi                                                                                                                                                                     | formula    |      mass| adduct    |  charge|  nmol|        mz| mode |
|:-----------------|:----------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------|---------:|:----------|-------:|-----:|---------:|:-----|
| LipidBlast000001 | CerP 24:0; CerP(d14:0/10:0) | InChI=1S/C24H50NO6P/c1-3-5-7-9-11-12-14-15-17-19-23(26)22(21-31-32(28,29)30)25-24(27)20-18-16-13-10-8-6-4-2/h22-23,26H,3-21H2,1-2H3,(H,25,27)(H2,28,29,30)/t22-,23+/m0/s1 | C24H50NO6P |  479.3376| \[M+H\]+  |       1|     1|  480.3449| pos  |
| LipidBlast000001 | CerP 24:0; CerP(d14:0/10:0) | InChI=1S/C24H50NO6P/c1-3-5-7-9-11-12-14-15-17-19-23(26)22(21-31-32(28,29)30)25-24(27)20-18-16-13-10-8-6-4-2/h22-23,26H,3-21H2,1-2H3,(H,25,27)(H2,28,29,30)/t22-,23+/m0/s1 | C24H50NO6P |  479.3376| \[2M+H\]+ |       1|     2|  959.6824| pos  |
| LipidBlast000001 | CerP 24:0; CerP(d14:0/10:0) | InChI=1S/C24H50NO6P/c1-3-5-7-9-11-12-14-15-17-19-23(26)22(21-31-32(28,29)30)25-24(27)20-18-16-13-10-8-6-4-2/h22-23,26H,3-21H2,1-2H3,(H,25,27)(H2,28,29,30)/t22-,23+/m0/s1 | C24H50NO6P |  479.3376| \[M+Na\]+ |       1|     1|  502.3268| pos  |

<br> <br>

Annotate peaklist
=================

We ultimately want to use the compound table in an interactive browser so lets remove some redundant info and take only one mode.

``` r
cmp_tbl_exp_pos <- cmp_tbl_exp %>% 
                   filter(mode=="pos") %>% 
                   select(-charge, -nmol, -mode)
                   
```

Next we load a sample peaklist. I have removed the data columns in this sample.

``` r
library(readr)
peaklist <- read_tsv(system.file("extdata", "peaklist_pos.tsv", package="PeakABro"))
## Parsed with column specification:
## cols(
##   mz = col_double(),
##   mzmin = col_double(),
##   mzmax = col_double(),
##   rt = col_double(),
##   rtmin = col_double(),
##   rtmax = col_double(),
##   npeaks = col_integer(),
##   isotopes = col_character(),
##   adduct = col_character(),
##   pcgroup = col_integer()
## )

peaklist %>% slice(1:3) %>% kable
```

|        mz|     mzmin|     mzmax|        rt|     rtmin|     rtmax|  npeaks| isotopes | adduct               |  pcgroup|
|---------:|---------:|---------:|---------:|---------:|---------:|-------:|:---------|:---------------------|--------:|
|  119.0861|  119.0856|  119.0873|  480.2640|  479.7749|  480.6898|      83| NA       | NA                   |       48|
|  129.0548|  129.0544|  129.0552|  682.1079|  681.5382|  682.5982|      94| NA       | \[M+H-H2O\]+ 146.058 |       10|
|  147.0654|  147.0649|  147.0657|  682.1068|  681.5382|  682.5982|      84| NA       | \[M+H\]+ 146.058     |       10|

Now we can annotate the table. The idea here is that each row will have a nested table with annotations from the compound table.

``` r
library(purrr)
peaklist_anno <- peaklist %>% mutate(anno = map(mz, cmp_mz_filter, cmp_tbl_exp_pos, ppm=30))
```

How the peaktable looks like this:

``` r
peaklist_anno %>% select(-mzmin, -mzmax, -rtmin, -rtmax, -npeaks)
## # A tibble: 49 x 6
##          mz       rt   isotopes
##       <dbl>    <dbl>      <chr>
##  1 119.0861 480.2640       <NA>
##  2 129.0548 682.1079       <NA>
##  3 147.0654 682.1068       <NA>
##  4 247.2419 796.0284       <NA>
##  5 259.1905 682.0464       <NA>
##  6 265.2527 795.9556   [31][M]+
##  7 266.2557 795.9540 [31][M+1]+
##  8 308.2944 796.7262       <NA>
##  9 321.2777 796.0501       <NA>
## 10 339.3451 795.8738       <NA>
## # ... with 39 more rows, and 3 more variables: adduct <chr>,
## #   pcgroup <int>, anno <list>
```

And one of the nested tables look like this:

``` r
peaklist_anno$anno[[1]] %>% slice(1:3) %>% kable
```

| id           | name                 | inchi                                                               | formula |      mass| adduct       |        mz|        ppm|
|:-------------|:---------------------|:--------------------------------------------------------------------|:--------|---------:|:-------------|---------:|----------:|
| LMFA06000136 | 2E,4E,6E-Nonatrienal | InChI=1S/C9H12O/c1-2-3-4-5-6-7-8-9-10/h3-9H,2H2,1H3/b4-3+,6-5+,8-7+ | C9H12O  |  136.0888| \[M+H-H2O\]+ |  119.0855|  -4.981859|
| LMFA06000137 | 2E,4E,6Z-Nonatrienal | InChI=1S/C9H12O/c1-2-3-4-5-6-7-8-9-10/h3-9H,2H2,1H3/b4-3-,6-5+,8-7+ | C9H12O  |  136.0888| \[M+H-H2O\]+ |  119.0855|  -4.981859|
| LMFA06000138 | 2E,4Z,6Z-Nonatrienal | InChI=1S/C9H12O/c1-2-3-4-5-6-7-8-9-10/h3-9H,2H2,1H3/b4-3-,6-5-,8-7+ | C9H12O  |  136.0888| \[M+H-H2O\]+ |  119.0855|  -4.981859|

<br> <br>

Interactive Browser
===================

Prepare the table for interactive browser
-----------------------------------------

Before we are ready to explore the peaklist interactively there are a few things we need to do and some optional things to fix:

``` r
library(tidyr)

peaklist_anno_nest <- peaklist_anno %>%
                        mutate(rt=round(rt/60,2), mz = round(mz,4)) %>% # peaklist rt in minutes and round 
                        select(mz, rt, isotopes, adduct, anno, pcgroup) %>% # get only relevant info
                        mutate(anno = map(anno,~ mutate(..1, mz = round(mz, 4), mass = round(mass, 4), ppm = round(ppm,0)))) %>% # round values in annotation tables
                        nest(-pcgroup, .key = "features") %>% # this is required! We nest the tables by the pcgroup
                        mutate(avg_rt = map_dbl(features,~round(mean(..1$rt),2))) %>% # extract average mass for each pcgroup
                        select(pcgroup, avg_rt, features) # putting the nested table last. ATM needed for the browser to work
    
```

We are almost there but first we want to add some magic to the table for the interaction (adds + button and View button).

``` r
peaklist_anno_nest_ready <- peaklist_browser_prep(peaklist_anno_nest, collapse_col = "features", modal_col = "anno")
```

<br> <br>

Interactively browse peaklist
-----------------------------

Now we can start the browser!

``` r
peaklist_browser(peaklist_anno_nest_ready, collapse_col = "features", modal_col = "anno")
```

![Peaklist Browser](inst/peaklist_browser.gif)

<br> <br>

Sources and licenses
====================

-   **LipidBlast**: Downloaded from MassBank of North America (MoNA) <http://mona.fiehnlab.ucdavis.edu/downloads> under the CC BY 4 license.
-   **LipidMaps**: Downloaded from <http://www.lipidmaps.org/resources/downloads> No data included in this package due to licensing issues.

<br> <br>

Journal References
==================

-   Kind T, Liu K-H, Lee DY, DeFelice B, Meissen JK, Fiehn O. LipidBlast in silico tandem mass spectrometry database for lipid identification. Nat. Methods. 2013 Aug;10(8):755–8. <http://dx.doi.org/10.1038/nmeth.2551>
-   Dennis EA, Brown HA, Deems RA, Glass CK, Merrill AH, Murphy RC, et al. The LIPID MAPS Approach to Lipidomics. Funct. Lipidomics. CRC Press; 2005. p. 1–15. <http://dx.doi.org/10.1201/9781420027655.ch1>
