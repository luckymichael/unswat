SUBROUTINE hhwatqual
 
! Code converted using TO_F90 by Alan Miller
! Date: 2015-03-30  Time: 03:56:00

!!    ~ ~ ~ PURPOSE ~ ~ ~
!!    this subroutine performs in-stream nutrient transformations and water
!!    quality calculations for hourly timestep

!!    ~ ~ ~ INCOMING VARIABLES ~ ~ ~
!!    name             |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    ai0              |ug chla/mg alg|ratio of chlorophyll-a to algal biomass
!!    ai1              |mg N/mg alg   |fraction of algal biomass that is N
!!    ai2              |mg P/mg alg   |fraction of algal biomass that is P
!!    ai3              |mg O2/mg alg  |the rate of oxygen production per unit of
!!                                    |algal photosynthesis
!!    ai4              |mg O2/mg alg  |the rate of oxygen uptake per unit of
!!                                    |algae respiration
!!    ai5              |mg O2/mg N    |the rate of oxygen uptake per unit of NH3
!!                                    |nitrogen oxidation
!!    ai6              |mg O2/mg N    |the rate of oxygen uptake per unit of NO2
!!                                    |nitrogen oxidation
!!    algae(:)         |mg alg/L      |algal biomass concentration in reach
!!    ammonian(:)      |mg N/L        |ammonia concentration in reach
!!    bc1(:)           |1/hr          |rate constant for biological oxidation of
!!                                    |NH3 to NO2 in reach at 20 deg C
!!    bc2(:)           |1/hr          |rate constant for biological oxidation of
!!                                    |NO2 to NO3 in reach at 20 deg C
!!    bc3(:)           |1/hr          |rate constant for hydrolysis of organic N
!!                                    |to ammonia in reach at 20 deg C
!!    bc4(:)           |1/hr          |rate constant for the decay of organic P
!!                                    |to dissolved P in reach at 20 deg C
!!    chlora(:)        |mg chl-a/L    |chlorophyll-a concentration in reach
!!    dayl(:)          |hours         |day length for current day
!!    disolvp(:)       |mg P/L        |dissolved P concentration in reach
!!    frad(:,:)        |none          |fraction of solar radiation occuring
!!                                    |during hour in day in HRU
!!    hdepth(:)        |m             |depth of flow on day
!!    hhtime(:)        |hr            |flow travel time for hour
!!    hhvaroute(2,:,:) |m^3 H2O       |water
!!    hhvaroute(4,:,:) |kg N          |organic nitrogen
!!    hhvaroute(5,:,:) |kg P          |organic posphorus
!!    hhvaroute(6,:,:) |kg N          |nitrate
!!    hhvaroute(7,:,:) |kg P          |soluble phosphorus
!!    hhvaroute(13,:,:)|kg            |chlorophyll-a
!!    hhvaroute(14,:,:)|kg N          |ammonium
!!    hhvaroute(15,:,:)|kg N          |nitrite
!!    hhvaroute(16,:,:)|kg            |carbonaceous biological oxygen demand
!!    hhvaroute(17,:,:)|kg O2         |dissolved oxygen
!!    hrchwtr(ii)      |m^3 H2O       |water stored in reach at beginning of day
!!    hrtwtr(:)        |m^3 H2O       |flow out of reach
!!    hru_ra(:)        |MJ/m^2        |solar radiation for the day in HRU
!!    igropt           |none          |Qual2E option for calculating the local
!!                                    |specific growth rate of algae
!!                                    |1: multiplicative:
!!                                    | u = mumax * fll * fnn * fpp
!!                                    |2: limiting nutrient
!!                                    | u = mumax * fll * Min(fnn, fpp)
!!                                    |3: harmonic mean
!!                                    | u = mumax * fll * 2. / ((1/fnn)+(1/fpp))
!!    inum1            |none          |reach number
!!    inum2            |none          |inflow hydrograph storage location number
!!    k_l              |MJ/(m2*hr)    |half saturation coefficient for light
!!    k_n              |mg N/L        |michaelis-menton half-saturation constant
!!                                    |for nitrogen
!!    k_p              |mg P/L        |michaelis-menton half saturation constant
!!                                    |for phosphorus
!!    lambda0          |1/m           |non-algal portion of the light extinction
!!                                    |coefficient
!!    lambda1          |1/(m*ug chla/L)|linear algal self-shading coefficient
!!    lambda2          |(1/m)(ug chla/L)**(-2/3)
!!                                    |nonlinear algal self-shading coefficient
!!    mumax            |1/hr          |maximum specific algal growth rate at
!!                                    |20 deg C
!!    nitraten(:)      |mg N/L        |nitrate concentration in reach
!!    nitriten(:)      |mg N/L        |nitrite concentration in reach
!!    organicn(:)      |mg N/L        |organic nitrogen concentration in reach
!!    organicp(:)      |mg P/L        |organic phosphorus concentration in reach
!!    p_n              |none          |algal preference factor for ammonia
!!    rch_cbod(:)      |mg O2/L       |carbonaceous biochemical oxygen demand in
!!                                    |reach
!!    rch_dox(:)       |mg O2/L       |dissolved oxygen concentration in reach
!!    rhoq             |1/hr          |algal respiration rate at 20 deg C
!!    rk1(:)           |1/hr          |CBOD deoxygenation rate coefficient in
!!                                    |reach at 20 deg C
!!    rk2(:)           |1/hr          |reaeration rate in accordance with Fickian
!!                                    |diffusion in reach at 20 deg C
!!    rk3(:)           |1/hr          |rate of loss of CBOD due to settling in
!!                                    |reach at 20 deg C
!!    rk4(:)           |mg O2/        |sediment oxygen demand rate in reach
!!                     |  ((m**2)*hr) |at 20 deg C
!!    rnum1            |none          |fraction of overland flow
!!    rs1(:)           |m/hr          |local algal settling rate in reach at
!!                                    |20 deg C
!!    rs2(:)           |(mg disP-P)/  |benthos source rate for dissolved P
!!                     |  ((m**2)*hr) |in reach at 20 deg C
!!    rs3(:)           |(mg NH4-N)/   |benthos source rate for ammonia nitrogen
!!                     |  ((m**2)*hr) |in reach at 20 deg C
!!    rs4(:)           |1/hr          |rate coefficient for organic nitrogen
!!                                    |settling in reach at 20 deg C
!!    rs5(:)           |1/hr          |organic phosphorus settling rate in reach
!!                                    |at 20 deg C
!!    rttime           |hr            |reach travel time
!!    tfact            |none          |fraction of solar radiation that is
!!                                    |photosynthetically active
!!    tmpav(:)         |deg C         |average air temperature on current day
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ OUTGOING VARIABLES ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    algae(:)    |mg alg/L      |algal biomass concentration in reach
!!    ammonian(:) |mg N/L        |ammonia concentration in reach
!!    chlora(:)   |mg chl-a/L    |chlorophyll-a concentration in reach
!!    disolvp(:)  |mg P/L        |dissolved phosphorus concentration in reach
!!    nitraten(:) |mg N/L        |nitrate concentration in reach
!!    nitriten(:) |mg N/L        |nitrite concentration in reach
!!    organicn(:) |mg N/L        |organic nitrogen concentration in reach
!!    organicp(:) |mg P/L        |organic phosphorus concentration in reach
!!    rch_cbod(:) |mg O2/L       |carbonaceous biochemical oxygen demand in
!!                               |reach
!!    rch_dox(:)  |mg O2/L       |dissolved oxygen concentration in reach
!!    soxy        |mg O2/L       |saturation concetration of dissolved oxygen
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ LOCAL DEFINITIONS ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    algcon      |mg alg/L      |initial algal biomass concentration in reach
!!    algi        |MJ/(m2*hr)    |photosynthetically active light intensity
!!                               |for hour
!!    algin       |mg alg/L      |algal biomass concentration in inflow
!!    ammoin      |mg N/L        |ammonium N concentration in inflow
!!    bc1mod      |1/day         |rate constant for biological oxidation of NH3
!!                               |to NO2 modified to reflect impact of low
!!                               |oxygen concentration
!!    bc2mod      |1/day         |rate constant for biological oxidation of NO2
!!                               |to NO3 modified to reflect impact of low
!!                               |oxygen concentration
!!    cbodcon     |mg/L          |initial carbonaceous biological oxygen demand
!!                               |concentration in reach
!!    cbodin      |mg/L          |carbonaceous biological oxygen demand
!!                               |concentration in inflow
!!    chlin       |mg chl-a/L    |chlorophyll-a concentration in inflow
!!    cinn        |mg N/L        |effective available nitrogen concentration
!!    cordo       |none          |nitrification rate correction factor
!!    disoxin     |mg O2/L       |dissolved oxygen concentration in inflow
!!    dispin      |mg P/L        |soluble P concentration in inflow
!!    f1          |none          |fraction of algal nitrogen uptake from
!!                               |ammonia pool
!!    fll         |none          |growth attenuation factor for light
!!    fnn         |none          |algal growth limitation factor for nitrogen
!!    fpp         |none          |algal growth limitation factor for phosphorus
!!    gra         |1/hr          |local algal growth rate at 20 deg C
!!    jrch        |none          |reach number
!!    lambda      |1/m           |light extinction coefficient
!!    nh3con      |mg N/L        |initial ammonia concentration in reach
!!    nitratin    |mg N/L        |nitrate concentration in inflow
!!    nitritin    |mg N/L        |nitrite concentration in inflow
!!    no2con      |mg N/L        |initial nitrite concentration in reach
!!    no3con      |mg N/L        |initial nitrate concentration in reach
!!    o2con       |mg O2/L       |initial dissolved oxygen concentration in
!!                               |reach
!!    orgncon     |mg N/L        |initial organic N concentration in reach
!!    orgnin      |mg N/L        |organic N concentration in inflow
!!    orgpcon     |mg P/L        |initial organic P concentration in reach
!!    orgpin      |mg P/L        |organic P concentration in inflow
!!    solpcon     |mg P/L        |initial soluble P concentration in reach
!!    thbc1       |none          |temperature adjustment factor for local
!!                               |biological oxidation of NH3 to NO2
!!    thbc2       |none          |temperature adjustment factor for local
!!                               |biological oxidation of NO2 to NO3
!!    thbc3       |none          |temperature adjustment factor for local
!!                               |hydrolysis of organic N to ammonia N
!!    thbc4       |none          |temperature adjustment factor for local
!!                               |decay of organic P to dissolved P
!!    thgra       |none          |temperature adjustment factor for local algal
!!                               |growth rate
!!    thour       |none          |flow duration (fraction of hr)
!!    thrho       |none          |temperature adjustment factor for local algal
!!                               |respiration rate
!!    thrk1       |none          |temperature adjustment factor for local CBOD
!!                               |deoxygenation
!!    thrk2       |none          |temperature adjustment factor for local oxygen
!!                               |reaeration rate
!!    thrk3       |none          |temperature adjustment factor for loss of
!!                               |CBOD due to settling
!!    thrk4       |none          |temperature adjustment factor for local
!!                               |sediment oxygen demand
!!    thrs1       |none          |temperature adjustment factor for local algal
!!                               |settling rate
!!    thrs2       |none          |temperature adjustment factor for local
!!                               |benthos source rate for dissolved phosphorus
!!    thrs3       |none          |temperature adjustment factor for local
!!                               |benthos source rate for ammonia nitrogen
!!    thrs4       |none          |temperature adjustment factor for local
!!                               |organic N settling rate
!!    thrs5       |none          |temperature adjustment factor for local
!!                               |organic P settling rate
!!    wtmp        |deg C         |temperature of water in reach
!!    wtrin       |m^3 H2O       |water flowing into reach on day
!!    uu          |varies        |variable to hold intermediate calculation
!!                               |result
!!    vv          |varies        |variable to hold intermediate calculation
!!                               |result
!!    wtrtot      |m^3 H2O       |inflow + storage water
!!    ww          |varies        |variable to hold intermediate calculation
!!                               |result
!!    xx          |varies        |variable to hold intermediate calculation
!!                               |result
!!    yy          |varies        |variable to hold intermediate calculation
!!                               |result
!!    zz          |varies        |variable to hold intermediate calculation
!!                               |result
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ SUBROUTINES/FUNCTIONS CALLED ~ ~ ~
!!    Intrinsic: Log, Exp, Min
!!    SWAT: Theta

