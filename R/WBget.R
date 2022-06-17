
# code to automatically download file(s) from WB Microdata Library


#' WBget
#'
#' @param id vector of dataset identifiers
#'
#' @return the function creates a new folder and saves the requested datasets there.
#' @export
#'
#' @examples
#' ids <- c("AFG_2020_VOLREP_v01_M", "AFG_2021_WBCS_v01_M", "AFG_2019_LIS_v01_M",
#' "AFG_2019_VOLREP_v01_M", "AFG_2018_SPA_v01_M", "AFG_2018_VOLREP_v01_M",
#' "AFG_2018_WBCS_v01_M","AFG_2017_FINDEX_v02_M", "AFG_2017_SABER-SD_v01_M",
#' "AFG_2017_SEA-HER_v01_M", "AFG_2017_SEA-KHO_v01_M", "AFG_2016_VOLREP_v01_M")
#'
#' WBget(ids)

WBget <- function(id){

    # load packages
    require(rjson)
    require(httr)
    require(tidyverse)
    require(magrittr)

    # initiate access status vector
    access <- c()

    for (item in id) { # for each of the ids supplied...

        # print message
        message(paste("checking access requirements for item ", item, " (",match(item, id),"/",length(id),")", sep = "" ))

        # get metadata for studies one by one
        temp <- paste("https://microdata.worldbank.org/index.php/api/catalog/",item, sep="")
        temp <- fromJSON(file = temp) %>% flatten()
        temp <- temp[-27]
        temp %<>% flatten() %>% data.frame()

        # extract access type
        access[match(item, id)] <- temp$data_access_type

        # print message
        message(paste("... item (", match(item,id),"/",length(id),") is of access type: ", access[match(item, id)], sep=""))
    }

    length(access) - length(which(access == "public")) -> not_public

    # ask whether user is already registered
    warning(paste(not_public," item(s) you requested are not open access. You can only proceed to download, if you are registered with World Bank Microdata Library.", sep = ""),immediate. = TRUE)
    registered <- readline(prompt = "Do you have an existing World Bank Microdata Library account? (type y for YES, n for NO):")

    # if not, stop program and display info - PROGRAM ENDS HERE
    if (registered == "n") {
        message("To register with the World Bank Microdata Library, please visit https://microdata.worldbank.org/index.php/auth/register. Rerun WBget() once you are registered.")
    }

    # if yes, proceed to log on
    else{
        message(paste("We will need to log you in. Please, enter your login details for World Bank Microdata Library"))
        email <- readline(prompt="Email Address: ")
        pw <- readline(prompt="Password: ")
    }
}

library(httr)

r <- GET("http://microdata.worldbank.org/index.php/api/catalog/search",
         query = list(inc_iso = TRUE, ps = 10000, dtype = "public"))

status_code(r)

str(content(r))
(content(r)) -> cont
cont$variables -> cont
cont %<>% multi_join(join_func = rbind) %>% data.frame() %>% tibble()

cont %>%
    unnest(col = form_model) %>%
    #If needed col1 as factors
    #mutate(col1 =factor(col1)) %>%
    count(form_model)

r <- GET("http://microdata.worldbank.org/index.php/api/catalog/NGA_2018_GHSP-W4_v03_M/variables")

cont$grepl <- grepl("longitude|latitude", cont$labl, ignore.case = TRUE)

cont %>% filter(grepl == TRUE) -> expend_vars


# public:     1. login
#             2. fill form
#             3. download csv
#
# open:       1. click "accept"
#             2. download csv
#
# direct:     1. click "accept"
#             2. download csv
#
# remote:     1. go to source
#             2. login
#             3. fill form
#             4. download csv
#
# licensed:   1. login
#             2. fill form
#             3. download csv
