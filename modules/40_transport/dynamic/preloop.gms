*** |  (C) 2008-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

pc40_distance(j) = f40_distance(j);

$onecho > traveldistance.R
library(gdx)
library(traveldistance)

modelpath <- ifelse(file.exists("model.rds"),"model.rds","modules/40_transport/input/model.rds")
model    <- readRDS(modelpath)
pcm_land <- readGDX("traveldistanceOut.gdx","pcm_land", restore_zeros = FALSE)
pcm_land <- as.data.frame(as.array(pcm_land)[,,])
pcm_land[is.na(pcm_land)] <- 0
prediction   <- predict(model, newdata = pcm_land)

pc40_distance <- readGDX("traveldistanceOut.gdx","pc40_distance", restore_zeros = FALSE)
pc40_distance[,1,1] <- prediction
writeGDX(pc40_distance,"traveldistanceIn.gdx")

$offecho
