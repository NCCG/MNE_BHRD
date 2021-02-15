################################################################################
###                                                                          ###
###  TO CREATE A LIST OF TREE SPECIES Of STATES OF MINAS GERAIS AND          ###
###                    ESPIRITO SANTO, BRAZIL                                ###
###                             9 Feb 2021                                   ###
###                                                                          ###
################################################################################


#install.packages( "devtools")
#devtools::install_github("saramortara/rocc")
library (rocc)

mg<-search_flora(domain = NULL,
             state = "MG",
             lifeform = "Árvore")

est<-rep("MG",nrow(mg))
sp_mg<-cbind(est, mg)

es<-search_flora(domain = NULL,
                     state = "ES",
                     lifeform = "Árvore")

est<-rep("es",nrow(es))
sp_es<-cbind(est, es)

lista<- rbind(sp_mg, sp_es)

dups2 <- duplicated(lista[, "id"])
sum(dups2)
lista2 <- lista[!dups2, ]


write.table(lista2, "./Data/Biotic/lista_mg_es.csv", row.names=F, sep=";", dec=",")

?search_flora

## PS: To get a list of species for the Doce river watersheld (BHRD), we need to (1) use the list "lista2",  (2) get records of the spp from GBIF, (3) then extract them only for the polygon of the BHRD.

#With the new list only for the BHRD, We will repeat the step 2, to get the records of these spp for South America, for niche modeling. 