!!    ~ ~ ~ ~ ~ ~ END SPECIFICATIONS ~ ~ ~ ~ ~ ~

use parm

INTEGER :: jrch, ii
REAL :: wtrin, chlin, algin, orgnin, ammoin, nitratin, nitritin
REAL :: orgpin, dispin, cbodin, disoxin, thour, wtmp, fll, gra
REAL :: lambda, fnn, fpp, algi, xx, yy, zz, ww, cinn
REAL :: uu, vv, cordo, f1, algcon, orgncon, nh3con, no2con, no3con
REAL :: orgpcon, solpcon, cbodcon, o2con, wtrtot, bc1mod, bc2mod
REAL :: thgra = 1.047, thrho = 1.047, thrs1 = 1.024
REAL :: thrs2 = 1.074, thrs3 = 1.074, thrs4 = 1.024, thrs5 = 1.024
REAL :: thbc1 = 1.083, thbc2 = 1.047, thbc3 = 1.047, thbc4 = 1.047
REAL :: thrk1 = 1.047, thrk2 = 1.024, thrk3 = 1.024, thrk4 = 1.060
!      real :: thrk5 = 1.047, thrk6 = 1.0, thrs6 = 1.024, thrs7 = 1.0

jrch = 0
jrch = inum1

!! hourly loop
DO ii = 1, nstep
!! initialize water flowing into reach
  wtrin = 0.
  wtrin = hhvaroute(2,inum2,ii) * (1. - rnum1)
  
  IF (hrtwtr(ii) / (idt * 60.) > 0.01) THEN
