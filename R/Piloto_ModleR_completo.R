#############################################################
###   PILOTO MODLER PARA MODELAGEM DE SPP DE ARVORES      ###
###   PARA A AMERICA DO SUL                               ###
#############################################################

#Definir pasta
#setwd("D:/01_INMA_BHRD/MNE_BHRD")

#carregar pacotes:
library(modleR)
library(rJava)
library(raster)

#para fazer pca
library(RStoolbox)

#para trabalhar com shapefile
library(rgdal)

#Download Worldclim data
#para baixar dados de resolução de 5 min (res = 5). Usado o pacote "raster"
#envi <- getData("worldclim", var = "bio", res = 5, path = './data/raster')

#para baixar dados de resolução de 30 seg (ou ~1km) (res = 0.5), deve-se informar uma latitude e longitude. Usado o pacote "raster"
#envi <- getData("worldclim", var = "bio", res = 0.5, path = './data/raster', lon = -57, lat = -33)

############################LER VARIOS ARQUIVOS RASTER (STACK)#################
raster_files <- list.files("./data/raster/wc2.1_30s_bio", full.names = T) ##use pattern = '.tif$' or something else if you have multiple files in this folder
head(raster_files)

envi <- stack(raster_files)
plot(envi)

############################# CORTAR RASTER (CROP)####################################
#para cortar as variáveis para o shapefile que queremos, neste caso, a América do Sul
shp<- readOGR("./data/shape/amesul.shp") #loading shapefile
envi.cut<-crop(envi, shp) #cut env by file
plot(envi.cut)

#Para criar uma mascara para cortar exatamente para os limites da A. do sul
envi.shp<- mask(envi.cut, shp)


############################PCA###############################################

#para fazer PCA entre as variaveis ambientais do worldclim. O nSamples significa
#que usamos uma amostragem de 70% dos pixels das variaveis do arquivo envi.shp
envi.pca<-rasterPCA(envi.cut, nSamples = 0.7*ncell(envi.shp), nComp = nlayers(envi.cut), spca = FALSE, maskCheck = TRUE)

#Para informar a importancia dos componentes
summary(envi.pca$model)

#neste exemplo, os dois primeiros componentes explicam mais de 99% da variacao (proportion of variance)

#para informar a importancia dos componentes para cada variavel
loadings(envi.pca$model)

#Plotar o PCA
plot(envi.pca$map[[1:3]])

#######################SALVAR OS RASTERS APOS PCA#############################

#criar uma pasta dentro do diretorio
dir.create("pca")

# create pca file to storage raster pca results
writeRaster(envi.pca$map[[1:3]],"pca/env.pca.tif", format="GTiff", overwrite=TRUE, bylayer=TRUE) # write pcaraster

#generate a list of input rasters ("grids")
#pattern = "*.tif$" - filters for main raster files only and skips any associated files (e.g. world files)
variaveis <- list.files(path="pca", ".*.tif$",
                   full.names = TRUE)

variaveis

#create a raster stack from the input raster files
variaveis.stack <- stack(variaveis)

#Plotar os rasters em um mapa
plot(variaveis.stack)


###########################SELECAO ESPECIES###################################

#Abrir a planilha de especies e ocorrencia em csv
# Loading occurrence data
data<-read.csv("arvores_sulamerica.csv", header = T, sep=";", dec=".")

View(data)
head(data)

#mostrar a dimensão da tabela
dim(data)

#Mostrar as esp?cies ?nicas presentes na tabela
species <- sort(unique(data$especies))
species

#Plotar os pontos das ocorrencias no mapa
library(rgdal) #para trabalhar com shapefile
shp<- readOGR("C:/DaniTeste_tutorial/amesul.shp") #loading shapefile
data
plot(shp)
points(data$lon, data$lat, col = "red", cex = .1)

#para ver o n?mero de registros para cada esp?cie da tabela
table(data$especies) %>% sort()

#selecionar somente as especies que queremos da planilha geral
library(dplyr)
#para selecionar a esp?cie da lista:
species[333]

#para filtrar os dados da primeira especie da lista. Usamos no filter
#na tabela "data", onde as especies vem da coluna especies
occs <- filter(data, especies == species[333]) %>% dplyr::select(lon, lat)

#para ver o numero de registros da spp escolhida
dim(occs)

########################MODELAGEM####################################

modelos <- "./modelos" # file to save models

sdmdata_1sp <- setup_sdmdata(species_name = species[333],
                             occurrences = occs,
                             predictors = clim.stack,
                             models_dir = modelos,
                             partition_type = "crossvalidation",
                             cv_partitions = 5,
                             cv_n = 1,
                             seed = 512,
                             buffer_type = "mean",
                             plot_sdmdata = T,
                             n_back = 500,
                             clean_dupl = F,
                             clean_uni = F,
                             clean_nas = F,
                             geo_filt = F,
                             #geo_filt_dist = 10,
                             select_variables = F)
                             #percent = 0.5,
                             #cutoff = 0.7)
