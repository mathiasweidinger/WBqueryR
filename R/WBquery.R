# initiate WBquery()
WBquery <- function(key = "",           # search keys
                    from = "",          # start year of data collection (Integer)
                    to = "",            # end year of data collection (Integer)
                    country = "",       # country name(s) or iso3 codes
                    collection = "lsms",# collection id
                    access = "",        # type of access rights
                    sort_by = "",       # c("rank","title","nation","year")
                    sort_order =""      # c("asc","desc")
                    ){


    # Load the package required to read JSON files.
    require(rjson)

    require(magrittr) # required for double and subset-pipe operators.

    require(tidyverse) # Load the tidyverse suite of packages.

    require(httr) # package to work with APIs

    require(pbapply) # add a progress bar to lapply() calls

    # require(future.apply) # parallelized apply functions

    require(parallel) # distributed (parallel) computing

    source("R/multi_join.R") # source custom function multi-join()


    # Process search criteria

    key <- ifelse(exists("key"),
                  paste(key, collapse = "|"), "")

    from <- ifelse(exists("from"),
                   paste(from, collapse = ","), "")

    to <- ifelse(exists("to"),paste(to, collapse = ","), "")

    country <- ifelse(exists("country"),
                      paste(country, collapse = "|"), "")

    collection <- ifelse(exists("collection"),
                         paste(collection, collapse = ","), "")

    access <- ifelse(exists("access"),
                     paste(access, collapse = ","), "")

    sort_by <- ifelse(exists("sort_by"),
                      paste(sort_by, collapse = ","), "")

    sort_order <- ifelse(exists("sort_order"),
                         paste(sort_order, collapse = ","), "")

    # first search for datasets in collections, countries and time frame
    # get their codebooks

    # set path for catalog search
    path_cat <- "http://microdata.worldbank.org/index.php/api/catalog/search"

    r <- GET(path_cat,
             query = list(from = from,
                          to = to,
                          country = country,
                          inc_iso = TRUE, # include iso3 country codes
                          collection = collection,
                          dtype = access,
                          ps = 10000, # max out how many sets are included
                          sorty_by = sort_by,
                          sort_order = sort_order))

    # check whether call was successful (200 = success)
    status_code(r)

    # reshape to get content
    r %<>% content %$% result %$% rows

    # collect names of relevant studies
    items <- as.data.frame(do.call(rbind, r)) %>% # collapse list
        tibble %$% # build tibble
        idno # extract item names

    message("gathering codebooks; this might take a while...")

    # set number of active cores for parallelization
    detectCores() %>% makeCluster() -> cl # detect cores and make clusters

    # load required packages for each cluster
    clusterEvalQ(cl, {
        require(httr)
        require(magrittr)
        require(pbapply)
        require(tidyverse)
        source("R/multi_join.R")
        })

    # download codebooks

    item_vars <- items
    names(item_vars) <- unlist(items)

    item_vars %<>% # start with list of codebooks
        pblapply(. %>% # start parallelized task: for each item...
            paste0("http://microdata.worldbank.org/index.php/api/catalog/",
                   .,
                   "/variables") %>% # paste URL path for API
            GET %>% # get codebooks from API
            content %$% # extract content from JSON response file
            variables %>% # select column "variables"
            multi_join(join_func = rbind) %>% # "multi-join" custom function
            data.frame %>% tibble %>% # save output as a listed tibble
            mutate(grepl = grepl(key, # search for key words in each tibble
                labl,ignore.case = TRUE)) %>% # ignore cases
            filter(.$grepl == TRUE) %>%  # drop variables that do not match keys
            select(., -grepl), # drop helper variable from tibbles
            cl = cl) %>% # set parallel clusters, end of parallelized task
        keep(., ~nrow(.) > 0) # drop empty tibbles

    stopCluster(cl) # switch off clusters


    wanna_read <- readline(  # ask whether to print or not
        prompt = "Done! Should I print the results? (type y for YES, n for NO):"
        )

    if (grepl(pattern = "y", wanna_read, ignore.case = TRUE) == TRUE){

        # if yes...
        message("RESULTS:")
        for (i in seq(1:length(item_vars))){ # ...print the name of each dataset

            message("")

            message(paste0(names(item_vars)[i], " contains the variable(s):"))

            #...followed by each variable in it that matches search criteria

            for (v in 1:length(item_vars[[i]]$labl)){
                message(paste0("     - ",
                               item_vars[[i]]$name[v],
                               " (", item_vars[[i]]$labl[v],")"))
            }
        }
    }
    else{
        Sys.sleep(time = 1) # else do nothing
    }
    return(item_vars) # give output

} # end of WBquery()

item_vars <- WBquery(key = c("per capita consumption"))





#
#
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
