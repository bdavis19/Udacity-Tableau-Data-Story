# Environment
library(tidyverse)
library(data.table)

# Read the data
airports <- fread("airports.csv", na.strings="NA")
carriers <- fread('carriers.csv', na.strings="NA")
flights <- fread('2008.csv', na.strings=c("NA", ""))

# Data inspection

# Peek
airports %>% head()
airports %>% sample()
carriers %>% head()
carriers %>% sample()
flights %>% head()
flights %>% sample()

# Structure
airports %>% str()
carriers %>% str()
flights %>% str()

# Values
unique(airports$airport)

# Fix times so leading 0's are present
unique(flights$DepTime)
flights$DepTime <- as.character(flights$DepTime)
flights$CRSDepTime <- as.character(flights$CRSDepTime)
flights$ArrTime <- as.character(flights$ArrTime)
flights$CRSArrTime <- as.character(flights$CRSArrTime)
flights$DepTimeCorrected <- ifelse(flights$DepTime=="NA", "NA",
                                   ifelse(nchar(flights$DepTime)==2, paste0("00", flights$DepTime),
                                          ifelse(nchar(flights$DepTime)==3, paste0("0",flights$DepTime),
                                                 ifelse(nchar(flights$DepTime)==1, paste0("000",flights$DepTime), flights$DepTime))))
flights$CRSDepTimeCorrected <- ifelse(flights$CRSDepTime=="NA", "NA",
                                   ifelse(nchar(flights$CRSDepTime)==2, paste0("00", flights$CRSDepTime),
                                          ifelse(nchar(flights$CRSDepTime)==3, paste0("0",flights$CRSDepTime),
                                                 ifelse(nchar(flights$CRSDepTime)==1, paste0("000",flights$CRSDepTime), flights$CRSDepTime))))
flights$ArrTimeCorrected <- ifelse(flights$ArrTime=="NA", "NA",
                                   ifelse(nchar(flights$ArrTime)==2, paste0("00", flights$ArrTime),
                                          ifelse(nchar(flights$ArrTime)==3, paste0("0",flights$ArrTime),
                                                 ifelse(nchar(flights$ArrTime)==1, paste0("000",flights$ArrTime), flights$ArrTime))))
flights$CRSArrTimeCorrected <- ifelse(flights$CRSArrTime=="NA", "NA",
                                   ifelse(nchar(flights$CRSArrTime)==2, paste0("00", flights$CRSArrTime),
                                          ifelse(nchar(flights$CRSArrTime)==3, paste0("0",flights$CRSArrTime),
                                                 ifelse(nchar(flights$CRSArrTime)==1, paste0("000",flights$CRSArrTime), flights$CRSArrTime))))

# Drop the old time columns
flights <- flights %>% select(-DepTime, -ArrTime, -CRSDepTime, -CRSArrTime)

# Join the carriers
flights <- merge(flights, carriers, by.x="UniqueCarrier", by.y="Code", all.x=TRUE)

# Join origin airports and change the new column names
flights <- merge(flights, airports, by.x="Origin", by.y="iata", all.x=TRUE)
setnames(flights, old=c("airport", "city", "state", "country", "lat", "long"), 
         new=c("OriginAirport", "OriginCity", "OriginState", "OriginCountry", "OriginLat", "OriginLong"))

# Join the destination airports and change the new column names
flights <- merge(flights, airports, by.x="Dest", by.y="iata", all.x=TRUE)
setnames(flights, old=c("airport", "city", "state", "country", "lat", "long"), 
         new=c("DestAirport", "DestCity", "DestState", "DestCountry", "DestLat", "DestLong"))

# Drop duplicate airport data
flights <- flights %>% select(-Origin, -Dest)

# Write new file
write.csv(flights, "data/flight_data.csv", row.names = FALSE)
