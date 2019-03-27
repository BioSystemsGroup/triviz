#! /usr/bin/Rscript

###
## Reads the output of dataperH-inband.r, runs ma.cent from misc.r and writes a -ma file.
##
## Time-stamp: <2019-03-27 10:38:12 gepr>
###

argv <- commandArgs(T)

usage <- function() {
  print("Usage: hsol_ma.r <window> <exp directory>")
  print("  requires files like <exp>_hsolute-avg-pHPC-pMC-dCV∈[0,6).csv")
  quit()
}

if (length(argv) < 2) usage()

source("~/R/misc.r")

ma.window <- as.numeric(argv[1])
exp <- argv[2]

pattern <- paste(exp, "_hsolute-avg-pHPC-pMC-d[CP]V∈\\[[0-9]+,[0-9]+\\).csv",sep="")
files <- list.files(path = ".", pattern = pattern, recursive=F)

for (f in files) {
  d <- read.csv(f, colClasses = "numeric")
  outname <- substr(f, 0, regexpr('.csv', f)-1)
  outname <- paste(outname, "-ma", ".csv", sep="")
  columns <- colnames(d)
  t <- d[,1]
  d <- d[,2:ncol(d)]
  dma <- ma.cent(d, ma.window)
  dma[is.na(dma)] <- 0
  dma <- cbind(t,dma)
  colnames(dma) <- columns
  write.csv(dma, outname, row.names=F)
} # end for (f in files) {
