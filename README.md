Reading and tabulting Nepali climatic data in R
===============

This is a collection of R code to process raw (ASCII) format data on climactic variables obtained from Department of Hydrology and Meteorology (DHM), Babarmahal, Kathmandu, Nepal. The read data can be stored as csv or xlsx files for storing and further processing.

No sample data is presented here as the data can only be obtained from DHM for upon written request and payment. The format for rainfall and temperature data is presented in the sections below.

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

Temperature data
----------
The first line of each of the files for temperature data consists of the corresponding 4 digit year number and name of the station. The second line consists of column headings for maximum and minimum temperatures. From the third line onwards, each text file in the dataset consists of one year of temperature records with each line represented by DOY, maximum temperature and minimum temperature for the corresponding DOY in Celsius (°C). The DOY ranges from 1 to 365 during non-leap years and from 1 to 366 in leap years.

Format for temperature data:

```
1985          Temperature for <STATION NAME>                
        Tmax  Tmin
     1  33.0   4.0 
     2  30.5  10.1 
     3  26.0  10.8 
     4  27.0   20.0 
     5  28.0  12.5 
     6  29.0   5.0 
     7  22.5   5.5 
	 and so on
```

Station name and code
----------
List of meteorological stations in Nepal can be found at http://www.dhm.gov.np/meteorological-station

See https://github.com/asheshwor/R-maps/blob/master/01_simple-map.R for R code to plot meterological stations of Nepal.