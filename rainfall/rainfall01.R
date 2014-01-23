#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*     Load packages
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
library(plyr)
library(lattice)
library(xts)
library(zoo)
library(lattice)
library(reshape2)
library(TTR)
library(data.table)
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*       Setting up directory and files list
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#set this according to the files you have
dirVars <- c("C:/metro_data/Run/", "Rain", "20", "/")
locVars <- c("1311","1316","1408")
locNames <- c("Dharan_Bazar", "Sunsari", "Damak")
for (i in 1:length(locVars)) {
  dirTemp <- paste(dirVars[1], dirVars[2],locVars[i],dirVars[3],dirVars[4], sep="")
  locTemp <- locNames[i]
  outputFile <- paste(dirVars[1],locTemp, "_rain1",".csv", sep="")
  fileList <- c(dir(dirTemp))
  numFiles <- length(fileList)
  #empty dataframe container
  emptyDf <- data.frame(V1 = character(), V2 = character())
  #reading files in a nested loop
  for (j in 1:numFiles) {
    fileTemp <- paste(dirTemp,fileList[j],sep="")
    dataTemp <- read.table(fileTemp, header=FALSE, na.strings=c("DNA", "NA"))
    dayNos <- dataTemp$V1
    yearNos <- unlist(strsplit(fileList[j],"[.]"))
    if (yearNos[2] >=15) {yearPrefix="19"} else {yearPrefix="20"}
    yearNos <- paste(yearPrefix,yearNos[2], sep="")
    originDate <- paste(yearNos, "-01-01", sep="")
    varDate <- as.Date(dayNos - 1, origin = originDate)
    varDate <- as.character(strptime(varDate, "%Y-%m-%d"))
    varRain <- as.character(dataTemp$V2)
    varDay <- format(as.Date(varDate), "%j")
    #make a dataframe
    df <- data.frame(varDate,varRain, varDay)
    emptyDf <- rbind(emptyDf, df)  
  }
  
  #write emptyDf to a file
  write.csv(emptyDf, file = outputFile, row.names=F)
  filesCreated <- c(filesCreated, outputFile)
}
