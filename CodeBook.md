# Getting-and-Cleaning-Data - Code Book


Tidy Data Set contains mean values for means and standard deviations of:
Time domain signals:
 - tBodyAccMag <br/>
 - tGravityAccMag <br/>
 - tBodyAccJerkMag <br/>
 - tBodyGyroMag <br/>
 - tBodyGyroJerkMag <br/>

And frequency domain signals:
 - fBodyAccMag <br/>
 - fBodyAccJerkMag <br/>
 - fBodyGyroMag <br/>
 - fBodyGyroJerkMag <br/>

For 6 types of activity (*ActivityName*) and 30 volunteers within an age bracket of 19-48 years (*Subject*).

  Tidy data set does not contain vriables using 3-axial signals in the X, Y and Z directions

## Script consist of the following parts:

0. Download the data, unzip and read datasets

```
file <- "UCI HAR Dataset.zip"
download.file(fileUrl, file, method="curl")
unzip(file, list = FALSE, overwrite = TRUE)

# read feature file
dtFeatures <- read.table(paste0(home, "/", folder, "/", "features.txt"),sep="",stringsAsFactors=F)
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))

# read activity labels file
dtActivityLabels <- read.table(paste0(home, "/", folder, "/", "activity_labels.txt"),sep="",stringsAsFactors=F)
setnames(dtActivityLabels, names(dtActivityLabels), c("ActivityNum", "ActivityName"))


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
```
1. Merge the training and the test sets to create one data set

```
# merge subject files
dtSubject <- rbind(TestSubject, TrainSubject)

# merge activity files
dtActivity <- rbind(TestActivity, TrainActivity)

# merge data files
dtData <- rbind(TestData, TrainData)
```
2. Extract only the measurements on the mean and standard deviation for each measurement

```
dtData2 <-dtData[, c(grep("Mag\\.mean|Mag\\.std", colnames(dtData)))]
```
3. Use descriptive activity names to name the activities in the data set

```
dtActivity <- merge(dtActivity, dtActivityLabels, by="ActivityNum", all.x=TRUE)
```
4. Label the data set with descriptive variable names

```
dtFullData <- cbind(dtSubject , dtActivity, dtData2)
```
5. Create a second, independent tidy data set with the average of each variable for each activity and each subject# Getting-and-Cleaning-Data

```
varList <- colnames(dtFullData[,-c(1:3)])
dtTidyData <- ddply(dtFullData, .(Subject, ActivityName), function(x) {colMeans(x[, c(varList)])})
```


## Final data set Summary:

```
str(dtTidyData)
```
```
  'data.frame':	35 obs. of  24 variables:
  Subject                      : int  1 1 2 3 4 5 6 7 8 8 ...
  ActivityName                 : chr  "WALKING_DOWNSTAIRS" "WALKING_UPSTAIRS" "WALKING" "WALKING_DOWNSTAIRS" ..
  tBodyAccMag.mean             : num  -0.0141 -0.4922 -0.5353 -0.5631 -0.5616 ...
  tBodyAccMag.std              : num  -0.102 -0.532 -0.553 -0.591 -0.607 ...
  tGravityAccMag.mean          : num  -0.0141 -0.4922 -0.5353 -0.5631 -0.5616 ...
  tGravityAccMag.std           : num  -0.102 -0.532 -0.553 -0.591 -0.607 ...
  tBodyAccJerkMag.mean         : num  -0.22 -0.574 -0.588 -0.65 -0.656 ...
  tBodyAccJerkMag.std          : num  -0.173 -0.546 -0.512 -0.608 -0.647 ...
  tBodyGyroMag.mean            : num  -0.0917 -0.5091 -0.6148 -0.6432 -0.6563 ...
  tBodyGyroMag.std             : num  -0.205 -0.526 -0.681 -0.674 -0.707 ...
  tBodyGyroJerkMag.mean        : num  -0.406 -0.66 -0.747 -0.784 -0.819 ...
  tBodyGyroJerkMag.std         : num  -0.462 -0.669 -0.74 -0.804 -0.844 ...
  fBodyAccMag.mean             : num  -0.0676 -0.5145 -0.5146 -0.5791 ... -0.6021
  fBodyAccMag.std              : num  -0.264 -0.618 -0.647 -0.663 -0.673 ...
  fBodyBodyAccJerkMag.mean     : num  -0.12 -0.532 -0.51 -0.605 -0.635 ...
  fBodyBodyAccJerkMag.std      : num  -0.254 -0.567 -0.519 -0.616 -0.667 ...
  fBodyBodyGyroMag.mean        : num  -0.248 -0.56 -0.7 -0.717 -0.746 ...
  fBodyBodyGyroMag.std         : num  -0.325 -0.588 -0.725 -0.704 -0.733 ...
  fBodyBodyGyroJerkMag.mean    : num  -0.436 -0.664 -0.752 -0.81 -0.839 ...
  fBodyBodyGyroJerkMag.std     : num  -0.538 -0.699 -0.744 -0.81 -0.863 ...
```
