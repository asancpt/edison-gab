PK02 = read.csv("data-raw/PK02.csv", skip=1)
colnames(PK02) = c("TIME","DV")
DV2 = c(4.75, 4.43, 4.21, 3.81, 3.57, 3.28, 2.93, 2.21, 1.95, 1.72, 1.47 ,1.24, 1.02, 0.77, 0.61, 0.36, 0.2)
PK02 = cbind(PK02, DV2)
PK02
dPK02 = PK02
require(wnl)

## Plot
plot(DV2 ~ TIME, data=PK02, type="o")
lines(DV ~ TIME, data=PK02, type="o", col="red")

plot(log(DV2) ~ TIME, data=PK02, type="o")
lines(log(DV) ~ TIME, data=PK02, type="o", col="red")

## NCA
library(NonCompart)
R1 = sNCA(PK02$TIME, PK02$DV2, dose=100, adm="Bolus", doseUnit="ug", timeUnit="min") ; R1
R2 = sNCA(PK02$TIME, PK02$DV, dose=100, adm="Extravascular", doseUnit="ug", timeUnit="min") ; R2
BA = R2["AUCIFO"]/R1["AUCIFO"]; BA * 100 # Absolute Bioavailability (BA)

## Model without tlag
Dose = 100

fPK01 = function(THETA) # Prediction function
{
  DOSE = Dose
  TIME = e$DATA[,"TIME"]

  BA   = BA
  K    = THETA[1]
  Ka   = THETA[2]
  V    = THETA[3]

  F  = BA*DOSE/V*Ka/(Ka - K) * (exp(-K*TIME) - exp(-Ka*TIME))
  H1 = 1

  return(cbind(F, H1))
}

nlr(fPK01, dPK02, pNames=c("k", "Ka", "V"), IE=c(0.05, 0.1, 30))
wnl5(fPK01, dPK02, pNames=c("k", "Ka", "V"), IE=c(0.05, 0.1, 30))

## Model with tlag
fPK02 = function(THETA) # Prediction function
{
  DOSE = Dose
  TIME = e$DATA[,"TIME"]

  BA   = BA
  K    = THETA[1]
  Ka   = THETA[2]
  V    = THETA[3]
  tlag = THETA[4]

  F  = BA*DOSE/V*Ka/(Ka - K) * (exp(-K*(TIME - tlag)) - exp(-Ka*(TIME - tlag)))
  H1 = 1

  return(cbind(F, H1))
}
BA = 1
Dose = 100
colnames(PK02) = c("TIME", "DV", "DV2")
nlr(fPK02, dPK02, pNames=c("k", "Ka", "V", "tlag"), IE=c(0.05, 0.1, 30, 20))
wnl5(fPK02, dPK02, pNames=c("k", "Ka", "V", "tlag"), IE=c(0.05, 0.1, 30, 20))
