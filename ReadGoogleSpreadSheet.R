# install.packages("XML")
# install.packages("RGoogleDocs", repos = "http://www.omegahat.org/R")

library(RGoogleDocs)
library(RMySQL)


## add options (as below) to a project specific .Rprofile
#  options(GoogleDocsPassword = c("GoogleUserName"="password"))
auth = getGoogleAuth(service="wise")
sheets.con = getGoogleDocsConnection(auth)

# get available spreadsheets
# http://stackoverflow.com/questions/20786901/logging-into-google-spreadsheets-with-rgoogledocs

# TODO (line below works on Windows)
spreadsheets = getDocs(sheets.con, cainfo=system.file("CurlSSL", "cacert.pem", package = "RCurl"))
# spreadsheets = getDocs(sheets.con, ssl.verifypeer=FALSE) #works on Linux

names(spreadsheets)
sheets = getWorksheets(spreadsheets[["merged pubmed 5 mar 2014 tracking data extraction"]], sheets.con)
names(sheets) #names of available worksheets

mergedPubmedTracking = sheetAsMatrix(sheets[["merged_full_text_screening"]], header = TRUE, as.data.frame = TRUE, stringsAsFactors=FALSE, trim = TRUE)

# Use sheet!
names(mergedPubmedTracking)

## Allows left join, keeping order
# library(plyr)
# newdf <- join(mergedPubmedTracking, copiedPMID)


## FIXME: "1999.0" --> regex first date string --> as.date
require(stringr)
year.orig <- mergedPubmedTracking$Year
year.orig
year.clean <- str_replace(year.orig, "\\.0", "")
year.clean

# 


## requires a C://my.cnf with username and password
## $mysql
## create database appy;
date()
con = dbConnect(MySQL(), dbname='appy')
dbListTables(con)
dbWriteTable(con,"trackingFile",mergedPubmedTracking,overwrite=T)

# a function to simplify queries

query <- function(...) dbGetQuery(con, ...) 

# all with any score
scores <- query("SELECt PMID, Title, Authors, Year, extractor, test_performance_status, test_type, score FROM trackingfile WHERE
                include_ = 'yes' AND test_performance = 'yes' AND test_type LIKE '%score%' ORDER by extractor, test_performance_status")

tail(scores[c("PMID", "score")])

write.csv(scores, file="scores_status.csv", row.names=FALSE)

scoreOnly <- query("SELECt PMID, extractor, test_performance_status, test_type, score FROM trackingfile WHERE
                include_ = 'yes'AND test_type = 'score'")
dim(scoreOnly)

AlvaradoScoreOnly <- query("SELECt PMID, extractor, test_performance_status, test_type, score FROM trackingfile WHERE
                include_ = 'yes'AND test_type = 'score' AND score LIKE '%Alvarado%'")
AlvaradoScoreOnly
write.csv(AlvaradoScoreOnly, file="AlvaradoScoreOnly.csv", row.names=FALSE)

## Find records in above where score is listed in 'test_type', but 'score' = NA
scores[scores$score == "NA",c("PMID", "test_type", "score")]

DWSextracted <- query("SELECT PMID FROM trackingfile WHERE
                        extractor='DS' AND test_type LIKE '%score%' AND test_performance='yes' AND test_performance_status='done'")   

DWSextracted
write.csv(DWSextracted, file="DWSextract.csv", row.names=FALSE)


toExtract <- query("SELECT extractor, PMID, test_type, test_performance FROM trackingfile WHERE
              extractor IS NOT NULL AND test_performance IS NULL AND (test_type LIKE '%CT%' OR test_type LIKE
              '%US%' OR test_type LIKE '%LAB%' OR test_type LIKE '%signs_symptoms%')")
toExtract

dbDisconnect(con)


