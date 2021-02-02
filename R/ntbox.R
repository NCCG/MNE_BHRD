

#NTBOX

#if (!require('devtools')) install.packages('devtools')
#devtools::install_github('luismurao/ntbox')
# If you want to build vignette, install pandoc before and then
#devtools::install_github('luismurao/ntbox',build_vignettes=TRUE)

library(ntbox)
run_ntbox()

#Se de o seguinte erro:
#Erro: package or namespace load failed for ‘rgl’ in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]):
#there is no package called ‘xfun’

#Instalar o pacote 'xfun'

#install.packages("xfun")

# Tentar novamente:

run_ntbox()