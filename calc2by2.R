
clipToRobject <- function(header=TRUE,...) {
        read.table("clipboard",sep="\t",header=TRUE,
                   na.strings="", blank.lines.skip=FALSE, ...)}


objectToClip <- function(x,row.names=FALSE,col.names=TRUE,...) {
        write.table(x,"clipboard",append=FALSE, sep="\t",row.names=row.names,col.names=col.names,...)
}


mymat <- as.matrix(clipToRobject())
mymat

## A function to calculate the 2x2 table

tbt <- function(N, npos, oc, ...){
        dis <- c(npos, N-npos)
        diag <- round(oc * dis,0)
        offdiag <- dis - diag
        tbt <- c(diag[1],offdiag[1],offdiag[2],diag[2])
        names(tbt) <- NULL
        return(tbt)
        }


## Look through rows of mat=[cutpoint, sens, spec] by score
mtbt  <- function(N, npos, mat, ...){
        tbtmat <- matrix(nrow=nrow(mat), ncol=5)
        colnames(tbtmat) <- c("cutpoint", "TP", "FN", "FP", "TN")
        for (i in 1:nrow(mat)){
        tbtmat[i,] <- (c(mat[i,1],tbt(N, npos, mat[i,2:3])))
        }
        return(tbtmat)
        }

PMID_18534219 <- mtbt(849, 123, mymat) 
objectToClip(PMID_18534219)
