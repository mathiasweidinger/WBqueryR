# Load the package required to read JSON files.
library("rjson")
# Load the package required for using double-pipe operator.
library("magrittr")
# Load the tidyverse suite of packages.
library("tidyverse")

# Get JSON of country names.
wb_ctries <- fromJSON(
    file = "https://microdata.worldbank.org/index.php/api/catalog/country_codes") %>%
    flatten()

# Define multiple join function.
multi_join <- function(list_of_loaded_data, join_func, ...){
    require("dplyr")
    output <- Reduce(function(x, y) {join_func(x, y, ...)}, list_of_loaded_data)
    return(output)
}

wb_ctries %<>% multi_join(join_func = rbind) %>% data.frame() %>%
    filter(countryid != "success") %>% tibble()



#' WBquery
#'
#' @param dest File destination (default is current working directory)
#' @param key A vector of keywords used in the quary
#' @param iso Iso Alpha 3 country codes in capital letters (ABW, AFG, AGO,...)
#' @param col ID of one or more World Bank Microdata Library collection(s). There are 23 choices: `c("afrobarometer", "datafirst","dime", "microdata_rg", "enterprise_surveys", "FCV", "global-findex", "ghdx", "hfps", "impact_evaluation", "ipums", "lsms", "dhs", "mrs", "MCC", "pets", "sdi", "step", "sief", "COS", "MICS", "unhcr", "WHO")`.
#' @param out One of `c("search", "get")`
#'
#' @return If `out = "search"`, `WBquery()` returns a list of items that match the search criteria. If `out = "get"`, `WBquery()` downloads all items that match the serach criteria to the current working directory, or the directory specified by `dest`.
#' @export
#'
#' @examples
WBquery <- function(dest, key, iso, col){

}
