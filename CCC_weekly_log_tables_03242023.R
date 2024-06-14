rm(list = ls())
library(bigrquery)
library(data.table)
library(boxr)
library(tidyverse)
library(dplyr)
library(reshape)  
library(stringr)
library(plyr)
library(lubridate)
library(expss) ###to add labels
library(epiDisplay)
#https://shaivyakodan.medium.com/7-useful-r-packages-for-analysis-7f60d28dca98
devtools::install_github("tidyverse/reprex")
bq_auth()
#The bigrquery package is requesting access to your Google account.
#Select a pre-authorised account or enter '0' to obtain a new token.
#Press Esc/Ctrl + C to cancel.

#1: wuj12@nih.gov
project <- "nih-nci-dceg-connect-prod-6d04"
billing <- "nih-nci-dceg-connect-prod-6d04" ##project and billing should be consistent

###for the verified, invitation, biospecimen checkin, module completions, all activity completed on Mar. 9, 2023
#data <- readRDS("~/Documents/CONNECT_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/recruit2023-03-20.rds" )
###the timing of verified, recruitment, incentive, biospecimen collections, survey completions
dd[grepl("TmComplete",dd$`Variable Name`),]
# # A tibble: 9 × 3
# CID       `Variable Label`                                                                        `Variable Name`       
# <chr>     <chr>                                                                                   <chr>                 
#   1 195145666 Date/Time mouthwash survey completed                                                    SrvMw_TmComplete_v1r0 
# 2 217640691 Date/Time menstrual cycle survey completed                                              SrvMC_TmComplete_v1r0 
# 3 222161762 Date/Time blood/urine/mouthwash research survey completed                               SrvBLM_TmComplete_v1r0
# 4 264644252 Date/time of Completion of Where You Live and Work                                      SrvLAW_TmComplete_v1r0
# 5 315032037 Date/Time SSN Survey completed                                                          SrvSS_TmComplete_v1r0 
# 6 517311251 Date/time Status of Completion of Background and Overall Health                         SrvBOH_TmComplete_v1r0
# 7 764863765 Date/Time blood/urine survey completed                                                  SrvBlU_TmComplete_v1r0
# 8 770257102 Date/time of Completion of Smoking, Alcohol, and Sun Exposure                           SrvSAS_TmComplete_v1r0
# 9 832139544 Date/time Status of Completion of Medications, Reproductive Health, Exercise, and Sleep SrvMRE_TmComplete_v1r0
# 1 536735468 Flag for Baseline Module Medications, Reproductive Health, Exercise and Sleep SrvMRE_BaseStatus_v1r0
# 2 663265240 Flag for Baseline Module Where You Live and Work                              SrvLAW_BaseStatus_v1r0
# 3 949302066 Flag for Baseline Module Background and Overall Health                        SrvBOH_BaseStatus_v1r0
# 4 976570371 Flag for Baseline Module Smoking, Alcohol, and Sun Exposure                   SrvSAS_BaseStatus_v1r0
modules <- c("d_100767870","d_949302066","d_536735468","d_663265240","d_976570371","d_517311251","d_832139544","d_264644252","d_770257102")
##for biospecimen 
# recrver1$BioFin_BaseMWCol_v1r0  <-factor(recrver1$d_684635302,exclude=NULL)
# recrver1$BioFin_BaseBloodCol_v1r0 <- factor(recrver1$d_878865966,exclude=NULL)
# recrver1$BioFin_BaseUrineCol_v1r0 <- factor(recrver1$d_167958071,exclude=NULL)
# recrver1$SrvBLM_ResSrvCompl_v1r0 <-factor(recrver1$d_265193023,exclude=NULL)
# recrver1$BL_BioSpm_MWSetting_v1r0 <- factor(recrver1$d_173836415_d_266600170_d_915179629,levels=c("Clinical","Research","Home"))
# recrver1$BL_BioSpm_UrineSetting_v1r0 <- factor(recrver1$d_173836415_d_266600170_d_718172863, levels=c("Clinical","Research","Home"))
# recrver1$BL_BioSpm_BloodSetting_v1r0 <- factor(recrver1$d_173836415_d_266600170_d_592099155,levels=c("Clinical","Research","Home"))

###For research collections you can the baseline BioFin_ variables for blood, urine, mouthwash. 
##research collection time:
# 170 d_173836415_d_266600170_d_561681068                                 Date/time Research Blood Collected
# d_173836415_d_266600170_d_847159717                                 Date/time Research Urine Collected
#d_173836415_d_266600170_d_448660695                                      Date/time Mouthwash Collected
###For clinical samples you can use the 'any clinical sample' variable that includes blood or urine.
#d_173836415_d_266600170_d_139245758                                 Date/time Clinical Urine Collected
# d_173836415_d_266600170_d_982213346                                 Date/time Clinical Blood Collected
bio.col <- c("d_684635302","d_878865966","d_167958071","d_173836415_d_266600170_d_915179629","d_173836415_d_266600170_d_718172863",
             "d_173836415_d_266600170_d_592099155","d_173836415_d_266600170_d_561681068","d_173836415_d_266600170_d_847159717",
             "d_173836415_d_266600170_d_448660695","d_173836415_d_266600170_d_139245758","d_173836415_d_266600170_d_541311218", 
             "d_173836415_d_266600170_d_224596428","d_173836415_d_266600170_d_740582332", "d_173836415_d_266600170_d_982213346",
             "d_173836415_d_266600170_d_398645039","d_173836415_d_266600170_d_822274939")
###clinical collection time:
clc.bldtm <- c("d_173836415_d_266600170_d_769615780","d_173836415_d_266600170_d_822274939","d_173836415_d_266600170_d_398645039","d_173836415_d_266600170_d_982213346","d_173836415_d_266600170_d_740582332")
clc.urinetm <- c("d_173836415_d_266600170_d_139245758","d_173836415_d_266600170_d_224596428","d_173836415_d_266600170_d_541311218","d_173836415_d_266600170_d_939818935","d_173836415_d_266600170_d_740582332")

##the final biospecimen collection time
data$biocol_tm
##incentive eligible
##time eligible:d_130371375_d_266600170_d_787567527 Time Payment Eligible for Round

