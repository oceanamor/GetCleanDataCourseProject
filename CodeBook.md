#**finalsensordata.txt is made up of the following 4 fields**

- **activityname** – the name of the activity
	  1. WALKING
	  2. WALKING\_UPSTAIRS
	  3. WALKING\_DOWNSTAIRS
	  4. SITTING
	  5. STANDING
	  6. LAYING

- **subjectnumber** – the number of the subject that performed the activity (1-30)
- **measurement** – the type of measurement being made follows the naming convention noting elements 4 and 6 may not be present in all variable names
  1. either time or frequency (variable name has "time" or "frequency")
  2. body or gravity (variable name has "body" or "gravity")
  3. either and accelerometer(variable name has "acc") or gyroscope(variable name has "gyro")
  4. measurement derivation of jerk or magnitude calculations (variable name will have "jerk" or "mag") noting that in the case of raw measurements this element of the name does not exist
  5. measurement statistic of mean or standard deviation (variable name has "mean" or "std") 
  6. if the variable name ends in vector it indicates which three dimensional axis the to which the measurement applies (variable name will have "xvector", "yvector", or "zvector")

- **mean** – the average of the measurement values grouped by activtyname, subjectnumber, and measurement

**More information regarding the original data can be found in the source files**

[http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)  
  
  
 [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
