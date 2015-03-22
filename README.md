# Introduction
This is my submission for the course project from the Coursera Getting & Cleaning Data Course.
The main purpose of this project is to transform an existing data set (from the Human Activity Recognition Using Smartphones Data Set - [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)).
The expected output is a set of 2 files containing each a tidy data set (tidyDS1.txt and tidyDS2.txt) along with a script (run_analysis.R) to create these files, a Code Book describing the tidy data sets (CodeBook.md) and a Readme file (README.md)

# Instructions
(taken from the Course Website)
You should create one R script called run_analysis.R that does the following:
- Merges the training and the test sets to create one data set. 
- Extracts only the measurements on the mean and standard deviation for each measurement. 
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names. 
- From the data set in the previous step creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Required R Packages
The script requires the dplyr and the reshape2 packages. You can install them using the install.packages command

# How to Run the Script
- Place the run_analysis.R in your working directory in R
- run the script by typing 
>source(« run_analysis.R »)
- The script will download and extract the source dataset if not present
- It will then create 2 files tidyDS1.txt & tidyDS2.txt which are the expected outcome of the exercise.

# How the Script Works
- The script will first check if the dataset.zip file is present. If not, it will download it from the following location: [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
- It will then check for the « UCI HAR Dataset » directory in the current folder. If not present, it will unzip the dataset.zip file in it.

For each of the train and test data set, the script will perform:
- load the feature file X_test/train.txt file
- filter the mean/standard deviation related variables using the grep(« mean|std ») function. This will extract the 79 mean(), std() and meanFreq() variables.
- load the activity file y_train/test.txt
- index the file to store the sort order before applying the merge function (which messes up the sort order)
- join the data with the activity_labels.txt files to store the activity labels (using the merge function)
- load the subject_test/train.txt data
- assemble the 3 data sets using the cbind function
- the dataset is also properly labeled using the features names with a little bit of cleanup for readability purposes.

Once the 2 datasets train & test have been created and tidied, the following actions are then performed:
- assemble the train and test dataset using the rbind() function
- create the tidyDS1.txt file
- use the melt / dcast functions from the reshape2 package to aggregate the features for each activity / subject pair using the mean function.
- create the tidyDS2.txt file

# A note on respecting the instruction order and guidelines
In order to optimize execution and memory space, train & test data are cleaned and filtered before being merged together (step 1 in the instructions).
This includes filtering mean & std data (step 2), using descriptive activity names from the activity_labels.txt (step 3), and labeling the variable appropriately(step 4)
Step 5 is then executed at the end using the reshape2 package.
