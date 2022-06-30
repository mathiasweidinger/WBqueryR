# initiate WBquery()

#' WBquery
#'
#' A custom function that queries the World Bank's Micro Data Library catalogue for items, according to search criteria specified by the user.
#'
#' `Wbquery()` conveniently combines two independent processes. Firstly, it is a wrapper for the World Bank's [Microdata Library API](https://microdata.worldbank.org/api-documentation/catalog/index.html), which it uses to download codebooks of the studies listed in the library's catalogue. In a second step, `WBquery()` implements a basic search engine that takes the variable labels, obtained from codebooks through the API, as input and scores them for the presence of user-specified key words. The underlying algorithm is a simple [vector-space-model](https://en.wikipedia.org/wiki/Vector_space_model). The helper function `vsm_score` is internally called to implement the vector-space-model. It is broadly based on multiple online tutorials, some of which can be found [here](https://rpubs.com/ftoresh/search-engine-Corpus), [here](https://www.r-bloggers.com/2013/03/build-a-search-engine-in-20-minutes-or-less/), and [here](https://gist.github.com/sureshgorakala/c990c3cd681b7cecdf57ef8a2ce42005).
#'
#' The specificity or "accuracy" of the results can be specified by the user, indicating an accuracy threshold between 0 and 1. All results with a matching score below the indicated threshold are discarded from the final output. The user needs to consider the following trade-off between quality and quantity of the search results. A higher accuracy threshold yields fewer results, but they are likely to be relevant to the user's query. A lower threshold generally yields more results, but they will probably be less relevant to the user's query. It is recommended to experiment with varying degrees of matching accuracy by adjusting the threshold and repeating the same search multiple times to get an idea of the variation implied. In particular, if a certain key word returns zero results, one potential solution is to be "less picky" and try again with a lower threshold.
#'
#' @param key REQUIRED: a character vector of key words; e.g. `c("income", "region", "child")`.
#' @param from OPTIONAL: start year of data collection (Integer).
#' @param to OPTIONAL: end year of data collection (Integer).
#' @param country OPTIONAL: a character vector of country name(s) or iso3 codes or a mix of both; e.g. `c("malawi", "nga", "peru", "vnm")`
#' @param collection OPTIONAL: a character vector including one or more of the WB microdata library collection ID codes. Defaults to `"lsms"` when left unspecified.
#' @param access OPTIONAL: an optional character vector indicating the desired type(s) of access rights; one or more of `c("open", "public","direct","remote","licensed")`
#' @param sort_by OPTIONAL: one of `c("rank","title","nation","year")`
#' @param sort_order OPTIONAL: indicate direction of sorting as ascending or descending; one of `c("asc","desc")`
#' @param accuracy OPTIONAL: desired level of scoring accuracy (a real number between 0 and 1); e.g. `0.75` to limit results to scores greater or equal to 75% accuracy. Defaults to `0.5` when left unspecified.
#'
#' @return `WBquery()` returns a nested list of results by key word, each consisting of tibbles that contain the library items' unique identifier (idno), matching variables, their labels and matching scores.
#' @export
#'
#' @import dplyr tm pbapply httr parallel jsonlite
#' @importFrom magrittr %>%
#' @importFrom magrittr %$%
#' @importFrom magrittr %<>%
#' @importFrom purrr keep
#'
#' @examples
#' \dontrun{
#' # look for variable(s) called "total consumption", which...
#' # ... were collected between 2000 and 2019,
#' # ... form part of data from nigeria, south africa, or vietnam,
#' # ... are open access or public.
#' # ... only accept matching scores of 60% and above
#'
#' example <- WBquery(
#'                key = c("total consumption"),
#'                from = 2000,
#'                to = 2019,
#'                country = c("nigeria", "zaf", "vnm"),
#'                access = c("open", "public"),
#'                accuracy = 0.6
#'            )
#' }

