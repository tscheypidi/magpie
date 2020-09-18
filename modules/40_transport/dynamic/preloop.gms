*** |  (C) 2008-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

pc40_distance(j) = f40_distance(j);

$onecho > traveldistance.R
.getYear <- function(gdx="traveldistanceOut.gdx") {
  return(as.character(gdx::readGDX(gdx,"ct")))
}

.getland <- function(gdx="traveldistanceOut.gdx") {
  year <- .getYear(gdx)
  message(".: get pcm_land from gdx for year ",year," :.")
  require(gdx)
  land <- gdx::readGDX(gdx,"pcm_land")
  getYears(land) <- year
  return(land)
}

.getland_ini <- function(fname="pcm_land_hr.mz", fname_start="avl_land_t_0.5.mz", year) {
  if(year=="y1995") {
    message(".: read in high resolution land data for initialization year 1995 :.")
    fpath <- ifelse(file.exists(fname_start),
                    fname_start,
                    paste0("modules/10_land/input/",fname_start))
    tmp <- read.magpie(fpath)[,1995,]
    getYears(tmp) <- 1985
    return(tmp)
  }
  message(".: read in high resolution land data from previous time step :.")
  return(read.magpie(fname))
}

.getmap <- function(cluster=NULL,cells=NULL) {
  message(".: get cluster mapping :.")
  require(spam, quietly = TRUE)
  require(luscale, quietly = TRUE)
  spamfile <- Sys.glob("*_sum.spam")
  if(length(spamfile)==0) spamfile <- Sys.glob("input/*_sum.spam")
  spam <- luscale::read.spam(spamfile)
  map <- luscale::spam2mapping(spam, clusterregions = cluster, cellregions = cells)
  map$weight <- NULL
  return(map)
}

.getland_hr <- function(land,land_ini,map,fname="pcm_land_hr.mz") {
  message(".: disaggregate land information :.")
  require(luscale)
  if(nyears(land_ini)>1) {
    land_prev <- land_ini[,1:(nyears(land_ini)-1),]
    land_ini <- land_ini[,nyears(land_ini),]
  } else {
    land_prev <- NULL
  }
  tmp <- land_ini[,nyears(land_ini),]
  land_hr <- luscale::interpolate2(x = land, x_ini = tmp, map = map)
  write.magpie(mbind(land_prev,land_hr),fname)
  return(land_hr)
}

.enhance_prediction <- function(prediction, base_prediction, reference) {
  message(".: enhance prediction :.")
  # enhance prediction by only applying changes in prediction on source data
  return(reference*prediction/base_prediction)
}

.predictaccessibility <- function(land_hr, mfile="accessibilitymodel.rds") {
  message(".: predict accessibility :.")
  require(randomForest, quietly = TRUE)
  df_land_hr <- as.data.frame(as.array(land_hr)[,nyears(land_hr),])
  modelpath <- ifelse(file.exists(mfile), mfile,
                      paste0("modules/40_transport/input/",mfile))
  m <- readRDS(mfile)
  newdata      <- cbind(df_land_hr,m$data[!(names(m$data) %in% c(names(df_land_hr),"distance","prediction"))])
  prediction   <- predict(m$model, newdata = newdata)
  enhanced_prediction <- .enhance_prediction(prediction,m$data$prediction,m$data$distance)
  return(list(raw=prediction, enhanced=enhanced_prediction))
}

.saveprediction <- function(prediction,year,file) {
  message(".: write prediction to file :.")
  if(year!="y1995") {
    data <- read.magpie(file)
  } else {
    data <- NULL
  }
  pr <- as.magpie(prediction$raw)
  getNames(pr) <- "prediction.raw"
  pe <- as.magpie(prediction$enhanced)
  getNames(pe) <- "prediction.enhanced"
  pepr <- mbind(pe,pr)
  getYears(pepr) <- year
  write.magpie(mbind(data,pepr),file)
}

.aggregateprediction <- function(prediction,land_hr) {
  message(".: aggregate prediction :.")
  require(madrat, quietly = TRUE)
  weight <- dimSums(land_hr,dim=c(2,3))
  prediction_lr <- toolAggregate(as.magpie(prediction), map, weight=weight)
  return(prediction_lr)
}

.prediction2gdx <- function(prediction_lr,gdxin="traveldistanceOut.gdx", gdxout="traveldistanceIn.gdx") {
  message(".: write aggregated prediction to gdx :.")
  pc40_distance <- readGDX(gdxin,"pc40_distance")
  pc40_distance[,1,1] <- magpiesort(prediction_lr)
  writeGDX(pc40_distance,gdxout)
}

gdxin   <- "traveldistanceOut.gdx"
gdxout  <- "traveldistanceIn.gdx"
fname   <- "pcm_land_hr.mz"
mfile   <- "accessibilitymodel.rds"
prediction_file <- "accessibilityprediction.mz"
year          <- .getYear(gdxin)
land          <- .getland(gdxin)
land_ini      <- .getland_ini(fname, year=year)
map           <- .getmap(getCells(land),getCells(land_ini))
land_hr       <- .getland_hr(land, land_ini, map, fname)
prediction    <- .predictaccessibility(land_hr, mfile)
.saveprediction(prediction,year,prediction_file)
prediction_lr <- .aggregateprediction(prediction$enhanced,land_hr)
.prediction2gdx(prediction_lr, gdxin, gdxout)
$offecho