###refusal and withdrawal:revocation, withdrawal, data destruction
#  659990606 Date withdrew consent                                                                 HdWd_WdConsentDt_v1r0 
# d_664453818 as HdRef_DateHIPAArevoked_v1r0, /* Autoset when HdWd_HIPAA revoked_v1r0 selected*/
# d_269050420 as HdRef_DateDatadestroy_v1r0, /* Autoset when  HdWd_Destroydata_v1r0 selected*/
# d_613641698 as HdWd_DateHIPAArevsign_v1r0, /* Autoset when HdWd_HIPAArevocationsigned_v1r0 selected*/
# d_906417725 as HdWd_Activepart_v1r0, /* Refusing all future activities*/
#   d_831041022 as HdWd_Destroydata_v1r0, /* Destroy data*/
#   d_773707518 as HdWd_HIPAArevoked_v1r0, /* Revoke HIPAA*/
#   d_269050420 as HdRef_DateDatadestroy_v1r0, /* Autoset when  HdWd_Destroydata_v1r0 selected*/
# 2 747006172 Withdraw consent                                              HdWd_WdConsent_v1r0   
# 3 773707518 Revoke HIPAA                                                  HdWd_HIPAArevoked_v1r0
# 4 831041022 Wants data destroyed                                          HdWd_Destroydata_v1r0 
# 5 906417725 Refusing all future activities                                HdWd_Activepart_v1r0  
ref.wd <- c("d_773707518","d_747006172","d_831041022","d_664453818","d_269050420","d_659990606")

var.list <- c("token","Connect_ID","d_821247024","d_914594314","d_512820379","state_d_158291096","d_471593703","d_827220437",
              "d_130371375_d_266600170_d_787567527","d_130371375_d_266600170_d_731498909",bio.col,modules,ref.wd)
requery <- paste(var.list,collapse=",")
tb <- bq_project_query(project, query="SELECT requery FROM `nih-nci-dceg-connect-prod-6d04.FlatConnect.participants_JP` Where d_512820379 != '180583933' or d_821247024='197316935'")
#Auto-refreshing stale OAuth token.
#Complete
#Billed: 0 B
data <- bq_table_download(tb)

# Check that it doesn't match any non-number
numbers_only <- function(x) !grepl("\\D", x)

###convert the numeric

cnames <- names(data)
# to check variables in recr_noinact_wl1
for (i in 1: length(cnames)){
  varname <- cnames[i]
  var<-pull(data,varname)
  data[,cnames[i]] <- ifelse(numbers_only(var), as.numeric(as.character(var)), var)
}


veri_resp <- data[which(data$d_512820379 != 486306141 | data$d_821247024 != 922622075 ),var.list] %>%
  mutate(recru_time = ymd_hms(d_471593703),
         verified_time = ymd_hms(d_914594314),
         elgible.time = ymd_hms(d_130371375_d_266600170_d_787567527))
          # recruit_year= year(ymd_hms(d_471593703)),
         # recruit_month = month(ymd_hms(d_471593703)),
         # verified_year= year(ymd_hms(d_914594314)),
         # verified_month = month(ymd_hms(d_914594314)),
veri_resp$recrstart.date <-  as_date(min(ymd_hms(veri_resp$d_471593703),na.rm=TRUE))
         


veri_resp <- apply_labels(veri_resp,d_827220437 = "Site",#RcrtES_Site_v1r0
                          d_827220437 = c("HealthPartners"= 531629870, "Henry Ford Health System"=548392715, 
                                          "Kaiser Permanente Colorado" = 125001209, "Kaiser Permanente Georgia" = 327912200,
                                          "Kaiser Permanente Hawaii" = 300267574,"Kaiser Permanente Northwest" = 452412599, 
                                          "Marshfield Clinic Health System" = 303349821,"Sanford Health" = 657167265, 
                                          "University of Chicago Medicine" = 809703864, "National Cancer Institute" = 517700004,
                                          "National Cancer Institute" = 13,"Other" = 181769837))
veri_resp$site <- factor(veri_resp$d_827220437,
                         levels=c("HealthPartners", "Henry Ford Health System","Marshfield Clinic Health System",
                                  "Sanford Health", "University of Chicago Medicine","Kaiser Permanente Colorado",
                                  "Kaiser Permanente Georgia","Kaiser Permanente Hawaii","Kaiser Permanente Northwest",
                                  "National Cancer Institute","Other"))
veri_resp$site <- droplevels(veri_resp$site)
# veri_resp$recru_time <- ymd_hms(veri_resp$d_471593703)
# veri_resp$verified_time <- ymd_hms(veri_resp$d_914594314)
# veri_resp$recrstart.date <- as_date(min(ymd_hms(veri_resp$d_471593703),na.rm=TRUE))
recrstart.date <- as_date(min(ymd_hms(veri_resp$recru_time),na.rm=TRUE))
wday(unique(veri_resp$recrstart.date), week_start = 1)
#[1] 5 #Friday
as_date(recrstart.date-days(5))
#[1] "2021-07-18" #Sunday the censoring starting day
wday(as_date(recrstart.date-days(5)),week_start=1)
#[1] 7 #Sunday
veri_resp$recruit.week <- ceiling(as.numeric(difftime(as_date(veri_resp$recru_time), as_date(veri_resp$recrstart.date-days(5)),units="days"))/7) #to lock at Monday as the start of week
veri_resp$recruit.week.date <- veri_resp$recrstart.date + days(2) + dweeks(veri_resp$recruit.week-1) #to present the date of the starting date in the following week
 summary(as_date(veri_resp$recruit.week.date))
#Min.      1st Qu.       Median         Mean      3rd Qu.         Max.         NA's 
#"2021-07-25" "2022-08-14" "2022-11-06" "2022-10-28" "2023-01-22" "2023-04-02"          "2" 
 
veri_resp$verified.week <- ceiling(as.numeric(difftime(as_date(ymd_hms(veri_resp$d_914594314)),as_date(veri_resp$recrstart.date-days(5)),units="days"))/7)
veri_resp$verified.week.date <- (veri_resp$recrstart.date) + days(2)+ dweeks(veri_resp$verified.week-1)

min(as_date(ymd_hms(veri_resp$verified_time)),na.rm=TRUE)
# [1] "2021-07-27"
unique(as_date(min(veri_resp$verified.week.date,na.rm=TRUE)))
#[1] "2021-08-01"
unique(as_date(max(veri_resp$verified.week.date,na.rm=TRUE)))
#[1] "2023-03-26"
wday(as_date(recrstart.date-days(5)),week_start=1)
#7 Sunday
###to create the time censoring variables by week;
#verified  over time:

recruit.wk.active <- veri_resp[which(veri_resp$d_512820379==486306141),] %>% 
  group_by(recruit.week,recruit.week.date) %>%
  dplyr::summarize(active_recruits=n(),
                   recruitdate_max=max(recru_time,rm.na=T))

