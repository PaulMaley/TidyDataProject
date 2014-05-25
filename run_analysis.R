## 
## Script for producing tidy data set 
##

## As required in the README, acknowledge the source
print("For data origin see:")
msg <- "[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012"
print(msg)

## Read data 
## (Note: sep defaults to whitespace - sep=" " inserts non-existant data when
## there are two consecutive spaces)
## (Note: read.csv & read.table differ in defaults !! Lots of time wasted here)
## read.table returns DATA FRAMES even when there is one column

## Training data
subject.train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
x.train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y.train <- read.table("./UCI HAR Dataset/train/Y_train.txt")

## Test data
subject.test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
x.test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y.test <- read.table("./UCI HAR Dataset/test/Y_test.txt")

## subject. contains the subject id (supposed to be in 1-30)
## x. contains the measurements
## y. contains the activity label

## Add headings to the subject. data frames
## These come from the second column of the file features.txt
features <- read.table("./UCI HAR Dataset/features.txt")[[2]]
colnames(x.train) <- as.character(features)
colnames(x.test) <- as.character(features)

## Replace the activity identifiers by a descriptive identifier
## These come from the second column of the file activity_labels.txt
## BEWARE: The ordering of the factors changes !!
## head(y.train) gives 5 5 5 5 5 (STANDING)
## head(activities.train) gives 3 3 3 3 3 (which is STANDING with the reordered factors)
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")[[2]]
activities.train <- sapply(y.train[[1]], function(x) activities[[x]])
activities.test <- sapply(y.test[[1]], function(x) activities[[x]])

## Change the column heading of subject data frames
## (this is because you can't change them below by 
## putting "subject=" when making the new data frame)
colnames(subject.train) <- c("subject")
colnames(subject.test) <- c("subject")

## Merge the subject and activity and measurments 
## into one data frame for each of test and training 
train <- cbind(subject.train, activity=activities.train, x.train)
test <- cbind(subject.test, activity=activities.test, x.test)

## I am going to concatenate the two data sets (test and train) together
## but so as not to lose track of which set an observation comes from
## I'll add a new column ("dataSet") with values in ("Test", "Train") 
train$dataSet <- "Train"
test$dataSet <- "Test"

## Concatenate the data
df <- rbind(train, test)
print(nrow(df))

##
## Ah, I now discover that the train and test data contain different
## subjects ... so there was no real need to do this.
##


## Now reduce the data columns to only those that are to do
## with the mean or standard deviation - do this by some 
## pattern recognition on the column headings
## the vector f will contain TRUE for any feature name containing
## mean or std 
f <- sapply(features, function(x) grepl("mean|std|Mean|Std",x) )

## Restrict the data frame to these variables plus the columns
## added previously (columns 1,2, and the last one)
df <- df[,c(TRUE,TRUE,f,TRUE)]

## Remove columns with name "angle..."
f <- sapply(colnames(df), function(x) !grepl("angle",x))
df <- df[,f]

## Rename the columns to get rid of "()" and "-"
## Capitalise the first letters of "mean" and "std" also
## This seems to give reasonable (matter of opinion) names 
z <- colnames(df)
z <- sapply(z, function(x) gsub("\\()","", x))
z <- sapply(z, function(x) gsub("-","", x))
z <- sapply(z, function(x) gsub("mean","Mean", x))
z <- sapply(z, function(x) gsub("std","Std", x))
colnames(df) <- z

## df is now the first tidy data set .... write it to a file
write.table(df, "tidyData1.txt", row.names=FALSE)

## Production of second dataset
## Use the plyr package to group the data
library("plyr")

## How does this work?
## As far as I understand, as follows:
## ddply takes the input frame df[1:81]
## (I remove the last train/test column which is non numeric and redundant anyway)
## For each combination of subject and activity it forms internally a data frame:
## The rows are the observations and the columns are the same as for df
## It then applies a function to each data frame which should operate on the rows
## and return a statistic per variable - in this case the mean
## We thus have one number per variable per combination of subject/activity
##
## Perform a check !!
## Check that the following two give the same result (0.27642)
# mean(df[df$activity=="WALKING" & df$subject==2, "tBodyAccMeanX"])
# M[M$activity=="WALKING" & M$subject==2, "tBodyAccMeanX"]
## ok ..

## Form the data frame
M <- ddply(df[1:81], .(subject, activity), function(x) {apply(x[3:81], 2, mean)} )

## Write it out into a file
write.table(M, "tidyData2.txt", row.names=FALSE)
 
## To read the file use:
# read.table("tidyData2.txt", header=TRUE )

 