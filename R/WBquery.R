
# initiate WBquery()
WBquery <- function(key = "",           # search keys
                    from = "",          # start year of data collection (Integer)
                    to = "",            # end year of data collection (Integer)
                    country = "",       # country name(s) or iso3 codes
                    collection = "",    # collection id
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
    # initiate list of codebooks
    item_vars <- items %>%
        pblapply(. %>%
        paste0("http://microdata.worldbank.org/index.php/api/catalog/",
               .,
               "/variables") %>%
            GET %>%
            content %$%
            variables %>%
            multi_join(join_func = rbind) %>%
            data.frame %>% tibble)

    # assign idno as list item names
    names(item_vars) = unlist(items)

    item_vars %<>% lapply( . %>%
        mutate(grepl = grepl(key, labl,ignore.case = TRUE)) %>%
        filter(grepl == TRUE))

    rmwac <- function(x) x[nrow(x) > 0]
    do.call(rbind, lapply(item_vars, rmwac)) -> output

    message("RESULTS:")
    for (i in seq(1:nrow(output))){
        message(paste0("Dataset ", rownames(output)[i], " contains the variable........ ", output$labl[i], sep = ""))
    }


    return(output)

} # end of WBquery()

item_vars <- WBquery(key = c("longitude", "latitude"),
                     country = c("malawi", "nigeria"),
                     collection = c("lsms", "afrobarometer"))






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