verified.wk.active <- veri_resp[which(veri_resp$d_821247024 == 197316935 & veri_resp$d_512820379==486306141),] %>% 
  group_by(verified.week,verified.week.date) %>%
  dplyr::summarize(active_verifieds=n(),
                   verified_activetime.max=max(verified_time,rm.na=T))

verified.wk.total <- veri_resp[which(veri_resp$d_821247024 == 197316935),] %>% 
  group_by(verified.week,verified.week.date) %>%
  dplyr::summarize(total_verifieds=n(),
                   verified_time.max=max(verified_time,rm.na=T))

verified.wk.all <- merge(verified.wk.active,verified.wk.total, by.x = c("verified.week","verified.week.date"),by.y=c("verified.week","verified.week.date"),all.y=TRUE,all.x=TRUE)
verified.wk.all$verified.week.date[is.na(verified.wk.all$verified.week.date)]<- recrstart.date + days(3)+ dweeks(verified.wk.all$verified.week-1)
recrui_wk_verified <- merge(recruit.wk.active,verified.wk.all, by.x=c("recruit.week","recruit.week.date"),by.y=c("verified.week","verified.week.date"),all.x=TRUE,all.y=TRUE)
recrui_wk_verified <- recrui_wk_verified %>% 
  mutate_at(c("active_recruits","active_verifieds","total_verifieds"),~replace_na(., 0))

#recrui_wk_verified <- recrui_wk_verified %>% mutate(week.date=as_date(do.call(pmax, c(select(.,ends_with('max')),na.rm=TRUE))))

recrui_wk_verified <- recrui_wk_verified %>% arrange(recruit.week,recruit.week.date)

# passive recruits are the passive verified
recrui_wk_verified$passive_verifieds <- recrui_wk_verified$total_verifieds-recrui_wk_verified$active_verifieds #new passive recruitment
recrui_wk_verified$active_recruits.cum <- cumsum(recrui_wk_verified$active_recruits)
recrui_wk_verified$passive_verifieds.cum <- cumsum(recrui_wk_verified$passive_verifieds)
recrui_wk_verified$active_verifieds.cum <- cumsum(recrui_wk_verified$active_verifieds)

recrui_wk_verified$total_recruits <- recrui_wk_verified$active_recruits + recrui_wk_verified$passive_verifieds ##the total recruits till that week

recrui_wk_verified$total_recruits.cum <- cumsum(recrui_wk_verified$active_recruits + recrui_wk_verified$passive_verifieds) ##the total recruits till that week

recrui_wk_verified$total_verified.cum <- cumsum(recrui_wk_verified$total_verifieds)

#new response rate:
recrui_wk_verified$new.active.response.rate <- ifelse(recrui_wk_verified$active_recruits >0, 100*(recrui_wk_verified$active_verifieds/recrui_wk_verified$active_recruits), 0)
recrui_wk_verified$new.passive.response.rate <- ifelse(recrui_wk_verified$active_recruits!=0, 100*(recrui_wk_verified$passive_verifieds/recrui_wk_verified$active_recruits),NA)
recrui_wk_verified$new.total.response.rate <- ifelse(recrui_wk_verified$active_recruits>0, 100*(recrui_wk_verified$total_verifieds/recrui_wk_verified$active_recruits), 0)

#cumalative rate
recrui_wk_verified$cum.active.response.rate <- 100*(cumsum(recrui_wk_verified$active_verifieds)/cumsum(recrui_wk_verified$active_recruits))
recrui_wk_verified$cum.passive.response.rate <- 100*(cumsum(recrui_wk_verified$passive_verifieds)/cumsum(recrui_wk_verified$active_recruits))
recrui_wk_verified$cum.total.response.rate <- 100*(cumsum(recrui_wk_verified$total_verifieds)/cumsum(recrui_wk_verified$active_recruits))

###for the verified group on their biospecimen collections, module completions, eligibility and refusal and withdrawal
veri_resp$elgible.time <- ymd_hms(veri_resp$d_130371375_d_266600170_d_787567527) 
veri_resp$eligible.week <- ifelse(!is.na( veri_resp$d_130371375_d_266600170_d_787567527) & veri_resp$d_821247024==197316935,
                                  ceiling(as.numeric(difftime(as_date(veri_resp$elgible.time),as_date(recrstart.date-days(5)),units="days"))/7),NA)

# 4 264644252 Date/time of Completion of Where You Live and Work                                      SrvLAW_TmComplete_v1r0
# 5 315032037 Date/Time SSN Survey completed                                                          SrvSS_TmComplete_v1r0 
# 6 517311251 Date/time Status of Completion of Background and Overall Health                         SrvBOH_TmComplete_v1r0
# 7 764863765 Date/Time blood/urine survey completed                                                  SrvBlU_TmComplete_v1r0
# 8 770257102 Date/time of Completion of Smoking, Alcohol, and Sun Exposure                           SrvSAS_TmComplete_v1r0
# 9 832139544 Date/time Status of Completion of Medications, Reproductive Health, Exercise, and Sleep SrvMRE_TmComplete_v1r0
# 170 d_173836415_d_266600170_d_561681068                                 Date/time Research Blood Collected
# d_173836415_d_266600170_d_847159717                                 Date/time Research Urine Collected
#d_173836415_d_266600170_d_448660695                                      Date/time Mouthwash Collected
###For clinical samples you can use the 'any clinical sample' variable that includes blood or urine.
#d_173836415_d_266600170_d_139245758                                 Date/time Clinical Urine Collected
# d_173836415_d_266600170_d_982213346                                 Date/time Clinical Blood Collected
# bldcol.time = case_when(d_173836415_d_266600170_d_592099155== 534621077 ~ as.POSIXct(d_173836415_d_266600170_d_561681068),
#                         d_173836415_d_266600170_d_592099155 == 664882224 ~ pmin(as.POSIXct(d_173836415_d_266600170_d_982213346),as.POSIXct(d_173836415_d_266600170_d_398645039),as.POSIXct(d_173836415_d_266600170_d_822274939),na.rm=TRUE)),
# urine.time = case_when(d_173836415_d_266600170_d_592099155==534621077 ~ as.POSIXct(d_173836415_d_266600170_d_847159717),
#                        d_173836415_d_266600170_d_592099155==664882224 ~ pmin(as.POSIXct(d_173836415_d_266600170_d_139245758),as.POSIXct(d_173836415_d_266600170_d_541311218),as.POSIXct(d_173836415_d_266600170_d_224596428),na.rm=TRUE)),

