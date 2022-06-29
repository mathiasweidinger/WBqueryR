vsm_score <- function(df, query, accuracy = 0.5){

    require(tm)
    require(dplyr)

    df %$% labl -> labels
    names(labels) <- df$name
    N.labels <- length(labels)

    my.docs <- VectorSource(c(labels, query))
    my.docs$Names <- c(names(labels), "query")

    my.corpus <- Corpus(my.docs)
    my.corpus

    #remove punctuation
    my.corpus <- tm_map(my.corpus, removePunctuation)

    #remove numbers, uppercase, additional spaces
    my.corpus <- tm_map(my.corpus, removeNumbers)
    my.corpus <- tm_map(my.corpus, content_transformer(tolower))
    my.corpus <- tm_map(my.corpus, stripWhitespace)

    #create document matrix in a format that is efficient
    term.doc.matrix.stm <- TermDocumentMatrix(my.corpus)
    colnames(term.doc.matrix.stm) <- c(names(labels), "query")

    #compare number of bytes of normal matrix against triple matrix format
    term.doc.matrix <- as.matrix(term.doc.matrix.stm)

    # cat("Dense matrix representation costs", object.size(term.doc.matrix), "bytes.\n",
    #     "Simple triplet matrix representation costs", object.size(term.doc.matrix.stm),
    #     "bytes.")

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

