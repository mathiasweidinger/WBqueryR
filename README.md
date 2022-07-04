<h1 align="center">
  <br>
  <a href="https://github.com/mathiasweidinger/WBqueryR"><img src="banner/banner.png" alt="WBqueryR" width="100%"></a>
  <br>
  WBqueryR
  <br>
</h1>

<h4 align="center">A "brick and mortar" R-package to query the <a href="https://microdata.worldbank.org" target="_blank">World Bank Microdata Library</a>.</h4>

<div align="center">

![GitHub R package version](https://img.shields.io/github/r-package/v/mathiasweidinger/WBqueryR) [![GitHub issues](https://img.shields.io/github/issues/mathiasweidinger/WBqueryR)](https://github.com/mathiasweidinger/WBqueryR/issues) [![GitHub stars](https://img.shields.io/github/stars/mathiasweidinger/WBqueryR)](https://github.com/mathiasweidinger/WBqueryR/stargazers) [![GitHub forks](https://img.shields.io/github/forks/mathiasweidinger/WBqueryR)](https://github.com/mathiasweidinger/WBqueryR/network) [![GitHub license](https://img.shields.io/github/license/mathiasweidinger/WBqueryR)](https://github.com/mathiasweidinger/WBqueryR)

  <a href="#background">Background</a> •
  <a href="#usage">Usage</a> •
  <a href="#installation">Installation</a> •
  <a href="#details">Details</a> •
  <a href="#development">Development</a> •
  <a href="#disclaimer">Disclaimer</a>

</div>

## TL;DR

The R-package **WBqueryR** makes it easy to query the World Bank's Microdata Library for variables from within R. Its main function `WBqueryR::WBquery()` takes user-defined search parameters and a list of keywords as input, downloads codebooks that meet the search criteria, and queries the variable labels in them for the presence of the keywords.

## Background

Researchers and practitioners from diverse disciplinary backgrounds - Economics, Public Policy, Development Studies, Sociology, to just name a few - rely on high quality data at the firm, household, and individual level for their work. Typically, these data are collected through survey instruments by national or international organizations, statistical services, or private enterprises. The [World Bank Microdata Library](https://microdata.worldbank.org/) is a large and popular repository for this kind of data. At the time of writing, it holds 3864 datasets.

Each of these datasets may include thousands of individual variables, all of which are described in the respective survey's codebook.  Browsing through these codebooks one by one to find what you are looking for can consume a lot of time. Automated querying has the potential to greatly reduce this burden and enable researchers to spend more of their time thinking about the big questions they are trying to answer. The World Bank provides a [dedicated API](https://microdata.worldbank.org/api-documentation/catalog/index.html#) for this purpose. **WBquery** acts as a wrapper for this API and implements a simple work routine for R users to query the Microdata Library for entries of interest.

Note that via the API, users can query for collections, datasets, and specific variables that match (and *exactly* match) the search parameters provided. Because labelling of variables varies widely from survey to survey, exact matches will only return a subset of those entries relevant to the researcher. **WBqueryR** solves this problem as it implements a vector-space-model (VSM) based search engine that scores variable labels for the presence of key words provided by the user.

## Usage

> :warning: **This project is in its very early development stage: expect bugs, performance issues, crashes or data loss!**

### How does it work?

For now, users of the **WBqueryR** package can only engage with one function : `WBqueryR::WBquery()`. It implements the following three steps:

1. **Gather** codebooks for (a subset of) all datasets listed in the Microdata Library, using the World Bank's API.

2. **Score** the variable labels (descriptions) in these codebooks for the presence of key words provided.

3. **Return** a list of tibbles for variables with a matching score above the accuracy threshold.

### Example

To illustrate the use of `WBqueryR::WBquery()`, consider the following example. Say you are interested in obtaining data on total consumption and expenditure for households in Nigeria, South Africa, or Vietnam. You are only interested in data that was collected between 2000 and 2019, and which is either in the public domain or else open access. Lastly, you want the results to match your key words at list by 60%. The example below queries the Microdata Library to find data that suits your needs:

``` r
library(WBqueryR)

my_example <- WBquery(
    key = c("total consumption", "total expenditure"), # enter your keywords
    
    from = 2000,                            # lower time limit
    to = 2019,                              # upper time limit
    country = c("nigeria", "zaf", "vnm"),   # specify countries
    collection = c("lsms"),                 # only look for lsms data
    access = c("open", "public"),           # specify access
    accuracy = 0.6                          # set accuracy to 60%
    )
```

<details>

<summary>Click to see output</summary>

``` r
#> gathering codebooks...
#> scoring for key word 1/2 (total consumption)...
#> scoring for key word 2/2 (total expenditure)...
#> Search complete! Print results in the console? (type y for YES, n for NO):
```

</details>

When `WBqueryR::WBquery()` has completed the search, the user is prompted to decide, whether a summary of the search results should be printed in the console or not.
Typing `y` into the console will print the summary, whereas `n` will not. Let us see what the summary looks like for the example above:

``` r
#> Search complete! Print results in the console? (type y for YES, n for NO):y
```

<details>

<summary>Click to see output</summary>

``` r
   
#> 5 result(s) for --total consumption-- in 2 library item(s):
#>    NGA_2018_GHSP-W4_v03_M
#>        s7bq2b (CONSUMPTION UNIT) - 67% match
#>        s7bq2b_os (OTHER CONSUMPTION UNIT) - 63% match
#>        s7bq2c (CONSUMPTION SIZE) - 61% match
#>    
#>    NGA_2015_GHSP-W3_v02_M
#>        totcons (Total consumption per capita) - 61% match
#>        totcons (Total consumption per capita) - 61% match
#>    
#>   
#> 3 result(s) for --total expenditure-- in 2 library item(s):
#>    NGA_2012_GHSP-W2_v02_M
#>        s2q19i (AGGREGATE EXPENDITURE) - 60% match
#>    
#>    NGA_2010_GHSP-W1_v03_M
#>        s2aq23i (aggregate expenditure) - 61% match
#>        s2bq14i (aggregate expenditure) - 61% match
```

</details>

Note that no matter whether you choose to display the summary or not, all the information necessary to find the data later has been assigned to the new R-object `my_example` in your environment. This object is a list of 2 items - one for each key word - and each of these items includes tibbles of varying sizes that correspond to the datasets in the Microdata Library for which results have been found. Every tibble includes information on the matched variables: their name, label, and matching score. Type the code below to inspect the structure of `my_example` in R.

``` r
str(my_example)
```

<details>

<summary>Click to see output</summary>

``` r
#>List of 2
#> $ total consumption:List of 2
#>  ..$ NGA_2018_GHSP-W4_v03_M: tibble [3 × 3] (S3: tbl_df/tbl/data.frame)
#>  .. ..$ doc  : chr [1:3] "s7bq2b" "s7bq2b_os" "s7bq2c"
#>  .. ..$ score: num [1:3, 1] 0.675 0.629 0.613
#>  .. .. ..- attr(*, "dimnames")=List of 2
#>  .. .. .. ..$ : chr [1:3] "s7bq2b" "s7bq2b_os" "s7bq2c"
#>  .. .. .. ..$ : NULL
#>  .. ..$ text :List of 3
#>  .. .. ..$ s7bq2b   : chr "CONSUMPTION UNIT"
#>  .. .. ..$ s7bq2b_os: chr "OTHER CONSUMPTION UNIT"
#>  .. .. ..$ s7bq2c   : chr "CONSUMPTION SIZE"
#>  ..$ NGA_2015_GHSP-W3_v02_M: tibble [2 × 3] (S3: tbl_df/tbl/data.frame)
#>  .. ..$ doc  : chr [1:2] "totcons" "totcons"
#>  .. ..$ score: num [1:2, 1] 0.606 0.606
#>  .. .. ..- attr(*, "dimnames")=List of 2
#>  .. .. .. ..$ : chr [1:2] "totcons" "totcons"
#>  .. .. .. ..$ : NULL
#>  .. ..$ text :List of 2
#>  .. .. ..$ totcons: chr "Total consumption per capita"
#>  .. .. ..$ totcons: chr "Total consumption per capita"
#> $ total expenditure:List of 2
#>  ..$ NGA_2012_GHSP-W2_v02_M: tibble [1 × 3] (S3: tbl_df/tbl/data.frame)
#>  .. ..$ doc  : chr "s2q19i"
#>  .. ..$ score: num [1, 1] 0.601
#>  .. .. ..- attr(*, "dimnames")=List of 2
#>  .. .. .. ..$ : chr "s2q19i"
#>  .. .. .. ..$ : NULL
#>  .. ..$ text :List of 1
#>  .. .. ..$ s2q19i: chr "AGGREGATE EXPENDITURE"
#>  ..$ NGA_2010_GHSP-W1_v03_M: tibble [2 × 3] (S3: tbl_df/tbl/data.frame)
#>  .. ..$ doc  : chr [1:2] "s2aq23i" "s2bq14i"
#>  .. ..$ score: num [1:2, 1] 0.61 0.61
#>  .. .. ..- attr(*, "dimnames")=List of 2
#>  .. .. .. ..$ : chr [1:2] "s2aq23i" "s2bq14i"
#>  .. .. .. ..$ : NULL
#>  .. ..$ text :List of 2
#>  .. .. ..$ s2aq23i: chr "aggregate expenditure"
#>  .. .. ..$ s2bq14i: chr "aggregate expenditure"
```

</details>

### Parameters for `WBqueryR::WBquery()`

`WBqueryR::WBquery()` takes nine parameters. One of them is called `key` and is required for the function to work as it includes the key words for step 2. above. There are also eight optional parameters. If left blank, they either remain undefined or default to internally defined values. Five of these optional values are used in step 1. above to limit the scope of codebooks gathered by time, country, collection, and access type. Two others, `sort_by` and `sort_order` are merely used to sort the codebooks before step 2. The last optional parameter is `accuracy` and defines a matching score threshold for step 2. such that matches with scores below it are discarded and only those matches with scores at or above the threshold are included in the final results. If unspecified by the user, this threshold defaults to `accuracy = 0.5`, which essentially means that a variable's label needs to match the key word at least by 50% for the variable to be included in the results.

In summary, the parameters for `WBqueryR::WBquery()` are:

| Parameter     | Syntax Example | Default       | Type | Description   |
|---------------|----------------|---------------|------|---------------|
| **key** | `key = (...)` | none |*required* | a character (string) vector of key words, separated by commas|
| **from** | `from = ####`| none | *optional* | an integer indicating the minimum year of data collection |
| **to** | `to = ####`| none | *optional* | an integer, indicating the maximum year of data collection |
| **country** | `country = c(...)` | none | *optional* | a character (string) vector of [country name(s) or iso3 codes](http://microdata.worldbank.org/index.php/api/catalog/country_codes), or a mix of both; separated by commas |
| **collection** | `collection = c(...)` | `"lsms"`| *optional* | a character (string) vector including one or more of the microdata library collection identifiers, separated by commas: <p></p><table> <thead> <th>String</th> <th>Collection title</th> <th># of datasets</th> </thead> <td>`"afrobarometer"`</td> <td>[Afrobarometer](https://www.afrobarometer.org/)</td> <td>32</td> <tr> <td>`"datafirst"`</td> <td>[DataFirst , University of Cape Town, South Africa](https://www.datafirst.uct.ac.za/)</td> <td>257</td> </tr> <tr> <td>`"dime"`</td> <td>[Development Impact Evaluation (DIME)](https://www.worldbank.org/en/research/dime)</td> <td>35</td> </tr> <tr> <td>`"microdata_rg"`</td> <td>[Development Research Microdata](https://microdata.worldbank.org/index.php/collections/microdata_rg)</td> <td>59</td> </tr> <tr> <td>`"enterprise_surveys"`</td> <td>[Enterprise Surveys](https://www.enterprisesurveys.org/en/enterprisesurveys)</td> <td>566</td> </tr> <tr> <td>`"FCV"`</td> <td>[Fragility, Conflict and Violence](https://www.worldbank.org/en/topic/fragilityconflictviolence/)</td> <td>1011</td> </tr> <tr> <td>`"global-findex"`</td> <td>[Global Financial Inclusion (Global Findex) Database](https://www.worldbank.org/en/publication/globalfindex)</td> <td>436</td> </tr> <tr> <td>`"ghdx"`</td> <td>[Global Health Data Exchange (GHDx), Institute for Health Metrics and Evaluation (IHME)](https://ghdx.healthdata.org/)</td> <td>20</td> </tr> <tr> <td>`"hfps"`</td> <td>[High-Frequency Phone Surveys](https://microdata.worldbank.org/index.php/collections/hfps/about)</td> <td>58</td> </tr> <tr> <td>`"impact_evaluation"`</td> <td>[Impact Evaluation Surveys](https://microdata.worldbank.org/index.php/collections/impact_evaluation)</td> <td>198</td> </tr> <tr> <td>`"ipums"`</td> <td>[Integrated Public Use Microdata Series (IPUMS)](https://www.ipums.org/)</td> <td>431</td> </tr> <tr> <td>`"lsms"`</td> <td>[Living Standards Measurement Study (LSMS)](https://www.worldbank.org/en/programs/lsms)</td> <td>151</td> </tr> <tr> <td>`"dhs"`</td> <td>[MEASURE DHS: Demographic and Health Surveys](https://dhsprogram.com/)</td> <td>362</td> </tr> <tr> <td>`"mrs"`</td> <td>[Migration and Remittances Surveys](https://microdata.worldbank.org/index.php/collections/mrs)</td> <td>9</td> </tr> <tr> <td>`"MCC"`</td> <td>[Millennium Challenge Corporation (MCC)](https://www.mcc.gov/)</td> <td>39</td> </tr> <tr> <td>`"pets"`</td> <td>[Service Delivery Facility Surveys](https://microdata.worldbank.org/index.php/collections/pets)</td> <td>13</td> </tr> <tr> <td>`"sdi"`</td> <td>[Service Delivery Indicators](https://www.sdindicators.org/)</td> <td>19</td> </tr> <tr> <td>`"step"`</td> <td>[The STEP Skills Measurement Program](https://microdata.worldbank.org/index.php/collections/step)</td> <td>22</td> </tr> <tr> <td>`"sief"`</td> <td>[The Strategic Impact Evaluation Fund (SIEF)](https://microdata.worldbank.org/index.php/collections/sief)</td> <td>38</td> </tr> <tr> <td>`"COS"`</td> <td>[The World Bank Group Country Opinion Survey Program (COS)](https://countrysurveys.worldbank.org/)</td> <td>343</td> </tr> <tr> <td>`"MICS"`</td> <td>[UNICEF Multiple Indicator Cluster Surveys (MICS)](https://mics.unicef.org/)</td> <td>221</td> </tr> <tr> <td>`"unhcr"`</td> <td>[United Nations Refugee Agency (UNHCR)](https://www.unhcr.org/data.html)</td>  <td>269</td> </tr> <tr> <td>`"WHO"`</td> <td>WHO’s [Multi-Country Studies Programmes](https://microdata.worldbank.org/index.php/collections/WHO)</td> <td>72</td> </tr> </table>  |
| **access** | `access = c(...)` | none| *optional* | a character (string) vector indicating the desired type(s) of access rights; one or more of: `"open"`, `"public"`, `"direct"`, `"remote"`, `"licensed"`; separated by commas|
| **sort_by** | `sort_by(...)`| none | *optional* | a character (string) vector indicating one of: `"rank"`, `"title"`, `"nation"`, `"year"` |
| **sort_order** | `sort_order(...)` | none | *optional* | a character (string) vector indicating ascending or descending sort order by one of: `"asc"`, `"desc"`|
| **accuracy** | `accuracy = #` | `0.5` | *optional* | a real number between 0 and 1, indicating the desired level of scoring accuracy |

<!--
#### Collections and Access Types

| Parameter | Collection | # of datasets|
|-----------|------------|-------------:|
| `"afrobarometer"` | [Afrobarometer](https://www.afrobarometer.org/) | 32 |
| `"datafirst"` | [DataFirst , University of Cape Town, South Africa](https://www.datafirst.uct.ac.za/) | 257 |
| `"dime"` | [Development Impact Evaluation (DIME)](https://www.worldbank.org/en/research/dime) | 35 |
| `"microdata_rg"` | [Development Research Microdata](https://microdata.worldbank.org/index.php/collections/microdata_rg) | 59 |
| `"enterprise_surveys"` | [Enterprise Surveys](https://www.enterprisesurveys.org/en/enterprisesurveys) | 566 |
| `"FCV"` | [Fragility, Conflict and Violence](https://www.worldbank.org/en/topic/fragilityconflictviolence/) | 1011 |
| `"global-findex"` | [Global Financial Inclusion (Global Findex) Database](https://www.worldbank.org/en/publication/globalfindex) | 436 |
| `"ghdx"` | [Global Health Data Exchange (GHDx), Institute for Health Metrics and Evaluation (IHME)](https://ghdx.healthdata.org/) | 20 |
| `"hfps"` | [High-Frequency Phone Surveys](https://microdata.worldbank.org/index.php/collections/hfps/about) | 58 |
| `"impact_evaluation"` | [Impact Evaluation Surveys](https://microdata.worldbank.org/index.php/collections/impact_evaluation) | 198 |
| `"ipums"` | [Integrated Public Use Microdata Series (IPUMS)](https://www.ipums.org/) | 431 |
| `"lsms"` | [Living Standards Measurement Study (LSMS)](https://www.worldbank.org/en/programs/lsms) | 151 |
| `"dhs"` | [MEASURE DHS: Demographic and Health Surveys](https://dhsprogram.com/) | 362 |
| `"mrs"` | [Migration and Remittances Surveys](https://microdata.worldbank.org/index.php/collections/mrs) | 9 |
| `"MCC"` | [Millennium Challenge Corporation (MCC)](https://www.mcc.gov/) | 39 |
| `"pets"` | [Service Delivery Facility Surveys](https://microdata.worldbank.org/index.php/collections/pets) | 13 |
| `"sdi"` | [Service Delivery Indicators](https://www.sdindicators.org/) | 19 |
| `"step"` | [The STEP Skills Measurement Program](https://microdata.worldbank.org/index.php/collections/step) | 22 |
| `"sief"` | [The Strategic Impact Evaluation Fund (SIEF)](https://microdata.worldbank.org/index.php/collections/sief) | 38 |
| `"COS"` | [The World Bank Group Country Opinion Survey Program (COS)](https://countrysurveys.worldbank.org/) | 343 |
| `"MICS"` | [UNICEF Multiple Indicator Cluster Surveys (MICS)](https://mics.unicef.org/) | 221 |
| `"unhcr"` | [United Nations Refugee Agency (UNHCR)](https://www.unhcr.org/data.html) | 269 |
| `"WHO"` | WHO’s [Multi-Country Studies Programmes](https://microdata.worldbank.org/index.php/collections/WHO) | 72 |
-->
## Installation

As I wrote **WBqueryR** primarily with myself and colleagues in mind, and because it is the first R-package I have ever written, I have no aspiration to get it onto CRAN. Built by an amateur, it might very well "act out" and throw all kinds of errors and bugs at you. If you want to give it a try nonetheless, please use the code snipped below to install it from this github repo. YOU HAVE BEEN WARNED 😉

``` r
# first check if devtools is installed, if not install...
if (!require("devtools", character.only = TRUE)) {
    install.packages("devtools", dependencies = TRUE)
    }

# now install WBqueryR from github...
devtools::install_github("mathiasweidinger/WBqueryR")
```

<details>
<summary>Click to see output</summary>

``` r
#> Downloading GitHub repo mathiasweidinger/WBqueryR@HEAD
#> rlang (1.0.2 -> 1.0.3) [CRAN]
#> Installing 1 packages: rlang
#> Installing package into 'C:/Users/mweidinger/AppData/Local/R/win-library/4.2'
#> (as 'lib' is unspecified)
#> 
#> The downloaded binary packages are in
#>  C:\Users\mweidinger\AppData\Local\Temp\RtmpeaDfjL\downloaded_packages
#>          checking for file 'C:\Users\mweidinger\AppData\Local\Temp\RtmpeaDfjL\remotes460066734547\mathiasweidinger-WBqueryR-1c8ad39/DESCRIPTION' ...     checking for file 'C:\Users\mweidinger\AppData\Local\Temp\RtmpeaDfjL\remotes460066734547\mathiasweidinger-WBqueryR-1c8ad39/DESCRIPTION' ...   ✔  checking for file 'C:\Users\mweidinger\AppData\Local\Temp\RtmpeaDfjL\remotes460066734547\mathiasweidinger-WBqueryR-1c8ad39/DESCRIPTION'
#>       ─  preparing 'WBqueryR':
#>    checking DESCRIPTION meta-information ...     checking DESCRIPTION meta-information ...   ✔  checking DESCRIPTION meta-information
#>       ─  checking for LF line-endings in source and make files and shell scripts
#>   ─  checking for empty or unneeded directories
#>       ─  building 'WBqueryR_0.0.0.9000.tar.gz'
#>      
#> #> Installing package into 'C:/Users/mweidinger/AppData/Local/R/win-library/4.2'
#> (as 'lib' is unspecified)
```

 </details>

## Details

`WBqueryR::WBquery()` internally calls the helper function `vsm_score()` to score the labels from the codebooks for the presence of the user-defined key words in the parameter `key`. `vsm_score()` is a custom-built function that implements a simple vector-space-model. It is broadly based on multiple online tutorials, some of which can be found [here](https://rpubs.com/ftoresh/search-engine-Corpus), [here](https://www.r-bloggers.com/2013/03/build-a-search-engine-in-20-minutes-or-less/), and [here](https://gist.github.com/sureshgorakala/c990c3cd681b7cecdf57ef8a2ce42005).

## Development

## Disclaimer

### Copyright
Mathias Weidinger, 2022.

### Licensing

**WBqueryR** is licensed under version 3 of the GNU Public License. To learn what that means for you (the user), please refer to the [license file](https://www.gnu.org/licenses/gpl-3.0.txt); or you can find a a quick guide to GPLv3 [here](https://www.gnu.org/licenses/quick-guide-gplv3.html).

### Copying Permission

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see [https://www.gnu.org/licenses/](https://www.gnu.org/licenses/).

## Notes 

With [rdhs](https://cran.r-project.org/web/packages/rdhs/index.html), there exists a much more comprehensive package to download and process data from DHS in R.