!! concentrations
!! initialize inflow concentrations
    chlin = 0.
    algin = 0.
    orgnin = 0.
    ammoin = 0.
    nitritin = 0.
    nitratin = 0.
    orgpin = 0.
    dispin = 0.
    cbodin = 0.
    disoxin = 0.
    cinn = 0.
    IF (wtrin > 0.001) THEN
      chlin = 1000. * hhvaroute(13,inum2,ii) * (1. - rnum1) / wtrin
      algin = 1000. * chlin / ai0        !! QUAL2E equation III-1
      orgnin = 1000. * hhvaroute(4,inum2,ii) * (1. - rnum1) / wtrin
      ammoin = 1000. * hhvaroute(14,inum2,ii) * (1. - rnum1) / wtrin
      nitritin = 1000. * hhvaroute(15,inum2,ii) * (1. - rnum1) / wtrin
      nitratin = 1000. * hhvaroute(6,inum2,ii) * (1. - rnum1) / wtrin
      orgpin = 1000. * hhvaroute(5,inum2,ii) * (1. - rnum1) / wtrin
      dispin = 1000. * hhvaroute(7,inum2,ii) * (1. - rnum1) / wtrin
      cbodin = 1000. * hhvaroute(16,inum2,ii) * (1. - rnum1) / wtrin
      disoxin= 1000. * hhvaroute(17,inum2,ii) * (1. - rnum1) / wtrin
    END IF
    
    IF (chlin < 1.e-6) chlin = 0.0
    IF (algin < 1.e-6) algin = 0.0
    IF (orgnin < 1.e-6) orgnin = 0.0
    IF (ammoin < 1.e-6) ammoin = 0.0
    IF (nitritin < 1.e-6) nitritin = 0.0
    IF (nitratin < 1.e-6) nitratin = 0.0
    IF (orgpin < 1.e-6) orgnpin = 0.0
    IF (dispin < 1.e-6) dispin = 0.0
    IF (cbodin < 1.e-6) cbodin = 0.0
    IF (disoxin < 1.e-6) disoxin = 0.0
    
