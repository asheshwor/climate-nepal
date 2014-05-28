#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*     Load packages
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#require(xlsx) #only if excel file is to be read
require(plyr)
#require(lattice)
#require(xts)
require(zoo)
#require(TTR)
#require(data.table)
require(ggplot2)
#require(Kendall)
#require(reshape2)
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*     Read monsoon data created from Rainfall_combined9.R
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##rm(list=ls())
rainrec.mon <- read.csv("C:/metro_data/rainrec.mon.csv")
rainrec.mon$Date <- as.Date(rainrec.mon$Date)
rainrec.mon$Year <- as.factor(rainrec.mon$Year)
head(rainrec.mon)
str(rainrec.mon)
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*     Read monsoon data created from Rainfall_combined9.R
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##  Debug data
#xdf <- rainrec.mon[1:100,]
#for (i in 2000:2012) {
 # xdf <- rainrec.mon[rainrec.mon$Station == "Gaida_Kankai" & rainrec.mon$Year == as.character(i),]
#  print(i)
#  countdry(xdf)
#}
#xdf <- rainrec.mon[rainrec.mon$Station == "Anarmani_Birta" & rainrec.mon$Year == "2009",]
#countdry(xdf)
is.rain <- function(x) x >= 0.85 #minimum rainfall amount to be considered as a rainy day
countdry <- function(xdf) {
  ##first get monsoon onset
  monindex <- NA
  xdf$Rainfall3 <- xdf$Rainfall2
  xdf[which(!is.rain(xdf$Rainfall2)), c("Rainfall3")] <- NA #replace records not matching min rain criteria w/ NA
  monindex <- min(which(sapply(rollapply(xdf$Rainfall3, 3, sum, partial=3), function(x) x>= 30)))
  monindex2 <- min(which(sapply(rollapply(xdf$Rainfall3, 2, sum, partial=2), function(x) x>= 25)))
  if (monindex == Inf) {return(data.frame(monsoon1 = NA, monsoon1DOY = NA,
                                          monsoon2 = NA, monsoon2DOY = NA,
                                          drycount = NA, drylength = NA,
                                          drydate = Inf, dryfirst = 0,
                                          dryindex = 0)) }
  rainlist.F.count <- 0
  rainlist.F.len <- 0
  #Get the dry spell date
  start <- monindex + 1 #first date to check
  end <- monindex + 120-2 #last date to check
  #debug rainlist <- rainrec.mon$Rainfall[1:100]
  xlist <- sapply(xdf$Rainfall2[start:end], is.rain)
  xlist <- xlist[!is.na(xlist)]
  #debug xlist <- sapply(rainlist, is.rain)
  rle.rain <- rle(xlist)
  rainlist.F <- rle.rain$lengths[!rle.rain$values]
  if (length(rainlist.F) == 0) {return(data.frame(monsoon1 = xdf$Date[monindex],
                                                  monsoon1DOY = xdf$DOY[monindex],
                                                  monsoon2 = xdf$Date[monindex2],
                                                  monsoon2DOY = xdf$DOY[monindex2],
                                                  drycount = 0, 
                                                  drylength = 0,
                                                  drydate = Inf,
                                                  dryfirst = 0,
                                                  dryindex = 0))
  }
  #debug
  ##first dry spell
  #make a dataframe with the first locaion of dry spell
  #total number of dry spells
  rainlist.F.count <- sum(sapply(rainlist.F, function(x) x >= 7), na.rm=TRUE)
  dryindex <- NA 
  drydate <- NA
  dryvalue <- NA
  dryindex.list <- NULL
  dryvalue.list <- NULL
  start.index <- 1
  for (i in 1:rainlist.F.count) { #repeat for each dry spell recorded
    #specify start index to check
    
    for (j in start.index:length(rle.rain$values)) {
      if (rle.rain$lengths[j] >= 7 & !rle.rain$values[j]) { dryindex <- sum(rle.rain$lengths[1:(j-1)])
                                                            dryvalue <- rle.rain$lengths[j]
                                                            start.index <- j+1
                                                            break
      }
    }
    #print(start.index)
    #make dataframe or append to dataframe
    dryindex.list <- c(dryindex.list, dryindex)
    dryvalue.list <- c(dryvalue.list, dryvalue)
    
  }
  if (is.na(dryindex)) {return(data.frame(monsoon1 = xdf$Date[monindex],
                                          monsoon1DOY = xdf$DOY[monindex],
                                          monsoon2 = xdf$Date[monindex2],
                                          monsoon2DOY = xdf$DOY[monindex2],
                                          drycount = 0, 
                                          drylength = 0,
                                          drydate = Inf,
                                          dryfirst = 0,
                                          dryindex = 0))
  }
  din <- monindex + dryindex.list
  #return(sapply(rainlist.F, as.character)) #remove after debug
  #return(data.frame(X = rainlist.F[1], Y = rainlist.F[2], Z = rainlist.F[3])) #remove after debug

  #return(rainlist.F.count) #remove after debug
  #total days of dry spell
  rainlist.F.len <- 0
  if (rainlist.F.count >= 1) 
  { rainlist.F.len <- sum(sapply(rainlist.F[rainlist.F >= 7], sum, na.rm=TRUE))  }
  #return(xdf$Date[dryloc]))
  #output <- list(rainlist.F.count, rainlist.F.length)
  return(data.frame(monsoon1 = xdf$Date[monindex],
                    monsoon1DOY = xdf$DOY[monindex],
                    monsoon2 = xdf$Date[monindex2],
                    monsoon2DOY = xdf$DOY[monindex2],
                    drycount = rainlist.F.count, 
                    drylength = rainlist.F.len,
                    drydate = xdf$Date[din],
                    dryfirst = dryvalue.list,
                    dryindex = 1:rainlist.F.count))
}
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*     Plot
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
drydateall <- ddply(rainrec.mon, c("Station","Year"), countdry)
#compute successfull plantation date
drydateall$drydate <- as.Date(drydateall$drydate)
drydateall$success <- FALSE
drydateall$success[drydateall$drycount == 0 ] <- TRUE
drydateall$plant <- drydateall$drydate - drydateall$monsoon1
#drydateall$success[(as.numeric(drydateall$drydate)*drydateall$drycount -
#                      as.numeric(drydateall$monsoon1)*drydateall$drycount) < 30] <- TRUE
drydateall$success[(drydateall$drydate - drydateall$monsoon1) == Inf |
                     (drydateall$drydate - drydateall$monsoon1) > 30] <- TRUE
