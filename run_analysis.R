library("reshape2")
library("data.table")
setwd("/Users/ula/数据分析/coursera/dataScience/course3/")
path <- getwd()
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, file.path(path, "Dataset.zip"), method = "curl")
dataDownloaded <- data()
unzip(zipfile = "Dataset.zip")

# Extracts measurements on mean and standard deviation for each measurement
activitylabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"),col.names = c("classLabels", "activityNames"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("featureIndex", "featureNames"))
selectFeatures <- grep("mean|std", features$featureNames)
featuresfiltered <- features[selectFeatures,]
#Appropriately labels the data set with descriptive variable names, extract "()" in the variable names
featuresfiltered <- gsub("[()]","", featuresfiltered[,featureNames])

#load traindata
#using with = FALSE, referring to a column by number is ok in data.table
traindata <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, selectFeatures, with= FALSE]
names(traindata) <- c(featuresfiltered)
trainActivity <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trainSubject <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("Subject"))
train <- cbind(trainSubject, trainActivity, traindata)

#load testdata
testdata <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, selectFeatures, with= FALSE]
names(testdata) <- c(featuresfiltered)
testActivity <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubject <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("Subject"))
test <- cbind(testSubject, testActivity, testdata)

#merges the training and the test sets to create one data set
combined <- rbind(train, test)
#Uses descriptive activity names to name the activities in the data set
final <- merge(activitylabels, combined, by.x="classLabels", by.y="Activity")

#creates a second, independent tidy data set with the average of each variable for each activity and each subject
final[["Subject"]] <- as.factor(combined[, Subject])
newdata <- melt(data = final, id = c("Subject", "activityNames"), measure.vars= c(featuresfiltered))
finalnew <- dcast(data = newdata, Subject + activityNames ~ variable, fun.aggregate = mean)
fwrite(x = finalnew, file = "finalTidyData.txt", quote = FALSE)