!! initialize concentration of nutrient in reach
    wtrtot = 0.
    algcon = 0.
    orgncon = 0.
    nh3con = 0.
    no2con = 0.
    no3con = 0.
    orgpcon = 0.
    solpcon = 0.
    cbodcon = 0.
    o2con = 0.
    wtrtot = wtrin + hrchwtr(ii)
    IF (ii == 1) THEN
      algcon = (algin * wtrin + algae(jrch) * hrchwtr(ii)) / wtrtot
      orgncon = (orgnin * wtrin + organicn(jrch) * hrchwtr(ii)) / wtrtot
      nh3con = (ammoin * wtrin + ammonian(jrch) * hrchwtr(ii)) / wtrtot
      no2con = (nitritin * wtrin + nitriten(jrch) * hrchwtr(ii)) / wtrtot
      no3con = (nitratin * wtrin + nitraten(jrch) * hrchwtr(ii)) / wtrtot
      orgpcon = (orgpin * wtrin + organicp(jrch) * hrchwtr(ii)) / wtrtot
      solpcon = (dispin * wtrin + disolvp(jrch) * hrchwtr(ii)) / wtrtot
      cbodcon = (cbodin * wtrin + rch_cbod(jrch) * hrchwtr(ii)) / wtrtot
      o2con = (disoxin * wtrin + rch_dox(jrch) * hrchwtr(ii)) / wtrtot
    ELSE
      algcon = (algin * wtrin + halgae(ii-1) * hrchwtr(ii)) / wtrtot
      orgncon = (orgnin * wtrin + horgn(ii-1) * hrchwtr(ii)) / wtrtot
      nh3con = (ammoin * wtrin + hnh4(ii-1) * hrchwtr(ii)) / wtrtot
      no2con = (nitritin * wtrin + hno2(ii-1) * hrchwtr(ii)) / wtrtot
      no3con = (nitratin * wtrin + hno3(ii-1) * hrchwtr(ii)) / wtrtot
      orgpcon = (orgpin * wtrin + horgp(ii-1) * hrchwtr(ii)) / wtrtot
      solpcon = (dispin * wtrin + hsolp(ii-1) * hrchwtr(ii)) / wtrtot
      cbodcon = (cbodin * wtrin + hbod(ii-1) * hrchwtr(ii)) / wtrtot
      o2con = (disoxin * wtrin + hdisox(ii-1) * hrchwtr(ii)) / wtrtot
    END IF
    
    IF (algcon < 1.e-6) algcon = 0.0
    IF (orgncon < 1.e-6) orgncon = 0.0
    IF (nh3con < 1.e-6) nh3con = 0.0
    IF (no2con < 1.e-6) no2con = 0.0
    IF (no3con < 1.e-6) no3con = 0.0
    IF (orgpcon < 1.e-6) orgpcon = 0.0
    IF (solpcon < 1.e-6) solpcon = 0.0
    IF (cbodcon < 1.e-6) cbodcon = 0.0
    IF (o2con < 1.e-6) o2con = 0.0
