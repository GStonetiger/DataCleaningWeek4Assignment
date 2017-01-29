# This R script does the following.
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

library(dplyr)
library(readr)
library(reshape2)
# ------------------------------------------------------------------------------
## 1. Merges the training and the test sets to create one data set.
# ------------------------------------------------------------------------------
unzip("Dataset.zip")

# merge X_test and X_train
xtest <- read_fwf("./UCI HAR Dataset/test/X_test.txt",
                  fwf_widths(rep(16, 561)))
xtrain <- read_fwf("./UCI HAR Dataset/train/X_train.txt",
                   fwf_widths(rep(16, 561)))
x <- rbind(xtest, xtrain)

# ------------------------------------------------------------------------------
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# ------------------------------------------------------------------------------
features <- read.table(file = "./UCI HAR Dataset/features.txt"
                       , stringsAsFactors = FALSE)
# get column indexes for all measurements on mean and std
ms <- grep("mean|std", features$V2)
msv <- grep("mean|std", features$V2, value = TRUE)

# x (mean and standard deviation)
xms <- x[, ms]

# ------------------------------------------------------------------------------
## 4. Appropriately labels the data set with descriptive variable names.
# ------------------------------------------------------------------------------
names(xms) <- msv

# merget subject_test and subject_train
subjecttest <-
    read.table(file = "./UCI HAR Dataset/test/subject_test.txt")
subjecttrain <-
    read.table(file = "./UCI HAR Dataset/train/subject_train.txt")
subject <- rbind(subjecttest, subjecttrain)
names(subject) <- "subject"

# merge y_test and y_train
ytest <- read.table(file = "./UCI HAR Dataset/test/y_test.txt")
ytrain <- read.table(file = "./UCI HAR Dataset/train/y_train.txt")
y <- rbind(ytest, ytrain)
names(y) <- "activityId"

# ------------------------------------------------------------------------------
# 3. Uses descriptive activity names to name the activities in the data set
# ------------------------------------------------------------------------------
# retrive activity labels
act <- read.table(file = "./UCI HAR Dataset/activity_labels.txt")
names(act) <- c("activityId", "activity")
y <- inner_join(y, act, by = "activityId")

# combine subject, activity(y), and all measurements on mean and standard deviation
ssd <- cbind(subject, y, xms)

# ------------------------------------------------------------------------------
# 5. From the data set in step 4, creates a second, independent tidy data set with
#    the average of each variable for each activity and each subject.
# ------------------------------------------------------------------------------
aggdata <- with(ssd, aggregate(ssd, by=list(Subject=subject, Activity=activity), FUN=mean, na.rm = TRUE))
aggdata <- select(aggdata, 1:2, 6:84)
md <- melt(aggdata, id=c("Subject", "Activity"))

write.table(md, file = "tidydata_Samsung.txt", row.name=FALSE)