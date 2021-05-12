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
spp.gbif.table <- fread("./data/registros/spp_Gualaxo/3_gbif_Gualaxo_amesul.csv")

###Checking the dimensions of the table
dim(spp.gbif.table)
unique(spp.gbif.table$species)

### checking the first rows of the table
#head(spp.gbif.table)

### Checking the column names of our dataframe.
names(spp.gbif.table)
#View(spp.gbif.table)



########### Identify Coordinates Outside their Reported Country #####################

# CoordinateCleaner Package - Removes or flags mismatches between geographic coordinates and additional country information.
#(usually this information is reliably reported with specimens). Such a mismatch can occur for
#example, if latitude and longitude are switched.

library(CoordinateCleaner)
# Will take a while:
data_clean <- clean_coordinates(spp.gbif.table, 
                                lon = "decimalLongitude",
                                lat = "decimalLatitude",)

summary(data_clean)
names(data_clean)
dim(data_clean)


# to filter only occurrences with no spacial problems
library(tidyverse)
data_clean %>% 
count(.summary)

data_clean2 <- data_clean %>% 
  filter(.summary == "TRUE")
dim(data_clean2)

names(data_clean2)

# Remove some columns
data_clean3 <- data_clean2[-c(1,55:64)]

dim(data_clean3)
names(data_clean3)

unique(data_clean3$species)

## to write the new table
write.csv(data_clean3, "./data/registros/spp_Gualaxo/4_gbif_Gualaxo_amesul_clean.csv")

################## LET'S PLOT THE CORRECT OCCURRENCES WITH NON CORRECTED OCCuRRENCES
## Read the shapefile from South America
library(rgdal)
library(raster)

amesul<- readOGR("./data/shape/amesul.shp") #loading shapefile

## Check CRS information 
proj4string(amesul)

## to assign the crs information  
## reproject shp to geographic system WGS 1984
crs(amesul) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs "
proj4string(amesul)

## Plot - Will get a while because of the number of occurrences
library(ggplot2)


figura <- ggplot() + 
  geom_polygon(data=amesul, aes(x = long, y = lat, group = group), fill="grey40", 
colour = "grey90", alpha = 1) + 
  labs(x="", y="", title="Occurrence points of plants in South America") + #labels
  theme(axis.ticks.y = element_blank(),axis.text.y = element_blank(), # get rid of x ticks/text
        axis.ticks.x = element_blank(),axis.text.x = element_blank(), # get rid of y ticks/text
        plot.title = element_text(lineheight=.8, face="bold", vjust=1)) + # make title bold and add space
  #geom_point(aes(x = decimalLongitude.1, y = decimalLatitude.1, color = .summary),
             #data = data_clean, alpha = 1, size = 3, color = "grey20") +# to get outline
  geom_point(data = data_clean, aes(x = decimalLongitude.1, y = decimalLatitude.1, 
                                    color = .summary), size = 1) +
  coord_equal(ratio=1) # square plot to avoid the distortion

figura

#Save figure
png("./figs/pts_spp_Gualaxo_AmericaSul.png", res = 300, width = 2400, height = 2400)
figura
#par(mfrow = c(2, 2),  mar = c(5, 5, 4, 1))
dev.off()



####################################### Extra: Data manipulation: cleanning table 

### Leaving only a few columns
data.clean.sub <- subset(data_clean3, select=c("species","infraspecificEpithet","countryCode","stateProvince","locality","decimalLongitude","decimalLatitude"))

### Combining columns species and infraspecificEpithet
#data.clean.sub$spp <- paste(data.clean.sub$species,data.clean.sub$infraspecificEpithet)

### now excluding columns species and infraspecificEpithet
names(data.clean.sub)
spp.points <- subset(data.clean.sub, select=c("species", "countryCode", "stateProvince", "locality", "decimalLongitude","decimalLatitude"))

names(spp.points)

### Rename column where names is "decimalLongitude" and "decimalLatitude"
names(spp.points)[names(spp.points) == "decimalLongitude"] <- "lon"
names(spp.points)[names(spp.points) == "decimalLatitude"] <- "lat"
names(spp.points)
colnames(spp.points)

unique(spp.points$species)

#Save table
write.csv(spp.points,file="./data/registros/spp_Gualaxo/5_Gualaxo_occ.csv")

# Leave table with 3 columns: spp, lon and lat
spp.points2 <- subset(spp.points, select=c("species", "lon","lat"))

names(spp.points2)

write.csv(spp.points2,file="./data/registros/spp_Gualaxo/6_Gualaxo_ModleR.csv")

############################
### To select only species with more than 5 occurrences points
# Checking the frequency of occurrences for each species
a <- table(spp.points2$species)%>%sort()
View(a)

# we need to transform the frequency results in a data.frame
a <- as.data.frame(a)

b <- a %>% 
  filter(Freq < 6)

View(b) # species with equal or less than 5 occurrences points

#change name of colunm Var1 to spp
names(b)[names(b) == "Var1"] <- "spp"
names(b)
b <- subset(b, select=c("spp"))
names(b)

# remove species from "spp.points2" using a list o names in "b". Signal ! means "except"
library(dplyr)
final <- filter(spp.points2, !(spp %in% b$spp))
dim(final)
head(final)

# To check the final list of speciss with more than 5 records
c <- table(final$spp)%>%sort()
View(c)


#Save the occurrence table with species with more than 5 records
write.csv(final,file="./data/registros/spp_Gualaxo/6_Gualaxo_ModleR.csv")


############################# Save shp points #####################

data<-read.csv("./data/registros/spp_Gualaxo/6_Gualaxo_ModleR.csv", 
               header = T, sep=",", dec=".",
               encoding="utf-8")
dim(data)
names(data)

# How many unique species?
spp_unique <- table(data$species)%>%sort()
View(spp_unique)

# If some coordinates are not available for some occurrences. We need to remove NA
#library(tidyr)
#pts.amesul <- spp.points2 %>% 
#  drop_na()

#dim(pts.amesul)
#names(data)

## Converting data.frame into a SpatialPointsDataFrame for spatial operations
### note that the lon and lat columns are in columns 3 and 4
### Get long and lat from your data.frame. Make sure that the order is in lon/lat.
xy2 <- data[,c(3,4)]


### convert
spp.shp2 <- SpatialPointsDataFrame(coords = xy2, 
                                  data = data,
                                  proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Save shp points of occurrences
writeOGR(spp.shp2, "./data/shape", "spp_Gualaxo_gbif_amesul", driver="ESRI Shapefile", overwrite_layer = TRUE)

