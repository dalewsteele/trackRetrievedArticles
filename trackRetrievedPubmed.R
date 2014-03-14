library(XLConnect)
library(stringr)

# extract list of all PMIDs in search
setwd("~/Desktop")
wb <-loadWorkbook("S:/task_order_04_DAA/LargeSR_diagnosis_of_acute_appendicitis/databases_for_retrieval/merged pubmed 5 mar 2014 tracking data extraction.xlsx")
pubmed  <- readWorksheet(wb, sheet="merged_full_text_screening")
allpubmed <- as.character(pubmed$PMID)

## FIXME: detect non-english papers
# names(pubmed)
non_english <- str_detect(pubmed$Title, "\\[.*")


# get filenemes from the shared directory 'PUBMED_OCT' that have a PMID in the title
pubmed_sharedDrive <- "S:/task_order_04_DAA/LargeSR_diagnosis_of_acute_appendicitis/PDFs/PUBMED_OCT"
dropbox_articles <- "D:/Dropbox/Appendicitis articles"

fileListsharedDrive <- list.files(pubmed_sharedDrive, pattern="[0-9]{6,8}")
fileListDropbox <- list.files(dropbox_articles, pattern="[0-9]{6,8}")

retrieved_sharedDrive <- str_extract(fileListsharedDrive,"[0-9]{6,8}") #extract pmid from filename
retrieved_dropbox <- str_extract(fileListDropbox,"[0-9]{6,8}")

# How many of the retrived papers are duplicates?
unique_retrieved_sharedDrive <- unique(retrieved_sharedDrive)

all_retrieved <- unique(c(retrieved_sharedDrive, retrieved_dropbox))

not_retrieved  <- setdiff(allpubmed, all_retrieved)
length(not_retrieved) #pmids of articles which have not been retrieved

# Logical vector: FALSE = Not retrieved
retrieved <- allpubmed %in% all_retrieved
priority <- allpubmed[which(retrieved == FALSE & non_english == FALSE)]

######################################################################
## experiment: get references directly from Entrez
library(RefManageR)
full_refs <- GetPubMedByID(priority, db="pubmed")
summary(full_refs)
full_refs
######################################################################

## write file to desktop
setwd("~/Desktop")
# write to Excel: identified_through_previous_reviews
# Load workbook (create if not existing)
wb2 <- loadWorkbook("priority.xlsx", create = TRUE)
createSheet(wb2, name = "Sheet1")
writeWorksheet(wb2, priority, sheet = "sheet1", startRow = 1, startCol = 1)

# Save workbook (this actually writes the file to disk)
## TODO: write an informative header
saveWorkbook(wb2)
