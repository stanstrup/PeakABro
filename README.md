
<!-- README.md is generated from README.Rmd. Please edit that file -->
PeakABro
========

Peaklist Annotator and Browser

The purpose of this package is to help identification in metabolomics by:

1.  extracting tables of compounds with their relevant info from different compound database formats
2.  annotating an XCMS (or other) peaklist with the compounds from the compound databases
3.  displaying an interactive browseable peaktable with the annotated compounds in nested tables

Get compound tables from databases
----------------------------------

Several compound databases can be downloaded and from and their database format we can extract a table of relevant information. So far I have added functions to extract in from the downloadable LipidMaps and LipidBlast.

-   Download the LipidMaps SDF from: <http://www.lipidmaps.org/resources/downloads/>
-   Download the LipidBlast json from: <http://mona.fiehnlab.ucdavis.edu/downloads> (see below; data supplied with package)
-   Adjust path to where you have downloaded the files

``` r
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

Expand adducts
--------------

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

Sources and licenses
--------------------

-   **LipidBlast**: Downloaded from MassBank of North America (MoNA) <http://mona.fiehnlab.ucdavis.edu/downloads> under the CC BY 4 license.
-   **LipidMaps**: Downloaded from <http://www.lipidmaps.org/resources/downloads> No data included in this package due to licensing issues.

Journal References
------------------

-   Kind T, Liu K-H, Lee DY, DeFelice B, Meissen JK, Fiehn O. LipidBlast in silico tandem mass spectrometry database for lipid identification. Nat. Methods. 2013 Aug;10(8):755–8. <http://dx.doi.org/10.1038/nmeth.2551>
-   Dennis EA, Brown HA, Deems RA, Glass CK, Merrill AH, Murphy RC, et al. The LIPID MAPS Approach to Lipidomics. Funct. Lipidomics. CRC Press; 2005. p. 1–15. <http://dx.doi.org/10.1201/9781420027655.ch1>
