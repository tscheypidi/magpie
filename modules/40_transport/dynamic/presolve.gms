*** |  (C) 2008-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de


execute_unload  'traveldistanceOut.gdx', pc40_distance, pcm_land;
execute 'Rscript traveldistance.R';
execute_load 'traveldistanceIn.gdx', pc40_distance;

p40_distance(t,j) = pc40_distance(j);