#Mar. 29, 2023, based on Michelle's comments: "any baseline blood or urine or mouthwash collected" would be the participants  
#with any biospecimen collected, in this way, the following up columns will be fixed soon. 
#and for the completion of all activities= complete of 4 modules and completion of all biospecimen by their settings: 
# research and clinic, but the incentive won't be included here
# the cumulative passive recruits are passive verified participants

veri_act <- filter(veri_resp,d_821247024==197316935) %>% 
  mutate(law.time = ymd_hms(d_264644252),
         sas.time = ymd_hms(d_770257102),
         mre.time = ymd_hms(d_832139544),
         boh.time = ymd_hms(d_517311251),
         bldcol.time = case_when(d_878865966 == 353358909 ~ pmin(as.POSIXct(d_173836415_d_266600170_d_561681068),as.POSIXct(d_173836415_d_266600170_d_982213346),as.POSIXct(d_173836415_d_266600170_d_398645039),as.POSIXct(d_173836415_d_266600170_d_822274939),na.rm=TRUE)),
         urine.time = case_when(d_167958071 == 353358909 ~ pmin(as.POSIXct(d_173836415_d_266600170_d_847159717),as.POSIXct(d_173836415_d_266600170_d_139245758),as.POSIXct(d_173836415_d_266600170_d_541311218),as.POSIXct(d_173836415_d_266600170_d_224596428),na.rm=TRUE)),
         mw.time = ymd_hms(d_173836415_d_266600170_d_448660695),
         biospeDonation = ifelse(d_878865966 %in% c(104430631,NA)  & d_167958071 %in% c(104430631,NA) & d_684635302 %in% c(104430631,NA),"No Sample Donations",
                                 ifelse(d_878865966 == 353358909 & d_167958071 == 353358909 & d_684635302 == 353358909,"Completed All 3 Sample Donations", 
                                        "Completed Some but Not All 3 Sample Donations")),
         biospeComplete = case_when(biospeDonation =="Completed All 3 Sample Donations" | 
                                      (d_173836415_d_266600170_d_592099155==664882224 & d_878865966 == 353358909 & d_167958071 == 353358909)  ~ 1,
                                    biospeDonation == "No Sample Donations" | ( biospeDonation == "Completed Some but Not All 3 Sample Donations" & 
                                                                                  d_173836415_d_266600170_d_592099155 %in% c(534621077,NA)) | 
                                      d_173836415_d_266600170_d_592099155==664882224 & d_878865966 %in% c(104430631, NA) | d_167958071 %in% c(104430631, NA) ~ 0),
         Module.complete = ifelse(d_100767870==353358909,"Complete","NotComplete"),
         HIPAARevVer = ifelse( d_773707518 == 353358909  & d_747006172 == 104430631 & d_831041022 == 104430631, 353358909,
                               ifelse( d_773707518 != 353358909  | d_747006172 != 104430631 | d_831041022 != 104430631,104430631, NA)),
         WdConsentVer = ifelse(d_747006172 == 353358909 & d_831041022 == 104430631, 353358909,
                               ifelse(d_747006172 != 353358909  | d_831041022 != 104430631,104430631, NA)),
         DestroyDataVer = ifelse(d_831041022 == 353358909, 353358909, ifelse(d_831041022 != 353358909,104430631, NA)))

veri_act$module.tm <- do.call(pmax, c(veri_act[,c("sas.time","mre.time","law.time","boh.time")],na.rm=TRUE))
veri_act <- veri_act%>% 
  mutate(module.time  = as_datetime(ifelse(d_100767870 ==353358909,module.tm,ifelse( d_100767870 ==104430631,NA,NA))),
         bioany.time = pmin(as.POSIXct(bldcol.time),as.POSIXct(urine.time),as.POSIXct(mw.time), na.rm = TRUE), #the earliest time of any collection
         biocol.time = pmax(as.POSIXct(bldcol.time),as.POSIXct(urine.time),as.POSIXct(mw.time), na.rm = TRUE)) ##the most recent time of any collection
           

veri_act <- veri_act%>% mutate(
  module.week = ifelse(!is.na(module.time),ceiling(as.numeric(difftime(as_date(module.time)+days(5),as_date(recrstart.date),units="days"))/7),NA),
  anybio.week = ifelse(!is.na(bioany.time),ceiling(as.numeric(difftime(as_date(bioany.time+days(5)),as_date(recrstart.date), units="days"))/7),NA),
  biocol.week = ifelse(!is.na(biocol.time),ceiling(as.numeric(difftime(as_date(biocol.time+days(5)),as_date(recrstart.date), units="days"))/7),NA),
  revoke.week = ifelse(!is.na(d_664453818),ceiling(as.numeric(difftime(as_date(ymd_hms(d_664453818)+days(5)),as_date(recrstart.date), units="days"))/7),NA),
  dtdestroy.week = ifelse(!is.na(d_269050420),ceiling(as.numeric(difftime(as_date(ymd_hms(d_269050420)+days(5)),as_date(recrstart.date), units="days"))/7),NA),
  wdconsent.week = ifelse(!is.na(d_659990606),ceiling(as.numeric(difftime(as_date(ymd_hms(d_659990606)+days(5)),as_date(recrstart.date), units="days"))/7),NA))

veri_act <- veri_act%>% mutate(allacts = case_when(d_100767870 == 353358909 & biospeComplete==1 ~ 353358909,
                                                d_100767870 == 104430631  | biospeComplete %in% c(0,NA) ~ 104430631 ))
veri_act$allacts.time <- apply(veri_act[,c("module.time","biocol.time")],1,max)
veri_act$allacts.week <- ceiling(as.numeric(difftime(as_date(ymd_hms(veri_act$allacts.time)+days(5)),as_date(recrstart.date), units="days"))/7)

eligible.wk.total <- veri_resp[which(veri_resp$d_821247024 == 197316935 & veri_resp$d_130371375_d_266600170_d_731498909 ==353358909 ),] %>% 
  group_by(eligible.week) %>%
  dplyr::summarize(total_eligible=n(),
                   eligible.time.max=max(elgible.time,rm.na=T))

module.wk.total <- filter(veri_act,d_100767870==353358909) %>% arrange(module.week,verified.week) %>% 
  group_by(module.week)%>%
  dplyr::summarize(total_module=n(),
                   module.time.max=max(as_date(module.time),rm.na=T))

anybio.wk.total <- filter(veri_act,biospeDonation!= "No Sample Donations") %>% arrange(anybio.week,verified.week) %>% 
  group_by(anybio.week)%>%
  dplyr::summarize(total_anybio=n(),
                   anybio.time.max=max(bioany.time,rm.na=T))


