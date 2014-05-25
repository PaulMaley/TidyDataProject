README
======

## Repository contents
- README.md --- This file
- run_analysis.R --- The script for producing the tidy dataset from the raw 
- CodeBook.md --- A description of the variables in the tidy dataset
- CodeBook.Rmd --- A file to be "knitred" to produce the CodeBook

### Using the code
To produce the tidy data set you must source the analysis script:
```
> source("run_analysis.R")
```

The script assumes that the data files are in a directory `UCI HAR Dataset` which
is in the same directory as the script itself.   
It also assumes that the layout of 
the data files beneath this directory is the same as in the zip file. 

### What the code does
The code executes the following steps

- Read the data files for the test data into data frames. subject_test.txt contains the subject 
  id (1-30), x_test.txt contains the measurements (561 columns), 
  y_test.txt contains the activity label. 
- Repeat for the training data
- Read the features.txt file to get the 561 measurement names
- Name the measurement columns according to this feature list
- Read the activity_labels.txt file to get the activity names
- Replace the activity identifier by an appropriate character string ("WALKING" etc.) 
- Combine the subject, activity and measurments data frames into a single dataframe using `cbind`
- add an extra column, called `dataSet` to both training and test dataframes. Set its value to "Test" or "Train" depending on the data set.
- Concatenate the test and training data frames. The origin of each row is preserved in the `dataSet` column
- Use `grepl("mean|std|Mean|Std",x)` to identify all measurment columns that conatain the word "mean" or "std" (standard deviation)
- Remove those measurements that start with "angle" which are superfluous
- Produce a new data containing only the columns, subject, activity, dataSet and those measurment columns selected above.
- Rename the measurement columns to get rid of "()" and "-" which may cause problems later
- This is the first tidy dataset
- Write it to a file called `tidyData1.txt`
- This large data set is then grouped into sub data sets depending on the value of `subject` and `activity` using the plyr package (and the ddply function)
- For each subset the mean of the observations is calculated and written into a new data frame
- This data frame is written into the file `tideyData2.txt`


### First tidy data set
The variable descriptions are contained in the file CodeBook.md.
To read the file do
```
read.table("tidyData1.txt", header=TRUE, row.names=FALSE)
```

### Second Tidy data set
The variable descriptions are contained in the file CodeBook.md.
```
read.table("tidyData2.txt", header=TRUE, row.names=FALSE)
```

### To produce the CodeBook
The Code book is produced from the CodeBook.Rmd file:
`
knit("CodeBook.Rmd", "CodeBook.md")
`
 
