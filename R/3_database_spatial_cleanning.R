################################################################################
###                                                                          ###
###             TO CLEAN INCORRECT OCCURRENCE RECORDS FROM A TABLE           ###
###                                                                          ###
###                                                                          ###
###                Created by Danielle de O. Moreira                         ###
###                         11 feb 2021                                      ###
###                                                                          ###
################################################################################


library(data.table)
#?fread
spp.gbif.table <- fread("./data/registros/endemicas/4_gbif_endemicas_amesul2.csv")

###Checking the dimensions of the table
dim(spp.gbif.table)

### checking the first rows of the table
#head(spp.gbif.table)

### Checking the column names of our dataframe.
names(spp.gbif.table)
#View(spp.gbif.table)

########## Identify Coordinates Outside their Reported Country
#Removes or flags mismatches between geographic coordinates and additional country information
#(usually this information is reliably reported with specimens). Such a mismatch can occur for
#example, if latitude and longitude are switched.

library(CoordinateCleaner)
# Will take a while:
data_clean <- clean_coordinates(spp.gbif.table, 
                                lon = "decimalLongitude",
                                lat = "decimalLatitude",)

summary(data_clean)
View(data_clean)
dim(data_clean)


# to filter only occurrences with no spacial problems
library(tidyverse)
data_clean %>% 
count(.summary)

data_clean2 <- data_clean %>% 
  filter(.summary == "TRUE")
dim(data_clean2)

names(data_clean2)

data_clean3 <- data_clean2[,-1]

dim(data_clean3)

## to write the new table
write.csv(data_clean3, "./data/registros/endemicas/5_gbif_endemicas_amesul_clean2.csv")

################## LET'S PLOT THE CORRECT OCCURRENCES WITH NON CORRECTED OCCuRRENCES
## Read the shapefile from South America
library(rgdal)
library(raster)

amesul<- readOGR("./data/shape/amesul.shp") #loading shapefile

## Check CRS information 
#proj4string(amesul)

## to assign the crs information  
## reproject shp to geographic system WGS 1984
crs(amesul) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs "
proj4string(amesul)

## Plot - Will get a while because of the number of occurrences
library(ggplot2)


figura <- ggplot() + 
  geom_polygon(data=amesul, aes(x = long, y = lat, group = group), fill="grey40", 
colour = "grey90", alpha = 1) + 
  labs(x="", y="", title="Occurrence points of endemic plants in South America") + #labels
  theme(axis.ticks.y = element_blank(),axis.text.y = element_blank(), # get rid of x ticks/text
        axis.ticks.x = element_blank(),axis.text.x = element_blank(), # get rid of y ticks/text
        plot.title = element_text(lineheight=.8, face="bold", vjust=1)) + # make title bold and add space
  #geom_point(aes(x = decimalLongitude.1, y = decimalLatitude.1, color = .summary),
             #data = data_clean, alpha = 1, size = 3, color = "grey20") +# to get outline
  geom_point(data = data_clean, aes(x = decimalLongitude.1, y = decimalLatitude.1, 
                                    color = .summary), size = 2) +
  coord_equal(ratio=1) # square plot to avoid the distortion

#Save figure
png("./figs/pts_endemicas_AmericaSul.png", res = 300, width = 2400, height = 2400)
figura
#par(mfrow = c(2, 2),  mar = c(5, 5, 4, 1))
dev.off()



####################################### Extra: Data manipulation

### Leaving only a few columns
data.clean.sub <- subset(data_clean2, select=c("species","infraspecificEpithet","countryCode","stateProvince","locality","decimalLongitude","decimalLatitude"))

### Combining columns species and infraspecificEpithet
data.clean.sub$spp <- paste(data.clean.sub$species,data.clean.sub$infraspecificEpithet)

### now excluding columns species and infraspecificEpithet
names(data.clean.sub)
spp.points <- subset(data.clean.sub, select=c("spp", "countryCode", "stateProvince", "locality", "decimalLongitude","decimalLatitude"))

dim(data.clean.sub)

### Rename column where names is "decimalLongitude" and "decimalLatitude"
names(spp.points)[names(spp.points) == "decimalLongitude"] <- "lon"
names(spp.points)[names(spp.points) == "decimalLatitude"] <- "lat"
head(spp.points)
colnames(spp.points)

write.csv(spp.points,file="./data/registros/endemic_pts_for_model.csv")
