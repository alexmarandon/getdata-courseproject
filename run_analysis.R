library(dplyr)
library(reshape2)

remotefile<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
localfile <- "./dataset.zip"
localdirectory <- "UCI HAR Dataset"

if (!file.exists(localfile)) {
    download.file(remotefile,localfile, method="curl")
}
if (!file.exists(localdirectory)) {
    unzip(localfile)
}

featurelistfile <-paste0(localdirectory, "/features.txt", collapse=NULL)
activitylabelsfile <-paste0(localdirectory, "/activity_labels.txt", collapse=NULL)

features <- read.table(featurelistfile
                       , colClasses=c("integer", "character")
                       , col.names=c("feature_id", "feature"))
activities <- read.table(activitylabelsfile
                        , colClasses=c("integer", "character")
                        , col.names=c("activity_id", "activity"))
                        
MeanStdId <- grep("mean|std", features$feature)
MeanStdName <- features$feature[grep("mean|std", features$feature)]


dataTidying <- function(dataset) {
    featurefile = paste0(localdirectory, "/", dataset, "/X_", dataset, ".txt", collapse=NULL)
    activityfile = paste0(localdirectory, "/", dataset, "/y_", dataset, ".txt", collapse=NULL)
    subjectfile = paste0(localdirectory, "/", dataset, "/subject_", dataset, ".txt", collapse=NULL)
    
    setX <- read.table(featurefile, col.names=features$feature)
    setX <- setX[,MeanStdId]
    setY <- read.table(activityfile, col.names=c("activity_id"))
    setY <- cbind(setY, "id"=seq(from = 1, to = length(setY$activity_id)))
    setY <- merge(setY, activities, by.x="activity_id", by.y="activity_id", all=FALSE)
    setY <- arrange(setY, id)
    setY <- as.data.frame(setY$activity)
    colnames(setY) <- c("activity")
    setSubject <- read.table(subjectfile, col.names=c("subject"))
    dataset <- cbind(setSubject, setY, setX)
}

trainset <- dataTidying("train")
testset <- dataTidying("test")

dataset <- rbind(trainset, testset)


datasetMelt <- melt(dataset, id=c("subject", "activity"), na.rm=TRUE)
datasetTidy <- dcast(datasetMelt, subject + activity ~ variable, mean)