WBquery <- function(key = "",           # search keys
                    from = "",          # start year of data collection (Integer)
                    to = "",            # end year of data collection (Integer)
                    country = "",       # country name(s) or iso3 codes
                    collection = "lsms",# collection id
                    access = "",        # type of access rights
                    sort_by = "",       # c("rank","title","nation","year")
                    sort_order = "",    # c("asc","desc")
                    accuracy = 0.5      # set search accuracy (vsm score limit)
                    ){


    # require(rjson) # to read JSON files
    #
    # require(tm) # text mining
    #
    # require(magrittr) # required for double and subset-pipe operators.
    #
    # require(tidyverse) # Load the tidyverse suite of packages.
    #
    # require(httr) # package to work with APIs
    #
    # require(pbapply) # add a progress bar to lapply() calls
    #
    # require(parallel) # distributed (parallel) computing
    #
    # # Define multiple join function.

    multi_join <- function(list_of_loaded_data, join_func){
        output <- Reduce(function(x, y) {join_func(x, y)}, list_of_loaded_data)
        return(output)
    }

    # Define vsm_score function.

    vsm_score <- function(df, query, accuracy = 0.5){

        # require(tm)
        # require(dplyr)

        df %$% labl -> labels
        names(labels) <- df$name
        N.labels <- length(labels)

        my.docs <- tm::VectorSource(c(labels, query))
        my.docs$Names <- c(names(labels), "query")

        my.corpus <- tm::Corpus(my.docs)
        my.corpus

        #remove punctuation
        my.corpus <- tm::tm_map(my.corpus, removePunctuation)

        #remove numbers, uppercase, additional spaces
        my.corpus <- tm::tm_map(my.corpus, tm::removeNumbers)
        my.corpus <- tm::tm_map(my.corpus, tm::content_transformer(tolower))
        my.corpus <- tm::tm_map(my.corpus, tm::stripWhitespace)

        #create document matrix in a format that is efficient
        term.doc.matrix.stm <- tm::TermDocumentMatrix(my.corpus)
        colnames(term.doc.matrix.stm) <- c(names(labels), "query")

        #compare number of bytes of normal matrix against triple matrix format
        term.doc.matrix <- as.matrix(term.doc.matrix.stm)

        #constructing the Vector Space Model
        get.tf.idf.weights <- function(tf.vec) {
            # Compute tfidf weights from term frequency vector
            n.docs <- length(tf.vec)
            doc.frequency <- length(tf.vec[tf.vec > 0])
            weights <- rep(0, length(tf.vec))
            weights[tf.vec > 0] <- (1 + log2(tf.vec[tf.vec > 0])) * log2(n.docs/doc.frequency)
            return(weights)
        }

        tfidf.matrix <- t(apply(term.doc.matrix, 1,
                                FUN = function(row) {get.tf.idf.weights(row)}))
        colnames(tfidf.matrix) <- colnames(term.doc.matrix)

        tfidf.matrix <- scale(tfidf.matrix, center = FALSE,
                              scale = sqrt(colSums(tfidf.matrix^2)))

        query.vector <- tfidf.matrix[, (N.labels + 1)]
        tfidf.matrix <- tfidf.matrix[, 1:N.labels]

        doc.scores <- t(query.vector) %*% tfidf.matrix

        results.df <- tibble(doc = names(labels), score = t(doc.scores),text = labels)

        results.df <- results.df[order(results.df$score, decreasing = TRUE), ]


        results.df %>% filter(score >= accuracy) -> scores    # filter out

        return(scores)
    }
    # Process search criteria

    # key <- ifelse(exists("key"),
    #               paste(key, collapse = "|"), "")

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

    request <- httr::GET(path_cat,
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
    httr::status_code(request)

    # reshape to get content
    text <- httr::content(request, "text", encoding="UTF-8")
    data <- jsonlite::fromJSON(text)


    data %$% result %$% rows %>% tibble %$% # build tibble
        idno -> items # extract item names

    # set number of active cores for parallelization
    parallel::detectCores() %>% parallel::makeCluster() -> cl # detect cores and make clusters

    # prep each cluster
    parallel::clusterEvalQ(cl, {

        # Define multiple join function.

        multi_join <- function(list_of_loaded_data, join_func){
            output <- Reduce(function(x, y) {join_func(x, y)}, list_of_loaded_data)
            return(output)
        }

        # Define vsm_score function.

        vsm_score <- function(df, query, accuracy = 0.5){

            # require(tm)
            # require(dplyr)

            df %$% labl -> labels
            names(labels) <- df$name
            N.labels <- length(labels)

            my.docs <- tm::VectorSource(c(labels, query))
            my.docs$Names <- c(names(labels), "query")

            my.corpus <- tm::Corpus(my.docs)
            my.corpus

            #remove punctuation
            my.corpus <- tm::tm_map(my.corpus, removePunctuation)

            #remove numbers, uppercase, additional spaces
            my.corpus <- tm::tm_map(my.corpus, tm::removeNumbers)
            my.corpus <- tm::tm_map(my.corpus, tm::content_transformer(tolower))
            my.corpus <- tm::tm_map(my.corpus, tm::stripWhitespace)

            #create document matrix in a format that is efficient
            term.doc.matrix.stm <- tm::TermDocumentMatrix(my.corpus)
            colnames(term.doc.matrix.stm) <- c(names(labels), "query")

            #compare number of bytes of normal matrix against triple matrix format
            term.doc.matrix <- as.matrix(term.doc.matrix.stm)

            #constructing the Vector Space Model
            get.tf.idf.weights <- function(tf.vec) {
                # Compute tfidf weights from term frequency vector
                n.docs <- length(tf.vec)
                doc.frequency <- length(tf.vec[tf.vec > 0])
                weights <- rep(0, length(tf.vec))
                weights[tf.vec > 0] <- (1 + log2(tf.vec[tf.vec > 0])) * log2(n.docs/doc.frequency)
                return(weights)
            }

            tfidf.matrix <- t(apply(term.doc.matrix, 1,
                                    FUN = function(row) {get.tf.idf.weights(row)}))
            colnames(tfidf.matrix) <- colnames(term.doc.matrix)

            tfidf.matrix <- scale(tfidf.matrix, center = FALSE,
                                  scale = sqrt(colSums(tfidf.matrix^2)))

            query.vector <- tfidf.matrix[, (N.labels + 1)]
            tfidf.matrix <- tfidf.matrix[, 1:N.labels]

            doc.scores <- t(query.vector) %*% tfidf.matrix

            results.df <- tibble(doc = names(labels), score = t(doc.scores),text = labels)

            results.df <- results.df[order(results.df$score, decreasing = TRUE), ]


            results.df %>% filter(score >= accuracy) -> scores    # filter out

            return(scores)
        }

        })

    # download codebooks

    message("gathering codebooks...")

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
            data.frame %>% tibble, cl = cl) # set parallel clusters, end of task

    scores <- vector("list", length(key)) # initiate list of results
    names(scores) <- key # assign keywords to item names in results

    for(k in 1:length(key)){

        message(paste0("scoring for key word ",k, "/", length(key),
                       " (", key[k],")..."))

        item_vars %>% pbapply::pblapply(. %>% vsm_score(. , query = key[k],
                                               accuracy = accuracy),
                               cl = cl) %>%
            purrr::keep(., ~nrow(.) > 0) -> scores[[k]] # drop empty tibbles
    }


    parallel::stopCluster(cl) # switch off clusters

    wanna_read <- readline(  # ask whether to print or not
        prompt = "Search complete! Print results in the console? (type y for YES, n for NO):"
        )

    if (grepl(pattern = "y", wanna_read, ignore.case = TRUE) == TRUE){

        # if yes...
        for (k in seq(1:length(key))){ # for each key word(s)

        # summary per key word(s)

            if(length(scores[[k]]) == 0){
                message(paste0("No results found for -- ",key[k]," -- at ",
                    100*accuracy, "% scoring accuracy or above.",
                    "Decrease accuracy threshold or change search parameters to obtain more results."))
            }
            else{
                message("   ")

                message(paste0(sum(sapply(scores[[k]], nrow)), " result(s) for --",
                               key[k], "-- in ", length(scores[[k]]),
                               " library item(s):"))

                #...followed by a summary of results by item

                for (i in 1:length(scores[[k]])){
                    message(paste0("    ",names(scores[[k]])[[i]]))
                    for (v in 1:nrow(scores[[k]][[i]])){
                        message(paste0("        ", scores[[k]][[i]]$doc[v],
                            " (", scores[[k]][[i]]$text[v],") - ",
                            100*(round(scores[[k]][[i]]$score[v], digits = 2)),
                            "% match"))
                    }
                    message("    ")
                }
            }
        }
    }
    else{
        Sys.sleep(time = 1) # else do nothing
    }
    return(scores) # give output

} # end of WBquery()

