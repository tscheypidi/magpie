*** |  (C) 2008-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

*' @equations
*'

q40_cost_transport(j2,k) ..
  vm_cost_transp(j2,k) =e= vm_prod(j2,k)*sum(ct,p40_distance(ct,j2))
                           * f40_transport_costs(k);

*'
*' Transportation costs for each cell are calculated as the product of
*' the production in each cell, the transport distance to a urban centre
*' and the transport costs.
*'
*' Transport distance is based on a random forest machine learning model
*' which was trained to estimate transport distances based on local
*' characteristics such as land use patterns and elevation. The cumulated time
*' needed to reach an urban center of minimal 50000 inhabitants works as
*' a dynamic proxy for accessibility of a grid cell.
*'

*' Relative transport costs `f40_transport_costs(k)` are calibrated using total
*' agricultural transport costs taken from the GTAP 7 database (see @narayanan_gtap7_2008
*' for a general description of the GTAP model structure). GTAP agricultural
*' transport costs represent transport costs from one sector to another sector
*' (e.g. from a farm to the mill). Based on GTAP we calculate sector to sector
*' transport costs for agricultural inputs and outputs. In MAgPIE we want to
*' represent market to market transport costs. Since markets are the links between
*' sectors, we assume that the sum of 50% of the agricultural input transport costs
*' and 50% of the output transport costs represent the agricultural transport costs
*' for a commodity.
*'
*' ![Transport Costs Concept](transport_costs_concept.png){ width=100% }
*'
*' Relative transport costs `f40_transport_costs(k)` are calculated by dividing
*' total agricultural transport costs from GTAP 7 by the product of an initial
*' (1995 as default) cellular MAgPIE production pattern and cellular travel time.
*' By doing so we ensure that relative transport costs, multiplied with the
*' initial MAgPIE production allocation and given travel times match the absolute
*' transport costs as reported by GTAP 7.
*'
*' Total agricultural transport costs from GTAP 7 are based on total agricultural
*' production in 2004. For consistency, we scale the GTAP data with the ratio of
*' FAO production data for 2004 and 1995. Subsequently, MAgPIE is run several
*' times in yield calibration mode until regional MAgPIE production is consistent
*' with FAO production for the initial time step. Based on this first calibration
*' run, total MAgPIE transportation costs are summed up and compared with GTAP data
*' (see Figure 3). In case of low agreement, the calculation of relative transportation
*' costs is repeated based on the calibrated MAgPIE production pattern and a second
*' round of MAgPIE yield calibration is started. This process is repeated until MAgPIE
*' total transport costs are in good agreement with GTAP total transport costs.
*'
*' ![Transport Costs Calibration - Comparison between GTAP transport costs and
*' MAgPIE transport costs for different GTAP commodities after each calibration
*' step](transport_costs_calib.png){ width=100% }
