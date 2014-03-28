#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*     Reading rainfall data                                           *
#*  2013-08-21                                                         *
#*  Update: 2014-01-24: reading all files from folder                  *
#*                                                                     *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*       Setting up directory
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
dirData <- "U:/metro_data/Run4/Rain"
dirList <- list.dirs(dirData, full.names=TRUE, recursive=FALSE)

#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*       Function to read and append rainfall files
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
readRain <- function(xdir) {
  xfilelist <- list.files(xdir, full.names=TRUE, pattern="AS")
  rainrecx <- data.frame(do.call("rbind", lapply(xfilelist,
                                              function(xfile) {
                                                   tempdata <- read.table(xfile, header=FALSE)
                                                   dayNos <- tempdata$V1
                                                   yearNos <- paste0(substr(xfile, nchar(xfile)-4, nchar(xfile)-3),
                                                                     substr(xfile, nchar(xfile)-1, nchar(xfile)))
                                                   originDate <- paste0(yearNos, "-01-01")
                                                   varDate <- as.Date(dayNos - 1, origin = originDate)
                                                   varDate <- as.character(strptime(varDate, "%Y-%m-%d"))
                                                   varRain <- as.character(tempdata$V2)
                                                   varDay <- format(as.Date(varDate), "%j")
                                                   cbind(varDate, varRain, varDay)
                                                 })))
  outputFile <- paste0(dirData, "/", substr(xdir, nchar(xdir)-3, nchar(xdir)),
                       "rain.csv")
  write.csv(rainrecx, file = outputFile, row.names=F)
  return(outputFile)
}

#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*       Read and write files
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
lapply(dirList, readRain)