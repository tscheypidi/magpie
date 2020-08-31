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

gdx <- path(outputdir,"fulldata.gdx")
rel <- Sys.glob(path(outputdir,"*_sum.spam"))
ofile <- path(outputdir,"travel_distance.nc")
###############################################################################

td <- readGDX(gdx,"p40_distance")
td_hr <- speed_aggregate(td,rel)
getNames(td_hr) <- "travel distance"
write.magpie(td_hr,ofile)


