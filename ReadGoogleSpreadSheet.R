# install.packages("XML")
# install.packages("RGoogleDocs", repos = "http://www.omegahat.org/R")

library(RGoogleDocs)

auth = getGoogleAuth("Dale_Steele@brown.edu", "2WfLmnWT", "wise")
sheets.con = getGoogleDocsConnection(auth)

# http://stackoverflow.com/questions/20786901/logging-into-google-spreadsheets-with-rgoogledocs
# spreadsheets = getDocs(sheets.con, ssl.verifypeer=FALSE)
spreadsheets = getDocs(sheets.con,
                      cainfo=system.file("CurlSSL", "cacert.pem", package = "RCurl"))

names(spreadsheets)
sheets = getWorksheets(spreadsheets[["merged pubmed 5 mar 2014 tracking data extraction"]], sheets.con)
names(sheets)

# worksheet_as_df = sheetAsMatrix(sheets[[1]], header = TRUE, as.data.frame = TRUE, stringsAsFactors=FALSE, trim = TRUE)
worksheet_as_df = sheetAsMatrix(sheets[["merged_full_text_screening"]], header = TRUE, as.data.frame = TRUE, stringsAsFactors=FALSE, trim = TRUE)

# Use sheet!
names(worksheet_as_df)
str(worksheet_as_df)
worksheet_as_df[,1]
as.numeric(worksheet_as_df[,6])
dim(worksheet_as_df)
str(worksheet_as_df)
study_pmid <- as.numeric(worksheet_as_df[,6])
study_pmid
unique(study_pmid)

