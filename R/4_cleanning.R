###########################################
# Teste modleR                            #
# Step 4: Limpeza                         #
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

# Loading pca environment data (pca axes, see script "1_variaveis ambientais")
clim <- list.files(path="./data/raster/wc5_amsul/pca", ".*.tif$",
                   full.names = TRUE)

clim.stack <- stack(clim) # stack raster
plot(clim.stack)  # stack raster

# Loading occurrence data
data<-read.csv("./data/registros/occ_56spp.csv", header = T, sep=";", dec=".")

View(data)
head(data)

# get column names
colnames(data)
# Rename column where names is "decimalLongitude" and "decimalLatitude"
names(data)[names(data) == "decimalLongitude"] <- "lon"
names(data)[names(data) == "decimalLatitude"] <- "lat"
head(data)
colnames(data)

#mostrar a dimensao da tabela
dim(data)

#Mostrar as esp?cies ?nicas presentes na tabela
species <- sort(unique(data$species))
species

#Plotar os pontos das ocorrencias no mapa
library(rgdal) #para trabalhar com shapefile
shp<- readOGR("./data/shape/amesul.shp") #loading shapefile

plot(shp)
points(data$lon, data$lat, col = "red", cex = .1)

#selecionar somente as especies que queremos da planilha geral
library(dplyr)
#para ver o n?mero de registros para cada esp?cie da tabela
table(data$species)%>%sort()
#para selecionar a esp?cie da lista:
species[48]

#para filtrar os dados da primeira especie da lista. Usamos no filter
#na tabela "data", onde as especies vem da coluna especies
occs <- filter(data, species == species[48]) %>% dplyr::select(lon, lat)

head(occs)

#para ver o numero de registros da spp escolhida
dim(occs)

######################## LIMPEZA DOS DADOS ####################################

modelos <- "./modelos" # file to save models

args(setup_sdmdata)

sdmdata_1sp <- setup_sdmdata(species_name = species[48],
                             occurrences = occs,
                             predictors = clim.stack,
                             models_dir = modelos,
                             partition_type = "crossvalidation",
                             cv_partitions = 5,
                             cv_n = 1,
                             seed = 512,
                             buffer_type = "mean",
                             png_sdmdata = T,
                             #plot_sdmdata = T,
                             n_back = 500,
                             clean_dupl = T,
                             clean_uni = F,
                             clean_nas = T,
                             geo_filt = F,
                             geo_filt_dist = 10,
                             select_variables = F,
                             sample_proportion = 0.5,
                             cutoff = 0.7,
                             #percent = 0.5,
                             #cutoff = 0.7
)

sdmdata_1sp
#para ver o numero de registros depois da limpeza
dim(sdmdata_1sp)
head(sdmdata_1sp)
