library(dplyr)
library(tidyverse)
library(data.table)
library(plyr)
library(tibble)
library(dataMaid)

#Sets wrking directorz and downoaing the zip file
setwd(" ")
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#Unpacking zip file
f <- file.path(getwd(), "data.zip")
download.file(url, f)
unzip(f)

#Read the labels and features
activity_labels<- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("n", "activity"))
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("code", "feature"))

#Load data containing the training datasets
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$feature)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

#Load the test data
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/x_test.txt", col.names = features$feature)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")

#Merge the datasets
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
merged_data <- cbind(Subject, Y, X)

#Create tidy dataset containing the means and std
df_tidy <- select(merged_data, code, subject, contains("mean"), contains("std"))
df_tidy$code <- activity_labels[df_tidy$code, 2]

#Change the names of the variables
names(df_tidy)[1] = "activity"
names(df_tidy)[2] = "subject"
names(df_tidy)<-gsub("Acc", "Accelerometer", names(df_tidy))
names(df_tidy)<-gsub("Gyro", "Gyroscope", names(df_tidy))
names(df_tidy)<-gsub("BodyBody", "Body", names(df_tidy))
names(df_tidy)<-gsub("Mag", "Magnitude", names(df_tidy))
names(df_tidy)<-gsub("^t", "Time", names(df_tidy))
names(df_tidy)<-gsub("^f", "Frequency", names(df_tidy))
names(df_tidy)<-gsub("tBody", "TimeBody", names(df_tidy))
names(df_tidy)<-gsub("-mean()", "Mean", names(df_tidy), ignore.case = TRUE)
names(df_tidy)<-gsub("-std()", "STD", names(df_tidy), ignore.case = TRUE)
names(df_tidy)<-gsub("-freq()", "Frequency", names(df_tidy), ignore.case = TRUE)
names(df_tidy)<-gsub("angle", "Angle", names(df_tidy))
names(df_tidy)<-gsub("gravity", "Gravity", names(df_tidy))

#Saving the tidy datafile
df_final <- df_tidy %>%
        group_by(subject, activity) %>%
        summarise_all(funs(mean))
write.table(df_final, "df_final.txt", row.name=FALSE)


