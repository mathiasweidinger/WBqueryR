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
  <a href="#license">License</a>

</div>

## TL;DR

**WBqueryR** is a "brick and mortar" R-package that makes it easy to query the World Bank's Microdata Library for variables from within R. Its main function `WBqueryR::WBquery()` takes user-defined search parameters and a list of keywords as input, downloads codebooks that meet the search criteria, and queries the variable labels in them for the presence of the keywords.

## Background

Researchers and practitioners from diverse disciplinary backgrounds - Economics, Public Policy, Development Studies, Sociology, to just name a few - rely on high quality data at the firm, household, and individual level for their work. Typically, these data are collected through survey instruments by national or international organizations, statistical services, or private enterprises. The World Bank Microdata Library is a large and popular repository for this kind of data. At the time of writing, it holds 3864 datasets.

Each of these datasets may include thousands of individual variables, all of which are described in the respective survey's codebook.  Browsing through these codebooks one by one to find what you are looking for can consume a lot of time. Automated querying has the potential to greatly reduce this burden and enable researchers to spend more of their time thinking about the big questions they are trying to answer. The World Bank provides its own dedicated API for this purpose. **WBquery** acts as a wrapper for this API and implements a simple work routine for R users to query the Microdata Library for entries of interest.

Note that via the API, users can query for collections, datasets, and specific variables that match (and *exactly* match) the search parameters provided. Because labelling of variables varies widely from survey to survey, exact matches will only return a subset of those entries relevant to the researcher. **WBqueryR** solves this problem as it implements a vector-space-model (VSM) based search engine that scores variable labels for the presence of key words provided by the user.

## Usage

> :warning: **This project is in its very early development stage: expect bugs, performance issues, crashes or data loss!**

### How does it work?

For now, users of the **WBqueryR** package can only engage with one function : `WBqueryR::WBquery()`. It implements the following three steps:

1. **Gather** codebooks for (a subset of) all datasets listed in the Microdata Library, using the World Bank's API.

2. **Score** the variable labels (descriptions) in these codebooks for the presence of key words provided.

3. **Return** a list of tibbles for variables with a matching score above the accuracy threshold.



### Parameters for `WBqueryR::WBquery()`

`WBqueryR::WBquery()` takes nine parameters. One of them is called `key` and is required for the function to work as it includes the key words for step 2. above. There are also eight optional parameters. If left blank, they either remain undefined or default to internally defined values. Five of these optional values are used in step 1. above to limit the scope of codebooks gathered by time, country, collection, and access type. Two others, `sort_by` and `sort_order` are merely used to sort the codebooks before step 2. The last optional parameter is `accuracy` and defines a matching score threshold for step 2. such that matches with scores below it are discarded and only those matches with scores at or above the threshold are included in the final results. If unspecified by the user, this threshold defaults to `accuracy = 0.5`, which essentially means that a variable's label needs to match the key word at least by 50% for the variable to be included in the results.

In summary, the parameters for `WBqueryR::WBquery()` are:

| Parameter     | Description   | Syntax Example| Default       | Type |
|---------------|---------------|---------------|---------------|------|
| **key** | a character (string) vector of key words, separated by commas| `key = (...)` | none |*required* |
| **from** | an integer indicating the minimum year of data collection | `from = ####`| none | *optional* |
| **to** | an integer, indicating the maximum year of data collection | `to = ####`| none | *optional* |
| **country** | a character (string) vector of [country name(s) or iso3 codes](http://microdata.worldbank.org/index.php/api/catalog/country_codes), or a mix of both; separated by commas | `country = c(...)` | none | *optional* |
| **collection** | a character (string) vector including one or more of the microdata library collection identifiers, separated by commas: <table> <thead> <th>Parameter</th> <th>Collection</th> <th># of datasets</th> </thead> <td>`"afrobarometer"`</td> <td>[Afrobarometer](https://www.afrobarometer.org/)</td> <td>32</td> </tr> <tr> <td>`"datafirst"`</td> <td>[DataFirst , University of Cape Town, South Africa](https://www.datafirst.uct.ac.za/)</td> <td>257</td> </tr> <tr> <td>`"dime"`</td> <td>[Development Impact Evaluation (DIME)](https://www.worldbank.org/en/research/dime)</td> <td>35</td> </tr> <tr> <td>`"microdata_rg"`</td> <td>[Development Research Microdata](https://microdata.worldbank.org/index.php/collections/microdata_rg)</td> <td>59</td> </tr> <tr> <td>`"enterprise_surveys"`</td> <td>[Enterprise Surveys](https://www.enterprisesurveys.org/en/enterprisesurveys)</td> <td>566</td> </tr> <tr> <td>`"FCV"`</td> <td>[Fragility, Conflict and Violence](https://www.worldbank.org/en/topic/fragilityconflictviolence/)</td> <td>1011</td> </tr> <tr> <td>`"global-findex"`</td> <td>[Global Financial Inclusion (Global Findex) Database](https://www.worldbank.org/en/publication/globalfindex)</td> <td>436</td> </tr> <tr> <td>`"ghdx"`</td> <td>[Global Health Data Exchange (GHDx), Institute for Health Metrics and Evaluation (IHME)](https://ghdx.healthdata.org/)</td> <td>20</td> </tr> <tr> <td>`"hfps"`</td> <td>[High-Frequency Phone Surveys](https://microdata.worldbank.org/index.php/collections/hfps/about)</td> <td>58</td> </tr> <tr> <td>`"impact_evaluation"`</td> <td>[Impact Evaluation Surveys](https://microdata.worldbank.org/index.php/collections/impact_evaluation)</td> <td>198</td> </tr> <tr> <td>`"ipums"`</td> <td>[Integrated Public Use Microdata Series (IPUMS)](https://www.ipums.org/)</td> <td>431</td> </tr> <tr> <td>`"lsms"`</td> <td>[Living Standards Measurement Study (LSMS)](https://www.worldbank.org/en/programs/lsms)</td> <td>151</td> </tr> <tr> <td>`"dhs"`</td> <td>[MEASURE DHS: Demographic and Health Surveys](https://dhsprogram.com/)</td> <td>362</td> </tr> <tr> <td>`"mrs"`</td> <td>[Migration and Remittances Surveys](https://microdata.worldbank.org/index.php/collections/mrs)</td> <td>9</td> </tr> <tr> <td>`"MCC"`</td> <td>[Millennium Challenge Corporation (MCC)](https://www.mcc.gov/)</td> <td>39</td> </tr> <tr> <td>`"pets"`</td> <td>[Service Delivery Facility Surveys](https://microdata.worldbank.org/index.php/collections/pets)</td> <td>13</td> </tr> <tr> <td>`"sdi"`</td> <td>[Service Delivery Indicators](https://www.sdindicators.org/)</td> <td>19</td> </tr> <tr> <td>`"step"`</td> <td>[The STEP Skills Measurement Program](https://microdata.worldbank.org/index.php/collections/step)</td> <td>22</td> </tr> <tr> <td>`"sief"`</td> <td>[The Strategic Impact Evaluation Fund (SIEF)](https://microdata.worldbank.org/index.php/collections/sief)</td> <td>38</td> </tr> <tr> <td>`"COS"`</td> <td>[The World Bank Group Country Opinion Survey Program (COS)](https://countrysurveys.worldbank.org/)</td> <td>343</td> </tr> <tr <td>`"MICS"`</td> <td>[UNICEF Multiple Indicator Cluster Surveys (MICS)](https://mics.unicef.org/)</td> <td>221</td> </tr> <tr> <td>`"unhcr"`</td> <td>[United Nations Refugee Agency (UNHCR)](https://www.unhcr.org/data.html)</td>  <td>269</td> </tr> <tr> <td>`"WHO"`</td> <td>WHO’s [Multi-Country Studies Programmes](https://microdata.worldbank.org/index.php/collections/WHO)</td> <td>72</td> </tr> </table>  | `collection = c(...)` | `"lsms"`| *optional* |
| **access** | an optional character (string) vector indicating the desired type(s) of access rights; one or more of: `"open"`, `"public"`, `"direct"`, `"remote"`, `"licensed"`; separated by commas| `access = c(...)` | none| *optional* |
| **sort_by** | a character (string) vector indicating one of: `"rank"`, `"title"`, `"nation"`, `"year"` | `sort_by(...)`| none | *optional* |
| **sort_order** | a character (string) vector indicating ascending or descending sort order by one of: `"asc"`, `"desc"`| `sort_order(...)` | none | *optional* |
| **accuracy** | a real number between 0 and 1, indicating the desired level of scoring accuracy | `accuracy = #` | `0.5` | *optional* |

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

## Installation

## Details

## Development

## License

## Notes 

With [rdhs](https://cran.r-project.org/web/packages/rdhs/index.html), there exists a much more comprehensive package to download and process data from DHS in R.