!! calculate temperature in stream
!! Stefan and Preudhomme. 1993.  Stream temperature estimation
!! from air temperature.  Water Res. Bull. p. 27-45
!! SWAT manual equation 2.3.13
    wtmp = 0.
    wtmp = 5.0 + 0.75 * tmpav(jrch)
    IF (wtmp <= 0.) wtmp = 0.1
    
!! calculate effective concentration of available nitrogen
!! QUAL2E equation III-15
    cinn = nh3con + no3con
    
!! calculate saturation concentration for dissolved oxygen
!! QUAL2E section 3.6.1 equation III-29
    ww = 0.
    xx = 0.
    yy = 0.
    zz = 0.
    ww = -139.34410 + (1.575701E05 / (wtmp + 273.15))
    xx = 6.642308E07 / ((wtmp + 273.15)**2)
    yy = 1.243800E10 / ((wtmp + 273.15)**3)
    zz = 8.621949E11 / ((wtmp + 273.15)**4)
    soxy = EXP(ww - xx + yy - zz)
    IF (soxy < 0.) soxy = 0.
!! end initialize concentrations
    
!! O2 impact calculations
!! calculate nitrification rate correction factor for low
!! oxygen QUAL2E equation III-21
    cordo = 0.
    cordo = 1.0 - EXP(-0.6 * o2con)
