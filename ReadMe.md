---
abstract: "`WBqueryR()` is a custom R-function that makes exploring and
  downloading data from the [World Bank Microdata
  Library](https://microdata.worldbank.org/index.php/home) easier from
  within R. The available items can be filtered and selected through
  user-defined search criteria. Essentially, `WBqueryR` is a wrapper for
  the World Bank's own [Microdata API
  (v1.0.0)](https://microdata.worldbank.org/api-documentation/catalog/index.html#)
  that allows for intuitive use in the [R
  language](https://www.r-project.org/) programming environment."
abstract-title: TL;DR
author:
- affiliation: ETH Zurich
  affiliation-url: "https://dec.ethz.ch"
  name: Mathias Weidinger
  orcid: 0000-0002-8613-2367
  url: "https://mathiasweidinger.com"
date: "`r Sys.Date()`"
format:
  html:
    code-fold: true
    html-math-method: katex
    theme: default
highlight-style: pygments
subtitle: An R-function to systematically query and download World Bank
  Microdata
title: WBqueryR
---

```{=html}
<div align="justify">
```
## The `WBqueryR()` workflow

This repository includes code to query the [World Bank Microdata
Library](https://microdata.worldbank.org/index.php/home) using the
dedicated [Microdata API
(v1.0.0)](https://microdata.worldbank.org/api-documentation/catalog/index.html#).
The final output is the R-function `WBqueryR()` that enables the user to
systematically query all the data available through the Microdata
Library, using a pre-defined set search criteria chosen by the user.
`WBqueryR()` offers two types of output, depending on the argument given
to the option `output`:

-   `output = "summary"` causes `WBqueryR()` to list the metadata of all
    the items that meet the user's search criteria. The summary includes
    links to each item's location in the Microdata Library. This can be
    useful to get a quick overview of the available datasets, select
    those that are of interest, and proceed to download them
    individually via the links provided.

-   `output = "get_data"`, causes `WBqueryR()` to batch-download all
    items that match the search criteria to a new folder. By default,
    this folder is located in the current R working directory. A
    different destination can be specified via the option `dest`. The
    download folder includes one zipped folder for each selected item,
    each of which includes the data and ancillary files (e.g.,
    documentation, codebook, basic information document, reports, etc.).
    Depending on how wide or narrow the search criteria are, WBquery()
    might take a while to complete this task.

    ```{=html}
    <div>

    ```
