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

# Loading selected environment data (pca axes, Pearson correlation, etc)
clim <- list.files(path="./data/raster/selection_vif", ".*.tif$",
                   full.names = TRUE)

clim.stack <- stack(clim) # stack raster
plot(clim.stack)  # stack raster

# Loading occurrence data
#library(data.table)
#data<-fread("./data/registros/endemicas/6_endemic_pts_for_model.csv")

data<-read.csv("./data/registros/endemicas/6_endemic_pts_for_model.csv", header = T, sep=",", dec=".", encoding="utf-8")

View(data)
head(data)

# get column names
#colnames(data)
names(data)

### Leaving only a few columns
table <- subset(data, select=c("spp","lon","lat"))
#change name of colunm spp to sp
names(table)[names(table) == "spp"] <- "sp"
str(table)


library(tidyverse)
# To rename spp names - changging space for "_"
table2 <- table %>% 
  mutate(sp = str_replace(sp, 
                              pattern = " ", 
                              replacement = "_"))

#Excluding spaces after words
table3 <- table2 %>% 
  mutate(sp = str_replace(sp, 
                           pattern = " ", 
                           replacement = ""))
head(table3)


#Count number of occurrences to each spp

#table %>% 
#  count(sp)

library(dplyr)
table(table$sp)%>%sort()

#to make a list of species names
species <- unique(table3$sp)
species

# Plot in a map the occurrences
library(rgdal) #for shapefile
shp<- readOGR("./data/shape/amesul.shp") #loading shapefile

plot(shp)
points(table3$lon, table3$lat, col = "red", cex = .1)

######################## LIMPEZA DOS DADOS ####################################

args(setup_sdmdata)
?setup_sdmdata

for (i in 1:length(table3)) {
  sp <- species[i]
  occs <- table3[[i]]
  setup_sdmdata(species_name = sp,
                occurrences = occs,
                lon = "lon",
                lat = "lat",
                predictors = clim.stack,
                models_dir = "./modelos/loop",
                partition_type = "bootstrap",
                boot_n = 5,
                boot_proportion = 0.7,
                buffer_type = "mean",
                write_buffer = T,
                png_sdmdata = T,
                n_back = 1000,
                clean_dupl = T,
                clean_uni = T,
                clean_nas = T,
                geo_filt = F,
                geo_filt_dist = 10,
                select_variables = T,
                sample_proportion = 0.5
)
}

sdmdata_1sp
#para ver o numero de registros depois da limpeza
dim(sdmdata_1sp)
head(sdmdata_1sp)
