Climate Nepal
---------
This is a collection of R code to process raw (ASCII) format data on climactic variables obtained from Department of Hydrology and Meteorology, Babarmahal, Nepal.

Rainfall data
----------
For rainfall data, each file in the dataset consists of one year of rainfall records with each line represented by day of year (DOY) and rainfall for the corresponding DOY in millimeters (mm). The DOY ranges from 1 to 365 during non-leap years and from 1 to 366 in leap years. Missing data is denoted by string 'DNA' and 'trace amount of rainfall' is marked by string 'T'.

Temperature data
----------
The first line of each of the files for temperature data consists of the corresponding 4 digit year number and name of the station. The second line consists of column headings for maximum and minimum temperatures. From the third line onwards, each text file in the dataset consists of one year of temperature records with each line represented by DOY, maximum temperature and minimum temperature for the corresponding DOY in Celsius (°C). The DOY ranges from 1 to 365 during non-leap years and from 1 to 366 in leap years.

Station name and code
----------
List of meteorological stations in Nepal can be found at http://www.dhm.gov.np/meteorological-station