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
library(Kendall)
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*       Setting up directory and files list
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
dirVars <- c("C:/metro_data/Run/", "Temp", "20", "/")
locVars <- c("1311", "1421", "1320")
locNames <- c("Dharan_Bazar", "Gaida_Kankai", "Tarahara")
filesCreated <- c("")
for (i in 1:length(locVars)) {
  dirTemp <- paste(dirVars[1], dirVars[2],locVars[i],dirVars[3],dirVars[4], sep="")
  locTemp <- locNames[i]
  outputFile <- paste(dirVars[1],locTemp, "_temp1",".csv", sep="")
  fileList <- c(dir(dirTemp))
  numFiles <- length(fileList)
  #empty dataframe container
  emptyDf <- data.frame(V1 = character(), V2 = character(), V3=character())
  #reading files in a nested loop
  for (j in 1:numFiles) {
    fileTemp <- paste(dirTemp,fileList[j],sep="")
    dataTemp <- read.table(fileTemp, header=FALSE, na.strings=c("DNA", "NA"), skip=2)
    dayNos <- dataTemp$V1
    yearNos <- unlist(strsplit(fileList[j],"[.]"))
    if (yearNos[2] >=15) {yearPrefix="19"} else {yearPrefix="20"} #updated from rainfall analysis update
    yearNos <- paste(yearPrefix,yearNos[2], sep="")
    originDate <- paste(yearNos, "-01-01", sep="")
    varDate <- as.Date(dayNos - 1, origin = originDate)
    varDate <- as.character(strptime(varDate, "%Y-%m-%d"))
    varMax <- as.character(dataTemp$V2)
    varMin <- as.character(dataTemp$V3)
    df <- data.frame(varDate,varMax, varMin)
    emptyDf <- rbind(emptyDf, df)
  }
  #write emptyDf to a file
  write.csv(emptyDf, file = outputFile, row.names=F)
  filesCreated <- c(filesCreated, outputFile)
}
#writing list of files created
filesCreated <- filesCreated[-1]
outputFile2 <- paste(dirVars[1], "files_created_temperature",".csv", sep="")
filesCreated.df <- data.frame(filesCreated, locVars, locNames)
names(filesCreated.df) <- c("File", "LocationCode", "Location")
write.csv(filesCreated.df, file = outputFile2, row.names=F)
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*       Prcessing data
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#to be added :)