biocol.wk.total <- filter(veri_act, (biospeDonation =="Completed All 3 Sample Donations" | 
                     (d_173836415_d_266600170_d_592099155==664882224 & d_878865966 == 353358909 & d_167958071 == 353358909)))%>% 
 arrange(biocol.week,verified.week) %>% 
  group_by(biocol.week)%>%
  dplyr::summarize(total_biocol=n(),
                   biocol.time.max=max(biocol.time,rm.na=T))

allacts.wk.total <- filter(veri_act,allacts==353358909) %>% arrange(allacts.week,verified.week) %>% 
  group_by(allacts.week)%>%
  dplyr::summarize(total_allacts=n(),
                   allacts.time.max=max(allacts.time,rm.na=T))

#revoke.wk.total <- veri_act[which(veri_act$HIPAARevVer  ==353358909 ),] %>% 
#  group_by(revoke.week) %>%
#  dplyr::summarize(total_revoke=n())

dtdestroy.wk.total <- filter(veri_act,DestroyDataVer ==353358909) %>% arrange(dtdestroy.week,verified.week) %>% 
  group_by(dtdestroy.week)%>%
  dplyr::summarize(total_dtdestroy=n())

wdconsent.wk.total <- filter(veri_act,WdConsentVer ==353358909 & !is.na(wdconsent.week)) %>% arrange(wdconsent.week,verified.week) %>% 
  group_by(wdconsent.week)%>%
  dplyr::summarize(total_wdconsent=n())

veri_wk_eligble <- merge(verified.wk.total, eligible.wk.total,by.x="verified.week",by="eligible.week", all.x=TRUE,all.y=TRUE)
veri_wk_eligble <- merge(veri_wk_eligble, module.wk.total,by.x="verified.week",by="module.week", all.x=TRUE,all.y=TRUE)
veri_wk_eligble <- merge(veri_wk_eligble, anybio.wk.total,by.x="verified.week",by="anybio.week", all.x=TRUE,all.y=TRUE)
veri_wk_eligble <- merge(veri_wk_eligble, biocol.wk.total,by.x="verified.week",by="biocol.week", all.x=TRUE,all.y=TRUE)
veri_wk_eligble <- merge(veri_wk_eligble, dtdestroy.wk.total,by.x="verified.week",by="dtdestroy.week", all.x=TRUE,all.y=TRUE)
veri_wk_eligble <- merge(veri_wk_eligble, wdconsent.wk.total,by.x="verified.week",by="wdconsent.week", all.x=TRUE,all.y=TRUE)
veri_wk_eligble <- merge(veri_wk_eligble, allacts.wk.total,by.x="verified.week",by="allacts.week", all.x=TRUE,all.y=TRUE)
veri_wk_eligble <- veri_wk_eligble %>% 
  mutate(verified.week.date=as_date(ifelse(is.na(verified.week.date),as_date(recrstart.date)+dweeks(verified.week-1)+days(5),verified.week.date)))
###mutate_at(vars(match())) cannot work on here with an error messages
vars <- c("total_verifieds.x","total_module","total_anybio","total_eligible","total_biocol","total_dtdestroy","total_wdconsent","total_allacts")
recr_veri_wk <-  merge(recrui_wk_verified,veri_wk_eligble, by.x="recruit.week",by.y="verified.week",all.x=TRUE,all.y=TRUE)
recr_veri_wk <- recr_veri_wk %>% dplyr::select(.,-c("total_verifieds.y","verified_time.max.y"))

recr_veri_wk <- recr_veri_wk %>% mutate_at(vars,~replace_na(., 0)) %>%  arrange(recruit.week)%>% 
  mutate(total_eligible.cum=cumsum(total_eligible),
         total_module.cum=cumsum(total_module),
         total_anybio.cum=cumsum(total_anybio),
         total_biocol.cum=cumsum(total_biocol),
         total_dtdestroy.cum=cumsum(total_dtdestroy),
         total_wdconsent.cum=cumsum(total_wdconsent),
         total_allacts.cum=cumsum(total_allacts))



#recr_veri_wk <- recr_veri_wk %>% dplyr::select(-c(total_verifieds.y,verified_time.max.y))

#write.csv(recrui_wk_verified,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_verified_recruits_cumulative_0306.csv",row.names = F,na="")
var.list <- c("eligible","module","anybio","biocol","allacts","dtdestroy","wdconsent")

recr_veri_wk <- recr_veri_wk %>% mutate_at(vars,~replace_na(., 0))
ratio <- function(x,y){ifelse(y==0, 0,100*x/y)}
for (i in 1:length(var.list)){
  name <-paste0("total_",var.list[i],".cum")
  x <- recr_veri_wk[,name]
  recr_veri_wk$ratio1 <- ratio(x,recr_veri_wk$active_recruits.cum)
  colnames(recr_veri_wk)[which(colnames(recr_veri_wk)=="ratio1")] <- paste(var.list[i],"Invites","ratio",sep="_")
  recr_veri_wk$ratio2 <- ratio(x,recr_veri_wk$total_verified.cum)
  colnames(recr_veri_wk)[which(colnames(recr_veri_wk)=="ratio2")] <- paste(var.list[i],"Verifieds","ratio",sep="_")
}

recr_veri_wk$Week.Starting <- recr_veri_wk$recruit.week.date-days(6)
recr_veri_wk$Week.Ending <- recr_veri_wk$recruit.week.date
recr_veri_wk$week.day <- wday(recr_veri_wk$Week.Starting,label=TRUE,abbr=F)
recr_veri_wk <- recr_veri_wk %>% mutate(total_analysis=cumsum(total_verifieds.x)-cumsum(total_dtdestroy),
                                        total_followup=cumsum(total_verifieds.x)-cumsum(total_wdconsent))
#write.csv(recr_veri_wk,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_Allratio_recruits_cumulative_0306.csv",row.names = F,na="")
#"recruit.week", "week.day", "recruit.week.date","passive_verifieds",
var.select <- c(  "active_recruits.cum", "passive_verifieds.cum", "total_verified.cum", "cum.total.response.rate", 
                  "active_recruits", "total_verifieds.x", "total_anybio.cum","anybio_Invites_ratio","anybio_Verifieds_ratio",
                  "total_anybio","total_module.cum", "module_Invites_ratio", "module_Verifieds_ratio", "total_module", "total_eligible.cum", "eligible_Invites_ratio",
                  "eligible_Verifieds_ratio", "total_eligible", "total_allacts.cum", "allacts_Invites_ratio", "allacts_Verifieds_ratio", "total_allacts", 
                  "total_wdconsent.cum", "wdconsent_Verifieds_ratio", "total_wdconsent", "total_dtdestroy.cum", "dtdestroy_Verifieds_ratio", "total_dtdestroy", 
                  "total_analysis", "total_followup")        

