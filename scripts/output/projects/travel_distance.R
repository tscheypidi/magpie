# |  (C) 2008-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  MAgPIE License Exception, version 1.0 (see LICENSE file).
# |  Contact: magpie@pik-potsdam.de

# --------------------------------------------------------------
# description: visualize travel distance development over time 
# comparison script: FALSE
# ---------------------------------------------------------------

library(gdx)
library(luscale)

############################# BASIC CONFIGURATION #############################
if(!exists("source_include")) {
  outputdir <- "."
  readArgs("outputdir")
}
###############################################################################

reportAccessibility <- function(outputdir) {
  cwd <- getwd()
  on.exit(setwd(cwd))
  setwd(outputdir)
  
  load("config.Rdata")
  gdx <- "fulldata.gdx"
  rel <- Sys.glob("*_sum.spam")
  a <- read.magpie("accessibilityprediction.mz")
  m <- readRDS("accessibilitymodel.rds")
  
  mdata <- as.magpie(m$data[c("distance","prediction")])
  mdata <- mdata[,rep(1,nyears(a)),]
  getYears(mdata) <- getYears(a)
  getNames(mdata) <- paste0(getNames(mdata),2015)
  getNames(a) <- sub(".","_",getNames(a),fixed=TRUE)
  
  td    <- readGDX(gdx,"p40_distance")
  td_hr <- speed_aggregate(td,rel)
  getCells(td_hr) <- getCells(a)
  getNames(td_hr) <- "prediction_cluster"
  
  out <- mbind(mdata,a,td_hr)
  
  write.magpie(out, paste0("accessibility_cell_",cfg$title,".nc"))
  write.magpie(out, paste0("accessibility_cell_",cfg$title,".mz"))
}
reportAccessibility(outputdir)
