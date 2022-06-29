# Define multiple join function.

multi_join <- function(list_of_loaded_data, join_func){
    require("dplyr")
    output <- Reduce(function(x, y) {join_func(x, y)}, list_of_loaded_data)
    return(output)
}
