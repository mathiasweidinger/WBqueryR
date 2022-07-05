WBget <- function(
        idno,
        query,
        dir = wdget()
        ){



}




library(WBqueryR)
library(tidyverse)
library(RCurl)
library(rvest)
library(magrittr)


root <- "C:/Users/spadmin/Desktop/projects/WB_data_compilation"

setwd(root)

# get table of country denominators

ctrs <- getURL("https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv")
ctrs %<>% read_html() %>%  html_table(header = TRUE) %>% .[[1]]

key = c("consumption", "expenditure", "longitude", "latitude")
query <- WBquery(key = key)

key.length <- length(key)

dta <- query %>% lapply(. %>% names %>% as.data.frame %>% tibble)


df <- dta[[1]]
for (i in 2:length(dta)){
    df %<>% merge(dta[[i]])
}

dta <- tibble(idno = idno, alpha3 = substr(idno,1,3))

dta %<>% distinct()




# webscrape data from microdata library

# first, add the numerical id to the list of idno's