#"total_biocol.cum", "biocol_Invites_ratio", "biocol_Verifieds_ratio", "total_biocol",  this part is about the completed biospecimen collection counts

labels <- c("Cumulative Invitations", "Cumulative Passive Verified Participants", "Cumulative Verified Participants", 
            "Response Ratio = Verfication/ Invitations", "Invitations per week", "Verifications per week", 
            "Cumulative Specimens defined as any baseline blood or urine or mouthwash collected", 
            "Specimen Response Ratio among Invited = Specimens/ Invited", "Specimen Response Ratio among Verified = Specimens/ Verified", 
            "Specimens collected per week", "Cumulative All Baseline Surveys (Modules 1-4)", "Survey Response Ratio among Invited = All Baseline Surveys/Invited", 
            "Survey Response Ratio among Verified = All Baseline Surveys/ Verified", "Survey Completion per week", 
            "Cumulative Incentive Eligible", "Incentive Eligible Response Ratio among Invited = Incentive Eligible/ Invited", 
            "Incentive Eligible Response Ratio among Verified = Incentive Eligible/ Verified", "Incentive Eligible  per week ", 
            "Cumulative Completed All Participant Study Activities", "Completed All Participant Study Activity Response Ratio among Invited = Completed All Activities/ Invited", 
            "Completed All Participant Study Activity Response Ratio among Verified = Completed All Activities/ Verified", 
            "Completed all Participant Study Activities per week",
            "Cumulative Withdrawals", "Withdrawal/ Verfied", "Withdrawals per week ", "Cumulative Data Destruction", "Data Destruction/ Verified", 
            "Data Destruction per week", "Available for Analysis (Verified - Data Destruction)", "Available for Follow-up (Verified - Withdrawals)")

base <- recr_veri_wk[,c("recruit.week", "Week.Starting", "Week.Ending","week.day")] #"Cumulative Revocations", "Revocation/ Verified", "Revocations per week", 
#colnames(base)[2] <- "week.date"
for (v in 1:length(var.select)){
  base$x <- recr_veri_wk[,var.select[v]]
  colnames(base)[v+4] <- labels[v]
}

##Mar. 27, 2023, as Amelia 
box_auth(client_id = client,
         client_secret = passwd)
box_setwd(dir_id = 200244295811)

box_write(object = base[which(base$Week.Starting!=currentDate),], file_name =paste("CCC_metrics_weekly_log_labels_",currentDate,".csv",sep=""),na="",row.names=F)

#write.csv(base,paste("~/Documents/CONNECT_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/CCC_metrics_weekly_log_labels_",currentDate,".csv",sep=""),na="",row.names=F)

#write.csv(base,"~/Documents/CONNECT_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/CCC_metrics_weekly_log_labels_03062023.csv",na.rm="",row.names=F)
###by site
veri_act <- apply_labels(veri_act,d_827220437 = "Site",#RcrtES_Site_v1r0
                         d_827220437 = c("HealthPartners"= 531629870, "Henry Ford Health System"=548392715, "Kaiser Permanente Colorado" = 125001209,
                                         "Kaiser Permanente Georgia" = 327912200,"Kaiser Permanente Hawaii" = 300267574,"Kaiser Permanente Northwest" = 452412599,
                                         "Marshfield Clinic Health System" = 303349821,"Sanford Health" = 657167265, "University of Chicago Medicine" = 809703864,
                                         "National Cancer Institute" = 517700004,"National Cancer Institute" = 13,"Other" = 181769837))

veri_act$site <- factor(veri_act$d_827220437,exclude=NULL,
                        levels=c("HealthPartners", "Henry Ford Health System","Marshfield Clinic Health System",
                                 "Sanford Health", "University of Chicago Medicine","Kaiser Permanente Colorado",
                                 "Kaiser Permanente Georgia","Kaiser Permanente Hawaii","Kaiser Permanente Northwest",
                                 "National Cancer Institute","Other"))

recruit.wk.active.site <- veri_resp[which(veri_resp$d_512820379==486306141),] %>% arrange(site,recruit.week) %>%
  group_by(site,recruit.week,recruit.week.date) %>%
  dplyr::summarize(active_recruits=n(),
                   recruitdate_max=max(recru_time,rm.na=T))

verified.wk.active.site <- veri_resp[which(veri_resp$d_821247024 == 197316935 & veri_resp$d_512820379==486306141),] %>% 
  arrange(site,verified.week) %>% group_by(site,verified.week,verified.week.date) %>%
  dplyr::summarize(active_verifieds=n(),
                   verified_activetime.max=max(verified_time,rm.na=T))

verified.wk.total.site <- veri_resp[which(veri_resp$d_821247024 == 197316935),] %>% arrange(site,verified.week) %>% 
  group_by(site,verified.week,verified.week.date) %>%
  dplyr::summarize(total_verifieds=n(),
                   verified_time.max=max(verified_time,rm.na=T))

verified.all.site <- merge(verified.wk.total.site,verified.wk.active.site, by.x=c("site","verified.week","verified.week.date"), by.y=c("site","verified.week","verified.week.date"),all.y=TRUE,all.x=TRUE)
recrui_wk_verified.site <- merge(recruit.wk.active.site,verified.all.site, by.x=c("site","recruit.week","recruit.week.date"),by.y=c("site","verified.week","verified.week.date"),all.y=TRUE,all.x=TRUE)
recrui_wk_verified.site <- recrui_wk_verified.site %>% mutate_at(c("active_recruits","active_verifieds","total_verifieds"),~replace_na(., 0))

recrui_wk_verified.site <- recrui_wk_verified.site %>% 
  mutate(passive_verifieds = total_verifieds-active_verifieds,
         total_recruits = total_verifieds + active_recruits - active_verifieds)

###verified group
eligible.wk.total.site <- veri_resp[which(veri_resp$d_821247024 == 197316935 & veri_resp$d_130371375_d_266600170_d_731498909 ==353358909 ),] %>% 
  group_by(site,eligible.week) %>%
  dplyr::summarize(total_eligible=n(),
                   eligible.time.max=max(elgible.time,rm.na=T))

module.wk.total.site <- filter(veri_act,d_100767870==353358909) %>% arrange(site,module.week,verified.week)  %>%
  group_by(site,module.week)%>%
  dplyr::summarize(total_module=n(),
                   module.time.max=max(as_date(module.time),rm.na=T))

