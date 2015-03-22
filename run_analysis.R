#loading required libraries
library(dplyr)
library(reshape2)

# set file variables
remotefile<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
localfile <- "./dataset.zip"
localdirectory <- "UCI HAR Dataset"

#check if remotefile already downloaded
if (!file.exists(localfile)) {
    download.file(remotefile,localfile, method="curl")
}
#check if dataset already unzipped
if (!file.exists(localdirectory)) {
    unzip(localfile)
}

#Loading Features and activites
featurelistfile <-paste0(localdirectory, "/features.txt", collapse=NULL)
activitylabelsfile <-paste0(localdirectory, "/activity_labels.txt", collapse=NULL)

features <- read.table(featurelistfile
                       , colClasses=c("integer", "character")
                       , col.names=c("feature_id", "feature"))
activities <- read.table(activitylabelsfile
                        , colClasses=c("integer", "character")
                        , col.names=c("activity_id", "activity"))

#column names for the mean/std filtered variables
# filter defined as the variable containing either mean or std in its name                 
MeanStdId <- grep("mean|std", features$feature)
MeanStdName <- features$feature[grep("mean|std", features$feature)]
MeanStdName <- gsub("[()]","", MeanStdName)
MeanStdName <- gsub("-","_", MeanStdName)


dataTidying <- function(dataset) {
    
    #setting files variable based on dataset (either test or train)
    featurefile = paste0(localdirectory, "/", dataset, "/X_", dataset, ".txt"
        , collapse=NULL)
    activityfile = paste0(localdirectory, "/", dataset, "/y_", dataset, ".txt"
        , collapse=NULL)
    subjectfile = paste0(localdirectory, "/", dataset, "/subject_", dataset, ".txt"
        , collapse=NULL)
    
    #loading feature file
    setX <- read.table(featurefile, col.names=features$feature)
    
    #filter set based on name containing either mean or std (step 2)
    setX <- setX[,MeanStdId]
    
    #setting column names in a nice & tidy way (step 4)
    colnames(setX) <- MeanStdName
    
    #loading activities
    setY <- read.table(activityfile, col.names=c("activity_id"))
    
    #indexing activity set to preserve sort order during merge phase
    setY <- cbind(setY, "id"=seq(from = 1, to = length(setY$activity_id)))

    #Inner join based on activity_id (step 3)
    setY <- merge(setY, activities
        , by.x="activity_id"
        , by.y="activity_id", all=FALSE)

    #restore initial sort order 
    setY <- arrange(setY, id)
    
    #subset based on activity name
    setY <- as.data.frame(setY$activity)

    #setting tidy column name for activity
    colnames(setY) <- c("activity")

    #loading subject data
    setSubject <- read.table(subjectfile, col.names=c("subject"))

    #merging activities, subject and features
    dataset <- cbind(setSubject, setY, setX)
}

#loading, filetering and cleaning train data set
trainset <- dataTidying("train")

#loading, filetering and cleaning test data set
testset <- dataTidying("test")

#merge train & test sets (step 1)
dataset <- rbind(trainset, testset)

#output first data set from expected output
write.table(dataset, "tidyDS1.txt", row.names=FALSE)

#using melt / dcast to group data by subject & activity and to aggregate it 
#with the mean function 
datasetMelt <- melt(dataset, id=c("subject", "activity"), na.rm=TRUE)
datasetTidy <- dcast(datasetMelt, subject + activity ~ variable, mean)

#output second data set from expected output
write.table(datasetTidy, "tidyDS2.txt", row.names=FALSE)

