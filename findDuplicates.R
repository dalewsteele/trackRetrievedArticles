# http://www.r-bloggers.com/copying-data-from-excel-to-r-and-back/

read.excel <- function(header=TRUE,...) {
  read.table("clipboard",sep="\t",header=TRUE,
             na.strings="", blank.lines.skip=FALSE, ...)
}

(copiedPMID=read.excel())


duplicatedPMID <- duplicated(copiedPMID)


write.excel <- function(x,row.names=FALSE,col.names=FALSE,...) {
  write.table(x,"clipboard",sep="\t",row.names=row.names,col.names=col.names,...)
}

write.excel(duplicatedPMID)