anybio.wk.total.site <- filter(veri_act,biospeDonation!= "No Sample Donations") %>% arrange(site,anybio.week,verified.week) %>% 
  group_by(site,anybio.week)%>%
  dplyr::summarize(total_anybio=n(),
                   anybio.time.max=max(bioany.time,rm.na=T))


biocol.wk.total.site <- filter(veri_act, (biospeDonation =="Completed All 3 Sample Donations" | 
                                       (d_173836415_d_266600170_d_592099155==664882224 & d_878865966 == 353358909 & d_167958071 == 353358909)))%>% 
  arrange(site,biocol.week,verified.week) %>% 
  group_by(site,biocol.week)%>%
  dplyr::summarize(total_biocol=n(),
                   biocol.time.max=max(biocol.time,rm.na=T))

allacts.wk.total.site <- filter(veri_act,allacts==353358909) %>% arrange(site,allacts.week,verified.week) %>% 
  group_by(site,allacts.week)%>%
  dplyr::summarize(total_allacts=n(),
                   allacts.time.max=max(allacts.time,rm.na=T))
#revoke.wk.total <- veri_act[which(veri_act$HIPAARevVer  ==353358909 ),] %>% 
#  group_by(revoke.week) %>%
#  dplyr::summarize(total_revoke=n())

dtdestroy.wk.total.site <- filter(veri_act,DestroyDataVer ==353358909) %>% arrange(site,dtdestroy.week) %>% 
  group_by(site,dtdestroy.week)%>%
  dplyr::summarize(total_dtdestroy=n())

wdconsent.wk.total.site <- filter(veri_act,WdConsentVer ==353358909 & !is.na(wdconsent.week)) %>% arrange(site,wdconsent.week) %>% 
  group_by(site,wdconsent.week)%>%
  dplyr::summarize(total_wdconsent=n())


veri_wk_eligble.site <- merge(verified.wk.total.site, eligible.wk.total.site,by.x=c("site","verified.week"),by=c("site","eligible.week"), all.x=TRUE,all.y=TRUE)
veri_wk_eligble.site <- merge(veri_wk_eligble.site, module.wk.total.site,by.x=c("site","verified.week"),by=c("site","module.week"), all.x=TRUE,all.y=TRUE)
veri_wk_eligble.site <- merge(veri_wk_eligble.site,anybio.wk.total.site,by.x=c("site","verified.week"),by=c("site","anybio.week"), all.x=TRUE,all.y=TRUE)
veri_wk_eligble.site <- merge(veri_wk_eligble.site, biocol.wk.total.site,by.x=c("site","verified.week"),by=c("site","biocol.week"), all.x=TRUE,all.y=TRUE)
veri_wk_eligble.site <- merge(veri_wk_eligble.site, dtdestroy.wk.total.site,by.x=c("site","verified.week"),by=c("site","dtdestroy.week"), all.x=TRUE,all.y=TRUE)
veri_wk_eligble.site <- merge(veri_wk_eligble.site, wdconsent.wk.total.site,by.x=c("site","verified.week"),by=c("site","wdconsent.week"), all.x=TRUE,all.y=TRUE)
veri_wk_eligble.site <- merge(veri_wk_eligble.site, allacts.wk.total.site,by.x=c("site","verified.week"),by=c("site","allacts.week"), all.x=TRUE,all.y=TRUE)

#veri_wk_eligble.site <- veri_wk_eligble.site %>% mutate_at(vars(matches("total")),~replace_na(., 0))

recr_veri_wk.site <-  merge(recrui_wk_verified.site,veri_wk_eligble.site, by.x=c("site","recruit.week", "verified_time.max","total_verifieds"),by.y=c("site","verified.week", "verified_time.max","total_verifieds"),all.x=TRUE,all.y=TRUE)

vars0 <- c("active_recruits","active_verifieds","passive_verifieds", "total_recruits","total_verifieds","total_module",
          "total_anybio","total_eligible","total_biocol","total_dtdestroy","total_wdconsent","total_allacts")


recr_veri_wk.site <- recr_veri_wk.site %>% mutate_at(vars0,~replace_na(., 0))
#recr_veri_wk.site <- recr_veri_wk.site %>% mutate_at(c("active_recruits","active_verifieds","passive_verifieds"),~replace_na(., 0))
recr_veri_wk.site$recruit.week.date <- as_date(ifelse(is.na(recr_veri_wk.site$recruit.week.date), recrstart.date + days(2)+dweeks(recr_veri_wk.site$recruit.week-1),recr_veri_wk.site$recruit.week.date))
recr_veri_wk.site$Week.Starting <- recr_veri_wk.site$recruit.week.date - days(6)
recr_veri_wk.site$week.day <- wday(recr_veri_wk.site$Week.Starting,label=TRUE,abbr=F)
recr_veri_wk.site$Week.Ending <- recr_veri_wk.site$recruit.week.date

