# |  (C) 2008-2020 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  MAgPIE License Exception, version 1.0 (see LICENSE file).
# |  Contact: magpie@pik-potsdam.de

# ----------------------------------------------------------
# description: testing dynamic transport distances
# ----------------------------------------------------------

######################################
#### Script to start a MAgPIE run ####
######################################

# Load start_run(cfg) function which is needed to start MAgPIE runs
source("scripts/start_functions.R")

#start MAgPIE run
source("config/default.cfg")

cfg$title <- "access_default"
cfg$gms$transport <- "dynamic" 
cfg$gms$factor_costs <- "mixed_feb17" 
start_run(cfg)

cfg$title <- "access_sticky"
cfg$gms$transport <- "dynamic" 
cfg$gms$factor_costs <- "sticky_feb18" 
start_run(cfg)