!! modify ammonia and nitrite oxidation rates to account for
!! low oxygen
    bc1mod = 0.
    bc2mod = 0.
    bc1mod = bc1(jrch) * cordo
    bc2mod = bc2(jrch) * cordo
!! end O2 impact calculations
    
!! calculate flow duration
    thour = 0.
    thour = hhtime(ii)
    IF (thour > 1.0) thour = 1.0
    thour = 1.0
    
!! algal growth
!! calculate light extinction coefficient
!! (algal self shading) QUAL2E equation III-12
    IF (ai0 * algcon > 1.e-6) THEN
      lambda = lambda0 + (lambda1 * ai0 * algcon) + lambda2 *  &
          (ai0 * algcon) ** (.66667)
    ELSE
      lambda = lambda0
    END IF
    
!! calculate algal growth limitation factors for nitrogen
!! and phosphorus QUAL2E equations III-13 & III-14
    fnn = 0.
    fpp = 0.
    fnn = cinn / (cinn + k_n)
    fpp = solpcon / (solpcon + k_p)
    
!! calculate hourly, photosynthetically active,
!! light intensity QUAL2E equation III-9c
!! Light Averaging Option # 3
    algi = 0.
    algi = frad(hru1(jrch),ii) * hru_ra(hru1(jrch)) * tfact
    
!! calculate growth attenuation factor for light, based on
!! hourly light intensity QUAL2E equation III-6a
    fll = 0.
    fll = (1. / (lambda * hdepth(ii))) *  &
        LOG((k_l + algi) / (k_l + algi * (EXP(-lambda * hdepth(ii)))))
    
!! calculcate local algal growth rate
    gra = 0.
    select case (igropt)
    case (1)
!! multiplicative QUAL2E equation III-3a
    gra = mumax * fll * fnn * fpp
    case (2)
!! limiting nutrient QUAL2E equation III-3b
    gra = mumax * fll * MIN(fnn, fpp)
    case (3)
!! harmonic mean QUAL2E equation III-3c
    IF (fnn > 1.e-6 .AND. fpp > 1.e-6) THEN
      gra = mumax * fll * 2. / ((1. / fnn) + (1. / fpp))
    ELSE
      gra = 0.
    END IF
  END select
  
!! calculate algal biomass concentration at end of day
!! (phytoplanktonic algae)
!! QUAL2E equation III-2
  halgae(ii) = 0.
  halgae(ii) = algcon + (theta(gra,thgra,wtmp) * algcon -  &
      theta(rhoq,thrho,wtmp) * algcon - theta(rs1(jrch),thrs1,wtmp)  &
      / hdepth(ii) * algcon) * thour
  IF (halgae(ii) < 0.) halgae(ii) = 0.
  
!! calculate chlorophyll-a concentration at end of day
!! QUAL2E equation III-1
  hchla(ii) = 0.
  hchla(ii) = halgae(ii) * ai0 / 1000.
!! end algal growth
  
!! oxygen calculations
!! calculate carbonaceous biological oxygen demand at end
!! of day QUAL2E section 3.5 equation III-26
  yy = 0.
  zz = 0.
  yy = theta(rk1(jrch),thrk1,wtmp) * cbodcon
  zz = theta(rk3(jrch),thrk3,wtmp) * cbodcon
  hbod(ii) = 0.
  hbod(ii) = cbodcon - (yy + zz) * thour
  IF (hbod(ii) < 0.) hbod(ii) = 0.
  
