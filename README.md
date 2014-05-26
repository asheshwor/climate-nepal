Reading and processing Nepali climatic and hydrological records
===============

This is a collection of ```R``` code to process raw (ASCII) format data on climatic variables obtained from Department of Hydrology and Meteorology (DHM), Babarmahal, Kathmandu, Nepal. While the raw data can be opened in any text editor and copied to a spreadsheet, it can be quite a hassel when dealing with decades of data from multiple stations.

These are the code that I am using for my own research to read the raw data in R, batch combine records for each station and output the data in csv file. This is a work in progress and I will continue to add the code for analysis as my research progresses.

No sample data is presented here as the data obtained from DHM cannot be shared publicly. The format for rainfall and temperature data is presented in the sections below with code sniplets to read and process the records.

Rainfall data
----------
For rainfall data, each file in the dataset consists of one year of rainfall records with each line represented by day of year (DOY) and rainfall for the corresponding DOY in millimeters (mm). The DOY ranges from 1 to 365 during non-leap years and from 1 to 366 in leap years. Missing data is denoted by string 'DNA' and 'trace amount of rainfall' is marked by string 'T'.

Format for rainfall data:

```
      1    3.0
      2    3.0
      3    4.0
      4    0.0
      5    0.0
      6    T
      7    0.0
      8    0.2
      9    6.1
     10    0.8
	 and so on
```

The following code reads rainfall record files of multiple stations and creates a continious record for each station as csv file. Each station's record should be in a separate folder. The daily rainfall records obtained from DHM is named in the ```AS####YY.yy``` where ```####``` is a four digit station code (leading 0 required for three digit codes), ```YY``` represents the first two digits of year and ```yy``` represents the last two digits for the year. For instance, a file ```AS142120.14```  is a daily rainfall record file for year 2014 for station 1421 which is Gaida Kankai in Eastern Nepal.

The year number is extracted from the file. The output file name is extraced based on the folder name which are named in the format ```Rain####``` where ```####``` is a four digit station code. E.g. ```Rain0105``` would be a folder containing daily rainfall records for Mahendranagar station (Station no. 105)


```
dirData <- "x:/metro_data/Rain" #directory which has folder(s)
dirList <- list.dirs(dirData, full.names=TRUE, recursive=FALSE) #list of folders
#*       Function to read and append rainfall files
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

lapply(dirList, readRain) #apply the function to folders
```

The same code with for loop.

```
#set the directory which has folders for each station
dirData <- "X:/metro_data/Rainfall"
dirList <- list.dirs(dirData, full.names=TRUE, recursive=FALSE)
#function to read, process and append record in each folder
readRain <- function(xdir) {
  xfilelist <- list.files(xdir, full.names=TRUE, pattern="AS",
                          recursive=TRUE, include.dirs=TRUE)
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
#apply read and write functon to all folders
lapply(dirList, readRain)
```

Format of converted rainfall data csv file:

```
varDate	varRain	varDay
01-01-00	0	1
02-01-00	0	2
03-01-00	0	3
04-01-00	0	4
05-01-00	0	5
06-01-00	0	6
07-01-00	0	7
08-01-00	0	8
 and so on
```

Temperature data
----------
The first line of each of the files for temperature data consists of the corresponding 4 digit year number and name of the station. The second line consists of column headings for maximum and minimum temperatures. From the third line onwards, each text file in the dataset consists of one year of temperature records with each line represented by DOY, maximum temperature and minimum temperature for the corresponding DOY in Celsius (°C). The DOY ranges from 1 to 365 during non-leap years and from 1 to 366 in leap years.

Format for temperature data:

```
1985          	Temperature for <STATION NAME>                
        Tmax  	Tmin
     1  33.0   	4.0 
     2  30.5  	10.1 
     3  26.0  	10.8 
     4  27.0   	20.0 
     5  28.0  	12.5 
     6  29.0   	5.0 
     7  22.5   	5.5 
	 and so on
```

