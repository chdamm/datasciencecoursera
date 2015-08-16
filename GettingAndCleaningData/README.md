Getting and Cleaning Data Project Course
========================================

Overview of the script
----------------------

The script assumes that the input files are in a folder called "UCI HAR Dataset", which should exist in the current working directory.

The script performs the following steps (highlevel):

 1. Combines the "test" and "train" data sets by concatenating the files.
 2. Reads the combined files (in chunks to not run out of memory), and for each observation it:
     a. Assigns meaningful column names (taken from features.txt)
     b. Takes only the "mean" and "std" columns
 3. Adds an Activity variable to the data set (by merging with activity_labels.txt)
 4. Adds a SubjectNumber variable to the data set (by merging with subject.txt)
 5. Groups by SubjectNumber and Activity, and for each group calculates the means of all the measurements

