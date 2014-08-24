**The data used for this project was created by**

Human Activity Recognition Using Smartphones Dataset

Version 1.0

Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.

Smartlab - Non Linear Complex Systems Laboratory

DITEN - Università degli Studi di Genova.

Via Opera Pia 11A, I-16145, Genoa, Italy.

activityrecognition@smartlab.ws

[www.smartlab.ws](http://www.smartlab.ws)

**Source Files**

[http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)  
  
  
 [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

**This dataset includes the following files:**

README.md – this file

CodeBook.md – explains the fields in the data

finalsensordata.txt – final summarized output data described in CodeBook.md

**Goal was to do the following in R:**

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variablenames.
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

**Set your working directory so path references will work accurately (commented out for peer review**

setwd("~/JohnsHopkinsDataScience/RFiles/GettingCleaningData/")

**Open libraries necessary for analysis**

	library(plyr)
	library(Hmisc)
	library(reshape2)

**Get the data into R from the text files available online – this step also addressed a portion of number 4 above by removing special characters from the features dataset and replacing them with underscores as well as converting all data to lower case. The read.table function will then use the information from the features text file to populate the column headers of the data using the col.names argument**

	FEATURES\_TEMP1 <- read.table("./UCI HAR Dataset/features.txt",header=FALSE,sep=" ")
	FEATURES\_TEMP2 <- sapply(FEATURES\_TEMP1,tolower)
	FEATURES\_TEMP3 <- gsub("-","\_",FEATURES\_TEMP2)
	FEATURES\_TEMP4 <- gsub("\\(","\_",FEATURES\_TEMP3)
	FEATURES\_TEMP5 <- gsub("\\)","\_",FEATURES\_TEMP4)
	FEATURES\_TEMP6 <- gsub("\\,","\_",FEATURES\_TEMP5)
	FEATURES\_TEMP7 <- gsub("\_\_\_\_","\_",FEATURES\_TEMP6)
	FEATURES\_TEMP8 <- gsub("\_\_\_","\_",FEATURES\_TEMP7)
	FEATURES\_TEMP9 <- gsub("\_\_","\_",FEATURES\_TEMP8)
	FEATURES <- as.vector(FEATURES\_TEMP9[,2])

	ACTIVITIES <-read.table("./UCI HAR Dataset/activity\_labels.txt",header=FALSE,sep="",col.names=c("activitynumber","activityname"))

	TESTX <- read.table("./UCI HAR Dataset/test/X\_test.txt",header=FALSE,sep="",col.names=FEATURES)

	TESTY <- read.table("./UCI HAR Dataset/test/Y\_test.txt",header=FALSE,sep="",col.names="activitynumber")

	TESTSUBJECT <- read.table("./UCI HAR Dataset/test/subject\_test.txt",col.names="subjectnumber")

	TRAINX <- read.table("./UCI HAR Dataset/train/X\_train.txt",header=FALSE,sep="",col.names=FEATURES)

	TRAINY <- read.table("./UCI HAR Dataset/train/Y\_train.txt",header=FALSE,sep="",col.names="activitynumber")

	TRAINSUBJECT <- read.table("./UCI HAR Dataset/train/subject\_train.txt",col.names="subjectnumber")

**Simple data check to make sure that subjects are not used in both the testing and training data**

	intersect(unique(TESTSUBJECT),unique(TRAINSUBJECT))

**This section of the code combines the test data with the test activity data and test subject data by using the cbind function noting that this action was performed prior to performing and sorting or merging to ensure that the original order of the data is preserved**

	TESTALL = cbind(TESTX,TESTY,TESTSUBJECT)
	TRAINALL = cbind(TRAINX,TRAINY,TRAINSUBJECT)

**The two datasets are then stacked on top of each other using the rbind function**

	ALL1 = rbind(TESTALL,TRAINALL)

**This step joins the activity descriptions to the large dataset created above automatically using the key "activitynumber" including a check to make sure that is the only variable that the two tables have in common**

	intersect(names(ACTIVITIES),names(ALL1))
	ALL2 <- join(ACTIVITIES,ALL1)

**This section uses various grepl functions and the or "|" operator to only keep variables we are interested in based on their column names. According to the README.txt that came with the file only the following values are the true mean and standard deviation "The set of variables that were estimated from these signals are: mean(): Mean value std(): Standard deviation . . . " as a result I only look for those columns that have that information in the column header to keep in my data**

	KEEPCOLNAME <- grepl("\_mean\_",names(ALL2))|grepl("\_std\_",names(ALL2))|grepl("\*subject\*",names(ALL2))|grepl("\*activityname\*",names(ALL2))
	ALL3 <- ALL2[KEEPCOLNAME]

**This section does the final formatting to the variable names to align with tidy concepts taught in the course. NOTE: I would not typically remove \_'s as I believe those make the data more readable but did so in this case to follow course guidelines**

	COLFORMAT1 <- gsub("^t","time",names(ALL3))
	COLFORMAT2 <- gsub("^f","frequency",COLFORMAT1)
	COLFORMAT3 <- gsub("x$","xvector",COLFORMAT2)
	COLFORMAT4 <- gsub("y$","yvector",COLFORMAT3)
	COLFORMAT5 <- gsub("z$","zvector",COLFORMAT4)
	COLFORMAT6 <- gsub("bodybody","body",COLFORMAT5)
	COLFORMAT7 <- gsub("\_","",COLFORMAT6)

**Replace the row names with the updated row name generated above**

	write.table(ALL3,"temp.txt",col.names=FALSE,row.names=FALSE)
	ALL4 <- read.table("temp.txt",header=FALSE,sep="",col.names=COLFORMAT7)

**This section of the program reshapes the data into a tidy format using the melt function and then summarizes the data and renames the aggregated variable names. There has been some debate on whether a "wide" format is better or worse than a "narrow" format. I chose to keep the data in a narrow format thinking that further questions regarding the data may more easily be answered if the data is in a "narrow" format: see discussion here** [https://class.coursera.org/getdata-006/forum/thread?thread\_id=236#post-1091](https://class.coursera.org/getdata-006/forum/thread?thread_id=236#post-1091)

**This section also summarizes the data with one row for each unique grouping of subject number, activity name, and measurement type using the aggregate function. It was also necessary to rename the variables after the aggregate function.**

	MELTALL4 <- melt(ALL4,id=c("activityname","subjectnumber"),measure.vars=c(COLFORMAT7[2:67]))
	ALL4SUM <- aggregate(MELTALL4$value,by=list(MELTALL4$activityname, MELTALL4$subjectnumber,MELTALL4$variable),FUN=mean)
	FINAL <- rename(ALL4SUM,c("Group.1"="activityname","Group.2"="subjectnumber","Group.3"="measurement","x"="mean"))

**Write the table out for upload to Coursera**

	write.table(FINAL,"finalsensordata.txt",row.names=FALSE)
