# install.packages("XML")
# install.packages("RGoogleDocs", repos = "http://www.omegahat.org/R")

library(RGoogleDocs)
library(RMySQL)

auth = getGoogleAuth("Dale_Steele@brown.edu", "mypassword", "wise")
sheets.con = getGoogleDocsConnection(auth)

# http://stackoverflow.com/questions/20786901/logging-into-google-spreadsheets-with-rgoogledocs
# spreadsheets = getDocs(sheets.con, ssl.verifypeer=FALSE)
spreadsheets = getDocs(sheets.con,
                      cainfo=system.file("CurlSSL", "cacert.pem", package = "RCurl"))

names(spreadsheets)
sheets = getWorksheets(spreadsheets[["merged pubmed 5 mar 2014 tracking data extraction"]], sheets.con)
names(sheets) #names of available worksheets

# worksheet_as_df = sheetAsMatrix(sheets[[1]], header = TRUE, as.data.frame = TRUE, stringsAsFactors=FALSE, trim = TRUE)
mergedPubmedTracking = sheetAsMatrix(sheets[["merged_full_text_screening"]], header = TRUE, as.data.frame = TRUE, stringsAsFactors=FALSE, trim = TRUE)

# Use sheet!
names(mergedPubmedTracking)
str(mergedPubmedTracking)

## FIXME: create a password file
con = dbConnect(MySQL(), user='root', password='passwd', dbname='appy')
dbWriteTable(con,"trackingFile",mergedPubmedTracking,overwrite=T)
dbListTables(con)
query <- function(...) dbGetQuery(con, ...) #simplify queries

DWSextract <- query("SELECT extractor, Authors, PMID, Year, test_type, test_performance,test_performance_status,harms,harms_status,other_outcomes,other_outcomes_status FROM trackingfile WHERE include_ = 'yes' AND identified_through_previous_reviews='FALSE' AND extractor='DS'")
head(DWSextract)

write.csv(DWSextract, file="DWSextract.csv", row.names=FALSE)
dbDisconnect(con)


