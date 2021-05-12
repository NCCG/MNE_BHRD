
#######################################################
###         BIOCLIMATIC VARIABLES            ##########
#######################################################

getwd()

#Defining folder
#setwd("D:/ModleR/")

#Working with raster 
library(raster)

#Working with spatial data
library(sp)

#To cut shapefile
library(rgdal)


########################### DOWNLOAD WORLDCLIM ##################################
#To download worldClim data with 2.5 min (or ~4.5 km in the equator) of resolution (res = 2.5) with "raster" package
envi <- getData("worldclim", var = "bio", res = 2.5, path = './data/raster')

elev <- getData('worldclim', var='alt', res = 2.5, path = './data/raster')


#To download worldclim data with 30 seg (or ~1km in the equator) of resolution (res = 0.5), it should inform a latitude and longitude. Ex:
#envi <- getData("worldclim", var = "bio", res = 0.5, path = './data/raster', lon = -57, lat = -33)


############################  READ SEVERAL RASTER (STACK)  #################
#Only for "envi" object
raster_files <- list.files("./data/raster/wc2-5", full.names = T, '.bil$') ##use pattern = '.tif$' or something else if you have multiple files in this folder
head(raster_files)

envi <- stack(raster_files)
plot(envi)


#############################  CROP RASTER  ####################################
#To cut variables to the shapefile limites that we want. For this case, to the South America.
shp<- readOGR("./data/shape/amesul.shp") #loading shapefile
plot(shp)

envi.cut<-crop(envi, shp) #cut env by file
plot(envi.cut[[1:2]])

#To create a mask to cut exactly for the South America limits.
envi.shp <- mask(envi.cut, shp)
plot(envi.shp[[1:2]])

envi.shp

#Cut elevation raster
elev.cut<-crop(elev, shp) #cut elev by file
plot(elev.cut)

#Create a mask for elevation
elev.shp <- mask(elev.cut, shp)
plot(elev.shp)

elev.shp

#####################   SAVING THE NEW RASTERS AS tif FILES  ##################################

#Save only one raster
writeRaster(envi.shp[[2]],filename='./data/raster/wc5_amsul/bio2_amsul.tif', format="GTiff", overwrite=TRUE)

#Save all raster 
writeRaster(envi.shp, filename='./data/raster/wc2-5_amesul/amsul', format="GTiff", bylayer=TRUE, suffix="names")

#save elevation
writeRaster(elev.shp,filename='./data/raster/wc2-5_amesul/amsul_elev.tif', format="GTiff", overwrite=TRUE)

