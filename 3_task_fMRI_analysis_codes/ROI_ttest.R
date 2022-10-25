#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# The above two line enables passing arguments through the terminal when calling Rscript.

# ROI analysis
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Define a simple function
ROI_ttest<-function(csvFile)
{
  data <- read.table(csvFile, sep=",") #read data from file
  t.test(data)
}

cat("\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n")
cat("ROI analysis for ", args, "\n")
cat("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n")
ROI_ttest(args)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
############ Some notes (and commented code) I had in the older file before making it a function:
# *REGISTERED ANALYSIS*
# analysis of zstats in the RIGHT PUTAMEN for task vs. rest onsets when comparing the last 2 vs. first 2 runs (in the 3 day group)
#rPutamen <- read.table(paste(folder, 'WoW.csv', sep=""),sep=",") #read data from file
#t.test(rPutamen)

# *REGISTERED ANALYSIS (AMBIGUOUS IF REGISTERED)*
# analysis of zstats in the PUTAMEN for task vs. rest onsets when comparing the last 2 vs. first 2 runs (in the 3 day group)
#Putamen <- read.table(paste(folder, 'WoW.csv', sep=""),sep=",") #read data from file
#t.test(Putamen)

# Exploratory analysis:
# analysis of zstats in the LEFT PUTAMEN for task vs. rest onsets when comparing the last 2 vs. first 2 runs (in the 3 day group)
#lPutamen <- read.table(paste(folder, 'WoW.csv', sep=""),sep=",") #read data from file
#t.test(lPutamen)
