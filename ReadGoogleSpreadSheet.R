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
spreadsheets = getDocs(sheets.con,
                      cainfo=system.file("CurlSSL", "cacert.pem", package = "RCurl"))

names(spreadsheets)
sheets = getWorksheets(spreadsheets[["merged pubmed 5 mar 2014 tracking data extraction"]], sheets.con)
names(sheets) #names of available worksheets

mergedPubmedTracking = sheetAsMatrix(sheets[["merged_full_text_screening"]], header = TRUE, as.data.frame = TRUE, stringsAsFactors=FALSE, trim = TRUE)
mergedPubmedTracking$Year
# Use sheet!
names(mergedPubmedTracking)
# Convert numeric 'year' to integer 'year'
## FIXME:  work-around creation of NA's 
mergedPubmedTracking$Year  <- as.integer(mergedPubmedTracking$Year)
mergedPubmedTracking$Year

## FIXME: create a password file
con = dbConnect(MySQL(), user='root', password='rootPassword', dbname='appy')
dbWriteTable(con,"trackingFile",mergedPubmedTracking,overwrite=T)
dbListTables(con)
query <- function(...) dbGetQuery(con, ...) #simplify queries

DWSextract <- query("SELECT extractor, Authors, PMID, Year, test_type, test_performance,test_performance_status,harms,harms_status,other_outcomes,other_outcomes_status FROM trackingfile WHERE include_ = 'yes' AND identified_through_previous_reviews='FALSE' AND extractor='DS'")
DWSdone <- query("SELECT extractor, PMID, Year, test_type, test_performance,test_performance_status FROM trackingfile WHERE include_ = 'yes' AND identified_through_previous_reviews='FALSE' AND extractor='DS' AND test_performance='yes'")
DWSdone


write.csv(DWSextract, file="DWSextract.csv", row.names=FALSE)
dbDisconnect(con)


