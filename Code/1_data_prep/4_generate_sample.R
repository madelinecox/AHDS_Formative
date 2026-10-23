#!/usr/bin/env Rscript

library(this.path)

datadir=paste0(this.dir(), "/../../Data/")

# read in the acceleromter ids and survey data
accel_IDs <- read.table(paste0(datadir, 'derived/accel/accel_IDs.txt'), header=FALSE, col.names='PID')
survey_data <- read.table(paste0(datadir, 'derived/BMX_D.tsv'), header=TRUE, sep="\t")

#-------- 2 ways to do this going forward, 1 = solutions, 2 = my way -----------
#1. 
# add indicator to accel data frame to show participants have accel data
accel_IDs$has_accel <- TRUE

# merge together, keeping all participants with either types of data
data_combined <- merge(survey_data, accel_IDs, by.x='SEQN', by.y='PID', all.x=TRUE, all.y=TRUE)

dim(accel_IDs)
dim(survey_data)
dim(data_combined)

# find all participant with a BMI value and accel data
ix <- which(!is.na(data_combined$BMXBMI) & !is.na(data_combined$has_accel))
data_combined$in_sample <- 0
data_combined$in_sample[ix] <- 1



#2.
all_IDs <- survey_data$SEQN
#finding which of 9950 IDs have accel files and adding this info
has_ACCEL <- all_IDs %in% accel_IDs$PID
data_combined_2 <- transform(survey_data, has_accel=has_ACCEL)
#finding which IDs are in our sample - have BMI data AND accel files
data_combined_2$in_sample <- as.integer(!is.na(data_combined$BMXBMI) & data_combined$has_accel==TRUE)

#-------------------------------------------------------------------------------

# see the numbers of people in our sample vs not in our sample
print(table(data_combined$in_sample))

#number of people with BMI data = 8949
length(which(!is.na(data_combined$BMXBMI)))
#number of people with BMI but no accel data
length(which(!is.na(data_combined$BMXBMI) & is.na(data_combined$has_accel)))

# save a sample data file
write.csv(data_combined[,c('SEQN', 'in_sample')], file = paste0(datadir, "derived/sample.csv"), row.names = FALSE)

