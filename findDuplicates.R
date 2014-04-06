# http://www.r-bloggers.com/copying-data-from-excel-to-r-and-back/
# Excel to clipboard, clipboard to R

clipToRobject <- function(header=TRUE,...) {
  read.table("clipboard",sep="\t",header=TRUE,
             na.strings="", blank.lines.skip=FALSE, ...)
}

(copiedPMID=clipToRobject())
extracted <- unique(copiedPMID)
setwd("~/Desktop")
write.csv(extracted, file="extracted.csv", append=FALSE)
?write.csv

## HACK to re-assign studies to Lori
toLD <- copiedPMID[,1]
str(toLD)
PMID <- as.integer(mergedPubmedTracking$PMID) #all PMID
str(PMID)

toCHANGE  <- PMID %in% toLD
mergedPubmedTracking$extractor[which(toCHANGE)]  <-'LD'
mergedPubmedTracking$extractor

objectToClip <- function(x,row.names=FALSE,col.names=TRUE,...) {
  write.table(x,"clipboard",append=FALSE, sep="\t",row.names=row.names,col.names=col.names,...)
}

objectToClip(extracted)
