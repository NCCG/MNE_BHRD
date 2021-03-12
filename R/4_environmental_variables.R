
#######################################################
###         BIOCLIMATIC VARIABLES            ##########
#######################################################

getwd()

#Definir pasta
#setwd("D:/ModleR/")

#para trabalhar com raster
library(raster)

#para trabalhar com dados espaciais
library(sp)

#para cortar shapefile
library(rgdal)


########################### DOWNLOAD WORLDCLIM ##################################
#para baixar dados de resolução de 5 min (res = 5). Usado o pacote "raster"
envi <- getData("worldclim", var = "bio", res = 5, path = './data/raster')

#para baixar dados de resolução de 30 seg (ou ~1km) (res = 0.5), deve-se informar uma latitude e longitude. Ex:
#envi <- getData("worldclim", var = "bio", res = 0.5, path = './data/raster', lon = -57, lat = -33)




############################  LER VARIOS ARQUIVOS RASTER (STACK)  #################
raster_files <- list.files("./data/raster/wc5", full.names = T, '.bil$') ##use pattern = '.tif$' or something else if you have multiple files in this folder
head(raster_files)

envi <- stack(raster_files)
plot(envi)



#############################  CORTAR RASTER (CROP)  ####################################
#para cortar as variáveis para o shapefile que queremos, neste caso, a América do Sul
shp<- readOGR("./data/shape/amesul.shp") #loading shapefile
plot(shp)

envi.cut<-crop(envi, shp) #cut env by file
plot(envi.cut)

#Para criar uma mascara para cortar exatamente para os limites da A. do sul
envi.shp<- mask(envi.cut, shp)
plot(envi.shp)

envi.shp




##################### Para salvar os novos rasters cortados ##################################

#salvar um raster de cada vez
writeRaster(envi.shp[[2]],filename='./data/raster/wc5_amsul/bio2_amsul.tif', format="GTiff", overwrite=TRUE)

#salvar todos de uma vez
writeRaster(envi.shp, filename='./data/raster/wc5_amsul/amsul', format="GTiff", bylayer=TRUE, suffix="names")