The following code reads temperature record files of multiple stations and creates a continious record for each station in csv format. Each station's record should be in a separate folder. The daily temperature records obtained from DHM is named in the ```TA####YY.yy``` where ```####``` is a four digit station code (leading 0 required for three digit codes), ```YY``` represents the first two digits of year and ```yy``` represents the last two digits for the year. For instance, a file ```TA131120.14```  is a daily temperature record file for year 2014 for station 1311 which is Dharan Bazar in Eastern Nepal.

The year number is extracted from the file. The output file name is extraced based on the folder name which are named in the format ```Temp####``` where ```####``` is a four digit station code. E.g. ```Temp0105``` would be a folder containing daily temperature records for Mahendranagar station (Station no. 105)


```
#set the directory which has folders for each station
dirData <- "C:/metro_data/Run4/Temp"
dirList <- list.dirs(dirData, full.names=TRUE, recursive=FALSE)
#function to read, process and append record in each folder
readTemperature <- function(xdir) {
  xfilelist <- list.files(xdir, full.names=TRUE, pattern="TA")
  temprecx <- data.frame(do.call("rbind", lapply(xfilelist,
                                                 function(xfile) {
    tempdata <- read.table(xfile, header=FALSE, skip=2)
    dayNos <- tempdata$V1
    yearNos <- paste0(substr(xfile, nchar(xfile)-4, nchar(xfile)-3),
                      substr(xfile, nchar(xfile)-1, nchar(xfile)))
    originDate <- paste0(yearNos, "-01-01")
    varDate <- as.Date(dayNos - 1, origin = originDate)
    varDate <- as.character(strptime(varDate, "%Y-%m-%d"))
    varMax <- as.character(tempdata$V2)
    varMin <- as.character(tempdata$V3)
    #varDay <- format(as.Date(varDate), "%j")
    cbind(varDate, varMax, varMin)
  })))
  outputFile <- paste0(dirData, "/", substr(xdir, nchar(xdir)-3, nchar(xdir)),
                       "temp.csv")
  write.csv(temprecx, file = outputFile, row.names=F)
  return(outputFile)
}
#apply read and write functon to all folders
lapply(dirList, readTemperature)
```

Format of converted temperature data in csv file:

```
Date		Max		Min	
01-01-00	23		9		
02-01-00	22		11.5	
03-01-00	18		7.1		
04-01-00	20.9	7.5		
05-01-00	20		12.5	
06-01-00	20.5	4		
07-01-00	20		7		
 and so on
```

Station name and code
----------
List of meteorological stations in Nepal can be found at http://www.dhm.gov.np/meteorological-station

See https://github.com/asheshwor/R-maps/blob/master/01_simple-map.R for R code to plot meterological stations of Nepal.

Counting NAs in temperature records
----------
One of the first we do once we get daily records is to check for days with no records. While there are many ways to count NA values in R, here's an example using ```ddply``` function from ```plyr``` package.

```
require(plyr)
temprec <- read.table("Dharan_Bazar_temp1.csv", sep="," , stringsAsFactors = FALSE)
temprec$Year <- strftime(as.Date(temprec$Date), format='%Y')
temprecna <- ddply(temprec, c("Year"), function(df) c(MaxNA = sum(is.na(df$Max)),
                                                      MinNA = sum(is.na(df$Min)),
                                                      MeaNA = sum(is.na(df$Mean))))
head(temprecna)
```
Which results in the summary of NA values as a dataframe.

```
   Year MaxNA MinNA MeanNA
1  2000     0     0      0
2  2001     0     0      0
3  2002     0     1      1
4  2003     0     0      0
5  2004     0     0      0
6  2005     0     0      0
```

Growing length season (modified)
----------
The days between the first occurence of at least 6 consecutive days with mean temperature > 20 and the first occurance after July 1 of at least 6 consecutive days with mean tempareature < 20.

