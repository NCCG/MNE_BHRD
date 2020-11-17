########################################
####CRIAR STACK PARA RASTER#############
########################################

####Definir pasta
#setwd("C:/DaniTeste_tutorial")

####CARREGAR ARQUIVOS###########

#para trabalhar com dados espaciais
library(sp)

#para trabalhar com raster
library(raster)

#para fazer pca
library(RStoolbox)

##############################CRIAR RASTER STACK###########################
#generate a list of input rasters ("grids")
#pattern = "*.tif$" - filters for main raster files only and skips any associated files (e.g. world files)
clim <- list.files(path="./data/raster/wc5_amsul", ".*.tif$",
                   full.names = TRUE)

clim

#create a raster stack from the input raster files
clim.stack <- stack(clim)

#Plotar os rasters em um mapa
plot(clim.stack)

