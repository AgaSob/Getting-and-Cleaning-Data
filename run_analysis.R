# You should create one R script called run_analysis.R that does the following:
# 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

setwd("C:/AGA/TRAININGS/Coursera/Data Science/3. Getting and Cleaning Data/dane")

# 0. Download the data, unzip and read datasets

library(httr)
library(data.table)
library(reshape2)
library(plyr)

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

file <- "UCI HAR Dataset.zip"
download.file(fileUrl, file, method="curl")

if (!file.exists("UCI HAR Dataset")) {
  print("unzip file")
  unzip(file, list = FALSE, overwrite = TRUE)
}

if(!file.exists("UCI HAR Results")){
  dir.create("UCI HAR Results")
}

# "/UCI HAR Dataset" - input data
# "/UCI HAR Results" - result data

home <- getwd()
folder <- "UCI HAR Dataset"
resfolder <- "UCI HAR Results"

# read feature file
dtFeatures <- read.table(paste0(home, "/", folder, "/", "features.txt"),sep="",stringsAsFactors=F)
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))
head(dtFeatures)
dtFeatures$featureName <- sub("\\(\\)", "", dtFeatures$featureName)
head(dtFeatures)

# read activity labels file
dtActivityLabels <- read.table(paste0(home, "/", folder, "/", "activity_labels.txt"),sep="",stringsAsFactors=F)
setnames(dtActivityLabels, names(dtActivityLabels), c("ActivityNum", "ActivityName"))
head(dtActivityLabels)


readData <- function(dt, filename, columnNames=NULL) {
  setwd(paste0(home, "/", folder, "/", dt))
#  list <- grep(".txt$", list.files(), value = TRUE)
  filename <- read.table(paste0(filename, "_", dt, ".txt"), stringsAsFactors=F, col.names= columnNames)
}

# read subject files
TestSubject <- readData("test", "subject", "Subject")
TrainSubject <- readData("train", "subject", "Subject")

# read activity files
TestActivity <- readData("test", "Y", "ActivityNum")
TrainActivity <- readData("train", "Y", "ActivityNum")

# read data files
TestData <- readData("test", "x", dtFeatures$featureName)
TrainData <- readData("train", "x", dtFeatures$featureName)


# 1. Merge the training and the test sets to create one data set

# merge subject files
dtSubject <- rbind(TestSubject, TrainSubject)
head(dtSubject)

# merge activity files
dtActivity <- rbind(TestActivity, TrainActivity)
head(dtActivity)

# merge data files
dtData <- rbind(TestData, TrainData)
head(dtData)


# 2. Extract only the measurements on the mean and standard deviation for each measurement

# select codes for mean and standard deviation from features file
dtFeatures$meanstdtest <- grepl("Mag-mean$|Mag-std", dtFeatures$featureName)
dtFeatures2 <- dtFeatures[grepl("Mag-mean$|Mag-std", dtFeatures$featureName), ]

# select only mean and standard deviation measures from data file
dtData2 <-dtData[, c(grep("Mag\\.mean|Mag\\.std", colnames(dtData)))]
head(dtData2)

dim(dtData)
dim(dtData2)


# 3. Use descriptive activity names to name the activities in the data set

dtActivity <- merge(dtActivity, dtActivityLabels, by="ActivityNum", all.x=TRUE)
head(dtActivity)

# 4. Label the data set with descriptive variable names

dtFullData <- cbind(dtSubject , dtActivity, dtData2)
head(dtFullData)

# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject

varList <- colnames(dtFullData[,-c(1:3)])

dtTidyData <- ddply(dtFullData, .(Subject, ActivityName), function(x) {colMeans(x[, c(varList)])})
head(dtTidyData, 30)

write.table(dtTidyData, paste0(home, "/", resfolder, "/", "dtTidyData.txt"), row.names=FALSE)

str(dtTidyData)
summary(dtTidyData)