```
gslm.this <- function(xdf) {
  xlist <- sapply(xdf$Mean, function(x) x > 20)
  ylist <- sapply(xdf$Mean[182:length(xdf$Mean)], function(x) x < 20)
  xrle <- rle(xlist)
  yrle <- rle(ylist)
  xdoy <- which((xrle$lengths >= 6) & xrle$values)
  xsum <- cumsum(xrle$lengths)
  xdoyref <- xsum[xdoy[1] - 1] + 1
  ydoy <- which((yrle$lengths >= 6) & yrle$values)
  ysum <- cumsum(yrle$lengths)
  ydoyref <- ysum[ydoy[1] - 1] + 1 + 182
  return(data.frame(GSL = ydoyref))
}
gslm <- ddply(temprec, c("Year"), gslm.this)
```

Counting NAs and Ts in rainfall records
----------

For most analysis, the days with trace amount of rainfall is replaced with 0. Before replacing, it may be a good idea to count the number of NAs and Ts. Here's the code to do just that for each year again using ```ddply``` function from ```plyr``` package.

```
rainrec <- read.csv(paste0("x:/DHM_data/Rain/", c("Dharan_Bazar.csv")), stringsAsFactors = FALSE)
names(rainrec) <- c("Date", "Rainfall", "DOY")
rainrec$Year <- strftime(as.Date(rainrec$Date, "%Y-%m-%d"), format='%Y') #add year column
rainrecna <- ddply(rainrec, c("Year"), function(df) c(RainfallNA = sum(is.na(df$Rainfall)),
                                                      Tcount = sum(sapply(df$Rainfall,
													  function(x) {
													  df$Rainfall[is.na(df$Rainfall)] <- -5
													  x=="T"}))))
head(rainrecna)
```

Which results in the summary of NA count and T count values as a dataframe.

```
   Year RainfallNA Tcount
1  2000          0      6
2  2001          0      9
3  2002          0      5
4  2003          0     11
5  2004          0     10
6  2005          0      1
```

Converting data to RClimDex readable format
----------
The following code converts the rainfall data into RClimDex readable text format. The format for RClimDex is documented here (link).

```
rainrec.rclimdex <- cbind(rainrec.export$Year, rainrec.export$Month,
                          as.numeric(strftime(as.Date(rainrec.export$Date), format='%d')),
                          rainrec.export$Rainfall2)
#add NA values for temp cols
rainrec.rclimdex <- cbind(rainrec.rclimdex, rep(-99.9, length(rainrec.export$Year)),
                          rep(-99.9, length(rainrec.export$Year)))
#replace NAs with -99.9
rainrec.df <- as.data.frame(rainrec.rclimdex)
rainrec.df$V4[is.na(rainrec.df$V4)] <- -99.9
write.table(rainrec.df, file = paste0(as.character(stationmerged$name[this.station]),
                                ".txt"), sep="\t", col.names=FALSE,
            row.names=FALSE)
```

Creating a time series of rainfall records
----------
For seasonal and yearly statistics, the data can be conveted into a time series. Here is an example using the ```zoo``` package.

```
require(zoo)
#replace Ts with 0
rainrec$Rainfall[rainrec$Rainfall == "T"] <- 0
rainrec$Rainfall <- as.numeric(rainrec$Rainfall)
rain.zoo <- zoo(rainrec$Rainfall, as.Date(rainrec$Date)) #create zoo object
rain.monthly <- apply.monthly(rain.zoo, "sum")
rain.yearly <- apply.yearly(rain.zoo, "sum")
#plot monthly and annual total rainfall
par(mfrow=c(1,2))
plot(rain.monthly, main="Total monthly rainfall in mm")
plot(rain.yearly, main= "Total annual rainfall in mm")
par(mfrow=c(1,1))
```

Computing seasonal rainfall statistics
----------
The following code uses ```ddply``` to aggregate seasonal statistics. The year is divided into four seasons with Pre-monsoon for the months of March to May, Monsoon for the months of June to September, Post-monsoon for the months of October - November and Winter for the months of December to February. Although this is the general practice, there are alternative definition of seasons in Nepal (see [4] for example).

