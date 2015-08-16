# Note: this script assumes that your current working directory contains the folder "UCI HAR Dataset".
library(dplyr)
library(Hmisc)


# Combine the test and training data sets (by concatenating the files)
file.create("X.txt")
file.append("X.txt", "UCI HAR Dataset/test/X_test.txt")
file.append("X.txt", "UCI HAR Dataset/train/X_train.txt")
file.create("Y.txt")
file.append("Y.txt", "UCI HAR Dataset/test/Y_test.txt")
file.append("Y.txt", "UCI HAR Dataset/train/Y_train.txt")
file.create("Subject.txt")
file.append("Subject.txt", "UCI HAR Dataset/test/subject_test.txt")
file.append("Subject.txt", "UCI HAR Dataset/train/subject_train.txt")


# Read the names of all the variables
features <- read.csv("UCI HAR Dataset/features.txt", sep = " ", header = FALSE)


# Read all the observations and clean the data
meanAndStdData <- NULL
linesToSkip <- 0
linesToRead <- 100
while (TRUE)
{
    print(linesToSkip)
    
    # Read next batch of lines
    data <- read.fwf("X.txt", widths = rep(16,561), n = linesToRead, skip = linesToSkip)

    # Assign descriptive column names
    colnames(data) <- make.names(features[,2], unique = TRUE)
    
    # Remove uninteresting columns
    dataMeanColumns <- select(data, contains("mean"))
    dataStdColumns <- select(data, contains("std"))
    reducedData <- cbind(dataMeanColumns,dataStdColumns)
    
    # Add these lines to full result
    meanAndStdData <- rbind(meanAndStdData, reducedData)
    
    # Did we read the last lines, then exit the loop
    if (nrow(data) < linesToRead)
    {
        break
    }
    
    # Prepare to read next batch of lines
    linesToSkip = linesToSkip + linesToRead
}
meanAndStdData <- filter(meanAndStdData, !is.na(meanAndStdData[1]))


# Add activity name to each observation
activityNumbersForObservations <- read.csv("Y.txt", header = FALSE)
activityNumbersForObservations <- rename(activityNumbersForObservations, ActivityNumber = V1)
activityLabels <- read.csv("UCI HAR Dataset/activity_labels.txt", sep = " ", header = FALSE)
activityLabels <- rename(activityLabels, ActivityNumber = V1, Activity = V2)
activitiesForObservations <- merge(activityNumbersForObservations, activityLabels)
meanAndStdAndActivityData <- cbind(meanAndStdData, activitiesForObservations) 
print("Result of step 4 is captured in the data frame meanAndStdAndActivityData.")


# Add subject number to each observation
subjectNumbersForObservations <- read.csv("Subject.txt", header = FALSE)
subjectNumbersForObservations <- rename(subjectNumbersForObservations, SubjectNumber = V1)
meanAndStdAndActivityAndSubjectData <- cbind(meanAndStdAndActivityData, subjectNumbersForObservations) 


# Calculate means of all measurements, for each combination of subject+activity
meansBySubjectAndActivity <- aggregate(meanAndStdAndActivityAndSubjectData, by=list(meanAndStdAndActivityAndSubjectData$SubjectNumber,meanAndStdAndActivityAndSubjectData$Activity), FUN=mean)
meansBySubjectAndActivity <- select(meansBySubjectAndActivity, -Activity, -ActivityNumber, -SubjectNumber)
meansBySubjectAndActivity <- rename(meansBySubjectAndActivity, SubjectNumber = Group.1, Activity = Group.2)
meansBySubjectAndActivity <- arrange(meansBySubjectAndActivity, SubjectNumber, Activity)
write.table(meansBySubjectAndActivity, file="Output.txt", row.name = FALSE)
print("Result of step 5 is captured in the data frame meansBySubjectAndActivity as well as stored in the file Output.txt.")

