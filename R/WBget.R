
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



# How to use search criteria (ID does not work yet, inc_iso and lsms do work)

library(httr)

r <- GET("http://microdata.worldbank.org/index.php/api/catalog/search",
         query = list(collection = "lsms", ID = 4322, inc_iso = TRUE))

status_code(r)

str(content(r))







