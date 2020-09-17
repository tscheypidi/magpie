*** |  (C) 2008-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

pc40_distance(j) = f40_distance(j);

$onecho > traveldistance.R
library(randomForest)
library(madrat)

.getland <- function() {
  require(gdx)
  land <- gdx::readGDX("traveldistanceOut.gdx","pcm_land")
  if(is.null(getYears(land))) getYears(land) <- 1995
  return(land)
}

.getland_ini <- function() {
  fname <- "pcm_land_hr.mz"
  if(!file.exists(fname)) {
    fpath <- ifelse(file.exists("avl_land_t_0.5.mz"),
                    "avl_land_t_0.5.mz",
                    "modules/10_land/input/avl_land_t_0.5.mz")
    tmp <- read.magpie(fpath)[,1,]
    getYears(tmp) <- 1985
    return(tmp)
  }
  return(read.magpie(fname))
}

.getmap <- function(cluster=NULL,cells=NULL) {
  require(spam)
  require(luscale)
  spamfile <- Sys.glob("*_sum.spam")
  if(length(spamfile)==0) spamfile <- Sys.glob("input/*_sum.spam")
  spam <- luscale::read.spam(spamfile)
  map <- luscale::spam2mapping(spam, clusterregions = cluster, cellregions = cells)
  map$weight <- NULL
  return(map)
}

.getland_hr <- function(land,land_ini,map) {
  require(luscale)
  land_hr <- luscale::interpolate2(x = land, x_ini = land_ini, map = map)
  write.magpie(land_hr,)
  return(land_hr,"pcm_land_hr.mz")
}

.enhance_prediction <- function(prediction, base_prediction, reference) {
  # enhance prediction by only applying changes in prediction on source data
  return(reference*prediction/base_prediction)
}

land     <- .getland()
land_ini <- .getland_ini()
map      <- .getmap(getCells(land),getCells(land_ini))
land_hr  <- .getland_hr(land, land_ini, map)

df_land_hr <- as.data.frame(as.array(land_hr)[,nyears(land_hr),])

mfile <- "accessibilitymodel.rds"
modelpath <- ifelse(file.exists(mfile), mfile,
                    paste0("modules/40_transport/input/",mfile))

m <- readRDS(mfile)
newdata      <- cbind(df_land_hr,m$data[!(names(m$data) %in% c(names(df_land_hr),"distance","prediction"))])
prediction   <- predict(m$model, newdata = newdata)

enhanced_prediction <- .enhance_prediction(prediction,m$data$prediction,m$data$distance)

weight <- dimSums(land_hr,dim=c(2,3))
prediction_lr <- toolAggregate(as.magpie(enhanced_prediction), map, weight=weight)

pc40_distance <- readGDX("traveldistanceOut.gdx","pc40_distance")
pc40_distance[,1,1] <- magpiesort(prediction_lr)
writeGDX(pc40_distance,"traveldistanceIn.gdx")
$offecho