!! calculate dissolved oxygen concentration if reach at
!! end of day QUAL2E section 3.6 equation III-28
  uu = 0.
  vv = 0.
  ww = 0.
  xx = 0.
  yy = 0.
  zz = 0.
  uu = theta(rk2(jrch),thrk2,wtmp) * (soxy - o2con)
  vv = (ai3 * theta(gra,thgra,wtmp) - ai4 * theta(rhoq,thrho,wtmp)) * algcon
  ww = theta(rk1(jrch),thrk1,wtmp) * cbodcon
  xx = theta(rk4(jrch),thrk4,wtmp) / (hdepth(ii) * 1000.)
  yy = ai5 * theta(bc1mod,thbc1,wtmp) * nh3con
  zz = ai6 * theta(bc2mod,thbc2,wtmp) * no2con
  hdisox(ii) = 0.
  hdisox(ii) = o2con + (uu + vv - ww - xx - yy - zz) * thour
  IF (hdisox(ii) < 0.) hdisox(ii) = 0.
!! end oxygen calculations
  
!! nitrogen calculations
!! calculate organic N concentration at end of day
!! QUAL2E section 3.3.1 equation III-16
  xx = 0.
  yy = 0.
  zz = 0.
  xx = ai1 * theta(rhoq,thrho,wtmp) * algcon
  yy = theta(bc3(jrch),thbc3,wtmp) * orgncon
  zz = theta(rs4(jrch),thrs4,wtmp) * orgncon
  horgn(ii) = 0.
  horgn(ii) = orgncon + (xx - yy - zz) * thour
  IF (horgn(ii) < 0.) horgn(ii) = 0.
  
!! calculate fraction of algal nitrogen uptake from ammonia
!! pool QUAL2E equation III-18
  f1 = 0.
  f1 = p_n * nh3con / (p_n * nh3con + (1. - p_n) * no3con + 1.e-6)
  
!! calculate ammonia nitrogen concentration at end of day
!! QUAL2E section 3.3.2 equation III-17
  ww = 0.
  xx = 0.
  yy = 0.
  zz = 0.
  ww = theta(bc3(jrch),thbc3,wtmp) * orgncon
  xx = theta(bc1mod,thbc1,wtmp) * nh3con
  yy = theta(rs3(jrch),thrs3,wtmp) / (hdepth(ii) * 1000.)
  zz = f1 * ai1 * algcon * theta(gra,thgra,wtmp)
  hnh4(ii) = 0.
  hnh4(ii) = nh3con + (ww - xx + yy - zz) * thour
  IF (hnh4(ii) < 0.) hnh4(ii) = 0.
  
!! calculate concentration of nitrite at end of day
!! QUAL2E section 3.3.3 equation III-19
  yy = 0.
  zz = 0.
  yy = theta(bc1mod,thbc1,wtmp) * nh3con
  zz = theta(bc2mod,thbc2,wtmp) * no2con
  hno2(ii) = 0.
  hno2(ii) = no2con + (yy - zz) * thour
  IF (hno2(ii) < 0.) hno2(ii) = 0.
  
!! calculate nitrate concentration at end of day
!! QUAL2E section 3.3.4 equation III-20
  yy = 0.
  zz = 0.
  yy = theta(bc2mod,thbc2,wtmp) * no2con
  zz = (1. - f1) * ai1 * algcon * theta(gra,thgra,wtmp)
  hno3(ii) = 0.
  hno3(ii) = no3con + (yy - zz) * thour
  IF (hno3(ii) < 0.) hno3(ii) = 0.
!! end nitrogen calculations
  