success <- drydateall[drydateall$success & drydateall$dryindex < 2,]
head(drydateall)
station.list <- levels(rainrec.mon$Station)
#panel title colors
panel.col <- c("azure2", "mistyrose1")
for (i in 1:length(station.list)) {
  stationmon <- station.list[i]
  #stationmon <- station.list[3]
  p.dry <- ggplot() + geom_rect(data = success[success$Station == stationmon,],
              aes(xmin = monsoon1, xmax = monsoon1+30.5,
                  ymin = 0, ymax = Inf), alpha = 0.3, fill="green") +
    geom_rect(data = drydateall[drydateall$Station == stationmon,],
              aes(xmin = drydate, xmax = drydate+dryfirst+0.5,
                  ymin = 0, ymax = Inf), alpha = 0.2, fill="red3") +
    geom_vline(aes(xintercept=as.numeric(monsoon1)),
               data=drydateall[drydateall$Station == stationmon,],
               color="darkgreen") +
    geom_bar(data=rainrec.mon[rainrec.mon$Station == stationmon,],
             aes(Date, Rainfall2), stat="identity", fill="blue", width=1) +
    facet_wrap(~Year, ncol=8, scales="free_x") + theme_bw() +
    theme(legend.position="none") + theme(strip.background = element_rect(fill="azure2"))
  p.dry <- p.dry + 
    geom_text(aes(monsoon1-5, 160, label=strftime(monsoon1, format='%d-%b')),
              angle=90, color="darkgreen", size=4,
              data=drydateall[drydateall$Station == stationmon,]) +
    geom_text(aes(drydate+dryfirst/2, 160,
                  label=paste(as.character(dryfirst), "days")),
              angle=90, color="red3", size=4,
              data=drydateall[drydateall$Station == stationmon & drydateall$drycount > 0,]) +
    ggtitle(paste("Daily rainfall, monsoon onset day, dry-spell days and successful plantation days for", stationmon, "station")) + 
    ylab("Rainfall (mm)")
  #print(p.dry)
  #ggsave(p.dry, width=1.5*297, height=1.5*210, units="mm", filename = paste0("Plot", as.character(i), ".pdf"), dpi=75) #save plot as pdf file
  ggsave(p.dry, width=300, height=300, units="mm", filename = paste0("Plot", as.character(i), ".png"), dpi=75) #save plot as pdf file
}