```
rainrec$Month <- as.numeric(strftime(as.Date(rainrec$Date), format='%m'))
rainrec$Season <- factor(rainrec$Season, levels=c(1:4),
                         labels=c("Pre-monsoon", "Monsoon",
                                  "Post-monsoon", "Winter"))
seasonal <- ddply(rainrec, c("Year", "Season"),
                  function(df) c(Total = sum(df$Rainfall, na.rm=TRUE)))
#the following takes mean annual rainfall from earlier calculation 
#   to calculate perecntage of seasonal means
meanseasonal <- ddply(seasonal, c("Season"),
                      function(df) c(SMean = mean(df$Total, na.rm=TRUE),
                                     SPercent = (mean(df$Total, na.rm=TRUE) /
                                                   mean(rain.yearly, na.rm=TRUE)) * 100))
```

The ```meanseasonal``` dataframe summarises the mean toal seasonal rainfall calculated from all the records.

```
        Season     SMean  SPercent
1  Pre-monsoon  304.6667 13.952974
2      Monsoon 1688.6583 77.336341
3 Post-monsoon  149.9250  6.866191
4       Winter   40.2750  1.844495
```

Computing monthly total and mean
----------
```
monthly <- ddply(rainrec, c("Year", "Month"),
                  function(df) c(Total = sum(as.numeric(df$Rainfall), na.rm=TRUE),
                                 Mean = mean(as.numeric(df$Rainfall), na.rm=TRUE)))
```
This gives the dataframe ```monthly``` in the following format.

```
  Year Month Total       Mean
1 2000     1  21.0  0.6774194
2 2000     2  17.7  0.6103448
3 2000     3   0.0  0.0000000
4 2000     4 122.5  4.0833333
5 2000     5 349.8 11.2838710
6 2000     6 740.6 24.6866667
```

Computing monsoon onset day for each year
----------
Again with the help of ```ddply``` the monsoon onset date for each year is computed in this example. Monsoon onset depends on various factors besides rainfall amount [1]. Since we are going to compute monsoon onset date only from rainfall data, the definition of monsoon onset is taken as any rainy day after June 1 with total rainfall of three consecutive days exceeding 30mm. See [2] & [3] for detailed explanation. A day is counted as a rainy day if there is a rainfall of at least 0.85 mm. There are other similar criteria for calculating monsoon onset which can be done with little modification to the following code.
```
rainrec.mon <- rainrec[rainrec$Season == "Monsoon",] #isolate only monsoon days
#replace NAs with 0
rainrec.mon$Rainfall[is.na(rainrec.mon$Rainfall)] <- 0
monsoonOnset <- function(xdf) {
  reclen <- length(xdf$Rainfall) -2
  for (i in 1:reclen) {
    if ((xdf$Rainfall[i] >= 0.85) &
          (sum(xdf$Rainfall[i],
               xdf$Rainfall[i+1],
               xdf$Rainfall[i+2], na.rm=TRUE) > 30))
      return(xdf$DOY[i])
  }
}
monsoon <- ddply(rainrec.mon, c("Year"), monsoonOnset)
```

This returns a dataframe with year and their corrosponding monsoon onset days in DOY. An example with first 6 rows is given below.

```
   Year  V1
1  2000 153
2  2001 153
3  2002 153
4  2003 156
5  2004 160
6  2005 160
```

Computing dry spell days
----------
For this analysis, a dry spell is defined as at least 7 consecutive days of no rainfall after commencement of monsoon in the next 30 days [2, pp 4]. A no rainfall day is defined as a day with less than 0.85 mm of rain. The following function first calculates monsoon onset day and checks the next 30 days for occurance of dry spells using ```rle``` function. The function outputs a dataframe which is parsed by ```ddply``` into columns.

