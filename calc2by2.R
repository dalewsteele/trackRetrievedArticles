
clipToRobject <- function(header=TRUE,...) {
        read.table("clipboard",sep="\t",header=TRUE,
                   na.strings="", blank.lines.skip=FALSE, ...)}


objectToClip <- function(x,row.names=FALSE,col.names=TRUE,...) {
        write.table(x,"clipboard",append=FALSE, sep="\t",row.names=row.names,col.names=col.names,...)
}


mymat <- as.matrix(clipToRobject())
mymat

## Two functions to calculate the 2x2 given N, npos, cutpoint, sens, spec
## TODO: Should be able to simplify - vectorize second function!!

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

(PMID_23623557  <- mtbt(261,53, mymat))
(PMID_21521827 <- mtbt(594, 306, mymat))
objectToClip(PMID_21521827)

### A function to convert cutpoint Dpos Dneg to 2x2 tables
counts.tbt <- function(counts){
        cp <- counts[,1]
        tbt <- matrix(nrow=nrow(counts), ncol=4)
        colnames(tbt)  <- c("TP", "FN", "FP", "TN")
        totals <- colSums(counts[,2:3])
                for (i in 1:nrow(counts)){
                        TP <- sum(counts[(i):nrow(counts),2])
                        FP <- sum(counts[(i):nrow(counts),3])
                        FN  <- totals[1] - TP
                        TN <- totals[2] - FP
                        tbt[i,] <- cbind(TP,FN,FP,TN)}
        return(cbind(cp,tbt))
}

mymat <- as.matrix(clipToRobject())
mymat

objectToClip(counts.tbt(mymat))
Alvarado.tbt(mymat)



