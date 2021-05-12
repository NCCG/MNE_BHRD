#################################################
# ModleR                                        #
# Cleaning and setup sdm_data                   #
# Species trees occurrences                     #
# Tutorial: https://github.com/Model-R/modleR   #
#################################################

# Packages
#para trabalhar com dados espaciais
library(sp)

#para trabalhar com raster
library(raster)

# para trabalhar com o ModleR
library(modleR)

# Loading selected environment data (pca axes, Pearson correlation, vif, etc)
clim <- list.files(path="./data/raster/wc2-5_amesul/pca", 
                   ".*.tif$",
                   full.names = TRUE)

clim.stack <- stack(clim) # stack raster
plot(clim.stack)  # stack raster

# Loading occurrence data
#library(data.table)
#data<-fread("./data/registros/endemicas/6_endemic_pts_for_model.csv")

data<-read.csv("./data/registros/spp_Gualaxo/6_Gualaxo_ModleR.csv", header = T, sep=",", dec=".", encoding="utf-8")

head(data)

# get column names
#colnames(data)
names(data)

unique(data$species)

# To remote white spaces from species names
### Leaving only a few columns
#table <- subset(data, select=c("spp","lon","lat"))
#change name of colunm spp to sp
#names(table)[names(table) == "spp"] <- "sp"

#library(tidyverse)
# To rename spp names - changging space for "_"
#table2 <- table %>% 
#  mutate(sp = str_replace(sp, 
#                              pattern = " ", 
#                              replacement = "_"))

#head(table2)

#Excluding spaces after words
#table3 <- table2 %>% 
#  mutate(sp = str_replace(sp, 
#                           pattern = " ", 
#                           replacement = ""))
#head(table3)

#write.csv(table3,file="./data/registros/spp_Gualaxo/6_gualaxo_modleR.csv")


#Count number of occurrences to each spp

#table %>% 
#  count(sp)

#library(dplyr)
###To check the frequency of occurrences for each species
#a <- table(table$sp)%>%sort()
#View(a)

#to make a list of species names
#species <- unique(table3$sp)
species <- unique(data$species)

species

#Use species with more than 10 occurrences points
#Count number of occurrences to each spp
#To check the frequency of occurrences for each species
count.occs <- table(data$species)%>%sort()
count.occs <- as.data.frame(count.occs)

#Select only species with more than 10 points.
#library(dplyr)
#a <- count.occs %>% 
#  filter(Freq > 10)

#View(a)


# Plot in a map the occurrences
library(rgdal) #for shapefile
shp<- readOGR("./data/shape/amesul.shp") #loading shapefile
crs(shp) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs "
proj4string(shp)


plot(clim.stack[[2]])
plot(shp, add=TRUE)
#points(table3$lon, table3$lat, col = "red", cex = .1)
points(data$lon, data$lat, col = "red", cex = .1)

#create a list from our data/table3
data_list <- split(data, data$species)
names(data_list) #check names
species <- names(data_list)

#data_list <- split(table3, table3$sp)
#names(data_list) #check names
#species <- names(data_list)

######################## Data Cleaning ####################################

args(setup_sdmdata)
?setup_sdmdata


for (i in 1:length(data_list)) {
  sp <- species[i]
  occs <- data_list[[i]]
  setup_sdmdata(species_name = sp,
                occurrences = occs,
                lon = "lon",
                lat = "lat",
                predictors = clim.stack,
                models_dir = "./modelos/modelos_gualaxo",
                partition_type = "bootstrap",
                boot_n = 10,
                boot_proportion = 0.7,
                buffer_type = "mean",
                write_buffer = T,
                png_sdmdata = T,
                n_back = 5000,
                clean_dupl = T,
                clean_uni = T,
                clean_nas = T,
                geo_filt = F,
                geo_filt_dist = 10,
                select_variables = F,
                sample_proportion = 0.5
)
}


