################################################################################
###                                                                          ###
###             TO CROP SPECIES RECORDS POINTS TO A SHAPEFILE                ###
###                                                                          ###
###                                                                          ###
###                Created by Danielle de O. Moreira                         ###
###                         09 feb 2021                                      ###
###                                                                          ###
################################################################################

# To work with raster
library(raster)

# to work with spatial data
library(sp)

# to crop shp
library(rgdal)


## Read the species records points
### I use the comand fread() from data.table package because with read.delim or read.csv, R is not reading all rows

library(data.table)
#?fread
spp.table <- fread("./data/registros/endemicas/3_gbif_endemicas_occ2.csv")

###Checking the dimensions of the table
dim(spp.table)

### checking the first rows of the table
head(spp.table)

### Checking the column names of our dataframe.
names(spp.table)
View(spp.table)


## Converting data.frame into a SpatialPointsDataFrame
### note that the lon and lat columns are in columns 2 and 3
### Get long and lat from your data.frame. Make sure that the order is in lon/lat.
xy <- spp.table[,c(23,22)]


### convert
spp.shp <- SpatialPointsDataFrame(coords = xy, 
                                          data = spp.table,
                                          proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

#############################  CROP SPECIES RECORDS  ####################################
# To clip species records to a specific shapefile; in this case, the South America

## Read the shapefile
amesul<- readOGR("./data/shape/amesul.shp") #loading shapefile

## Check CRS information 
crs(amesul)
#proj4string(amesul)

## to assign the crs information  
## reproject shp to geographic system WGS 1984
crs(amesul) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
#proj4string(amesul) <- CRS("+proj=longlat +datum=WGS84") #to assign a CRS

proj4string(amesul)

## Plot shp
plot(amesul)
plot(spp.shp, add=TRUE)

# Now let's crop the points into the shapefile limits we want to. In this case, South America
spp.shp.ame<-crop(spp.shp, amesul) #cut by file

dim(spp.shp.ame)

##Plot spatial objects
plot(amesul)
plot(spp.shp.ame, add=TRUE)

# Save shp points of occurrences
#writeOGR(spp.shp.ame, "./data/shapes", "spp_gbif_amesul", driver="ESRI Shapefile")

#Save table of species for South America
write.csv(spp.shp.ame, "./data/registros/endemicas/4_gbif_endemicas_amesul2.csv")


