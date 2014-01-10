Reading and tabulating Nepali climatic and hydrological records
===============

This is a collection of ```R``` code to process raw (ASCII) format data on climatic variables obtained from Department of Hydrology and Meteorology (DHM), Babarmahal, Kathmandu, Nepal. While the raw data can be opened in any text editor and copied to a spreadsheet, it can be quite a hassel when dealing with decades of data from multiple stations. I find it easy to read and combine the data in R which can be stored as csv or xlsx files for storing and further processing.

These are the code that I am using for my own research. I will continue to add the code for analysis as my research progresses.

No sample data is presented here as the data can only be obtained from DHM for upon written request and payment. The format for rainfall and temperature data is presented in the sections below. In both cases the yearly records are combined into one continious time-series object.

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

Format of converted temperature data in csv file:

```
Date		Max		Min		Mean
01-01-00	23		9		16
02-01-00	22		11.5	16.75
03-01-00	18		7.1		12.55
04-01-00	20.9	7.5		14.5
05-01-00	20		12.5	16.25
06-01-00	20.5	4		16.88
07-01-00	20		7		13.5
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
temprec <- read.csv("Dharan_Bazar_temp1.csv", stringsAsFactors = FALSE)
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

Counting NAs and Ts in rainfall records
----------

For most analysis, the days with trace amount of rainfall is replaced with 0. Before replacing, it may be a good idea to count the number of NAs and Ts. Here's the code to do just that for each year again using ```ddply``` function from ```plyr``` package.

```
rainrec <- read.csv(paste0("x:/DHM_data/Rain/", c("Dharan_Bazar.csv")), stringsAsFactors = FALSE)
names(rainrec) <- c("Date", "Rainfall", "DOY")
rainrec$Year <- strftime(as.Date(rainrec$Date, "%Y-%m-%d"), format='%Y') #add year column
rainrecna <- ddply(rainrec, c("Year"), function(df) c(RainfallNA = sum(is.na(df$Rainfall)),
                                                      Tcount = sum(sapply(df$Rainfall,
													  function(x) x=="T"))))
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
The following code uses ```ddply``` to aggregate seasonal statistics. 

```
rainrec$Month <- as.numeric(strftime(as.Date(rainrec$Date), format='%m'))
rainrec$Season <- factor(rainrec$Season, levels=c(1:4),
                         labels=c("Pre-monsoon", "Monsoon",
                                  "Post-monsoon", "Winter"))
seasonal <- ddply(rainrec, c("Year", "Season"),
                  function(df) c(Total = sum(df$Rainfall, na.rm=TRUE)))
#the following takes man annual rainfall from earlier calculation 
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

Computing monsoon onset day for each year
----------
Again with the help of ```ddply``` the monsoon onset date for each year is computed in this example. The definition of monsoon onset is taken as any rainy day after June 1 with total rainfall of three consecutinve days exceeding 30mm. A day is counted as a rainy day if there is a rainfall of at least 0.85 mm. There are other similar criteria for calculating mosoon onset which can be done with little modification to the following code.

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
For this analysis, a dry spell is defined as at least 7 consecutive days of no rainfall after commencement of monsoon in the 30 days after monsoon commencement [1, pp 4]. A no rainfall day is defined as a day with less than 0.85 mm of rain. The following function first calculates monsoon onset day and checks the next 30 days for occurance of dry spells using ```rle``` function. The function outputs a dataframe which is parsed by ```ddply``` into columns.

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

Alternative code for dry spell days withtout for loop with ```rolapply``` function from ```zoo``` package is given below.

```
drySpell3 <- function(xdf) {
  #first get monsoon onset
  monindex <- min(which(sapply(rollapply(xdf$Rainfall, 3, sum, partial=1), function(x) x>= 30)))
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
  rainlist.F.count <- sum(sapply(rainlist.F, function(x) x >= 7))
  rainlist.F.len <- 0
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

References
-----------

1. Karmacharya, J 2010, Exploring daily rainfall data to investigate evidence of climate change in Kathmandu Valley and its implication in rice farming in the area, Ministry of Agriculture, Kathmandu, Nepal.