!! phosphorus calculations
!! calculate organic phosphorus concentration at end of
!! day QUAL2E section 3.3.6 equation III-24
  xx = 0.
  yy = 0.
  zz = 0.
  xx = ai2 * theta(rhoq,thrho,wtmp) * algcon
  yy = theta(bc4(jrch),thbc4,wtmp) * orgpcon
  zz = theta(rs5(jrch),thrs5,wtmp) * orgpcon
  horgp(ii) = 0.
  horgp(ii) = orgpcon + (xx - yy - zz) * thour
  IF (horgp(ii) < 0.) horgp(ii) = 0.
  
!! calculate dissolved phosphorus concentration at end
!! of day QUAL2E section 3.4.2 equation III-25
  xx = 0.
  yy = 0.
  zz = 0.
  xx = theta(bc4(jrch),thbc4,wtmp) * orgpcon
  yy = theta(rs2(jrch),thrs2,wtmp) / (hdepth(ii) * 1000.)
  zz = ai2 * theta(gra,thgra,wtmp) * algcon
  hsolp(ii) = 0.
  hsolp(ii) = solpcon + (xx + yy - zz) * thour
  IF (hsolp(ii) < 0.) hsolp(ii) = 0.
!! end phosphorus calculations
  
ELSE
!! all water quality variables set to zero when no flow
  algin = 0.0
  chlin = 0.0
  orgnin = 0.0
  ammoin = 0.0
  nitritin = 0.0
  nitratin = 0.0
  orgpin = 0.0
  dispin = 0.0
  cbodin = 0.0
  disoxin = 0.0
  halgae(ii) = 0.0
  hchla(ii) = 0.0
  horgn(ii) = 0.0
  hnh4(ii) = 0.0
  hno2(ii) = 0.0
  hno3(ii) = 0.0
  horgp(ii) = 0.0
  hsolp(ii) = 0.0
  hbod(ii) = 0.0
  hdisox(ii) = 0.0
  soxy = 0.0
END IF
IF (halgae(ii) < 1.e-6) halgae(ii) = 0.0
IF (hchla(ii) < 1.e-6) hchla(ii) = 0.0
IF (horgn(ii) < 1.e-6) horgn(ii) = 0.0
IF (hnh4(ii) < 1.e-6) hnh4(ii) = 0.0
IF (hno2(ii) < 1.e-6) hno2(ii) = 0.0
IF (hno3(ii) < 1.e-6) hno3(ii) = 0.0
IF (horgp(ii) < 1.e-6) horgp(ii) = 0.0
IF (hsolp(ii) < 1.e-6) hsolp(ii) = 0.0
IF (hbod(ii) < 1.e-6) hbod(ii) = 0.0
IF (hdisox(ii) < 1.e-6) hdisox(ii) = 0.0
IF (soxy < 1.e-6) soxy = 0.0

END DO
!! end hourly loop

!! set end of day concentrations
algae(jrch) = halgae(nstep)
chlora(jrch) = hchla(nstep)
organicn(jrch) = horgn(nstep)
ammonian(jrch) = hnh4(nstep)
nitriten(jrch) = hno2(nstep)
nitraten(jrch) = hno3(nstep)
organicp(jrch) = horgp(nstep)
disolvp(jrch) = hsolp(nstep)
rch_cbod(jrch) = hbod(nstep)
rch_dox(jrch) = hdisox(nstep)

IF (algae(jrch) < 1.e-6) algae(jrch) = 0.0
IF (chlora(jrch) < 1.e-6) chlora(jrch) = 0.0
IF (organicn(jrch) < 1.e-6) organicn(jrch) = 0.0
IF (ammonian(jrch) < 1.e-6) ammonian(jrch) = 0.0
IF (nitriten(jrch) < 1.e-6) nitriten(jrch) = 0.0
IF (organicp(jrch) < 1.e-6) organicp(jrch) = 0.0
IF (disolvp(jrch) < 1.e-6) disolvp(jrch) = 0.0
IF (rch_cbod(jrch) < 1.e-6) rch_cbod(jrch) = 0.0
IF (rch_dox(jrch) < 1.e-6) rch_dox(jrch) = 0.0

RETURN
END SUBROUTINE hhwatqual
