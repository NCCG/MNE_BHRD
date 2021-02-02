
########################################
#### CORRELATION TEST  #################
#### By: Danielle de O. Moreira ########
#### Date: 02 feb 2021 #################
########################################

####define file path
#setwd("C:/DaniTeste_tutorial")


# To work with rasters
library(raster)


############################## CRIAR RASTER STACK ###########################
#generate a list of input rasters ("grids")
#pattern = "*.tif$" - filters for main raster files only and skips any associated files (e.g. world files)
clim <- list.files(path="./data/raster/wc5_amsul", ".*.tif$",
                   full.names = TRUE)

clim

#create a raster stack from the input raster files
clim.stack <- stack(clim)

#Plotar os rasters em um mapa
plot(clim.stack)



############################ CORRELATION TEST #####################
#library(raster)

#subsample 70% of pixels and calculate pairwise correlations
clim.cor<- cor(sampleRandom(clim.stack, size = ncell(clim.stack)*0.7, nComp = nlayers(clim.stack)), 
               method = "pearson")

#visualize the correlation matrix
clim.cor

#plot correlation matrix
library(corrplot) # To do correlation

##The function colorRampPalette() is very convenient for generating color spectrum.
col4 <- colorRampPalette(c("#7F0000", "red", "#FF7F00", "yellow", "#7FFF7F",
                           "cyan", "#007FFF", "blue", "#00007F"))


#Combining correlogram with the significance test
res1 <- cor.mtest(clim.cor, conf.level = .95)
res2 <- cor.mtest(clim.cor, conf.level = .99)

?corrplot

## specialized the insignificant value according to the significant level
corrplot(clim.cor, p.mat = res1$p, sig.level = .05) 

## add p-values on no significant coefficient
corrplot(clim.cor, p.mat = res1$p, col = col4(100), insig = "p-value")

## add all p-values
corrplot(clim.cor, p.mat = res1$p, insig = "p-value", sig.level = -1)






############## EXTRA: PLAY MORE WITH THE CORRELATION MATRIX #######################3

corrplot(clim.cor, method = "circle")
corrplot(clim.cor, method = "number") # Display the correlation coefficient
corrplot.mixed(clim.cor) #corrplot.mixed() is a wrapped function for mixed visualization style.

#Reorder a correlation matrix
##"AOE" is for the angular order of the eigenvectors. It is calculated from the order of the angles
corrplot(clim.cor, order = "AOE")

#"hclust" for hierarchical clustering order, and "hclust.method" for the agglomeration method to be used. "hclust.method" should be one of "ward", "single", "complete", "average", "mcquitty", "median" or "centroid".
corrplot(clim.cor, order = "hclust")

corrplot(clim.cor, order = "hclust", addrect = 6) # addrect= number of rectangles

#"FPC" for the first principal component order.
corrplot(clim.cor, type = "upper", order = "FPC")

#"alphabet" for alphabetical order.
corrplot(clim.cor, order = "alphabet")

# Change background color to lightblue
corrplot(clim.cor, type = "upper", order = "hclust",
         col = c("black", "white"), bg = "lightblue")

#Other color
##The function colorRampPalette() is very convenient for generating color spectrum.
col1 <- colorRampPalette(c("#7F0000", "red", "#FF7F00", "yellow", "white",
                           "cyan", "#007FFF", "blue", "#00007F"))
col2 <- colorRampPalette(c("#67001F", "#B2182B", "#D6604D", "#F4A582",
                           "#FDDBC7", "#FFFFFF", "#D1E5F0", "#92C5DE",
                           "#4393C3", "#2166AC", "#053061"))
col3 <- colorRampPalette(c("red", "white", "blue")) 
col4 <- colorRampPalette(c("#7F0000", "red", "#FF7F00", "yellow", "#7FFF7F",
                           "cyan", "#007FFF", "blue", "#00007F"))
whiteblack <- c("white", "black")

## using these color spectra
corrplot(clim.cor, type = "upper", order = "hclust", method = "number", 
         addrect = 2, col = col4(20))


corrplot(abs(clim.cor),order = "AOE", col = col4(20), cl.lim = c(0, 1))


#Combining correlogram with the significance test

res1 <- cor.mtest(clim.cor, conf.level = .95)
res2 <- cor.mtest(clim.cor, conf.level = .99)

#Combining correlogram with the significance test
## specialized the insignificant value according to the significant level
corrplot(clim.cor, p.mat = res1$p, sig.level = .2) 

## add p-values on no significant coefficient
corrplot(clim.cor, p.mat = res1$p, col = col4(100), insig = "p-value")
## add all p-values
corrplot(clim.cor, p.mat = res1$p, insig = "p-value", sig.level = -1)

#Visualize confidence interval
res1 <- cor.mtest(clim.cor, conf.level = .95)
corrplot(clim.cor, p.mat = res1$p, insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = .9, pch.col = "white")

corrplot(clim.cor, p.mat = res1$p, insig = "label_sig", pch.col = "white",
         pch = "p<.05", pch.cex = .5, order = "AOE")
