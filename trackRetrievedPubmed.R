library(XLConnect)
library(stringr)

# extract list of all PMIDs in search
setwd("D://trackRetrievedArticles/")

wb <-loadWorkbook("S:/task_order_04_DAA/LargeSR_diagnosis_of_acute_appendicitis/databases_for_retrieval/merged pubmed 5 mar 2014 tracking data extraction.xlsx")
pubmed  <- readWorksheet(wb, sheet="merged_full_text_screening")
allpubmed <- as.character(pubmed$PMID)
table(nchar(allpubmed))  #length of PMID
## Detect non-english papers
# names(pubmed)
non_english <- str_detect(pubmed$Title, "\\[.*")


# get filenemes from the shared directory 'PUBMED_OCT' that have a PMID in the title
pubmed_sharedDrive <- "S:/task_order_04_DAA/LargeSR_diagnosis_of_acute_appendicitis/PDFs/PUBMED_OCT"
dropbox_articles <- "D:/Dropbox/Appendicitis articles"

fileListsharedDrive <- list.files(pubmed_sharedDrive, pattern="[0-9]{5,8}")
fileListDropbox <- list.files(dropbox_articles, pattern="[0-9]{5,8}")

retrieved_sharedDrive <- str_extract(fileListsharedDrive,"[0-9]{5,8}") #extract pmid from filename
retrieved_dropbox <- str_extract(fileListDropbox,"[0-9]{5,8}")

# How many of the retrived papers are duplicates?
unique_retrieved_sharedDrive <- unique(retrieved_sharedDrive)

all_retrieved <- unique(c(retrieved_sharedDrive, retrieved_dropbox))

not_retrieved  <- setdiff(allpubmed, all_retrieved)
length(not_retrieved) #pmids of articles which have not been retrieved

# Logical vector: FALSE = Not retrieved
retrieved <- allpubmed %in% all_retrieved
priority <- allpubmed[which(retrieved == FALSE & non_english == FALSE)]
length(priority)
non_priority <- allpubmed[which(retrieved == FALSE & non_english == TRUE)]
length(non_priority)
######################################################################
## experiment: get references directly from Entrez
library(RefManageR)
BibOptions(check.entries = FALSE)
trace(RefManageR:::ProcessPubMedResult, quote(res$language <- unlist(xpathApply(tdoc, "//PubmedArticle/MedlineCitation/Article/Language", 
                                                                                xmlValue))), at =18, print = FALSE)
english_refs <- GetPubMedByID(priority, db="pubmed")

nonEnglish_refs <- GetPubMedByID(non_priority[1:10], db="pubmed")

table(unlist(nonEnglish_refs$language))
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


## TODO: Use sqldf to query multiple fields including 'extractor'
=======
## TODO: Use sqldf to query multiple fields


##### Read 'SR_extraction_merged'
## Write a logical vector if paper appears in a least one review
wb3 <-loadWorkbook("S:\\\\task_order_04_DAA\\LargeSR_diagnosis_of_acute_appendicitis\\DRAFT_REPORT\\DATA_EXTRACTION\\SR_extraction_merged.xlsx")
reviews  <- readWorksheet(wb3, sheet="Sheet1")

## FIXME: Figure out what is causing the warnings of type "1: Error detected in cell AB593 - Incompatible type"
# warnings() 

names(reviews)
studies_in_review <- unique(unlist(str_extract_all(reviews$study_pmid, "[0-9]{5,8}")))
allpubmed <- as.character(pubmed$PMID)

in_review <- allpubmed %in% studies_in_review
## FIXME: Why does excel not recognize as csv?  
## FIXME: How to write a column name?
write.csv(in_review, file="in_review_csv", row.names=FALSE)
######
names(pubmed)
pubmed[which(pubmed$extractor == "DS"), "PMID"]
