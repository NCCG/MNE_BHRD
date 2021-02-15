###########################################
# Teste modleR                            #
# Step 5: SetupSDMdata and Do_many        #
# Especies arvores BHRD                   #
# Kele Rocha Firmiano & Danielle O Moreira#
###########################################

# Directory
setwd("C:/DaniTeste_tutorial")

# Packages
#para trabalhar com dados espaciais
library(sp)

#para trabalhar com raster
library(raster)

#para fazer pca
library(RStoolbox)

# para trabalhar com o ModleR
library(modleR)

# Loading pca environment data (pca axes, see script "1_variaveis ambientais")
clim <- list.files(path="pca", ".*.tif$", 
                   full.names = TRUE)

clim.stack <- stack(clim) # stack raster
plot(clim.stack)  # stack raster

# Loading occurrence data
data<-read.csv("arvores_sulamerica.csv", header = T, sep=";", dec=".")

View(data)
head(data)

#mostrar a dimensao da tabela
dim(data)

#Mostrar as espécies únicas presentes na tabela
species <- sort(unique(data$especies))
species

#Plotar os pontos das ocorrencias no mapa
library(rgdal) #para trabalhar com shapefile
shp<- readOGR("C:/DaniTeste_tutorial/amesul.shp") #loading shapefile
data
plot(shp)
points(data$lon, data$lat, col = "red", cex = .1)

#selecionar somente as especies que queremos da planilha geral
library(dplyr)
#para ver o número de registros para cada espécie da tabela
table(data$especies)%>%sort()
#para selecionar a espécie da lista:
species[333]

#para filtrar os dados da primeira especie da lista. Usamos no filter
#na tabela "data", onde as especies vem da coluna especies
occs <- filter(data, especies == species[333]) %>% dplyr::select(lon, lat)

#para ver o numero de registros da spp escolhida
dim(occs)

######################## LIMPEZA DOS DADOS ####################################

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
                             geo_filt_dist = 10,
                             select_variables = F)
#percent = 0.5,
#cutoff = 0.7)

######################### MODELAGEM DO MANY ####################################

# carregar dados do sdmdata (criado pelo setup_sdmdata), caso precise indicar
#o caminho
#sdmdata_SL<-read.csv("C:/DaniTeste_tutorial/modelos/Sparattosperma leucanthum,
                    # /present/partitions/sdmdata.txt", header = T, dec=".")

#para ver o arquivo sdmdata_SL
sdmdata_SL

####Fitting a model per partition: do_many()
args(do_many)

do_many(species_name = species[333],
        sdmdata = sdmdata_1sp,
        occurrences = occs,
        predictors = clim.stack,
        plot_sdmdata = T,
        models_dir = modelos,
        write_png = T,
        write_bin_cut = F,
        bioclim = T,
        domain = T, 
        glm = T,
        svmk = T,
        svme = T, 
        maxent = T,
        maxnet = T,
        rf = T,
        mahal = F, 
        brt = T, 
        equalize = T)

#You can explore the list of files created at this phase, for example

partitions.folder <-list.files(modelos, recursive = T,
                               pattern = "partitions",
                               include.dirs = T, full.names = T)
partitions.folder
list.files(partitions.folder, recursive = T)

####################### Joining partitions: final_model() #####################

args(final_model)

final_model(species_name = species[333],
            algorithms = NULL, #if null it will take all the in-disk algorithms 
            models_dir = modelos,
            select_partitions = TRUE,
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

#para plotar os modelos em um mapa
library(raster)
final_models <- stack(final_mods)

#Não deu certo o argumento abaixo. Parece q serve para renomear os nomes para
#plotar os mapas em uma figura
library(stringr)
names(final_models) <- str_split(names(final_models), "_", simplify = T) %>% 
  data.frame() %>% dplyr::select(7) %>% dplyr::pull()

plot(final_models)

############################# ENSEMBLE ######################################
args(ensemble_model)

#Para criar o concenso dos modelos finais de vários algoritmos
ens <- ensemble_model(species[333],
                      occurrences = occs,
                      which_models = "raw_mean",
                      models_dir = modelos)

#At any point we can explore the outputs in the folders:

ensemble_files <-  list.files(paste0(modelos,"/", species[333],"/present/ensemble"),
                              recursive = T,
                              pattern = "raw_mean.+tif$",
                              full.names = T)

ensemble_files

#Para criar um mapa dos ensembles
ens_mod <- raster::stack(ensemble_files)
names(ens_mod) <- c("mean", "median", "range", "st.dev")
raster::plot(ens_mod)
