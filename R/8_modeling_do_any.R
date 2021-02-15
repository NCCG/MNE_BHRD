###########################################
# Teste modleR                            #
# Step 5: Do Any                          #
# Especies arvores BHRD                   #
# Kele Rocha Firmiano & Danielle O Moreira#
###########################################

# Packages
#para trabalhar com dados espaciais
library(sp)

#para trabalhar com raster
library(raster)

# para trabalhar com o ModleR
library(modleR)


#Objeto criado após a limpeza de dados
sdmdata_1sp
#para ver o numero de registros depois da limpeza
dim(sdmdata_1sp)
head(sdmdata_1sp)

#Plotar os pontos das ocorrencias no mapa
library(rgdal) #para trabalhar com shapefile
shp<- readOGR("./data/shape/amesul.shp") #loading shapefile

plot(shp)
points(sdmdata_1sp$lon, sdmdata_1sp$lat, col = "red", cex = .1)



# Loading pca environment data (pca axes, see script "1_variaveis ambientais")
#clim <- list.files(path="./data/raster/wc5_amsul/pca", ".*.tif$",
#                   full.names = TRUE)

#clim.stack <- stack(clim) # stack raster
#plot(clim.stack)  # stack raster


######################### MODELAGEM DO_ANY ####################################

# carregar dados do sdmdata (criado pelo setup_sdmdata no passo anterior), caso precise indicar o caminho
#sdmdata_Ss<-read.csv("./modelos/Senna spectabilis
#                     /present/data_setup/sdmdata.csv", header = T, dec=".")

#para ver o arquivo sdmdata_SL
#sdmdata_SL

####Fitting a model per partition: do_any()

args(do_any)
?do_any

modelos <- "./modelos" # file to save models

do_any(species_name = species[48],
       #sdmdata = sdmdata_1sp,
       #occurrences = occs,
       algo = "maxent",
       #seed = 512,
       predictors = clim.stack,
       #plot_sdmdata = T,
       png_partitions = T,
       models_dir = modelos,
       #write_png = T,
       write_bin_cut = F,
       equalize = T)

#You can explore the list of files created at this phase, for example

partitions.folder <-list.files(modelos, recursive = T,
             pattern = "partitions",
             include.dirs = T, full.names = T)
partitions.folder
list.files(partitions.folder, recursive = T)

####################### Joining partitions: final_model() #####################

args(final_model)
?final_model

final_model(species_name = species[48],
            algorithms = NULL, #if null it will take all the in-disk algorithms
            models_dir = modelos,
            #select_partitions = TRUE,
            select_par = "TSS",
            select_par_val = 0,
            which_models = c("raw_mean", "bin_consensus"),
            consensus_level = 0.5,
            uncertainty = T,
            overwrite = T)

#We can explore these models from the files:

final.folder <- list.files(modelos,
                           recursive = T,
                           pattern = "final_models",
                           include.dirs = T,
                           full.names = T)
final.folder
final_mods <- list.files(final.folder, full.names = T,
                         pattern = "raw_mean.+tif$", recursive = T)
final_mods