```
is.rain <- function(x) x >= 0.85 #only days with >= 0.85mm of rain
drySpell2 <- function(xdf) {
  #first get monsoon onset
  monindex <- 0
  reclen <- length(xdf$Rainfall) - 2
  for (i in 1:reclen) {
    if ((xdf$Rainfall[i] >= 0.85) &
          (sum(xdf$Rainfall[i],
               xdf$Rainfall[i+1],
               xdf$Rainfall[i+2], na.rm=TRUE) > 30))
      {monindex <- i; break}
  }
  monindex <- monindex + 1 #we only need to check from the day after monsoon onset
  reclen2 <- length(xdf$Rainfall)
  rainlist.F.count <- 0; rainlist.F.len <- 0
  rle.rain <- rle(sapply(xdf$Rainfall[monindex:(monindex+30)], is.rain)) #check next 30 days
  rainlist.F <- rle.rain$lengths[!rle.rain$values]
  #total number of dry spells
  rainlist.F.count <- sum(sapply(rainlist.F, function(x) x >= 7))
  #total days of dry spell
  rainlist.F.len <- 0
  if (rainlist.F.count >= 1) 
     { rainlist.F.len <- sum(sapply(rainlist.F[rainlist.F >= 7], sum)) }
  return(data.frame(drycount = rainlist.F.count, drylength = rainlist.F.len))
}
drydate <- ddply(rainrec.mon, c("Year"), drySpell2)
```

The output dataframe ```drydate``` lists the number of dry days and the total length of dry spell in days.

```
   Year 	drycount drylength
1  2000           0         0
2  2001           0         0
3  2002           0         0
4  2003           0         0
5  2004           1         7
6  2005           0         0
7  2006           0         0
```

Alternative code for dry spell days withtout for loop with ```rollapply``` function from ```zoo``` package is given below.

```
is.rain <- function(x) x >= 0.85 #only days with >= 0.85mm of rain
drySpell3 <- function(xdf) {
  #first get monsoon onset
  monindex <- 0
  #reclen <- length(xdf$Rainfall) - 2
  ydf <- xdf
  ydf$Rainfall2[ydf$Rainfall2<0.85] <- NA
  ## *** corrected 2014-05-26
  monindex <- min(which(sapply(rollapply(ydf$Rainfall, 3, sum, partial=3), function(x) x>= 30)))
  if (monindex == Inf) {monindex = NA;
                        return(data.frame(monsoon1 = NA,
                                          monsoon1DOY = NA,
                                          drycount = NA, 
                                          drylength = NA))}
  rainlist.F.count <- 0
  rainlist.F.len <- 0
  rainlist <- sapply(xdf$Rainfall[(monindex + 1) :(monindex+30)], is.rain)
  rle.rain <- rle(rainlist)
  rainlist.F <- rle.rain$lengths[!rle.rain$values]
  if (length(rainlist.F) == 0) {return(data.frame(monsoon1 = xdf$Date[monindex],
                                          monsoon1DOY = xdf$DOY[monindex],
                                          drycount = 0, 
                                          drylength = 0))}
  rainlist.F.count <- sum(sapply(rainlist.F, function(x) x >= 7), na.rm=TRUE)
  if (rainlist.F.count >= 1) 
  { rainlist.F.len <- sum(sapply(rainlist.F[rainlist.F >= 7], sum)) }
  return(data.frame(monsoon1 = xdf$Date[monindex],
                    monsoon1DOY = xdf$DOY[monindex],
                    drycount = rainlist.F.count, 
                    drylength = rainlist.F.len))
}

drydate3 <- ddply(rainrec.mon, c("Year"), drySpell3)
```

The output dataframe ```drydate3``` lists the monsoon onset date, monsoon onset DOY, number of dry days and the total length of dry spell in days.

```
   Year   monsoon1 monsoon1DOY drycount drylength
1  2000 2000-06-02         155        0         0
2  2001 2001-06-03         154        0         0
3  2002 2002-06-03         155        0         0
4  2003 2003-06-06         157        0         0
5  2004 2004-06-09         161        1         7
6  2005 2005-06-10         163        0         0
7  2006 2006-06-11         162        0         0
```

Replacing NA rainfall with proxy values
----------
As the spatial interpolation of precipitation data is not recommended for Nepali terrain [5], the missing rainfall is replaced by a proxy based on the value of the day in the previous year and the value for the day in the next year. The following code does not take into account of leap years. In the case when the first year's data is missing, only the value from the next year is used.


```
rainproxy <- function(xlist) {
  nax <- which(is.na(xlist))
  naxi <- nax + 365 #next year; does not take into a/c of leap year
  naxo <- nax - 365 #previous year
  nay <- which(naxo <= 0)
  naxo[nay] <- naxi[nay] #if missing year is 1st, next year's data is repeated
  xlist[nax] <- rowMeans(cbind(xlist[naxi], xlist[naxo]))
  return(xlist)
}

rainrec <- transform(rainrec, Rainfall2 = rainproxy(Rainfall))
```

