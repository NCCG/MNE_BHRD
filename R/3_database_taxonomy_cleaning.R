#------------------------------------------------------
# Script to check species names, just raw string check
# using rocc, to install:
# remotes::install_github("saramortara/rocc")
#------------------------------------------------------


# loading packages
library(rocc)
library(dplyr)


data<-read.csv("./data/registros/spp_Gualaxo/5_Gualaxo_occ2.csv", header = T, sep=",", dec=".", encoding="utf-8")

data$spp
# Obs: The names of species have a whitespace after them.
#Let's use str_trim to remove whitespace after the species names
library(stringr)
spp <- str_trim(data$spp, "right") #remove whitespace from right. The new object only have the species column
spp <- as.data.frame(spp) # need to convert again to a data frame
coord <- subset(data, select=c("lon", "lat")) #subset to link the species' names column with coordinates column
data2 <- cbind(spp, coord)
data2$spp # no more whitespace after the species' names

# Now let's verify if the species names are correct using package rocc 
# using rocc::check_string() ####
?check_string

check <- check_string(species = data2$spp)
head(check)

# open information of status of species
table(check$speciesStatus)

# We stay with: possibly_ok, subspecies, variety, name_w_authors, name_w_non_ascii
stay <- c("name_w_authors",
          "possibly_ok")

verify <- c("not_Genus_epithet_format")

# checking fields ####
# for not genus epithet format; number [1] of the list
not_genus <- data2 %>% filter(check$speciesStatus %in% verify[1])
unique(not_genus$spp) # how many species need to check genus format
length(unique(not_genus$spp))

# To create a new column (check_ok).
check$check_ok <- "out"
head(check)

check$check_ok[check$speciesStatus %in% c(stay)] <- "ok"
check$check_ok[check$speciesStatus %in% "not_Genus_epithet_format"] <- "verify"

table(check$check_ok)

# now merging with object data2
tax_check <- cbind(data2, check[, -1])
head(tax_check)

# exporting data after check
write.csv(tax_check,
          file = "./data/registros/spp_Gualaxo/5_Gualaxo_occ_TaxonCheck.csv",
          row.names = FALSE)

#############################################################################
# Script to check taxonomy

# Check routine:
# get synonyms from Flora 2020
# 1. Flora 2020
# 2. Kew - World Checklist of Vascular Plants
# 3. TNRS - Taxonomic Name Resolution Service

library(dplyr)
library(flora)
library(rocc)
library(parallel)

tax_ok <- tax_check %>% filter(check_ok == "ok")

scientificName <- unique(tax_ok$species)
length(scientificName)

# 1. suggesting a name ####
# using parallel

# Calculate the number of cores
no_cores <- detectCores() - 1
# Initiate cluster
cl <- makeCluster(no_cores)

start_time <- Sys.time()
list_taxa <- parLapply(cl, scientificName, suggest_flora)
end_time <- Sys.time()

t1 <- end_time - start_time

stopCluster(cl)

suggest_taxa <- bind_rows(list_taxa)

search_taxa <- suggest_taxa$species %>%
  unique() %>%
  na.omit()

search_df <- data.frame(scientificName_search = search_taxa,
                        search_id = 1:length(search_taxa))
# 2. checking if the name exists in Brazilian Flora ####
?check_flora

flora_taxa <- list()
for (i in 1:length(search_taxa)) {
  message(paste(i, "species"))
  flora_taxa[[i]] <- check_flora(search_taxa[i],
                                 get_synonyms = FALSE,
                                 infraspecies = TRUE)
}

length(flora_taxa)

flora_taxa2 <- lapply(flora_taxa, function(x) x[1]$taxon)

flora_df <- bind_rows(flora_taxa2)

head(flora_df)

table(flora_df$taxonomicStatus)

# Changing column name of object search_df: scientificName_search to species
names(search_df)[names(search_df) == "scientificName_search"] <- "species"
head(search_df)

flora_df2 <- left_join(flora_df, search_df, by = "species")

# writing output
write.csv(flora_df2,
          file = "results/04_taxon_data_flora_check.csv",
          row.names = FALSE)

