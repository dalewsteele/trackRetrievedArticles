# install.packages("XML")
# install.packages("RGoogleDocs", repos = "http://www.omegahat.org/R")

library(RGoogleDocs)
library(RMySQL)

## add options (as below) to a project specific .Rprofile
#  options(GoogleDocsPassword = c("GoogleUserName"="password"))
auth = getGoogleAuth(service="wise")
sheets.con = getGoogleDocsConnection(auth)

# http://stackoverflow.com/questions/20786901/logging-into-google-spreadsheets-with-rgoogledocs
# spreadsheets = getDocs(sheets.con, ssl.verifypeer=FALSE)
# get available spreadsheets

# TODO (line below works on Windows)
# spreadsheets = getDocs(sheets.con, cainfo=system.file("CurlSSL", "cacert.pem", package = "RCurl"))
spreadsheets = getDocs(sheets.con, ssl.verifypeer=FALSE)

names(spreadsheets)
sheets = getWorksheets(spreadsheets[["merged pubmed 5 mar 2014 tracking data extraction"]], sheets.con)
names(sheets) #names of available worksheets

mergedPubmedTracking = sheetAsMatrix(sheets[["merged_full_text_screening"]], header = TRUE, as.data.frame = TRUE, stringsAsFactors=FALSE, trim = TRUE)

# Use sheet!
names(mergedPubmedTracking)
str(mergedPubmedTracking)

## FIXME: "1999.0" --> regex first date string --> as.date
require(stringr)
year.orig <- mergedPubmedTracking$Year[1:10]
year.clean <- str_replace(year.orig, ".0", "")
year.clean


mergedPubmedTracking$Year  <- 
mergedPubmedTracking$extractor
names(mergedPubmedTracking)


## requires a C://my.cnf with username and password
## $mysql
## create database appy;

con = dbConnect(MySQL())
str(con)
con = dbConnect(MySQL(), dbname='appy')
dbListTables(con)
dbWriteTable(con,"trackingFile",mergedPubmedTracking,overwrite=T)

# a function to simplify queries

query <- function(...) dbGetQuery(con, ...) 

scores <- query("SELECt PMID, Title, Authors, Year,ShortDetails, test_type FROM trackingfile WHERE include_ = 'yes'AND test_type LIKE '%score%'
                OR test_type LIKE '%classifier%' OR test_type LIKE '%strategy%'")
scores  
write.csv(scores, file="scores.csv", row.names=FALSE)
  

DWSextracted <- query("SELECT extractor, PMID FROM trackingfile WHERE
                        extractor='DS' AND test_performance='yes' AND test_performance_status='done'")   
write.csv(DWSextracted, file="DWSextract.csv", row.names=FALSE)


toExtract <- query("SELECT extractor, PMID, test_type, test_performance FROM trackingfile WHERE
              extractor IS NOT NULL AND test_performance IS NULL AND (test_type LIKE '%CT%' OR test_type LIKE
              '%US%' OR test_type LIKE '%LAB%' OR test_type LIKE '%signs_symptoms%')")
toExtract

dbDisconnect(con)


