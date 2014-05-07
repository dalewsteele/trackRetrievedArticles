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
spreadsheets = getDocs(sheets.con, cainfo=system.file("CurlSSL", "cacert.pem", package = "RCurl"))

names(spreadsheets)
sheets = getWorksheets(spreadsheets[["merged pubmed 5 mar 2014 tracking data extraction"]], sheets.con)
names(sheets) #names of available worksheets

mergedPubmedTracking = sheetAsMatrix(sheets[["merged_full_text_screening"]], header = TRUE, as.data.frame = TRUE, stringsAsFactors=FALSE, trim = TRUE)

# Use sheet!
names(mergedPubmedTracking)
# Convert numeric 'year' to integer 'year'
## FIXME:  work-around creation of NA's 
mergedPubmedTracking$Year  <- as.integer(mergedPubmedTracking$Year)
mergedPubmedTracking$extractor

## requires a C://my.cnf with username and password
con = dbConnect(MySQL(), dbname='appy')
dbListTables(con)
dbWriteTable(con,"trackingFile",mergedPubmedTracking,overwrite=T)

# a function to simplify queries
query <- function(...) dbGetQuery(con, ...) 

scores <- query("SELECt PMID, test_type FROM trackingfile WHERE include_ = 'yes'AND test_type LIKE '%score%'")
      

DWSextracted <- query("SELECT extractor, PMID FROM trackingfile WHERE
                        extractor='DW' AND test_performance='yes' AND test_performance_status='done'")

    
write.csv(DWSextracted, file="DWSextract.csv", row.names=FALSE)
write.csv(scores, file="scores.csv", row.names=FALSE)
dbDisconnect(con)


