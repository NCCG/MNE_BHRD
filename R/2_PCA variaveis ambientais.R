
###################################################################
################### PCA NO R #####################################
#################################################################

#carregar pacotes:
#para trabalhar com raster
library(raster)

#para trabalhar com dados espaciais
library(sp)

#para fazer pca
library(RStoolbox)

############################ PCA ###############################################

#para fazer PCA entre as variaveis ambientais do worldclim. O nSamples significa
#que usamos uma amostragem de 70% dos pixels das variaveis do arquivo envi.shp
envi.pca <- rasterPCA(clim.stack, nSamples = 0.7*ncell(clim.stack), nComp = nlayers(clim.stack), spca = FALSE, maskCheck = TRUE)

?rasterPCA

#Para informar a importancia dos componentes
summary(envi.pca$model)

#neste exemplo, os dois primeiros componentes explicam mais de 96% da variacao (proportion of variance)

#para informar a importancia dos componentes para cada variavel
loadings(envi.pca$model)

#Plotar o PCA
plot(envi.pca$map[[1:2]])

#Outra forma de plotar o mapa pca
ggRGB(envi.pca$map,1,2, stretch="lin", q=0)
if(require(gridExtra)){
  plots <- lapply(1:2, function(x) ggR(envi.pca$map, x, geom_raster = TRUE))
  grid.arrange(plots[[1]],plots[[2]], ncol=2)
}

#######################  SALVAR OS RASTERS APOS PCA  #############################

#criar uma pasta dentro do diretorio
dir.create("./data/raster/wc5_amsul/pca")

# create pca file to storage raster pca results
writeRaster(envi.pca$map[[1:2]],"./data/raster/wc5_amsul/pca/env.pca.tif", format="GTiff", overwrite=TRUE, bylayer=TRUE) # write pcaraster

#generate a list of input rasters ("grids")
#pattern = "*.tif$" - filters for main raster files only and skips any associated files (e.g. world files)
variaveis <- list.files(path="./data/raster/wc5_amsul/pca", ".*.tif$",
                        full.names = TRUE)

variaveis

#create a raster stack from the input raster files
variaveis.stack <- stack(variaveis)

#Plotar os rasters em um mapa
plot(variaveis.stack)

variaveis.stack[2]