Computing trend statistics
----------
The following code uses ```Kendall``` package for Kendall's test for trend the Kendall's tau value and p value are reported in a table.

```
trend.grain <- ddply(grain, c("Station"), function(xdf) {
  x <- MannKendall(xdf$V1)
  return(data.frame(grain_tau = x$tau[1],
                    grain_p_value = x$sl[1]))
})
```

Computing precipitation anomalies
----------
For calculation of annual precipation anomalies, mean annual rainfall for each station is first computed. The anomaly for each year is given by substracting the value for that year with the mean for that station.

```
annualmean <- ddply(annual, c("Station"),
                    function(dfx) c(AnnMean = mean(as.numeric(dfx$Total), na.rm=TRUE)))
annualmerged <- merge(annual, annualmean, by="Station")
annualmerged$Anomaly <- annualmerged$Total - annualmerged$AnnMean
```

This outputs the dataframe in the following format

```
  Station Year  Total     Mean  AnnMean    Anomaly
1  Anarma 2000 3038.1 8.300820 2704.283  333.81667
2  Anarma 2001 3115.7 8.536164 2704.283  411.41667
3  Anarma 2002 2603.1 7.131781 2704.283 -101.18333
4  Anarma 2003 2789.7 7.643014 2704.283   85.41667
5  Anarma 2004 2636.8 7.204372 2704.283  -67.48333
6  Anarma 2005 1755.3 4.809041 2704.283 -948.98333
```

Hydrological data
----------
For daily discharge data, each text file contains daily records in cubimc m per second for the year in columnar format as shown below. The first nine lines of the file consists of the information on the station and title information. The final three lines of the file also contains the monthly summary of the data.

```
Station number: 120
Location:       Nayal Badi                                                        Latitude: 29 40 20
River:          Chamelia                                                         Longitude: 80 33 30

Year:           2000

                                    Mean daily discharge in m3/s
                                    ============================

Day     Jan.   Feb.   Mar.   Apr.   May    Jun.   Jul.   Aug.   Sep.   Oct.   Nov.   Dec.   Year
 01     25.6   21.6   21.5   29.3   34.7   40.3   99.0    283    230   75.1   39.6   27.5
 02     25.9   24.1   20.8   29.8   32.4   38.7   98.2    259    200   72.7   39.4   27.3
 03     25.6   22.7   21.0   79.1   34.0   38.9   98.0    187    202   69.0   39.1   27.3
 04     25.7   22.7   21.0   22.5   40.9   47.4   86.2    172    181   65.1   39.1   24.9
 ... and so on ...
Min     21.8   20.8   20.5   25.6   32.4   38.7   85.5    130   76.7   40.1   28.4   21.8   20.5
Mean    23.7   22.0   22.0   30.8   43.9   94.3    175    199    135   53.6   33.4   24.2   71.4
Max     25.9   24.1   29.1   41.6   61.5    398    488    291    230   74.1   39.6   27.5    488
 ```

References
-----------

1. Devkota, LP 1984, 'Onset of summer monsoon in Nepal', The Himalayan Review, vol. 15, no. 1983-84, pp. 11-20. 

2. Karmacharya, J 2010, Exploring daily rainfall data to investigate evidence of climate change in Kathmandu Valley and its implication in rice farming in the area, Ministry of Agriculture, Kathmandu, Nepal.

3. Upadhyay, S 2010, 'Monsoon variability analysis in Nepal from 1979 to 2008', Department of Environmental Science and Engineering, Bachelor of Science (Honors) thesis, Kathmandu University.

4. Nayava, JL 1980, 'Rainfall in Nepal', Himalayan Review, vol. 12, pp. 1-18.

5. Hormann K 1994, Computer based climatological maps for high mountain areas. International Centre for Integrated Mountain Development, ICIMOD, Kathmandu, Nepal, MEM Ser, 12.

