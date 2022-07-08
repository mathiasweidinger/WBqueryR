#' WBget
#'
#' A wrapper function around `WBdownload` to batch-download `.csv` data files, associated with individual items listed in the Microdata Library, based on a list of numeric ids (e.g. obtained from `WBquery`).
#'
#' @param ids_list a list of numerical idns, perhaps from `WBquery()` output
#' @param dir local directory to store the downloads (default is current working directory)
#' @param unzip logical, whether to unzip data (default is `TRUE`)
#' @param user.email a valid email address associated with a registered user account at the WB Microdata Library.
#' @param user.password a valid password associated with the same registered user account at the WB Microdata Library as `user.email`.
#' @param user.abstract a short description of the purpose for which the data is being downloaded (defaults to Sect. 1.10.32 of M.T. Cicero's "de Finibus Bonorum et Malorum" as a placeholder).
#'
#' @return returns a list of directories where the data has been stored
#' @export
#'
#' @import magrittr dplyr pbapply
#'
#' @examples
#'\dontrun{
#'WBget(ids_list = list(4444,408),
#'user.email = "user@example.com",
#'user.password = "a.VerY_DiffiCULT-PasSWoRD",
#'user.abstract = "Writing a very innovative paper on something rather important."
#'dir = "C:/Users/myusername/Desktop",
#'unzip = FALSE)
#'}
#'
WBget <- function(ids_list,
                  dir = getwd(),
                  unzip = TRUE,
                  user.email,
                  user.password,
                  user.abstract = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"
){
    dir = paste0(dir,"/WB_batch")
    dir.create(file.path(dir))

    ids_list %>%
        pbapply::pblapply(. %>%
                              WBdownload(item.id = .,
                                       user.email = user.email,
                                       user.password = user.password,
                                       user.abstract = user.abstract,
                                       dir = dir,
                                       unzip = unzip)
                          )
}
#
# sum <- WBget(ids_list = list(4444,408),
#       user.email = "m.weidinger@student.maastrichtuniversity.nl",
#       user.password = "MiNh3mACz6yc9Tw",
#       dir = "C:/Users/spadmin/Desktop",
#       unzip = T)