site_recruit_verified <- list()
site <- levels(droplevels(recr_veri_wk.site$site))
for(i in 1:length(site)){
  s = site[i]
  subs.recrui_verified <- filter(recr_veri_wk.site,site==s)
  #subs.recrui_verified[is.na(subs.recrui_verified)] = 0
  
  subs.recrui_verified <- subs.recrui_verified %>% arrange(recruit.week,recruit.week.date)
  subs.recrui_verified$active_verifieds.cum <- cumsum(subs.recrui_verified$active_verifieds)
  subs.recrui_verified$passive_verifieds.cum <- cumsum(subs.recrui_verified$total_verifieds-subs.recrui_verified$active_verifieds)
  subs.recrui_verified$cum.total_verifieds <- cumsum(subs.recrui_verified$total_verifieds)
  subs.recrui_verified$active_recruits.cum <- cumsum(subs.recrui_verified$active_recruits)
  subs.recrui_verified$total_recruits.cum <- cumsum(subs.recrui_verified$active_recruits + subs.recrui_verified$passive_verifieds)
  
  subs.recrui_verified$new.active.response.rate <- 100*(subs.recrui_verified$active_verifieds/subs.recrui_verified$active_recruits)
  subs.recrui_verified$new.passive.response.rate <- 100*(subs.recrui_verified$passive_verifieds/subs.recrui_verified$active_recruits)
  subs.recrui_verified$new.total.response.rate <- 100*(subs.recrui_verified$total_verifieds/subs.recrui_verified$active_recruits)
  
  subs.recrui_verified$cum.active.response.rate <- 100*(cumsum(subs.recrui_verified$active_verifieds)/cumsum(subs.recrui_verified$active_recruits))
  subs.recrui_verified$cum.passive.response.rate <- 100*(cumsum(subs.recrui_verified$passive_verifieds)/cumsum(subs.recrui_verified$active_recruits))
  subs.recrui_verified$cum.total.response.rate <- 100*(cumsum(subs.recrui_verified$total_verifieds)/cumsum(subs.recrui_verified$active_recruits))
  
  
  subs.recr_veri_wk <- subs.recrui_verified %>% arrange(recruit.week)%>% 
    mutate(total_anybio.cum=cumsum(total_anybio),
           anybio.invite.ratio=100*cumsum(total_anybio)/active_recruits.cum,
           anybio.verified.ratio=100*cumsum(total_anybio)/cum.total_verifieds,
           total_module.cum=cumsum(total_module),
           module.invite.ratio=100*cumsum(total_module)/active_recruits.cum,
           module.verified.ratio=100*cumsum(total_module)/cum.total_verifieds,
           
           total_eligible.cum=cumsum(total_eligible),
           eligible.invite.ratio=100*cumsum(total_eligible)/active_recruits.cum,
           eligible.verified.ratio=100*cumsum(total_eligible)/cum.total_verifieds,
           total_allacts.cum=cumsum(total_allacts),
           allacts.verified.ratio=100*cumsum(total_allacts)/cum.total_verifieds,
           allacts.invite.ratio=100*cumsum(total_allacts)/active_recruits.cum,
           
           total_dtdestroy.cum=cumsum(total_dtdestroy),
           dtdestroy.invite.ratio=100*cumsum(total_dtdestroy)/active_recruits.cum,
           dtdestroy.verified.ratio=100*cumsum(total_dtdestroy)/cum.total_verifieds,
           total_wdconsent.cum=cumsum(total_wdconsent),
           wdconsent.verifed.ratio=100*cumsum(total_wdconsent)/cum.total_verifieds,
           wdconsent.invite.ratio=100*cumsum(total_wdconsent)/active_recruits.cum,
           total_analysis=cumsum(total_verifieds)-cumsum(total_dtdestroy),
           total_followup=cumsum(total_verifieds)-cumsum(total_wdconsent),
           total_biocol.cum=cumsum(total_biocol),
           biocol.invite.ratio=100*cumsum(total_biocol)/active_recruits.cum,
           biocol.verified.ratio=100*cumsum(total_biocol)/cum.total_verifieds)
  #var.list <- c("eligible","module","biocol","allacts","dtdestroy","wdconsent")
  var.select <- c(  "active_recruits.cum", "passive_verifieds.cum", "cum.total_verifieds", "cum.total.response.rate", 
                    "active_recruits", "total_verifieds", "total_anybio.cum", "anybio.invite.ratio", "anybio.verified.ratio", "total_anybio", 
                    "total_module.cum", "module.invite.ratio", "module.verified.ratio", "total_module", "total_eligible.cum", "eligible.invite.ratio",
                    "eligible.verified.ratio", "total_eligible", "total_allacts.cum", "allacts.invite.ratio", "allacts.verified.ratio", "total_allacts", 
                    "total_wdconsent.cum", "wdconsent.verifed.ratio", "total_wdconsent", "total_dtdestroy.cum", "dtdestroy.verified.ratio", "total_dtdestroy", 
                    "total_analysis", "total_followup")
  labels <- c("Cumulative Invitations", "Cumulative Passive Verified Participants", "Cumulative Verified Participants", 
              "Response Ratio = Verfication/ Invitations", "Invitations per week", "Verifications per week", 
              "Cumulative Specimens defined as any baseline blood or urine or mouthwash collected", 
              "Specimen Response Ratio among Invited = Specimens/ Invited", "Specimen Response Ratio among Verified = Specimens/ Verified", 
              "Specimens collected per week", "Cumulative All Baseline Surveys (Modules 1-4)", "Survey Response Ratio among Invited = All Baseline Surveys/Invited", 
              "Survey Response Ratio among Verified = All Baseline Surveys/ Verified", "Survey Completion per week", 
              "Cumulative Incentive Eligible", "Incentive Eligible Response Ratio among Invited = Incentive Eligible/ Invited", 
              "Incentive Eligible Response Ratio among Verified = Incentive Eligible/ Verified", "Incentive Eligible  per week ", 
              "Cumulative Completed All Participant Study Activities", "Completed All Participant Study Activity Response Ratio among Invited = Completed All Activities/ Invited", 
              "Completed All Participant Study Activity Response Ratio among Verified = Completed All Activities/ Verified", 
              "Completed all Participant Study Activities per week",
              "Cumulative Withdrawals", "Withdrawal/ Verfied", "Withdrawals per week ", "Cumulative Data Destruction", "Data Destruction/ Verified", 
              "Data Destruction per week", "Available for Analysis (Verified - Data Destruction)", "Available for Follow-up (Verified - Withdrawals)")
  
  sub.base <- subs.recr_veri_wk[,c("site","recruit.week", "Week.Starting", "Week.Ending", "week.day")] #"Cumulative Revocations", "Revocation/ Verified", "Revocations per week", 
  #colnames(sub.base)[3] <- "Week Date"
  for (v in 1:length(var.select)){
    sub.base$x <- subs.recr_veri_wk[,var.select[v]]
    colnames(sub.base)[v+5] <- labels[v]
  }
  
  #write.csv(sub.base[which(subs.recr_veri_wk$Week.Starting != currentDate),],paste("~/Documents/CONNECT_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/CCC_metrics_weekly_log_labels_",site[i],"03202023.csv", sep=""))
  #write.csv(sub.base[which(subs.recr_veri_wk$Week.Starting != currentDate),],paste("~/Documents/CONNECT_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/CCC_metrics_weekly_log_labels_",site[i],currentDate,".csv", sep=""),na="",row.names=F)
  
  box_write(object = sub.base[which(sub.base$Week.Starting!=currentDate),], file_name =paste("CCC_metrics_weekly_log_labels_",site[i],currentDate,".csv",sep=""),na="",row.names=F)
  
  site_recruit_verified[[i]] <- subs.recr_veri_wk
  #write.csv(subs.recr_veri_wk,paste("~/Documents/CONNECT_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/CCC_metrics_weekly_log",site[i],"03202023.csv", sep=""))
  #write.csv(subs.recr_veri_wk,paste("~/Documents/CONNECT_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/CCC_metrics_weekly_log",site[i],currentDate,".csv", sep=""),na="",row.names=F)
  
}  

###based on Mia and Michelle's requests on the variable nomes and their order consistent with the spreadsheet, this part program is to make the variables
###as requested with labels and order


###All study activities: as submitted survey modules 1-4, and for all non-KP sites collected blood (any), urine and mouthwash; and for KP sites collected blood (any) and urine
