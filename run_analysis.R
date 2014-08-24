##setworking directory commented out for peer review
##setwd("~/JohnsHopkinsDataScience/RFiles/GettingCleaningData/")

library(plyr)
library(Hmisc)
library(reshape2)
#############################################
##pull all of the necessary data into R 
#############################################

##pull in the features file for column headers
FEATURES_TEMP1 <- read.table("./UCI HAR Dataset/features.txt",header=FALSE,sep=" ")
##convert all characters to lower case
FEATURES_TEMP2 <-  sapply(FEATURES_TEMP1,tolower)
##remove special characters from the column names so can parse the column names into parts to find where the second element
##is equal to mean or std
FEATURES_TEMP3 <- gsub("-","_",FEATURES_TEMP2)
FEATURES_TEMP4 <- gsub("\\(","_",FEATURES_TEMP3)
FEATURES_TEMP5 <- gsub("\\)","_",FEATURES_TEMP4)
FEATURES_TEMP6 <- gsub("\\,","_",FEATURES_TEMP5)
FEATURES_TEMP7 <- gsub("____","_",FEATURES_TEMP6)
FEATURES_TEMP8 <- gsub("___","_",FEATURES_TEMP7)
FEATURES_TEMP9 <- gsub("__","_",FEATURES_TEMP8)


##only keep the name row and convert to a vector so it can be used in the read.table function
FEATURES <- as.vector(FEATURES_TEMP9[,2])

##pull in the activity labels
ACTIVITIES <-read.table("./UCI HAR Dataset/activity_labels.txt",header=FALSE,sep="",col.names=c("activitynumber","activityname"))

##read the text files col.names = FEATURES will append the column names to the top of the table and any special 
##characters will be converted to "."
TESTX <- read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE,sep="",col.names=FEATURES)
TESTY <- read.table("./UCI HAR Dataset/test/Y_test.txt",header=FALSE,sep="",col.names="activitynumber")
TESTSUBJECT <- read.table("./UCI HAR Dataset/test/subject_test.txt",col.names="subjectnumber")

TRAINX <- read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE,sep="",col.names=FEATURES)
TRAINY <- read.table("./UCI HAR Dataset/train/Y_train.txt",header=FALSE,sep="",col.names="activitynumber")
TRAINSUBJECT <- read.table("./UCI HAR Dataset/train/subject_train.txt",col.names="subjectnumber")

## check to make sure that the same subject numbers aren't reused between the train and test
intersect(unique(TESTSUBJECT),unique(TRAINSUBJECT))

##add the columns for activity and subject to each of the test and train tables tables 
TESTALL = cbind(TESTX,TESTY,TESTSUBJECT)
TRAINALL = cbind(TRAINX,TRAINY,TRAINSUBJECT)

##combine the two datasets together to have one large dataset
ALL1 = rbind(TESTALL,TRAINALL)

##test to see which columns are in both tables prior to merging this should only be activitynumber
intersect(names(ACTIVITIES),names(ALL1))

##merge the combined test/train dataset to the activity name dataset
ALL2 <- join(ACTIVITIES,ALL1)

##according to the README.txt that came with the file only the following values are the true mean and standard deviation
##"The set of variables that were estimated from these signals are: mean(): Mean value std(): Standard deviation . . . "
##as a result I only look for those columns that have that information in the column header to keep in my data
KEEPCOLNAME <- grepl("_mean_",names(ALL2))|grepl("_std_",names(ALL2))|grepl("*subject*",names(ALL2))|grepl("*activityname*",names(ALL2))
 
##keep only the columns where the column names matched the patterns indicated above
ALL3 <- ALL2[KEEPCOLNAME]

##format the column names further
COLFORMAT1 <- gsub("^t","time",names(ALL3))
COLFORMAT2 <- gsub("^f","frequency",COLFORMAT1)
COLFORMAT3 <- gsub("x$","xvector",COLFORMAT2)
COLFORMAT4 <- gsub("y$","yvector",COLFORMAT3)
COLFORMAT5 <- gsub("z$","zvector",COLFORMAT4)
COLFORMAT6 <- gsub("bodybody","body",COLFORMAT5)
COLFORMAT7 <- gsub("_","",COLFORMAT6)

##variable naming convention for measurements are the first element is either time or frequency, second element is body or gravity, third element is either
##accelerometer(acc) or gyroscope(gyro) fourth and fifth elements are either the measurement statistice (mean or standard deviation) or the measurement derivation
##(jerk or magnitude)calculation or if the variable name ends in vector in indicates what three dimensional axis the to which the measurement applies (X,Y,Z)
write.table(ALL3,"temp.txt",col.names=FALSE,row.names=FALSE)
ALL4 <- read.table("temp.txt",header=FALSE,sep="",col.names=COLFORMAT7)
 
#you can make a dataset tall and skinny using melt so that you don't have t list all the variables out to summarize
MELTALL4 <- melt(ALL4,id=c("activityname","subjectnumber"),measure.vars=c(COLFORMAT7[2:67]))
##summarize the dataset by the 3 columns taking the mean of the value

ALL4SUM <- aggregate(MELTALL4$value,by=list(MELTALL4$activityname, MELTALL4$subjectnumber,MELTALL4$variable),FUN=mean)
FINAL <- rename(ALL4SUM,c("Group.1"="activityname","Group.2"="subjectnumber","Group.3"="measurement","x"="mean"))
write.table(FINAL,"finalsensordata.txt",row.names=FALSE)
