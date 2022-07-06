# WBget <- function(
#         idno,
#         query,
#         dir = getwd()
#         ){
#
#
#
# }




library(WBqueryR)
library(tidyverse)
library(RSelenium)
library(netstat)


#### webscrape using Selenium

# set url
url = "https://microdata.worldbank.org/index.php/auth/login?destination=catalog/4444/get-microdata"

# set user details
user.email <- "m.weidinger@student.maastrichtuniversity.nl"
user.pw <- "MiNh3mACz6yc9Tw"
user.abstract <- "I am running a study of poverty and inequality across sub-saharan nations, using a novel method comparing horizontal inequalities in asset indeces"

# webscrape data from microdata library

# open server
rs_driver_object <- RSelenium::rsDriver(
    browser = "chrome",
    chromever = "103.0.5060.53",
    verbose = FALSE,
    port = netstat::free_port()
)

# run client
remDR <- rs_driver_object$client
remDR$open()

# navigate to url
remDR$navigate(url)

# sense email, password, and login fields
email <- remDR$findElement(using = 'xpath', '//input[@id="email"]')
passw <- remDR$findElement(using = 'xpath', '//input[@id="password"]')
login <- remDR$findElement(using = 'xpath', '//input[@value="Login"]')

# click and enter email
email$clickElement()
email$sendKeysToElement(list(user.email))

# click and enter password
passw$clickElement()
passw$sendKeysToElement(list(user.pw))

# click login
login$clickElement()

# # fill in abstract
# abstract <- remDR$findElement(using = 'xpath', '//textarea[@id="abstract"]')
# abstract$clickElement()
# abstract$sendKeysToElement(list(user.abstract))
#
#
# agree <- remDR$findElement(using = 'xpath', '//input[@id="chk_agree"]')
# agree$clickElement()
#
# submit <- remDR$findElement(using = 'xpath', '//input[@id="submit"]')
# submit$clickElement()


download_button <- remDR$findElement(using = 'xpath', '//div[@class="resource-right-col float-right"]/a')
download_button$getElementAttribute("href") -> dl_add



#### SAVE THE DOWNLOADS (USING ONE OF TWO OPTIONS)

### OPTION 1 - save in temporary directory:

# # create temporary directory
# temp <- tempdir()
#
# # download zip file to temporary directory
# download.file(url = dl_add[[1]], destfile = paste0(temp,"/",4444, "wbget.zip"), mode = "wb")
#
# # see content of temporary directory
# list.files(temp) # one zip file
#
# # unzip downloads
# unzip(paste0(temp,"/",4444, "wbget.zip"), exdir = paste0(temp,"/",4444, "wbget"))
#
# # inspect unzipped files
# list.files(paste0(temp,"/",4444, "wbget")) # one zip file
#
# # INSERT USE OF DATA HERE...
#
# # delete temporary directory
# unlink(temp)


### OPTION 2 - save in permanent, user-indicated directory

dir <- "C:/Users/spadmin/Desktop/" # user-indicated dir

# paste together a directory for the download
dl_dir <- paste0(dir,"wbget_",format(Sys.time(), "%d_%b_%Y_%H_%M"))

# create download directory
dir.create(file.path(dl_dir))

# paste together zip-file name
dl_file <- paste0(dl_dir,"/",4444, "wbget.zip")

# download zipped data folder
download.file(url = dl_add[[1]], destfile = dl_file, mode = "wb")

# unzip data files into download directory
unzip(dl_file, exdir = dl_dir)



### KILL JAVA

system('taskkill /im java.exe /f')

# dl_add now contains the link to the zipped folder on the microdata library that contains the files of interest.
#
# Next, I would like to make these files available temporarily, unzip them and - one by one - load them into the environment.
















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
