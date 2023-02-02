###this R program is to do the biospecimen metrics for both Clinical and Research Biospecimen check #########
####the template data are used from three parts downloaded from GCP stage: biospecimen, boxes and reruitment biospecimen part
####the recruitment biospeicmen part mostly had unique summary info. of the biospecimen collections from each verified participant and biospecimen survey completions 
####the flat biospecimen data is recorded as every tube and visit of biospecimen collections of participants in all available biospecimen
####collection visit, therefore, some participant could have replicate entries of biospecimen in each visit identified by their visit time
####boxed data is the biospecimen shipping info. by tube IDs
###the master dd: json file is the dictionary for check the labels/variable names of each CID
#####################
rm(list = ls())
library(bigrquery) ###to download data from GCP
library(data.table) ###to write or read and data management 
library(boxr) ###read or write data from/to box
library(tidyverse) ###for data management
library(dplyr) ###data management
library(reshape)  ###to work on transition from long to wide or wide to long data
library(listr) ###to work on a list of vector, files or..
library(sqldf) ##sql
library(lubridate) ###date time
library(ggplot2) ###plots
library(ggpubr) ###for the publications of plots
library(RColorBrewer) ###visions color http://www.sthda.com/english/wiki/colors-in-r
library(gridExtra)
library(stringr) ###to work on patterns, charaters
library(plyr)
library(rmarkdown) ###for the output tables into other files: pdf, rtf, etc.
library(sas7bdat) ###input data
library(finalfit) #https://cran.r-project.org/web/packages/finalfit/vignettes/export.html t
library(expss) ###to add labels
library(epiDisplay) ##recommended applied here crosstable, tab1
library(summarytools) ##recommended
library(gmodels) ##recommended
library(rlist)
library(gtsummary)
library(kableExtra)

#library(labelled)
##import data to R
bq_auth()
project <- "nih-nci-dceg-connect-prod-6d04"
billing <- "nih-nci-dceg-connect-prod-6d04" ##project and billing should be consistent

sche_bio <- bq_project_query(project, query="SELECT * FROM `nih-nci-dceg-connect-prod-6d04.Connect`.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS WHERE table_name='biospecimen'")
bioschm <- bq_table_download(sche_bio,bigint="integer64")
bioschm1 <- bioschm[!grepl("_key_|error_", bioschm$field_path),]
bioschm1$flatvar <- ifelse(grepl("d_|D_",bioschm1$field_path), gsub(".d_","_d_",bioschm1$field_path),bioschm1$field_path)

bioschm_only <- bioschm1 %>% filter(substring(bioschm1$data_type,1,6)!="STRUCT"  & bioschm1$flatvar %nin% colnames(biospe)) #0
bioschm_common <- bioschm1 %>% filter(substring(bioschm1$data_type,1,6)!="STRUCT"  & bioschm1$flatvar %in% colnames(biospe)) #0

biospe_only <- colnames(biospe)[which(colnames(biospe) %nin% bioschm_common$flatvar)]
colnames(biospe)[which(colnames(biospe) %nin% bioschm_common$flatvar)]
# [1] "d_139245758"             "d_198261154"             "d_210921343"             "d_224596428"            
# [5] "d_232343615_d_536710547" "d_341570479"             "d_376960806_d_536710547" "d_398645039"            
# [9] "d_453452655"             "d_530173840"             "d_534041351"             "d_541311218"            
# [13] "d_611091485"             "d_683613884_d_825582494" "d_683613884_d_926457119" "d_693370086"            
# [17] "d_728696253"             "d_769615780"             "d_786930107"             "d_822274939"            
# [21] "d_860477844"             "d_939818935"             "d_958646668_d_536710547" "d_982213346"            
# [25] "date"            /01172023       

dd[grepl("139245758|198261154|210921343|224596428|341570479|398645039|453452655|530173840|534041351|541311218|611091485|693370086|728696253|769615780|786930107|822274939|860477844|d_939818935|982213346",dd$CID),c("CID","Variable Label")]
# CID                               Variable Label
# 1: 139245758           Date/time Clinical Urine Collected
# 2: 198261154             Sent Clinical Urine accession ID
# 3: 210921343               Clinical DB Urine RRL received
# 4: 224596428 Clinical Site Urine RRL Date / Time Received
# 5: 341570479             Sent Clinical Blood accession ID
# 6: 398645039     Clinical DB blood RRL Date/Time Received
# 7: 453452655             Clinical Site Urine RRL Received
# 8: 530173840                           Blood Order Placed
# 9: 534041351               Clinical DB Blood RRL Received
# 10: 541311218     Clinical DB urine RRL Date/Time received
# 11: 693370086                Clinical Site Blood Collected
# 12: 728696253             Clinical_Site Blood RRL Received
# 13: 769615780                 Date/Time Blood Order Placed
# 14: 786930107                Clinical_Site Urine Collected
# 15: 822274939 Clinical Site Blood RRL Date / Time Received
# 16: 860477844                           Urine Order Placed
# 17: 982213346           Date/time Clinical Blood Collected

biovar[grepl("139245758|198261154|210921343|224596428|341570479|398645039|453452655|530173840|534041351|541311218|611091485|693370086|728696253|769615780|786930107|822274939|860477844|d_939818935|982213346",biovar)]
# [1] "d_173836415_d_266600170_d_139245758" "d_173836415_d_266600170_d_198261154" "d_173836415_d_266600170_d_210921343"
# [4] "d_173836415_d_266600170_d_224596428" "d_173836415_d_266600170_d_341570479" "d_173836415_d_266600170_d_398645039"
# [7] "d_173836415_d_266600170_d_453452655" "d_173836415_d_266600170_d_530173840" "d_173836415_d_266600170_d_534041351"
# [10] "d_173836415_d_266600170_d_541311218" "d_173836415_d_266600170_d_693370086" "d_173836415_d_266600170_d_728696253"
# [13] "d_173836415_d_266600170_d_769615780" "d_173836415_d_266600170_d_786930107" "d_173836415_d_266600170_d_822274939"
# [16] "d_173836415_d_266600170_d_860477844" "d_173836415_d_266600170_d_939818935" "d_173836415_d_266600170_d_982213346"
##most biospecim only variables (only shown in the flat biospecimen table ) should be in the recruitment table. 
dupid <- length(recr.bio[duplicated(recr.bio$Connect_ID),"Connect_ID"]) #nodup

#bio_tb <- bq_project_query(project, query="SELECT * FROM `nih-nci-dceg-connect-prod-6d04.Biospecimens.flatBiospecimen_JP`") #before 01/05/2023
bio_tb <- bq_project_query(project, query="SELECT * FROM `nih-nci-dceg-connect-prod-6d04.FlatConnect.biospecimen_JP`") # starting 01/09/2023

biospe <- bq_table_download(bio_tb,bigint="integer64")


bio_tb <- bq_project_query(project, query="SELECT Connect_ID, token, d_recrvar.bio$column_name FROM `nih-nci-dceg-connect-prod-6d04.FlatConnect.biospecimen_JP`") # starting 01/09/2023

#tb_box <- bq_project_query(project, query="SELECT * FROM `nih-nci-dceg-connect-prod-6d04.Biospecimens.flatBoxes_WL`")#before 01/05/2023
tb_box <- bq_project_query(project, query="SELECT * FROM `nih-nci-dceg-connect-prod-6d04.FlatConnect.boxes_JP`")#after 01/09/2023
box_wl_flat <- bigrquery::bq_table_download(tb_box,bigint = "integer64")

urlfile<- "https://github.com/episphere/conceptGithubActions/raw/master/csv/masterFile.csv" ###to grab the updated dd from github
y <- read.csv(urlfile)

library(rio)
dictionary <- rio::import("https://episphere.github.io/conceptGithubActions/aggregate.json",format = "json")
dd<-rbindlist(dictionary,fill=TRUE,use.names=TRUE,idcol="CID")

box_CID <- as.data.frame(as.numeric(sapply((strsplit(colnames(box_wl_flat),"d_")),tail,1)))
box_CID$variable <- colnames(box_wl_flat)
colnames(box_CID)[1] <-"CID"

box_CID_dd <- merge(box_CID, dd,by="CID",all.x=TRUE)

numbers_only <- function(x) !grepl("\\D", x)
cnames <- names(box_wl_flat)
###to check variables in recr_noinact_wl1
data2 <- box_wl_flat
for (i in 1: length(cnames)){
  varname <- cnames[i]
  var<-pull(data2,varname)
  data2[,cnames[i]] <- ifelse(numbers_only(var), as.numeric(as.character(var)), var)
}

write.csv(biospe,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_biospecimen_12022022.csv",row.names = F,na="")
#1032
write.csv(data2,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_flatBoxes_WL_12022022.csv",row.names = F,na="")
#6752

write.csv(biospe,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_biospecimen_12192022.csv",row.names = F,na="")
#1172
write.csv(data1,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_flatBoxes_WL_12192022.csv",row.names = F,na="")
#7805
write.csv(biospe,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_biospecimen_01032023.csv",row.names = F,na="")
#1172
write.csv(data1,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_flatBoxes_WL_01032023.csv",row.names = F,na="")

write.csv(biospe,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_biospecimen_01092023.csv",row.names = F,na="")
#1251
write.csv(data2,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_flatBoxes_WL_01092023.csv",row.names = F,na="")
#8320

dd[grepl("561681068",CID),]

biovar <- c("d_512820379","d_512820379", "d_821247024", "d_914594314", "d_822499427", "d_222161762", "Connect_ID", "d_827220437", "token",
         "d_265193023", "d_878865966", "d_167958071", "d_684635302", "d_253883960", "d_534669573", "d_764863765",  
          "d_331584571_d_266600170_d_135591", "d_331584571_d_266600170_d_840048", "d_331584571_d_266600170_d_343048", 
          "d_173836415_d_266600170_d_448660", "d_173836415_d_266600170_d_561681", "d_173836415_d_266600170_d_847159", 
          "d_173836415_d_266600170_d_592099", "d_173836415_d_266600170_d_718172", "d_173836415_d_266600170_d_915179", 
          "d_173836415_d_266600170_d_534041", "d_173836415_d_266600170_d_693370", "d_173836415_d_266600170_d_210921", 
          "d_173836415_d_266600170_d_786930", "d_173836415_d_266600170_d_139245", "d_173836415_d_266600170_d_453452", 
          "d_173836415_d_266600170_d_530173", "d_173836415_d_266600170_d_198261", "d_173836415_d_266600170_d_224596", 
          "d_173836415_d_266600170_d_341570", "d_173836415_d_266600170_d_398645", "d_173836415_d_266600170_d_452847", 
          "d_173836415_d_266600170_d_541311", "d_173836415_d_266600170_d_728696", "d_173836415_d_266600170_d_769615", 
          "d_173836415_d_266600170_d_822274", "d_173836415_d_266600170_d_860477", "d_173836415_d_266600170_d_939818", 
          "d_173836415_d_266600170_d_982213")


tb <- bq_project_query(project, query="SELECT d_512820379,d_821247024, d_914594314, d_822499427, d_222161762, Connect_ID, d_827220437, token,
d_265193023, d_878865966, d_167958071, d_684635302, d_253883960, d_534669573, d_764863765, d_331584571_d_266600170_d_135591601,  
d_331584571_d_266600170_d_840048338, d_331584571_d_266600170_d_343048998, d_173836415_d_266600170_d_139245758, d_173836415_d_266600170_d_185243482,
d_173836415_d_266600170_d_198261154, d_173836415_d_266600170_d_210921343, d_173836415_d_266600170_d_224596428,
d_173836415_d_266600170_d_316824786, d_173836415_d_266600170_d_341570479, d_173836415_d_266600170_d_398645039,
d_173836415_d_266600170_d_448660695, d_173836415_d_266600170_d_452847912, d_173836415_d_266600170_d_453452655,
d_173836415_d_266600170_d_530173840, d_173836415_d_266600170_d_534041351, d_173836415_d_266600170_d_541311218,
d_173836415_d_266600170_d_561681068, d_173836415_d_266600170_d_592099155, d_173836415_d_266600170_d_611091485,
d_173836415_d_266600170_d_646899796, d_173836415_d_266600170_d_693370086, d_173836415_d_266600170_d_718172863,
d_173836415_d_266600170_d_728696253, d_173836415_d_266600170_d_740582332, d_173836415_d_266600170_d_769615780,
d_173836415_d_266600170_d_786930107, d_173836415_d_266600170_d_822274939, d_173836415_d_266600170_d_847159717,
d_173836415_d_266600170_d_860477844, d_173836415_d_266600170_d_915179629, d_173836415_d_266600170_d_939818935,
d_173836415_d_266600170_d_951355211, d_173836415_d_266600170_d_982213346 FROM `nih-nci-dceg-connect-prod-6d04.FlatConnect.participants_JP` 
                       WHERE d_821247024 = '197316935'")
recr.bio <- bq_table_download(tb,bigint="integer64")
cnames <- names(recr.bio)
###to check variables in recr_noinact_wl1
recrver <- recr.bio
for (i in 1: length(cnames)){
  varname <- cnames[i]
  var<-pull(recrver,varname)
  recrver[,cnames[i]] <- ifelse(numbers_only(var), as.numeric(as.character(var)), var)
}


currentDate <- Sys.Date()
write.csv(recr.bio,paste("~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/Connect_prod_recr_veriBiospe_",currentDate,".csv",sep=""),row.names = F,na="")


#recrver <- read.sas7bdat("~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_recrverified_bio_09262022.sas7bdat")
recrver <- read.csv("~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/Connect_stg_recr_veriBiospe_11082022.csv",header=T)
names(recrver)
# d_512820379	as	RcrtSI_RecruitType_v1r0,
# d_821247024	as 	RcrtV_Verification_v1r0, 
# d_914594314	as	RcrtV_VerificationTm_V1R0,
# d_822499427	as	SrvBLM_TmStart_v1r0, /*Date/time Status of Start of blood/urine/mouthwash research survey*/
#   d_222161762	as	SrvBLM_TmComplete_v1r0,	/*Date/Time blood/urine/mouthwash research survey completed*/
#   studyId	as	studyId,
# Connect_ID	as	Connect_ID, 
# d_827220437 as	RcrtES_Site_v1r0,
# d_265193023	as	SrvBLM_ResSrvCompl_v1r0, /*Blood/urine/mouthwash combined research survey*/
#   d_878865966	as	BioFin_BaseBloodCol_v1r0, /*Baseline Blood Collected*/
#   d_167958071	as	BioFin_BaseUrineCol_v1r0, /*Baseline Urine collected*/
#   d_684635302	as	BioFin_BaseMouthCol_v1r0, /*	Baseline MW Collected*/
#   d_331584571_d_266600170_d_135591	as	BL_BioChk_Complete_v1r0, /*Baseline Check in complete*/
#   d_331584571_d_266600170_d_840048	as	BL_BioChk_Time_v1r0, /*Autogenerated date/time baseline check in complete*/  
#   d_331584571_d_266600170_d_343048	as	BL_BioFin_CheckOutTime_v1r0, /*Autogenerated date/time baseline check out complete*/
#   d_173836415_d_266600170_d_448660	as	BL_BioFin_BMTime_v1r0, /*Autogenerated date/time baseline MW collected*/ 
#   d_173836415_d_266600170_d_561681	as	BL_BioFin_BBTime_v1r0, /*Autogenerated date/time baseline blood collected*/
#   d_173836415_d_266600170_d_847159	as	BL_BioFin_BUTime_v1r0, /*Autogenerated date/time baseline urine collected updated in Warren's code*/
# d_173836415_d_266600170_d_592099	as	BL_BioSpm_BloodSetting_v1r0, /*Blood Collection Setting*/
# d_173836415_d_266600170_d_718172	as	BL_BioSpm_UrineSetting_v1r0, /*Urine Collection Setting*/
# d_173836415_d_266600170_d_915179	as	BL_BioSpm_MWSetting_v1r0/*, Mouthwash Collection Setting*/


names(recrver)
recrver_CID <- as.data.frame(sapply((strsplit(colnames(recrver),"d_")),tail,1))
colnames(recrver_CID)[1] <- "CID"
recrver_CID$variable <- names(recr.bio)
recrver_CID[which(!(recrver_CID$CID %in% dd$CID)),] 
# "Connect_ID" "token"      "studyId"    "611091485" 
recrver_ver <- dd %>% filter(grepl(paste(recrver_CID[,1],collapse = "|"),dd$CID)) %>% mutate(CID == as.numeric() )

recrver_ver1 <- merge(dd,recrver_CID,by="CID")


recrver_CID <- substring(names(recrver),length())
recrver1 <- apply_labels(recrver,
                        d_512820379 = "Recruitment type",#RcrtSI_RecruitType_v1r0
                        d_512820379=c(	"Not active"=180583933,  
                                       "Active"= 486306141, 
                                       "Passive"=854703046),
                        d_821247024 = "Verification status",#RcrtV_Verification_v1r0
                        d_821247024 = c("Not yet verified" =875007964,
                                        "Verified"=197316935,  
                                        "Cannot be verified"=219863910, 
                                        "Duplicate"=922622075 , 
                                        "Outreach timed out"= 160161595),
                        d_827220437 = "Site",#RcrtES_Site_v1r0
                        d_827220437 = c("HealthPartners"= 531629870, "Henry Ford Health System"=548392715,"Marshfield Clinic Health System" = 303349821,
                                        "Sanford Health" = 657167265, "University of Chicago Medicine" = 809703864,
                                        "Kaiser Permanente Colorado" = 125001209,
                                        "Kaiser Permanente Georgia" = 327912200,"Kaiser Permanente Hawaii" = 300267574,"Kaiser Permanente Northwest" = 452412599,
                                        "National Cancer Institute" = 517700004,"National Cancer Institute" = 13,"Other" = 181769837),
                        d_914594314 = "Verification status time",#RcrtV_VerificationTm_V1R0
                        d_878865966 = "Baseline blood sample collected",#BioFin_BaseBloodCol_v1r0
                        d_878865966 = c( "No blood collected"=104430631, "Any blood collected"=353358909 ),
                        d_173836415_d_266600170_d_561681068 = "Date/time basline Research Blood Collected",#BL_BioFin_BBTime_v1r0
                        d_684635302 = "Baseline Mouthwash Collected",#BioFin_BaseMWCol_v1r0
                        d_684635302 = c( "No mouthwash collected"=104430631, "Any mouthwash collected"=353358909 ),
                        d_173836415_d_266600170_d_448660695 = "Date/time Mouthwash Collected", #
                        d_167958071 = "Baseline Urine Collected",#BioFin_BaseUrineCol_v1r0
                        d_167958071 = c( "No urine collected"=104430631, "Any urine collected"=353358909 ),
                        d_173836415_d_266600170_d_847159717 = "Baseline Date/time Urine Collected",
                        d_331584571_d_266600170_d_135591601 = "Baseline Check-In Complete",#BL_BioChk_Complete_v1r0
                        d_331584571_d_266600170_d_135591601 =  c( "No"=104430631, "Yes"=353358909 ),
                        d_331584571_d_266600170_d_840048338 = "Date/Time Baseline Check-In Complete",
                        d_331584571_d_266600170_d_343048998 = "Time Baseline check out complete",#
                        d_173836415_d_266600170_d_592099155 = "Blood Collection Setting",#BL_BioSpm_BloodSetting_v1r0
                        d_173836415_d_266600170_d_592099155 =c("Research"=534621077, "Clinical"= 664882224,"Home" =103209024),
                        d_173836415_d_266600170_d_718172863 = "Urine Collection Setting",#BL_BioSpm_UrineSetting_v1r0
                        d_173836415_d_266600170_d_718172863 =c("Research"=534621077, "Clinical"= 664882224,"Home" =103209024),
                        d_173836415_d_266600170_d_915179629 = "Mouthwash Collection Setting",#BL_BioSpm_MWSetting_v1r0
                        d_173836415_d_266600170_d_915179629 =c("Research"=534621077, "Clinical"= 664882224,"Home" =103209024),
                        
                        d_265193023 = "Blood/urine/mouthwash combined research survey-Complete",   
                        d_265193023 = c(	"Not Started" =	972455046, "Started"= 615768760,"Submitted"= 231311385),#SrvBLM_ResSrvCompl_v1r0
                        d_822499427 = "Placeholder (Autogenerated) - Date/time Status of Start of blood/urine/mouthwash research survey",#SrvBLM_TmStart_v1r0
                        d_222161762  = "Placeholder (Autogenerated)- Date/Time blood/urine/mouthwash research survey completed" #   SrvBLM_TmComplete_v1r0
)

###to convert to categorical variables
recrver1$RcrtSI_RecruitType_v1r0 <- factor(recrver1$d_512820379, exclude=NULL)
recrver1$RcrtV_Verification_v1r0 <- factor(recrver1$d_821247024, exclude=NULL)
recrver1$BioFin_BaseMWCol_v1r0  <-factor(recrver1$d_684635302,exclude=NULL)
recrver1$BioFin_BaseBloodCol_v1r0 <- factor(recrver1$d_878865966,exclude=NULL)
recrver1$BioFin_BaseUrineCol_v1r0 <- factor(recrver1$d_167958071,exclude=NULL)
recrver1$SrvBLM_ResSrvCompl_v1r0 <-factor(recrver1$d_265193023,exclude=NULL)
recrver1$BL_BioSpm_MWSetting_v1r0 <- factor(recrver1$d_173836415_d_266600170_d_915179,exclude=NULL,levels=c("Clinical","Home","Research"))
recrver1$BL_BioSpm_UrineSetting_v1r0 <- factor(recrver1$d_173836415_d_266600170_d_718172, exclude=NULL,levels=c("Clinical","Home","Research"))
recrver1$BL_BioSpm_BloodSetting_v1r0 <- factor(recrver1$d_173836415_d_266600170_d_592099,exclude=NULL,levels=c("Clinical","Home","Research"))
recrver1$BL_BioChk_Complete_v1r0 <- factor(recrver1$d_331584571_d_266600170_d_135591,exclude=NULL)
recrver1$RcrtES_Site_v1r0 <- factor(recrver1$d_827220437, exclude = NULL) 
recrver1<- recrver1 %>% mutate(BldCollection = ifelse(recrver1$BioFin_BaseBloodCol_v1r0 == 353358909, "YES", "No"))

#biospe <- read.csv("~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_biospecimen_10172022.csv",header = T)
###requested from Michelle to check the biospeimen data today Nov. 28, 2022
#biospe <- read.csv("~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/Connect_stg_flatBiospecimen_JP_11082022.csv",header = T)

##to check the duplicate collection by verified participants Connect_ID

biospe[duplicated(biospe$Connect_ID),c("Connect_ID","d_820476880","d_410912345","d_387108065")]
biospe[duplicated(biospe$Connect_ID),"Connect_ID"]
#[1] 4289925849 7154937817 2699722546
# Connect_ID
# <int64>
#   1 2513005250
# 2 2699722546
# 3 4289925849
# 4 7154937817
# 5 8087190864
biospe$Connect_ID[duplicated(biospe$Connect_ID)]
#integer64
#[1] 2513005250 2699722546 4289925849 7154937817 8087190864 #5
#[1] 1219400073 1397465779 2310991421 2513005250 2699722546 4289925849 7154937817 8087190864 #8 01/17/2023
dupid <- biospe$Connect_ID[duplicated(biospe$Connect_ID)]
#1219400073 2310991421 2513005250 2699722546 4289925849 7154937817 8087190864
##d_387108065	as BioSpm_ColIDEntered_v1r0,/*"Collection ID Manually Entered"*/
##d_410912345	as BioRec_CollectFinal_v1r0,/* "Collection Entry Finalized"*/
biospe[which(biospe$Connect_ID %in% dupid),c("Connect_ID","d_820476880","d_410912345","d_387108065","d_143615646_d_593843561","d_973670172_d_593843561")]
# Connect_ID d_820476880 d_410912345 d_387108065 d_143615646_d_593843561 d_973670172_d_593843561 #stg data 11/08/2022
# 6  2055639272   CXA000162   353358909   104430631               104430631               353358909
# 7  2055639272   CXA123448   353358909   353358909               104430631               104430631
# 8  2055639272   CXA123457   353358909   353358909               353358909               353358909
# 9  2055639272   CXA213456   353358909   353358909               353358909               353358909
# 10 2055639272   CXA613456   353358909   353358909               353358909               353358909
# 24 3654414289   CXA002227   353358909   104430631               353358909               353358909
# 25 3654414289   CXA000201   353358909   353358909               353358909               353358909
# 36 4467774615   CXA000157   353358909   104430631               353358909               353358909
# 37 4467774615   CXA123446   353358909   353358909               104430631               104430631
# 38 4467774615   CXA123456   353358909   353358909               353358909               353358909
# 39 4467774615   CXA113456   353358909   353358909               353358909               353358909
# 40 4467774615   CXA523456   353358909   353358909               353358909               353358909
# 52 5537363912   CXA123459   353358909   353358909               353358909               353358909
# 53 5537363912   CXA413456   353358909   353358909               353358909               353358909
# 54 5537363912   CXA813456   353358909   353358909               353358909               353358909
# 55 5537363912   CXA000172   353358909   104430631               353358909               353358909
# 61 6258863606   CXA000161   353358909   104430631               353358909               104430631
# 62 6258863606   CXA000171   353358909   104430631               104430631               104430631
# 63 6258863606   CXA123458   353358909   353358909               353358909               353358909
# 64 6258863606   CXA313456   353358909   353358909               353358909               353358909
# 65 6258863606   CXA713456   353358909   353358909               353358909               353358909
# 72 7574078898   CXA002701   353358909          NA                      NA               104430631
# 73 7574078898   CXA002699   353358909          NA                      NA               353358909
# 80 8261536089   CXA000202   353358909   104430631               353358909               104430631
# 81 8261536089   CXA002229   353358909   104430631               353358909               353358909
#the prod data:12/02/2022
# A tibble: 10 × 6
# Connect_ID d_820476880 d_410912345 d_387108065 d_143615646_d_593843561 d_973670172_d_593843561
# <int64> <chr>       <chr>       <chr>       <chr>                   <chr>                  
#   1 2513005250 CXA002354   353358909   104430631   353358909               353358909              
# 2 2513005250 CXA002350   353358909   104430631   104430631               104430631              
# 3 2699722546 CXA001813   NA          104430631   104430631               104430631              
# 4 2699722546 CXA001814   353358909   104430631   353358909               353358909              
# 5 4289925849 CXA001396   NA          104430631   104430631               104430631              
# 6 4289925849 CXA001434   353358909   104430631   353358909               353358909              
# 7 7154937817 CXA001444   NA          104430631   353358909               353358909              
# 8 7154937817 CXA001443   353358909   104430631   353358909               353358909              
# 9 8087190864 CXA002321   NA          104430631   104430631               104430631              
# 10 8087190864 CXA002336   353358909   104430631   353358909               353358909   
table(biospe$d_410912345, biospe$d_387108065)##353358909 411
##            104430631 353358909
##353358909       400        11

##the biospecimen concepts for the biospecimen variablesbles
biospe_var <- as.data.frame((colnames(biospe)))
colnames(biospe_var)[1] <- "variable"
biospe_var$cid1 <- sapply(strsplit(colnames(biospe),"_"), "[", 2)
biospe_var$cid2 <- sapply(strsplit(colnames(biospe),"_"), "[", 4)
biospe_var$cid3 <- sapply(strsplit(colnames(biospe),"_"), "[", 6)
biospe_var$cid_tail <- sapply(strsplit(colnames(biospe),"_"), tail,1)

CID <- unique(c(biospe_var$cid1,biospe_var$cid2,biospe_var$cid3))
biospe_CIDs <- list()
for (i in 1:length(CID)){
  ID <- CID[i]
  biospe_CIDs[[i]] <- dd[grepl(ID,dd$CID),]
  
}

biospe_dd<- merge(biospe_var,biospe_CID,by.x="cid_tail",by.y="CID")
biospe_CIDs1 <-  biospe_CIDs[sapply(biospe_CIDs, function(x) dim(x)[1])]
biospe_CID <- unique(as.data.frame(do.call('rbind',biospe_CIDs[sapply(biospe_CIDs, function(x) dim(x)[1]) >0])))

tubes <- dd[grepl(" Tube ",dd$`Variable Label`),]

urine <- dd[grepl("Urine",dd$`Variable Label`),]
mouthwash <- dd[grepl("Mouthwash",dd$`Variable Label`),]


#sapply((strsplit(colnames(recrver),"d_")),tail,1)

###table1 Percent (and number) of verified participants with baseline biospecimen collections by site
##for any biospecimen collections
recrver1 <- recrver1 %>% mutate(BiospeCollection = ifelse((recrver1$d_684635302 == 353358909 | recrver1$d_878865966 == 353358909 
                                                                   | recrver1$d_167958071 == 353358909), "Any biospecimen Collections","No biospecimen collections"))

Table1_biospecol <- recrver1 %>% dplyr::select(RcrtES_Site_v1r0, BiospeCollection )  %>% tbl_cross(
  row = RcrtES_Site_v1r0,
  col = BiospeCollection,
  percent = "row",
  label=list(RcrtES_Site_v1r0="Site",
             BiospeCollection = "Biospecimen Collections")) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label ~ "**Baseline Biospecimen Collections**") %>%
  modify_caption("**table1 Number (and percent) of verified participants with any baseline biospecimen collections by site**") %>%
  as_kable()


###Table 2 Percent (and number) of verified participants with baseline blood collected by site
Table2_bldcol <- recrver1 %>% dplyr::select(RcrtES_Site_v1r0, BioFin_BaseBloodCol_v1r0 )  %>% tbl_cross(
  row = RcrtES_Site_v1r0,
  col = BioFin_BaseBloodCol_v1r0,
  percent = "row",
  label=RcrtES_Site_v1r0~"Site") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label ~ "**Baseline Blood Collections**") %>%
  modify_caption("**Table 2. Percent (and number) of verified participants with baseline blood collected by site**") %>%
  as_kable()

###Table 3 Percent (and number) of verified participants with baseline urine collected by site
Table3_urincol <- recrver1 %>% dplyr::select(RcrtES_Site_v1r0, BioFin_BaseUrineCol_v1r0 )  %>% tbl_cross(
  row = RcrtES_Site_v1r0,
  col = BioFin_BaseUrineCol_v1r0,
  percent = "row",
  label=RcrtES_Site_v1r0~"Site") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label ~ "**Baseline Urine Collections**") %>%
  modify_caption("**Table 3. Percent (and number) of verified participants with baseline urine collected by site**") %>%
  as_kable()

##option 2 for table 3
recrver1 = apply_labels(recrver1,
                        RcrtES_Site_v1r0 = "Site",
                        BioFin_BaseUrineCol_v1r0 = "Baseline Urine collected"
)

table(recrver1$RcrtES_Site_v1r0)
explanatory = "RcrtES_Site_v1r0"
dependent = 'BioFin_BaseUrineCol_v1r0'
recrver1 %>%
  summary_factorlist(dependent, explanatory, 
                     p=FALSE, add_dependent_label=TRUE) -> t4

colnames(t4)[2] <- "Site"
t4_all <- merge(t4, t_site, by.x="Site",by.y="row.names",all.y=TRUE)
t4_all[1,c(3,4)] <- table(recrver1$BioFin_BaseUrineCol_v1r0)
t4_all1 <- t4_all[,-c(2,5:7)]

##Table 4

Table4_mwcol <- recrver1 %>% dplyr::select(RcrtES_Site_v1r0, BioFin_BaseMWCol_v1r0 )  %>% tbl_cross(
  row = RcrtES_Site_v1r0,
  col = BioFin_BaseMWCol_v1r0,
  percent = "row",
  label=RcrtES_Site_v1r0~"Site") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label ~ "**Baseline Mouthwash Collections**") %>%
  modify_caption("**Table 4. Percent (and number) of verified participants with baseline mouthwash collected by site**") %>%
  as_kable()


#otption 2
explanatory = "RcrtES_Site_v1r0"
dependent = 'BioFin_BaseMWCol_v1r0'
recrver1 = apply_labels(recrver1,
                        RcrtES_Site_v1r0 = "Site",
                        BioFin_BaseMWCol_v1r0 = "Baseline Mouthwash collected"
)
recrver1 %>%
  summary_factorlist(dependent, explanatory, 
                     p=FALSE, add_dependent_label=TRUE) -> t3
colnames(t3)[2] <- "Site"

t_site <- as.data.frame(tab1(recrver1$RcrtES_Site_v1r0)[[2]])
t_site$freq_pct <- paste0(t_site$Frequency," (",t_site$Percent, "%)")
t3_all <- merge(t3, t_site, by.x="Site",by.y="row.names",all.y=TRUE)
t3_all[1,c(3,4)] <- table(recrver1$BioFin_BaseMWCol_v1r0)
t3_all1 <- t3_all[,-c(2,5:7)]
colnames(t3_all1)[4] <- "Total"
#  t3$Site <- t3$Site %>% replace_na('Total')
#t3$'Any biospecimen Collected'[t3$'Any Mouthwash Collected' == ''] <- "0 (0.0)"

#Table 5.
blood <- as.data.frame(tab1(recrver1[which(recrver1$d_878865966==353358909),"BL_BioSpm_BloodSetting_v1r0"]))
blood$blood_n_pct <- paste0(blood$output.table.Frequency," (",round(blood$output.table.Percent,2)," %)") 
urine <- as.data.frame(tab1(recrver1[which(recrver1$d_167958071==353358909),"BL_BioSpm_UrineSetting_v1r0"]))
urine$urine_n_pct <- paste0(urine$output.table.Frequency," (",round(urine$output.table.Percent,2)," %)") 
mw <- as.data.frame(tab1(recrver1[which(recrver1$d_684635302==353358909),"BL_BioSpm_MWSetting_v1r0"]))
mw$mw_n_pct <- paste0(mw$output.table.Frequency," (",round(mw$output.table.Percent,2)," %)")
biosetting_all<- as.data.frame(cbind(rownames(blood),blood$blood_n_pct,urine$urine_n_pct,mw$mw_n_pct))
biosetting_all$Biospecimen
colnames(biosetting_all) <- c("Collection Setting","Blood collected", "Urine collected", "Mouthwash collected")



###Table 5 Baseline biospecimen collection status among verified participants
levels(recrver1$BioFin_BaseBloodCol_v1r0)

biocol <- recrver1 %>% group_by(BioFin_BaseBloodCol_v1r0,BioFin_BaseUrineCol_v1r0,BioFin_BaseMWCol_v1r0) %>% dplyr::tally() 
total <- nrow(recrver1)
biocol$pct <- round(100*biocol$n/nrow(recrver1),digits=2)
biocol$cumcount <- cumsum(biocol$n)
biocol$cumpct <- round(100*cumsum(biocol$n)/nrow(recrver1),digits=2)

biocol <- apply_labels(biocol, 
                       pct="percentage of Total verified",
                       cumcount="cumulative counts of verified",
                       cumpct="cumulative percentage")


print(biocol)
biocol.site <- list()
###Table 6. by site
biocol.sub <- recrver1 %>% 
  group_by(RcrtES_Site_v1r0,BioFin_BaseBloodCol_v1r0,BioFin_BaseUrineCol_v1r0,BioFin_BaseMWCol_v1r0) %>% 
  dplyr::tally() 

biocol.sub$RcrtES_Site_v1r0 <- droplevels(biocol.sub)
for(site in unique(recrver1$site)){
  
  biocol.sub <- recrver1 %>% filter(site==site) %>% 
    group_by(RcrtES_Site_v1r0,BioFin_BaseBloodCol_v1r0,BioFin_BaseUrineCol_v1r0,BioFin_BaseMWCol_v1r0) %>% dplyr::tally() 
  total <- as.numeric(nrow(recrver1[which(recrver1$site==site),]))
  biocol.sub$pct <- round(100*biocol.sub$n/total,digits=2)
  biocol.sub$cumcount <- cumsum(biocol.sub$n)
  biocol.sub$cumpct <- round(100*cumsum(biocol.sub$n)/total,digits=2)
  biocol.site[[i]] <- biocol.sub
  UP_type_verified  <- filter(data[which(data$d_827220437>0 & data$d_699625233 == 353358909),],d_512820379== 486306141 & site==site ) %>%
    arrange(site,factor(Rcrt_Verified_v1r0)) 
}
##Fig 1(table6)
recrver1 <- recrver1 %>% mutate(BiospmCols_v1r0 =case_when((recrver1$d_684635302 == 353358909 & recrver1$d_878865966 == 353358909 
                                                                & recrver1$d_167958071 == 353358909) ~ "All blood, urine and mouthwash",
                                                               (recrver1$d_684635302 == 353358909 & recrver1$d_878865966 == 353358909 
                                                                & recrver1$d_167958071 == 104430631) ~ "Mouthwash and blood, no urine",
                                                               (recrver1$d_684635302 == 353358909 & recrver1$d_878865966 == 104430631 
                                                                & recrver1$d_167958071 == 104430631) ~ "Only mouthwash,no blood or urine",
                                                               (recrver1$d_684635302 == 104430631 & recrver1$d_878865966 == 353358909 
                                                                & recrver1$d_167958071 == 353358909) ~ "Blood and urine, no mouthwash",
                                                               (recrver1$d_684635302 == 104430631 & recrver1$d_878865966 == 104430631 
                                                                & recrver1$d_167958071 == 353358909) ~ "Only urine, no blood or mouthwash",
                                                               (recrver1$d_684635302 == 353358909 & recrver1$d_878865966 == 104430631 
                                                                & recrver1$d_167958071 == 353358909) ~ "Mouthwash and urine, no blood",
                                                               (recrver1$d_684635302 == 104430631 & recrver1$d_878865966 == 353358909
                                                                & recrver1$d_167958071 == 104430631) ~ "Only blood, no urine or mouthwash",
                                                                ((recrver1$d_684635302 == 104430631 | is.na(recrver1$d_684635302)) & 
                                                                   (recrver1$d_878865966 == 104430631 | is.na(recrver1$d_878865966))
                                                            & (is.na(recrver1$d_167958071) |recrver1$d_167958071 == 104430631)) ~ "No any biospecimen collections"
                                                           ))
table(as.character(recrver1$d_684635302))

table_colspm <- recrver1[which(recrver1$d_684635302 == 353358909 | recrver1$d_878865966 == 353358909 | recrver1$d_167958071 == 353358909),] %>%
        group_by(BiospmCols_v1r0) %>% dplyr::summarise(count=n()) 
table_colspm$count_pct <- paste0(table_colspm$count," (", round(100*table_colspm$count/sum(table_colspm$count),digits=2),"%)")
table_colspm <- table_colspm[order(-table_colspm$count),]
table_colspm$midpoint = cumsum(table_colspm$count) - (table_colspm$count / 2)
table_colspm$midpoint <- ifelse(table_colspm$count>7, table_colspm$count, cumsum(table_colspm$count) - (table_colspm$count / 2))
table_colspm$midpoint
ggplot(table_colspm, aes(x = "", y = count, fill = BiospmCols_v1r0)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar(theta = "y", start = 0) +
  scale_fill_manual(values = c("light blue", "Red", "Green", "Orange", "Pink", "Purple","Yellow")) +
  scale_colour_brewer(palette = "Set1") +
  labs(x = "", y = "", title = "Percent (and number) of Biospecimen Collection Completion among baseline collections",
       fill = "BiospmCols_v1r0") + 
  geom_text(aes(x=1.6, label=count_pct),
            position =  position_stack(vjust=0.6), size=3) +
  geom_text(aes(x = 1.3, y = midpoint , label = count_pct), color="black",
            fontface = "bold") +
  theme(plot.title = element_text(hjust = 0.5), 
        legend.title = element_text(hjust = 0.5, face="bold", size = 10)) 

#label outside
ggplot(table_colspm, aes(x = "", y = count, fill = BiospmCols_v1r0)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar(theta = "y", start = 0) +
  scale_fill_manual(values = c("light blue", "Red", "Green", "Orange", "Pink", "Purple","Yellow")) +
  #scale_colour_brewer(palette = "Set1") +
  labs(x = "", y = "", title = "Percent (and number) of Biospecimen Collection Completion among baseline collections",
       fill = "BiospmCols_v1r0") + 
  geom_text(aes(x=1.6, label=count_pct),
            position =  position_stack(vjust=0.6), size=3, color="black",fontface = "bold") +
  theme(panel.background = element_blank(),
        plot.title = element_text(hjust = 0.0, face="bold"), 
        axis.ticks = element_blank(),axis.text = element_blank(),
        legend.title = element_text(hjust = 0.5, face="bold", size = 10))


###for the biospecimen data:collections, deviation, and nocollections# ###Table 14. Number of blood, urine, and mouthwash collected by collection setting
pct_tb <- function(x,y){
  table1 <- CrossTable(x,y, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,chisq=FALSE)
  pct <- as.data.frame(cbind(table1$prop.row,table1$t))
  if(ncol(pct)==2){
    total <- as.numeric(sum(pct[,2]))
    pct[nrow(pct)+1,c(1:2)] <- c(1,total)
    rownames(pct)[nrow(pct)] <- "Total"
    colnames(pct)[1] <- paste0("pct_",colnames(pct)[1])
    colnames(pct)[2] <- paste0("n_",colnames(pct)[2])
    
  }
  else  if(ncol(pct)>2 ){
    total <- as.numeric(sum(pct[,3] + pct[,4]))
    pct[nrow(pct)+1,c(1:4)] <- c(sum(pct[,3])/total,sum(pct[,4])/total,sum(pct[,3]),sum(pct[,4]))
    rownames(pct)[nrow(pct)] <- "Total"
    colnames(pct)[c(1:2)] <- paste0("pct_",colnames(pct[c(1:2)]))
    colnames(pct)[c(3:4)] <- paste0("n_",colnames(pct)[c(3:4)])
    
    pct[,5] <- paste0(pct[,3]," (",round(100*pct[,1],2), "%)")
    pct[,6] <- paste0(pct[,4]," (",round(100*pct[,2],2), "%)") 
    colnames(pct)[5] <- paste0("n_",colnames(pct)[1])
    colnames(pct)[6] <- paste0("n_",colnames(pct)[2])
  }
  return(pct)
}

recrver1$BL_BioSpm_BloodSetting_v1r0 <- factor(recrver1$BL_BioSpm_BloodSetting_v1r0,levels=c("Clinical","Home","Research"))


# biospm <- c("Blood","Urine","MW" )
# biosetting <- list()
# for (i in 1 : length(biospm)){
#   eval(parse(text=paste("dt<-cross_cases(recrver1, BL_BioSpm_",biospm[i],"Setting_v1r0,BioFin_Base",biospm[i],"Col_v1r0)", sep="")))
#   data <- as.data.frame(dt)
#   data$setting <- sapply(strsplit(data$row_labels,"\\|"), '[', 2)
#   biosetting[[i]] <- data[,c(3,4)]
# }
# biosetting[[1]]
# biosetting_all<- biosetting %>% reduce(inner_join, by = "setting")
# biosetting_all <- biosetting_all %>% mutate_at(c(1,3,4), ~replace_na(.,0))
# #biosetting_all[3,] <- c("|Clinical",0,0,0)
# #biosetting_all[4,] <- c("|Home",0,0,0)
# biosetting_all[5,] <- biosetting_all[2,]

#biosetting_all <- biosetting_all[-2,]


###to input the biospecimen data
###compared with the original data in Connect.biospecimen: 11 variables are missing during the flattening.
###d_299553921.d_338286049
##d_299553921.d_883732523
##d_454453939.d_338286049
##d_454453939.d_883732523
##d_652357376.d_536710547
##d_703954371.d_338286049
##d_703954371.d_536710547
##d_703954371.d_883732523
##d_838567176.d_338286049
##d_838567176.d_536710547
##d_838567176.d_883732523

#####d_827220437	as RcrtES_Site_v1r0,
##d_331584571	as BioSpm_Visit_v1r0,
#d_338570265	as BioCol_ColNote1_v1r0,
#d_387108065	as BioSpm_ColIDEntered_v1r0,
#d_410912345	as BioRec_CollectFinal_v1r0,
#d_556788178	as BioRec_CollectFinalTime_v1r0,
#d_650516960	as BioSpm_Setting_v1r0,
#d_678166505	as BioCol_ColTime_v1r0,
#d_820476880	as BioSpm_ColIDScan_v1r0,
#d_951355211	as BioSpm_Location_v1r0,
#d_926457119	as BioBPTL_DateRec_v1r0,
#d_143615646_d_926457119	as MWTube1_BioBPTL_DateRec_v1r0,
#d_143615646_d_593843561	as MWTube1_BioCol_TubeCollected,
#d_143615646_d_678857215	as MWTube1_BioCol_Deviation,
#d_143615646_d_762124027	as MWTube1_BioCol_Discard,
#d_143615646_d_825582494	as MWTube1_BioCol_TubeID,
#d_143615646_d_883732523	as MWTube1_BioCol_NotCol,
#d_143615646_d_338286049	as MWTube1_BioCol_NotCollNotes,
#299553921	Serum Separator Tube 1
#703954371	Serum Separator Tube 2
#838567176	Heparin Tube 1
#958646668	Heparin Tube 2
#454453939	EDTA Tube 1
#652357376	ACD Tube 1
#825582494	Object ID
#787237543	Biohazard Bag scan
#338570265	Additional notes on Collection
#678166505	Date/Time samples collected, automatically populated when next is hit at the end of the Collection Data Entry page prior to reason selection and additional comments.
#915838974	Autogenerated date/time when scanned at regional lab - automatically populated when next is hit at the end of the Collection Data Entry page prior to reason selection and additional comments.
#883732523	Select reason tube was not collected
#973670172	Urine Tube 1
#143615646	Mouthwash Tube 1
#678857215	Deviation
#223999569	Biohazard Bag (mouthwash) scan
#
###to check all the blood samples are collected from each participants
#Table 11. Percent (and number) of Blood Completeness among baseline research sample collections
##for blood collection based on the biospecimen data individually

tubes <- dd[grepl(" Tube ",dd$`Variable Label`),]
tubes[grepl("00", tubes$`Variable Name`),]
###         CID         Variable Label    Variable Name
# 1: 232343615 Serum Separator Tube 4 BioCol_0012_v1r0
# 2: 299553921 Serum Separator Tube 1 BioCol_0001_v1r0
# 3: 376960806 Serum Separator Tube 3 BioCol_0011_v1r0
# 4: 454453939            EDTA Tube 1 BioCol_0004_v1r0
# 5: 589588440 Serum Separator Tube 5 BioCol_0021_v1r0
# 6: 652357376             ACD Tube 1 BioCol_0005_v1r0
# 7: 677469051            EDTA Tube 2 BioCol_0014_v1r0
# 8: 683613884            EDTA Tube 3 BioCol_0024_v1r0
# 9: 703954371 Serum Separator Tube 2 BioCol_0002_v1r0
# 10: 838567176         Heparin Tube 1 BioCol_0003_v1r0
# 11: 958646668         Heparin Tube 2 BioCol_0013_v1r0
biospe_dd[grepl("00", biospe_dd$`Variable Name`),]
bld.ls <- c("d_299553921","d_703954371","d_454453939","d_838567176","d_652357376","d_376960806","d_232343615","d_589588440","d_677469051",
            "d_683613884","d_958646668") #blood tube types CIDs: the first 5 tubes are research, add the rest are clinical


#bld.ls <- c("d_299553921","d_703954371","d_454453939","d_838567176","d_652357376") #blood tube types CIDs

##research collection tubes
 ##biospeciment tube type CIDs

tubeid <- grep("d_825582494", names(biospe), value=TRUE) #tube ID
deviation <- grep("d_678857215",names(biospe),value=TRUE) 
colid <- grep("d_593843561", names(biospe), value=TRUE) #collected yes/no
discard <- grep("d_762124027",names(biospe),value=TRUE) #discard yes/no
biodiscard <- biospe[,(which(names(biospe) %in% discard))]
#eval(parse(text=paste("varlong <-grep(",\"d_593843561\",",names(biospe),value=TRUE)",sep="")))
###Table 6. Percent (and number) of Blood Completeness among baseline collections


###reshape the data: binary variables for tube collections: collected(y/n),deviation(y/n), tubeID, discarded (y/n), notcollection reasons:5,
###notcollection Notes (338286049), deviation notes (536710547)


biospe$blddev <-0 #blood deviations
biospe$bldcol <- 0 #blood collections
biospe$blddid <- 0 #discarded
for(i in 1:length(bld.ls)){
  
  bldcol <- ifelse(biospe[,paste(bld.ls[i],"d_593843561",sep="_")] == 104430631 | is.na(biospe[,paste(bld.ls[i],"d_593843561",sep="_")]),0,1)  ##for tube collected
  
  blddev <- ifelse(biospe[,paste(bld.ls[i],"d_678857215",sep="_")]==104430631 | is.na(biospe[,paste(bld.ls[i],"d_678857215",sep="_")]),0,1) #for tube deviations yes/no
  
  blddid <- ifelse(biospe[,paste(bld.ls[i],"d_762124027",sep="_")]==104430631 | is.na(biospe[,paste(bld.ls[i],"d_762124027",sep="_")]),0,1)
  
  biospe$blddev <- biospe$blddev+blddev
  biospe$bldcol <- bldcol + biospe$bldcol ###to check collection
  biospe$blddid <- biospe$blddid+blddid  
  # k the completion of the blood collection of 5 types
  
}
table(biospe$d_650516960,biospe$bldcol)
# 0  1  3  4  5  9
# 534621077  6  4  1  7 67  0
# 664882224  2  1  0  0  0  4
biospe <- biospe %>% mutate(BioFin_BaseBLDComplt_v1r0 = ifelse((d_650516960==534621077 & bldcol == 5) | (d_650516960==664882224 & bldcol == 9), 2 ,#blood collection completion
                                          ifelse( (d_650516960==534621077 & (bldcol<5 & bldcol>0)) | (d_650516960==664882224 & (bldcol <  9 & bldcol < 0)),1,0)),
                            Urine_col = ifelse(d_973670172_d_593843561==353358909, 1, ifelse(d_973670172_d_593843561==104430631,0,0)),
                            MW_col = ifelse(d_143615646_d_593843561==353358909,1,ifelse(d_143615646_d_593843561==104430631,0,0)),
                            Biocol_Setting = case_when(d_650516960==534621077  ~"Research",
                                                        d_650516960==664882224 ~ "Clinical",
                                                         d_650516960 ==103209024 ~ "Home")) 
 
biospe$Biospe_col <- biospe$bldcol + biospe$Urine_col + biospe$MW_col    

biospe$BioFin_BaseBLDCol_v1r0 <-ifelse(biospe$bldcol>0,1,ifelse(is.na(biospe$bldcol),NA,0)) #blood collection Yes/No

unique(biospe[duplicated(biospe$Connect_ID),"Connect_ID"])
#[1] 2055639272 3654414289 4467774615 5537363912 6258863606 7574078898 8261536089 #stg biospecimen data
# A tibble: 5 × 1
# Connect_ID
# <int64>
# 1 2513005250
# 2 2699722546
# 3 4289925849
# 4 7154937817
# 5 8087190864
###to get the summary collection data per person on urine, blood, and mouthwash collections for each biospecimen collection settings
#tube_col <- biospe %>% dplyr::select(Connect_ID, d_678166505,d_951355211, d_410912345,d_650516960, d_556788178,grep("593843561",colnames(biospe)),bldcol)
#tube_col <- tube_col %>% group_by(as.character(Connect_ID))  %>% arrange(bldcol,d_973670172_d_593843561,d_143615646_d_593843561) %>% slice(n())

#biospe1 <- biospe %>% group_by(as.character(Connect_ID)) %>% arrange(desc(Biospe_col)) %>% slice(n())
tube_col <- biospe  %>% group_by(as.character(Connect_ID),d_650516960) %>% dplyr::summarise(bldcol_max = max(bldcol),
                                                       Urine_col_max= max(Urine_col),
                                                       MW_col_max=max(MW_col),
                                                       d_973670172_d_593843561_max=max(d_973670172_d_593843561),
                                                       d_143615646_d_593843561_max = max(d_143615646_d_593843561),
                                                       d_410912345_max=max(d_410912345))
table(tube_col$d_650516960)

colnames(tube_col)
tube_col$Connect_ID <- as.numeric(tube_col$`as.character(Connect_ID)`)
tube_col[which(tube_col$Connect_ID %in%  c("2513005250","2699722546","4289925849","7154937817","8087190864")),c("Connect_ID","d_410912345_max","bldcol_max","d_143615646_d_593843561_max","d_973670172_d_593843561_max")]
# # A tibble: 5 × 5
# Connect_ID d_410912345_max bldcol_max d_143615646_d_593843561_max d_973670172_d_593843561_max
# <dbl> <chr>                <dbl> <chr>                       <chr>                      
#   1 2513005250 353358909                5 353358909                   353358909                  
# 2 2699722546 NA                       5 353358909                   353358909                  
# 3 4289925849 NA                       5 353358909                   353358909                  
# 4 7154937817 NA                       5 353358909                   353358909                  
# 5 8087190864 NA                       0 353358909                   353358909  
recr_biospe <- merge(recrver1,tube_col, by="Connect_ID", all.x=TRUE)

##Table 6. Baseline biospecimen collection status among verified participant at HP

recrver1 <- recrver1 %>% mutate(Biocol_research = ifelse(recrver1$d_173836415_d_266600170_d_592099155  %in% c(664882224,NA) &
                                                           recrver1$d_173836415_d_266600170_d_718172863 %in% c(664882224,NA) &
                                                           recrver1$d_173836415_d_266600170_d_915179629 %in% c(664882224,NA),
                                                            "no research", "research"))
                                                         
recr_biospe[which(recr_biospe$d_650516960==534621077 & recr_biospe$Biocol_research=="no research"),
            c("Connect_ID","d_173836415_d_266600170_d_592099155","d_173836415_d_266600170_d_718172863","d_173836415_d_266600170_d_915179629","d_650516960","Biocol_research")]

# recr_biospe <- recr_biospe %>% filter_at(vars(c(d_173836415_d_266600170_d_592099155 , d_173836415_d_266600170_d_718172863,d_173836415_d_266600170_d_915179629)), 
#                                                 any_vars(. ==534621077) ) %>% mutate(Biocol_research="research")
recr_biospe <- recr_biospe %>% mutate(Biocol_Setting = case_when(d_650516960==534621077  ~"Research",
                                                                 d_650516960==664882224 ~ "Clinical",
                                                                 d_650516960 ==103209024 ~ "Home"))
#Table7-11 for research sites
site_biocol <- list()
for (site in unique(recr_biospe$RcrtES_Site_v1r0)){
  biocol_site <- recr_biospe %>% filter(RcrtES_Site_v1r0 == site) %>%
    group_by(RcrtES_Site_v1r0,Biocol_Setting,BioFin_BaseBloodCol_v1r0,BioFin_BaseUrineCol_v1r0,BioFin_BaseMWCol_v1r0) %>% dplyr::tally() 
  total <- nrow(recr_biospe[which(recr_biospe$RcrtES_Site_v1r0==site),])
  biocol_site$pct <- round(100*biocol_site$n/total,digits=2)
  biocol_site$cumcount <- cumsum(biocol_site$n)
  biocol_site$cumpct <- round(100*cumsum(biocol_site$n)/total,digits=2)
  site_biocol[[site]] <- biocol_site
}


# biocol <- apply_labels(biocol, 
#                        pct="percentage of Total verified",
#                        cumcount="cumulative counts of verified",
#                        cumpct="cumulative percentage")



#biospe1 <- biospe[which(survey %in% survey[complete.cases(as.numeric(survey))]),]  ##to remove the duplicates without collections, biospe is direcrly from the GCP, as integer, to only a vector can be applied for the function "complete.cases" 
#biospe1 <- biospe[!is.na(biospe$d_410912345),]
#biospe1 <- biospe[complete.cases(biospe[,c("Connect_ID","d_410912345")]),]


# biospe2 <- biospe %>% 
#   group_by(as.character(Connect_ID))  %>% arrange(!is.na(d_410912345))%>% slice(n()) #n=645
# 
# biospe2 <- biospe2[-646,]
# 
# biospe2[which(biospe2$Connect_ID %in% c(4289925849,2699722546,7154937817,8087190864,2513005250)),c("Connect_ID","d_410912345")]
table(biospe1$bldcol)
recr_biospe <- recr_biospe %>% mutate(BioFin_BaseBLDComplt_v1r0 = ifelse((d_650516960==534621077 & bldcol_max == 5) | (d_650516960==664882224 & bldcol_max == 9), "All Blood Tubes Collected" ,#blood collection completion
                                          ifelse( (d_650516960==534621077 & (bldcol_max<5 & bldcol_max>0)) | (d_650516960==664882224 & (bldcol_max <  9 & bldcol_max < 0)),"Partial Blood Tubes Collected","No Blood Tubes Collected")))
                                      
recr_biospe$BioFin_BaseBLDComplt_v1r0 <- factor(recr_biospe$BioFin_BaseBLDComplt_v1r0,levels=c("No Blood Tubes Collected","Partial Blood Tubes Collected",
                                                                                       "All Blood Tubes Collected"))
recr_biospe1$BioFin_BaseBLDCol_v1r0 <-ifelse(biospe1$bldcol>0,1,ifelse(is.na(biospe1$bldcol),NA,0)) #blood collection Yes/No



##Table 11. Percent (and number) of Blood Completeness among baseline research sample collections
Table11_bldcpt <- recr_biospe %>% filter(d_650516960==534621077) %>%
  dplyr::select(RcrtES_Site_v1r0, BioFin_BaseBLDComplt_v1r0 )  %>% tbl_cross(
  row = RcrtES_Site_v1r0,
  col = BioFin_BaseBLDComplt_v1r0,
  percent = "row",
  label=RcrtES_Site_v1r0~"Site",
  missing="no") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label ~ "**Baseline Blood Collection Completion**") %>%
  modify_caption("**Table 11. Percent (and number) of Blood Completeness among baseline research sample collections**") %>%
  as_kable()

##Table 12. Blood collected status according to data sent by KP vs data entered into Connect
  # if	BL_BioClin_DBBloodRRL_v1r0 = . then BL_BioClin_DBBloodRRL_v1r0= 104430631;/*"Clinical DB Blood RRL Received"*/
  # if	BL_BioClin_SiteBloodColl_v1r0 = . then  BL_BioClin_SiteBloodColl_v1r0 = 104430631;/*"Clinical Site Blood Collected"*/
  # if	BL_BioClin_SiteBloodRRL_v1r0 = . then BL_BioClin_SiteBloodRRL_v1r0 = 104430631; /*"Clinical Site Blood RRL Received"*/
  # 
  # if	BL_BioClin_DBUrineRRL_v1r0 = . then BL_BioClin_DBUrineRRL_v1r0= 104430631; /*"Clinical Site Urine RRL Received"*/
  # if	BL_BioClin_SiteUrineRRL_v1r0 = . then BL_BioClin_SiteUrineRRL_v1r0= 104430631;/*"Clinical Site Urine RRL Received"*/
  # if	BL_BioClin_SiteUrineColl_v1r0 = . then BL_BioClin_SiteUrineColl_v1r0 = 104430631; /*"Clinical DB Urine RRL Date/Time Received"*/
recrver_ver1[grep("BioClin_DBBloodRRL|BioClin_SiteBloodColl|BioClin_DBUrineRR|BioClin_SiteUrineRRL",recrver_ver1$`Variable Name`),]
# CID                               Variable Label               Variable Name                            variable
# 1: 210921343               Clinical DB Urine RRL received     BioClin_DBUrineRRL_v1r0 d_173836415_d_266600170_d_210921343
# 2: 224596428 Clinical Site Urine RRL Date / Time Received BioClin_SiteUrineRRLDt_v1r0 d_173836415_d_266600170_d_224596428
# 3: 398645039     Clinical DB blood RRL Date/Time Received   BioClin_DBBloodRRLDt_v1r0 d_173836415_d_266600170_d_398645039
# 4: 453452655             Clinical Site Urine RRL Received   BioClin_SiteUrineRRL_v1r0 d_173836415_d_266600170_d_453452655
# 5: 534041351               Clinical DB Blood RRL Received     BioClin_DBBloodRRL_v1r0 d_173836415_d_266600170_d_534041351
# 6: 541311218     Clinical DB urine RRL Date/Time received   BioClin_DBUrineRRLDt_v1r0 d_173836415_d_266600170_d_541311218
# 7: 693370086                Clinical Site Blood Collected  BioClin_SiteBloodColl_v1r0 d_173836415_d_266600170_d_693370086  
recr_clin <- recr_biospe %>% filter(d_650516960 == 664882224) %>%
   mutate(BL_BioClin_DBUrineRRL_v1r0=ifelse(d_173836415_d_266600170_d_210921343==104430631 | is.na(d_173836415_d_266600170_d_210921343), "No","Yes"),
          BioClin_SiteUrineRRL_v1r0=ifelse(d_173836415_d_266600170_d_453452655==104430631 | is.na(d_173836415_d_266600170_d_453452655), "No","Yes"),
          BL_BioClin_DBBloodRRL_v1r0=ifelse(d_173836415_d_266600170_d_534041351==104430631 | is.na(d_173836415_d_266600170_d_534041351), "No","Yes"),
          BioClin_SiteBloodColl_v1r0=ifelse(d_173836415_d_266600170_d_693370086==104430631 | is.na(d_173836415_d_266600170_d_693370086), "No","Yes")
   )

Table12_BldCli <- recr_clin %>% 
  dplyr::select(BL_BioClin_DBBloodRRL_v1r0, BioClin_SiteBloodColl_v1r0 )  %>% tbl_cross(
    col = BL_BioClin_DBBloodRRL_v1r0,
    row = BioClin_SiteBloodColl_v1r0,
    percent = "row",
    label=list(BL_BioClin_DBBloodRRL_v1r0~"Clinical DB Blood RRL received", BioClin_SiteBloodColl_v1r0 ~ 'Clinical Site Blood Collected'),
    missing="no") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label ~ "**Baseline Clinical Site Blood RRL Received**") %>%
  modify_caption("**Table 12. Blood collected status according to data sent by KP vs data entered into Connect**") %>%
  as_kable()

Table13_UrineCli <- recr_clin %>% 
  dplyr::select(BL_BioClin_DBUrineRRL_v1r0, BioClin_SiteUrineRRL_v1r0 )  %>% tbl_cross(
    col = BL_BioClin_DBUrineRRL_v1r0,
    row = BioClin_SiteUrineRRL_v1r0,
    percent = "row",
    label=list(BL_BioClin_DBUrineRRL_v1r0~"Clinical DB Urine RRL received", BioClin_SiteUrineRRL_v1r0 ~ 'Clinical Site Urine RRL Received'),
    missing="no") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label ~ "**Baseline Clinical Site Urine RRL Received**") %>%
  modify_caption("**Table 13. Blood collected status according to data sent by KP vs data entered into Connect**") %>%
  as_kable()

#Table 14. Number of blood, urine, and mouthwash collected by collection setting
blood <- as.data.frame(tab1(recrver1[which(recrver1$d_878865966==353358909),"BL_BioSpm_BloodSetting_v1r0"]))
blood$blood_n_pct <- paste0(blood$output.table.Frequency," (",round(blood$output.table.Percent,2)," %)") 
urine <- as.data.frame(tab1(recrver1[which(recrver1$d_167958071==353358909),"BL_BioSpm_UrineSetting_v1r0"]))
urine$urine_n_pct <- paste0(urine$output.table.Frequency," (",round(urine$output.table.Percent,2)," %)") 
mw <- as.data.frame(tab1(recrver1[which(recrver1$d_684635302==353358909),"BL_BioSpm_MWSetting_v1r0"]))
mw$mw_n_pct <- paste0(mw$output.table.Frequency," (",round(mw$output.table.Percent,2)," %)")
biosetting_all<- cbind(rownames(blood),blood$blood_n_pct,urine$urine_n_pct,mw$mw_n_pct)
biosetting_all$Biospecimen
colnames(biosetting_all) <- c("Collection Setting","Blood collected", "Urine collected", "Mouthwash collected")


# biospe1 %>%
#   group_by(RcrtES_Site_v1r0,BioFin_BaseBLDComplt_v1r0) %>%
#   dplyr::summarize(count=n())
# # summarise()` has grouped output by 'RcrtES_Site_v1r0'. You can override using the `.groups` argument.
# # # A tibble: 12 × 3
# # # Groups:   RcrtES_Site_v1r0 [5]
# # RcrtES_Site_v1r0                BioFin_BaseBLDComplt_v1r0  count
# # <fct>                           <fct>                      <int>
# #   1 Marshfield Clinic Health System No Blood Tubes Collected       1
# # 2 Marshfield Clinic Health System PartialBloodTubesCollected     1
# # 3 Marshfield Clinic Health System All Blood Tubes Collected    115
# # 4 HealthPartners                  PartialBloodTubesCollected     1
# # 5 HealthPartners                  All Blood Tubes Collected    148
# # 6 Henry Ford Health System        No Blood Tubes Collected       1
# # 7 Henry Ford Health System        PartialBloodTubesCollected     2
# # 8 Henry Ford Health System        All Blood Tubes Collected     53
# # 9 Sanford Health                  All Blood Tubes Collected     53
# # 10 University of Chicago Medicine  No Blood Tubes Collected      19
# # 11 University of Chicago Medicine  PartialBloodTubesCollected     8
# # 12 University of Chicago Medicine  All Blood Tubes Collected     70
# colnames(t5)[2] <- "Site"
# 
# t_site <- as.data.frame(tab1(biospe1$RcrtES_Site_v1r0)[[2]])
# t_site$freq_pct <- paste0(t_site$Frequency," (",t_site$Percent, "%)")
# t5_all <- merge(t5, t_site, by.x="Site",by.y="row.names",all.y=TRUE)
# t5_all[1,c(3,4)] <- table(recrver1$BioFin_BaseBLDComplt_v1r0)
# t5_all1 <- t5_all[,-c(2,5:7)]
# colnames(t5_all1)[4] <- "Total"


###for Table 15. Total number (and percent) of checked-in baseline blood collections
###Table 8. Total number (and percent) of checked-in baseline blood collections (previous research biospecimen metrics)
###BL_BioChk_Complete_v1r0^=. and BioSpm_Visit_v1r0=266600170 for all the participants with check-in complete time
####   d_331584571_d_266600170_d_135591	as	BL_BioChk_Complete_v1r0, /*Baseline Check in complete*/
#   d_331584571_d_266600170_d_840048	as	BL_BioChk_Time_v1r0, /*Autogenerated date/time baseline check in complete*/  
#   d_331584571_d_266600170_d_343048	as	BL_BioFin_CheckOutTime_v1r0, /*Autogenerated date/time baseline check out complete*/
#   d_173836415_d_266600170_d_448660	as	BL_BioFin_BMTime_v1r0, /*Autogenerated date/time baseline MW collected*/ 
#   d_173836415_d_266600170_d_561681	as	BL_BioFin_BBTime_v1r0, /*Autogenerated date/time baseline blood collected*/
#   d_173836415_d_266600170_d_847159	as	BL_BioFin_BUTime_v1r0, /*Autogenerated date/time baseline urine collected updated in Warren's code*/
# d_173836415_d_266600170_d_592099	as	BL_BioSpm_BloodSetting_v1r0, /*Blood Collection Setting*/
# d_173836415_d_266600170_d_718172	as	BL_BioSpm_UrineSetting_v1r0, /*Urine Collection Setting*/
# d_173836415_d_266600170_d_915179	as	BL_BioSpm_MWSetting_v1r0/*, Mouthwash Collection Setting*/

Table15_bld_resh <- recr_biospe %>% filter(d_650516960==534621077 & !is.na(d_331584571_d_266600170_d_343048998) ) %>% 
  select(Biocol_Setting,BioFin_BaseBloodCol_v1r0) %>%
  tbl_cross(    col = BioFin_BaseBloodCol_v1r0,
                row = Biocol_Setting,
                percent = "row",
                label=list(Biocol_Setting~"Baseline Collection Setting",
                             BioFin_BaseBloodCol_v1r0 ~ 'Blood Collection'),
                missing="no") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header() %>%
  modify_caption("**Table 15. Total number (and percent) of checked-in baseline blood collections**") %>%
  as_kable()#tab_header(title = "Patient Characteristics", subtitle = "Presented by treatment")


#Collected NotCollected tota1


recrver_bio <- merge(recrver1,biospe1, by="Connect_ID",all.x=TRUE)
table(recrver_bio$d_331584571) #266600170 472
table(recrver_bio$d_650516960) #534621077 472 
table(recrver_bio$d_650516960,recrver_bio$d_331584571)
# 
# 266600170
# 534621077       472
tb8 <- CrossTable(recrver_bio$d_650516960,recrver_bio$d_878865966,prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)
d_650516960
tb8_1 <- tab1(recrver_bio$d_878865966,sort.group = "decreasing", cum.percent = TRUE)$output.table

tb8_base_research <- as.data.frame(cbind(tb8$t,tb8$prop.tbl))
colnames(tb8_base_research) <- c("N_No_Blood_Collected","N_Blood_Collected","No_Blood_Collected_pct","Blood_Collected_pct")

tb8_base_research$NoCollect_n_pct <- paste(tb8_base_research$N_No_Blood_Collected,"(", paste0(round(100*tb8_base_research$No_Blood_Collected_pct, 2), "%"), ")", sep=" ")
tb8_base_research$Collected_n_pct <- paste(tb8_base_research$N_Blood_Collected,"(", paste0(round(100*tb8_base_research$Blood_Collected_pct, 2), "%"), ")", sep=" ")
tb8_base_research$Total_n_pct <- paste(sum(tb8_base_research$N_Blood_Collected,tb8_base_research$N_No_Blood_Collected),"(100%)", sep=" ")
tb8_base_research$visit_setting <- ifelse(rownames(tb8_base_research) == 534621077,"Research",
                                          ifelse(rownames(tb8_base_research) == 664882224,"Clinical",
                                            elseif(rownames(tb8_base_research) ==103209024, "Home", NA)))
tb8_base_research$visit <- "baseline"
Table8 <- tb8_base_research[,c(9,8,6,5,7)]

Table8 = apply_labels(Table8,
                        visit = "select visit",
                        visit_setting = "Collection Setting",
                        Collected_n_pct = "Collected",
                        NoCollect_n_pct = "Not Collected",
                        Total_n_pct ="Total")
colnames(Table8) <- c("Select viist","Collection Setting","Collected","Not Collected","Total")
print(Table8)

##the biospe collections:urine, blood, and mw

"d_650516960"
# reshape(dat1, idvar = "name", timevar = "numbers", direction = "wide")
# t8_long <- reshape(tb8_base_research, idvar="d_650516960", timevar="d_878865966",direction = "wide")

###Table 16. Total number (and percent) of checked-in baseline research samples collections

Table16_bum_resh <- recr_biospe %>% filter(d_650516960==534621077 & !is.na(d_331584571_d_266600170_d_343048998) ) %>% 
  select(Biocol_Setting,BiospeCollection) %>%
  tbl_cross(    col = BiospeCollection,
                row = Biocol_Setting,
                percent = "row",
                label=list(Biocol_Setting~"Baseline Collection Setting",
                           BiospeCollection ~ 'Biospecimen Collection'),
                missing="no") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header() %>%
  modify_caption("**Table 15. Total number (and percent) of checked-in baseline research sample collections**") %>%
  as_kable()#tab_header(title = "Patient Characteristics", subtitle = "Presented by treatment")


bio_col <- recr_biospe[which(!is.na(recr_biospe$d_331584571_d_266600170_d_135591601) & recr_biospe$d_650516960==534621077),]
table(bio_col$biocol_bum)

bio_col[ which(bio_col$biocol_bum == 0),c("Connect_ID","d_878865966","d_684635302", "d_167958071","d_331584571_d_266600170_d_135591")]
# Connect_ID d_878865966 d_684635302 d_167958071 d_331584571_d_266600170_d_135591
# 2476 9355022053   104430631   104430631   104430631                        353358909
##to replace NA in the values of d_650516960 and d_331584571.y
bio_col$d_331584571 <- replace_na(bio_col$d_331584571, 99)
bio_col$d_650516960 <- replace_na(bio_col$d_650516960, 99)
table(bio_col$d_331584571,bio_col$d_650516960,recrver_bio$d_331584571_d_266600170_d_135591)
# 104430631 353358909 
# 465         8 
options(digits=2) ##to keep values with two digits
tmp<- n.table(table(bio_col$d_650516960,bio_col$d_331584571,bio_col$biocol_bum))
tb9 <- CrossTable(bio_col$Biocol_Setting,bio_col$BiospeCollection,prop.t=FALSE, prop.r=FALSE, prop.c=FALSE,prop.chisq=FALSE)  
tb9_base_research <- as.data.frame(cbind(tb9$t,tb9$prop.tbl))
tb9_base_research$Total_n_pct <- paste(sum(tb9$t),"(100%)", sep=" ")
colnames(tb9_base_research)

tb9_base_research$NoCollect_n_pct <- paste(tb9_base_research[,2],"(", paste0(round(100*tb9_base_research[,4], 2), "%"), ")", sep=" ")
tb9_base_research$Collect_n_pct <- paste(tb9_base_research[,1],"(", paste0(round(100*tb9_base_research[,3], 2), "%"), ")", sep=" ")

tb9_base_research$visit <- "baseline"                                                
Table9 <- tb9_base_research[,c(8,7,6,5)]                                                                      
# Table9 = apply_labels(Table9,
#                       visit = "Selected visit",
#                       research_setting = "Collection Setting",
#                       Collect_n_pct = "Any sample Collected",
#                       NoCollect_n_pct = "No sample Collected",
#                       Total_n_pct ="Total Number of Baseline Check-in")                                                  
colnames(Table9) <- c("Selected visit","Any Sample Collected","No Sample Collected","Total Number of Baseline Check-in")


 ###Table 17. Number (and percent) of tubes with any deviation by site
bios.ls <- c("d_299553921","d_703954371","d_454453939","d_838567176","d_652357376","d_376960806","d_232343615","d_589588440","d_677469051",
             "d_683613884","d_958646668","d_973670172","d_143615646") ##biospeciment tube type CIDs

###reshape the data: binary variables for tube collections: collected(y/n),deviation(y/n), tubeID, discarded (y/n), notcollection reasons:5,
###notcollection Notes (338286049), deviation notes (536710547)


biospe$tubedev <-0 #blood deviations
biospe$tubecol <- 0 #blood collections
biospe$tubedis <- 0 #discarded

for(i in 1:length(bios.ls)){
  
  tubecol <- ifelse(biospe[,paste(bios.ls[i],"d_593843561",sep="_")] == 104430631 | is.na(biospe[,paste(bios.ls[i],"d_593843561",sep="_")]),0,1)  ##for tube collected
  
  tubedev <- ifelse(biospe[,paste(bios.ls[i],"d_678857215",sep="_")]==104430631 | is.na(biospe[,paste(bios.ls[i],"d_678857215",sep="_")]),0,1) #for tube deviations yes/no
  
  tubedis <- ifelse(biospe[,paste(bios.ls[i],"d_762124027",sep="_")]==104430631 | is.na(biospe[,paste(bios.ls[i],"d_762124027",sep="_")]),0,1)
  
  biospe$tubedev <- biospe$tubedev+tubedev
  biospe$tubecol <- tubecol + biospe$tubecol ###to check collection
  biospe$tubedis <- biospe$tubedis+tubedis  
  # k the completion of the blood collection of 5 types
  
}

biospe$d_827220437 <- as.numeric(biospe$d_827220437)
biospe <- apply_labels(biospe,d_827220437 = "Site",#RcrtES_Site_v1r0
                       d_827220437 = c("HealthPartners"= 531629870, "Henry Ford Health System"=548392715, "Kaiser Permanente Colorado" = 125001209,
                                      "Kaiser Permanente Georgia" = 327912200,"Kaiser Permanente Hawaii" = 300267574,"Kaiser Permanente Northwest" = 452412599,
                                      "Marshfield Clinic Health System" = 303349821,"Sanford Health" = 657167265, "University of Chicago Medicine" = 809703864,
                                      "National Cancer Institute" = 517700004,"National Cancer Institute" = 13,"Other" = 181769837))

biospe$Site <- factor(biospe$d_827220437,exclude = NULL)
biospe$tube_nodev <- biospe$tubecol-biospe$tubedev
total1 <- sum(biospe$tubedev) 
total2 <- sum(biospe$tube_nodev) 

tube_dev <- as.data.frame(aggregate( biospe$tubedev,                # Specify data column[,c("tubedev","tube_nodev")]
                                     by = list(biospe$Site),              # Specify group indicator
                                     FUN = sum))
tube_nodev <- as.data.frame(aggregate( biospe$tube_nodev,                # Specify data column[,c("tubedev","tube_nodev")]
                                     by = list(biospe$Site),              # Specify group indicator
                                     FUN = sum))

Table17 <- merge(tube_dev,tube_nodev,by="row.names")
Table17 <- Table17[,c(2,3,5)]

Table17[9,2] <- total1
Table17[9,3] <- total2
Table17$Total <- Table17[,2]+Table17[,3]
Table17$dev_n_pct <- paste0(Table17[,2]," (", round(100*Table17[,2]/Table17$Total,2), " %)")
Table17$nodev_n_pct <- paste0(Table17[,3]," (", round(100*Table17[,3]/Table17$Total,2), " %)")
Table17 <- Table17 %>% mutate(Site = ifelse(is.na(Group.1.x), "Total",  as.character(Group.1.x))) ###to replace NA in the factor variable


# d_703954371_d_248868659_d_102695	as SSTube2_Deviation_ClotS,
# d_703954371_d_248868659_d_242307	as SSTube2_Deviation_Hemolyzed,
# d_703954371_d_248868659_d_283900	as SSTube2_Deviation_MislabelR,
# d_703954371_d_248868659_d_313097	as SSTube2_Deviation_OutContam,
# d_703954371_d_248868659_d_453343	as SSTube2_Deviation_Other,
# d_703954371_d_248868659_d_472864	as SSTube2_Deviation_Broken,
# d_703954371_d_248868659_d_550088	as SSTube2_Deviation_TempL,
# d_703954371_d_248868659_d_561005	as SSTube2_Deviation_SpeedL,
# d_703954371_d_248868659_d_635875	as SSTube2_Deviation_Gel,
# d_703954371_d_248868659_d_654002	as SSTube2_Deviation_TimeL,
# d_703954371_d_248868659_d_684617	as SSTube2_Deviation_MislabelD,
# d_703954371_d_248868659_d_690540	as SSTube2_Deviation_TempH,
# d_703954371_d_248868659_d_728366	as SSTube2_Deviation_LowVol,
# d_703954371_d_248868659_d_757246	as SSTube2_Deviation_Leak,
# d_703954371_d_248868659_d_777486	as SSTube2_Deviation_TubeSz,
# d_703954371_d_248868659_d_810960	as SSTube2_Deviation_Discard,
# d_703954371_d_248868659_d_861162	as SSTube2_Deviation_SpeedH,
# d_703954371_d_248868659_d_912088	as SSTube2_Deviation_ClotL,
# d_703954371_d_248868659_d_937362	as SSTube2_Deviation_TimeS,
# d_703954371_d_248868659_d_982885	as SSTube2_Deviation_NotFound,
devia_type <- grep("678857215",colnames(biospe),value=TRUE)

dev_tube <- NULL
for (i in 1:length(bios.ls)){
  
  tube <- paste(bios.ls[i],"d_678857215",sep="_")
  tube_dev <- paste(bios.ls[i],"d_248868659", sep="_")
  deviation <- grep(tube_dev,colnames(biospe),value=TRUE)
  tmp <- as.data.frame(biospe[,which(colnames(biospe) %in% c(devia_type,tube,deviation))] )
  dev_long <- reshape(tmp,direction="long",varying=deviation,v.names ="deviation", timevar=c("dev_type"),times=deviation)
  
  colnames(dev_long)[grep("d_678857215",names(dev_long))] <- "d_678857215"
  #colnames(dev_long)[1] <- "d_678857215"
  dev_tube <- dplyr::bind_rows(dev_tube,dev_long)
  #print(c(i,bios.ls[i]))
}  
   dev_tube1   <- filter(dev_tube, d_678857215 ==353358909 & deviation == 353358909)  %>%  
     mutate(biospecimen=ifelse(grepl("d_973670172",dev_type), "urine",
                                  ifelse(grepl("d_143615646",dev_type),"Mouthwash","blood")),
            tube_type = case_when(grepl("d_973670172",dev_type) ~ "Urine Tube1",
                                  grepl("d_143615646",dev_type) ~ "MM Tube1",
                                  grepl("d_299553921",dev_type) ~ "Serum Seperater Tube1",
                                  grepl("d_703954371",dev_type) ~ "Serum Seperater Tube2",
                                  grepl("d_454453939",dev_type) ~ "EDTA Tube1",
                                  grepl("d_838567176",dev_type) ~ "Heparin Tube1",
                                  grepl("d_652357376",dev_type) ~ "ACD Tube1",
                                  grepl("d_677469051",dev_type) ~ "EDTA Tube2",
                                  grepl("d_683613884",dev_type) ~ "EDTA Tube3",
                                  grepl("d_376960806",dev_type) ~ "Serum Seperater Tube3",
                                  grepl("d_232343625",dev_type) ~ "Serum Seperater Tube4",
                                  grepl("d_589588440",dev_type) ~ "Serum Seperater Tube5",
                                  grepl("d_958646668",dev_type) ~ "Heparin Tube2"),
            
              deviationnotes =case_when(sapply(strsplit(dev_type,"d_"),"[[",4) =="102695484" ~ "Deviation Clot < 30min",
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="242307474" ~ "Hemolyzed", 
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="283900611" ~ "Mislabel Resolved",
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="313097539" ~ "Outside Contamated",
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="453343022" ~ "Other",
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="472864016" ~ "Broken", 
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="550088682" ~ "Temparture Too Low",
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="561005927" ~ "Cent Low",
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="635875253" ~ "Brokne Gel",
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="654002184" ~ "Centrifuge Too Long",
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="684617815" ~ "MisLabled Discard",
                  sapply(strsplit(dev_type,"d_"),"[[",4) =="690540566" ~"Tempature Too High",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="728366619" ~"Low Volume-(tube/container partially filled but still usable)",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="742806035" ~"MW < 30s",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="757246707" ~"Leak/Spilled",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="777486216" ~"Tube Size",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="810960823" ~"Discard",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="861162895" ~"Cent High",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="912088602" ~"Clot > 2h",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="937362785" ~"Centrifuge Too Short",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="956345366" ~"Insufficient Volume",
              sapply(strsplit(dev_type,"d_"),"[[",4) =="982885431" ~ "Not Found"))

   notcol_tube <- NULL
   collection_long <- NULL
   for (i in 1:length(bios.ls)){
     
     tubecol <- paste(bios.ls[i],"d_593843561",sep="_")
     tube_notcol <- paste(bios.ls[i],"d_883732523", sep="_")
     tube_notcolnotes <- paste(bios.ls[i],"d_338286049", sep="_")
     tube_deviation <- paste(bios.ls[i], "d_678857215",sep="_")
     tube_devnotes <- paste(bios.ls[i],"d_536710547",sep="_")
     select <- c(tubecol,tube_notcol,tube_notcolnotes,tube_deviation,tube_devnotes)
     tmp <- biospe[,(colnames(biospe)%in% c(select,"d_820476880","Site","Biocol_Setting"))]
     notcol <- tmp
     colnames(notcol)[colnames(notcol)==tubecol] <- "tubecol"
     colnames(notcol)[colnames(notcol)==tube_notcol] <- "tube_notcol"
     colnames(notcol)[colnames(notcol)==tube_notcolnotes] <- "tube_notcolnotes"
     colnames(notcol)[colnames(notcol)==tube_deviation] <- "tube_deviation"
     colnames(notcol)[colnames(notcol)==tube_devnotes] <- "tube_deviationnotes"
     notcol$tubeID <- bios.ls[i]
     
     notcol1 <- notcol[which(notcol$tubecol==104430631),]
     notcol_tube <- dplyr::bind_rows(notcol_tube,notcol1)
     collection_long <- dplyr::bind_rows(collection_long,notcol)
   } 
   
   Table17_option2 <- collection_long %>% mutate(deviation = dplyr::case_when(tube_deviation == 353358909 ~ "Any Deviation",
                                                                              tube_deviation == 104430631 ~ "No Deviation"),
                                                   Collected = dplyr::case_when(tubecol ==353358909 ~ "Collected",
                                                                                tubecol == 104430631 ~ "Not Collected")) %>%
   
     #filter(d_650516960==534621077 & !is.na(d_331584571_d_266600170_d_343048998) ) %>% 
     select(Site,deviation) %>%
     tbl_cross(    col = deviation,
                   row = Site,
                   percent = "row",
                   #label=(),
                   missing="no") %>%
     bold_labels() %>%
     italicize_levels() %>% 
     modify_header() %>%
     modify_caption("**Table 17. Number (and percent) of tubes with any deviation by site**") %>%
     as_kable()#tab_header(title = "Patient Characteristics", subtitle = "Presented by treatment")
   
   
   dev_tube1$tube_dev <- paste(dev_tube1$tube_type,"Deviation", dev_tube1$deviationnotes,sep=" ")
   dev_tube1$tubeID <- substr(dev_tube1$dev_type,1,11)
  dev <- collection_long %>% filter(tube_deviation==353358909) 
  dev_tube2 <- merge(dev,dev_tube1,by=c("d_820476880","tubeID"))
  
  #Table18_devtype <- dev_tube2 %>% select()
  
  dev_count <- dev_tube2 %>% group_by(Biocol_Setting,biospecimen,tube_dev) %>%   dplyr::summarize(count=n()) #Table11
  colnames(dev_count) <- c("Biospecimen Collection Setting","Biospecimen Types", "Biospecimen collection Deviation?","Counts of Biospecimen Deviation")

  
# dev_id<- dev_tube[which(dev_tube$d_678857215 ==353358909),] %>% 
#   group_by(d_820476880,deviation) %>% 
#   arrange(deviation) %>%  
#   slice(n()) 
# 
# dupid <- dev_id$id[duplicated(dev_id$id)]
# dev_id_nodev <- dev_id[!(dev_id$id %in% dev_id$id[duplicated(dev_id$id)]),]
# 
# dev_tubeall<- rbind(dev_tube1,dev_id_nodev)


###3983492332,4563945288

tb10_dev$No_deviation <- 
group_by(y) %>%
  dplyr::summarize(count=n()/sum(n()))


colnames(tb10)
reshape(dat1, idvar = "name", timevar = "numbers", direction = "wide")

#recode by patterns
#library(dplyr)
#data %>%
#  mutate_at(vars(nm1), ~ str_replace(., "sfsdf", "Hi"))


###Table 19. Number of tube tubes not collected at research collection visits


# VALUE TubeNotCollFmt 
# 234139565 = "Short draw"
# 681745422 = "Participant refusal" 
# 745205161 = "Participant attempted"
# 889386523 = "Supply Unavailable"
# 181769837 = "Other" 
# 999999999 = "missing";

bios.ls <- c("d_299553921","d_703954371","d_376960806","d_232343615","d_589588440","d_652357376","d_454453939","d_677469051",
             "d_683613884","d_838567176","d_958646668","d_973670172","d_143615646")
type.ls <- c("SSTube1","SSTube2","SSTube3","SSTube4","SSTube5","ACDTube1","EDTATube1","EDTATube2","EDTATube3","HepTube1","HepTube2","UrineTube1","MWTube1")


library(tidyr) #to replace the na with a string

notcol_tube <- notcol_tube %>%  mutate(notcol_tube,tube_notcolR = case_when(tube_notcol == 234139565 ~ "Short draw",
                                                           tube_notcol == 681745422 ~ "Participant refusal",
                                                           tube_notcol == 745205161 ~ "Participant attempted",
                                                           tube_notcol == 889386523 ~ "Supply Unavailable",
                                                           tube_notcol == 181769837 ~ "Other"),
                      biospecimen=ifelse(grepl("d_973670172",tubeID), "urine",
                                    ifelse(grepl("d_143615646",tubeID),"Mouthwash","blood")),
                      tube_type = case_when(grepl("d_973670172",tubeID) ~ "Urine Tube1",
                                            grepl("d_143615646",tubeID) ~ "MM Tube1",
                                            grepl("d_299553921",tubeID) ~ "Serum Seperater Tube1",
                                            grepl("d_703954371",tubeID) ~ "Serum SeperaterTube2",
                                            grepl("d_454453939",tubeID) ~ "EDTA Tube1",
                                            grepl("d_838567176",tubeID) ~ "Heparin Tube1",
                                            grepl("d_652357376",tubeID) ~ "ACD Tube1",
                                            grepl("d_677469051",tubeID) ~ "EDTA Tube2",
                                            grepl("d_683613884",tubeID) ~ "EDTA Tube3",
                                            grepl("d_376960806",tubeID) ~ "Serum Seperater Tube3",
                                            grepl("d_232343625",tubeID) ~ "Serum Seperater Tube4",
                                            grepl("d_589588440",tubeID) ~ "Serum Seperater Tube5",
                                            grepl("d_958646668",tubeID) ~ "Heparin Tube2"))
                                            

notcol_tube$tube_notcolR <- notcol_tube$tube_notcolR %>% replace_na('missing')  

# notcol_tube$tube_notcolR <- ifelse(notcol_tube$tube_notcol == 234139565,"Short draw",
#                              ifelse(notcol_tube$tube_notcol == 681745422, "Participant refusal",
#                                     ifelse(notcol_tube$tube_notcol == 745205161, "Participant attempted",
#                                            ifelse(notcol_tube$tube_notcol == 889386523, "Supply Unavailable",
#                                                   ifelse(notcol_tube$tube_notcol == 181769837,"Other" ,"missing")))))


Table19_nocol <- notcol_tube %>% filter(Biocol_Setting == "Research") %>% mutate(Site=droplevels(Site)) %>%
  dplyr::select(Site,tube_type) %>%
  tbl_cross(col=tube_type,row=Site,percent = "row",
            label=list(Site="Research Site",tube_type="Tube Type"),
            missing="no") %>%
    bold_labels() %>%
    italicize_levels() %>% 
    modify_header() %>%
    modify_caption("**Table 19. Number of tube types not collected at research collection visits**") %>%
    as_kable()#tab_header(title = "Patient Characteristics", subtitle = "Presented by treatment")

###Table 20. Number of tube types not collected at clinical collections
Table20_nocol_clin <- notcol_tube %>% filter(Biocol_Setting == "Clinic") %>% mutate(Site=droplevels(Site)) %>%
  dplyr::select(Site,tube_type) %>%
  tbl_cross(col=tube_type,row=Site,percent = "row",
            label=list(Site="Research Site",tube_type="Tube Type"),
            missing="no") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header() %>%
  modify_caption("**Table 19. Number of tube types not collected at clinic collections**") %>%
  as_kable()#tab_header(title = "Patient Characteristics", subtitle = "Presented by treatment")

#Table 21: Reason not collected by tube type and by site for research collections only

Table21_nocola <- notcol_tube %>% dplyr::filter(Biocol_Setting == "Research") %>% 
  dplyr::select(tube_notcolR,tube_type) %>%
  tbl_cross(row=tube_type,
            col=tube_notcolR,
            percent = "row",
            label=list(tube_nocolR="Reason for not collected",tube_type="Tube Type"),
            missing="no") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header() %>%
  modify_caption("**Table 21a.Reason not collected by tube type for Rsearch Collection Only**") %>%
  as_kable()#tab_header(title = "Patient Characteristics", subtitle = "Presented by treatment")

Table21b_nocol <- notcol_tube %>% dplyr::filter(Biocol_Setting == "Research") %>% 
  dplyr::select(tube_notcolR,Site) %>%
  tbl_cross(row=Site,
            col=tube_notcolR,
            percent = "row",
            label= list(Site="Research Site",tube_nocolR="Reason for not collected"),
            missing="no") %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header() %>%
  modify_caption("**Table 21b.Reason not collected by site for Research Collection Only**") %>%
  as_kable()

# explanatory = "RcrtES_Site_v1r0"
# dependent = 'tube_type'
# notcol_tube %>%
#   summary_factorlist(dependent, explanatory, 
#                      p=FALSE, add_dependent_label=TRUE) -> t12a
# colnames(t12a)[2] <- "site"
# 
# t_tube <- as.data.frame(tab1(notcol_tube$tube_type)[[2]])
# t_tube$freq_pct <- paste0(t_tube$Frequency," (",t_tube$Percent, "%)")
# t_tube_t <- as.data.frame(t(t_tube$freq_pct))
# colnames(t_tube_t) <- rownames(t_tube)
# t_tube_t$site <- "  Total" 
# 
# t12a_all <- dplyr::bind_rows(t12a, t_tube_t[,-c(8)])
# t12a_all_site <- merge(t12a_all, t_site, by.x="site",by.y="row.names",all.y=TRUE) ##final table
# 
# colnames(t12a_all_site)[13] <- "Total tubes not Collected"
# table12 <- t12a_all_site[c(2:6,1),c(1,3:9,13)]
#       
# 
# explanatory = "RcrtES_Site_v1r0"
# dependent = 'tube_notcolR'
# notcol_tube %>%
#   summary_factorlist(dependent, explanatory, 
#                      p=FALSE, add_dependent_label=TRUE) -> t12
# colnames(t12)[2] <- "site"
# 
# t_site <- as.data.frame(tab1(notcol_tube$RcrtES_Site_v1r0)[[2]])
# t_site$freq_pct <- paste0(t_site$Frequency," (",t_site$Percent, "%)")
# t_site_t <- as.data.frame(t(t_site$freq_pct))
# colnames(t_site_t) <- rownames(t_site)
# t_site_t$site <-   Total
# 
# 
# 
# t_notcol <- as.data.frame(tab1(notcol_tube$tube_notcolR)[[2]])
# t_notcol$freq_pct <- paste0(t_notcol$Frequency," (",t_notcol$Percent, "%)")
# t_notcol_t <- as.data.frame(t(t_notcol$freq_pct))
# colnames(t_notcol_t) <- rownames(t_notcol)
# t_notcol_t$site <- "  Total" 
# t_notcol_t$'Tube Type' <- "  Total" 
# 
# t12_all <- dplyr::bind_rows(t12, t_notcol_t[,-c(6)])
# t12_all_site <- merge(t12_all, t_site, by.x="site",by.y="row.names",all.y=TRUE)
###Table 13. Number (and percent) of reason not collected by tube type and by site

# notcol_tube %>%
#   group_by(tube_notcolR) %>%
#   dplyr::summarize(count=n())

explanatory = "tube_type"
dependent = 'tube_notcolR'
notcol_tube %>%
  summary_factorlist(dependent, explanatory, 
                     p=FALSE, add_dependent_label=TRUE) -> t12b
colnames(t12b)[2] <- "Tube Type"

t12b <- apply(t12b[,-c(1)], 2, function(x) gsub("^$|^ $", "0 (0.0)", x))
t12b <- as.data.frame(t12b)


t12_all1 <- dplyr::bind_rows(t12, t_site_t[,-c(6)])
t12_all_site <- merge(t12_all1, t_site, by.x="site",by.y="row.names",all.y=TRUE)#Table13a

t12_all2 <- dplyr::bind_rows(t12b, t_notcol_t[,-c(6,7)])
t12_all2_site <- merge(t12_all2, t_tube, by.x="Tube Type",by.y="row.names",all.y=TRUE)#Table13b
Table13a <- tb12_all_site[,c(1,)]

###Table 14. Number (and percent) of Discarded Tubes by biospecimen type/ by site

library(reshape2)
discard_tube <- NULL
for (i in 1:length(bios.ls)){
  tube_discard <- paste(bios.ls[i],"d_762124027",sep="_")
  tmp <- biospe[,(colnames(biospe)%in% c(tube_discard,"d_820476880","Site"))]
  discard <- tmp
  colnames(discard)[colnames(discard)==tube_discard] <- "tube_discard"
  discard$tubeID <- bios.ls[i]
  discard <- discard[which(discard$tube_discard==353358909),]
  discard_tube <- dplyr::bind_rows(discard_tube,discard)
}  

Table22_discard <- discard_tube %>% mutate( biospecimen=ifelse(grepl("d_973670172",tubeID), "urine",ifelse(grepl("d_143615646",tubeID),"Mouthwash","blood"))) %>%
  dplyr::select(Site, biospecimen) %>% tbl_summary(by=biospecimen,missing="no") %>% add_n() %>% bold_labels() %>% italicize_levels() %>% 
  as_kable(include=everything(),caption="Table 21. Number (and percent) of Discarded Tubes by biospecimen type/ by site")

  
  
#Table 22. Total number and percent of biospecimen survey status- research
###here I would like to use the original csv data on the recruitment table
recrbio <- read.csv("~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_recrverified_bio_09262022.csv",header=T)#2685
table(recrbio$d_331584571_d_265193023)
#231311385 615768760 972455046 
#432        11      2242 
recr_bio1 <- apply_labels(recr_bio1,
                        d_265193023 = "Blood/urine/mouthwash combined research survey-Complete",   
                        d_265193023 = c(	"Not Started" =	972455046, "Started"= 615768760,"Submitted"= 231311385),#SrvBLM_ResSrvCompl_v1r0
                        d_822499427 = "Placeholder (Autogenerated) - Date/time Status of Start of blood/urine/mouthwash research survey",#SrvBLM_TmStart_v1r0
                        d_222161762  = "Placeholder (Autogenerated)- Date/Time blood/urine/mouthwash research survey completed",#  SrvBLM_TmComplete_v1r0
                        d_331584571_d_266600170_d_135591601 = "Baseline Check-In Complete",#BL_BioChk_Complete_v1r0
                        d_331584571_d_266600170_d_135591601 =  c("No"=104430631, "Yes"=353358909),
                        d_331584571_d_266600170_d_840048338 = "Date/Time Baseline Check-In Complete",
                        d_331584571_d_266600170_d_343048998 = "Time Baseline check out complete")
                        
recrbio1 <- recr_bio1[which(grepl("2022",recr_bio1$d_331584571_d_266600170_d_840048338)),]
biosurvey <- tab1(recr_bio1$d_265193023,sort.group = "decreasing", cum.percent = TRUE)$output.table
recrbio1$biosv_time <- difftime(as.POSIXct(ymd_hms(recrbio1$d_331584571_d_266600170_d_343048998)),as.POSIXct(ymd_hms(recrbio1$d_331584571_d_266600170_d_840048338)),units="hours")
summary(as.numeric(recrbio1$biosv_time))
#Table 15b. Total number and percent of research biospecimen survey status by site
recrver_bio <- merge(recr_bio1,biospe1, by="token",all.x=TRUE)
bio_survey <- merge(recr_bio1,biospe1, by="token")
survey <- as.data.frame((tab1(bio_survey$d_265193023,sort.group = "decreasing", cum.percent = TRUE)$output.table))

survey$SurveyStatus <- rownames(survey)
survey$Cum.Freq <- ifelse(survey$SurveyStatus == "  Total",survey$Frequency,cumsum(survey$Frequency))

#Table 16. Baseline research biospecimen survey completion time from time of visit check-in
# d_678166505	as BioCol_ColTime_v1r0:"Collection Date/Time"
##tm_biocolSuv=intck("hour", BioCol_ColTime_v1r0,SrvBLM_TmComplete_v1r0);
# time_biochk=intck("minute", BL_BioChk_Time_v1r0,BL_BioFin_CheckOutTime_v1r0);
# if abs(time_biochk/60) > 24 then biochk_outlier=1;
# else if 0< =abs(time_biochk/60) < = 24 then biochk_outlier=0;
# 
# if 0<= abs(tm_biocolSuv) < =3 then checktmvisit=0;
# else if 12 =>abs(tm_biocolsuv)>3 then checktmvisit=1;
# else if  24 =>abs(tm_biocolsuv)>12 then checktmvisit=2;
# else if 48 =>abs(tm_biocolsuv)>24 then checktmvisit=3;
# else if  72 =>abs(tm_biocolsuv)>48 then checktmvisit=4;
# else if  abs(tm_biocolSuv)>72 then checktmvisit=5;
# 
# label tm_biocolSuv="time (hour) between biospecimen collection time with survey completion time" 
# time_biochk="visit time by minutes (check-out time minus check-in time)";
# attrib checkvisit format=checkdayfmt. label= "Survey Completion Time"
# checktmvisit format=checktimefmt. label="biospecimen Survey Completion/Submission Time range";
tmp_tm <- recrver_bio[,c("Connect_ID.x","d_222161762","d_822499427","d_265193023","d_678166505")]
tm <- c("d_222161762","d_822499427","d_265193023","d_678166505")
tmp_tm1 <- tmp_tm[complete.cases(tmp_tm[, c("d_222161762","d_822499427","d_265193023","d_678166505")]),]
#recrver_bio$tm_biocolsuv <- diff.difftime((as.POSIXct(ymd_hms(recrver_bio$d_684635302)

tmp_tm1$diff_suvcpt <-difftime(as.POSIXct(ymd_hms(tmp_tm1$d_222161762)),as.POSIXct(ymd_hms(tmp_tm1$d_678166505)),units="hours")
tmp_tm$tm_biocolsuv <-difftime(as.POSIXct(ymd_hms(tmp_tm$d_222161762)),as.POSIXct(ymd_hms(tmp_tm$d_678166505)),units="hours")
tmp_tm <-tmp_tm %>% mutate(checktmvisit=ifelse( abs(as.numeric(tm_biocolsuv)) >72,"greater than 72hrs (3days)",
                                            ifelse( 72 >= abs(as.numeric(tm_biocolsuv)) & abs(as.numeric(tm_biocolsuv)) > 48, "> 48 hrs to 72 hrs",
                                              ifelse( 48 >= abs(as.numeric(tm_biocolsuv)) & abs(as.numeric(tm_biocolsuv)) > 24, "> 24 hrs to 48 hrs",   
                                                ifelse( 24 >= abs(as.numeric(tm_biocolsuv)) & abs(as.numeric(tm_biocolsuv)) > 12, "> 12 hrs to 24 hrs",
                                                  ifelse( 12 >= abs(as.numeric(tm_biocolsuv)) & abs(as.numeric(tm_biocolsuv)) > 3, "> 3 hrs to 12 hrs ",      
                                                    ifelse( 3 >= abs(as.numeric(tm_biocolsuv)) & abs(as.numeric(tm_biocolsuv)) >= 0, "0 hrs to 3 hrs", NA)))))))     
table(tmp_tm$checktmvisit) ###the levels are different from the ones calculated by sas intck, because their rounding are different.
check_suvsubmit <- as.data.frame(tab1(tmp_tm[which(tmp_tm$d_265193023 == 231311385),"checktmvisit"], sort.group = "decreasing", cum.percent = TRUE)$output.table)
Table16 <- check_suvsubmit %>% mutate(SurveyStatus ="Submitted",
                                Cum.Frequency.Count = cumsum(Frequency),
                                `Survey Completion Time` = rownames(check_suvsubmit))

#Table 23a. Total number and percent of biospecimen survey status- research
#Table 24a. Total number and percent of biospecimen survey status by site- research

#Table 23b. Total number and percent of biospecimen survey status- clinical
#Table 24b. Total number and percent of biospecimen survey status by site- clinical

#Table 25. Baseline research biospecimen survey completion time from time of visit check-in


#Table 26. Baseline clinical biospecimen survey completion time from date/time sample received at RRL in Connect Dashboard'


#Table 27. Research biospecimen collection visit length (in minutes)


#Fig2

#Table 28. Research biospecimen collection visit length by site (in minutes)

#Fig3 

#Fig4: Number of research biospecimen visit over time by site'

#Fig5: Number of clinical blood collections over time by site
#Add a graph after this one, same graph but only KP sites, and base it on the number of blood collections per week (as opposed to the number of visits per week).  


#Fig.6Number of clinical urine collections over time by site
#Add another graph after that one, same graph only KP sites, and base it on the number of urine collections per week (as opposed to the number of visits per week). Title will be Figure X: 

#Table 29: Blood Collection Completeness by Walk-In vs Scheduled for UChicago Site. Change label on last column to 'Total Blood Collections'. Confirm walk-in is defined as participant was verified and had blood collection on same date
#Table 17. Research biospecimen collection visit length (in minutes)
#time_biochk=intck("minute", BL_BioChk_Time_v1r0,BL_BioFin_CheckOutTime_v1r0)
bio_survey$time_biochk <- difftime(as.POSIXct(ymd_hms(bio_survey$d_331584571_d_266600170_d_343048998)),as.POSIXct(ymd_hms(bio_survey$d_331584571_d_266600170_d_840048338)),units="mins")
bio_survey$biochk_outlier <- ifelse(as.numeric(bio_survey$time_biochk)/60 > 24, 1,
                               ifelse( 0<= abs(as.numeric(bio_survey$time_biochk))/60 & abs(as.numeric(bio_survey$time_biochk))/60 <= 24, 0, NA))
statics_biock <- tapply(as.numeric(bio_survey$time_biochk),bio_survey$biochk_outlier,summary)
tab17 <- bind_rows(statics_biock)
tab17$`Outlier Present?` <- ifelse(rownames(statics_biock)==1,"no outliers","outlier")
STD <- bio_survey %>% group_by(biochk_outlier) %>%
  dplyr::summarize(sd(as.numeric(time_biochk)))

tab17 <- cbind(tab17,STD[-3,2])
tapply(as.numeric(bio_survey$time_biochk),bio_survey$biochk_outlier,sd)
#Figure 17. Research biospecimen collection visit length (in minutes)
boxplot(as.numeric(bio_survey$time_biochk),main="Figure 17. Research biospecimen collection visit length (in minutes)",
        ylab="Visit Length (minutes)") 
abline(h=1440, col="red")



#Table 17b. Research biospecimen collection visit length by site (in minutes)
sv_time<- bio_survey %>% group_by(biochk_outlier, d_827220437.y) %>%
  dplyr::summarize(mean=mean(as.numeric(time_biochk)),sd=sd(as.numeric(time_biochk)), 
                   min=min(as.numeric(time_biochk)),
                   Q1=quantile(as.numeric(time_biochk),probs=0.25,na.rm=TRUE),
                   median=median(as.numeric(time_biochk)),
                   Q3=quantile(as.numeric(time_biochk),probs=0.75,na.rm=TRUE), max=max(as.numeric(time_biochk)))
sv_time <- apply_labels(sv_time,
                        d_827220437.y = "Site",#RcrtES_Site_v1r0
                        d_827220437.y = c("HealthPartners"= 531629870, "Henry Ford Health System"=548392715, "Kaiser Permanente Colorado" = 125001209,
                                        "Kaiser Permanente Georgia" = 327912200,"Kaiser Permanente Hawaii" = 300267574,"Kaiser Permanente Northwest" = 452412599,
                                        "Marshfield Clinic Health System" = 303349821,"Sanford Health" = 657167265, "University of Chicago Medicine" = 809703864,
                                        "National Cancer Institute" = 517700004,"National Cancer Institute" = 13,"Other" = 181769837),
                        biochk_outlier = "Outlier Present?",
                        biochk_outlier = c("No outliers"= 0, "Outliers"=1, "Missing(Not Checkout)"=" "))
library(plyr)
sv_time <- sv_time %>% mutate(Site= case_when(d_827220437.y ==125001209 ~ "KPCO", 
                                              d_827220437.y == 327912200 ~ "KPGA", 
                                              d_827220437.y == 452412599 ~ "KPNW", 
                                              d_827220437.y == 303349821 ~ "Marshfield",
                                              d_827220437.y == 300267574 ~ "KPHI",
                                              d_827220437.y == 531629870 ~ "HP", 
                                              d_827220437.y == 548392715 ~ "HFHS",
                                              d_827220437.y == 657167265 ~ "SH",
                                              d_827220437.y == 809703864 ~ "UoCh", 
                                              d_827220437.y == 517700004 ~ "NIH",
                                              d_827220437.y == 181769837 ~ "Others"),
                            `Outlier Present?` = case_when(biochk_outlier == 0 ~ "No outliers",
                                                           biochk_outlier == 1 ~ "Outliers",
                                                           is.na(biochk_outlier)  ~ "Missing(Not Checkout)"))


#Figure 17b. Research biospecimen collection visit length by site (in minutes)
bio_survey <- bio_survey %>% mutate(Site= case_when(d_827220437.y ==125001209 ~ "KPCO", 
                                              d_827220437.y == 327912200 ~ "KPGA", 
                                              d_827220437.y == 452412599 ~ "KPNW", 
                                              d_827220437.y == 303349821 ~ "Marshfield",
                                              d_827220437.y == 300267574 ~ "KPHI",
                                              d_827220437.y == 531629870 ~ "HP", 
                                              d_827220437.y == 548392715 ~ "HFHS",
                                              d_827220437.y == 657167265 ~ "SH",
                                              d_827220437.y == 809703864 ~ "UoCh", 
                                              d_827220437.y == 517700004 ~ "NIH",
                                              d_827220437.y == 181769837 ~ "Others"),
                              `Outlier Present?` = case_when(biochk_outlier == 0 ~ "No outliers",
                                                             biochk_outlier == 1 ~ "Outliers",
                                                             is.na(biochk_outlier)  ~ "Missing(Not Checkout)"))

ggplot(bio_survey, aes(x=Site, y=as.numeric(time_biochk),fill=Site,color=Site)) + 
  geom_boxplot() + geom_jitter(width = 0.2) +   scale_fill_brewer(palette="Dark2") +
  geom_hline(linetype = "dashed", yintercept = 1440,color="red") + 
  ggtitle("Research biospecimen collection visit length (in minutes) by site") +
          ylab("Visit Length (minutes)") + xlab("Site") +
  scale_y_continuous(limits = c(0, 50000)) +
  theme(panel.background = element_blank(),
        legend.title = element_text(size=7),
        axis.line = element_line(size=0.2),
        axis.text.x = element_text(hjust = 0.5,size = 8, face = "bold"),                                                            
        plot.title = element_text(hjust = 0.5,size = 12, face = "bold"))

##Figure 4. Number of biospecimen collection visits over time by site
recr_survey1 <- merge(recr_bio1, biospe2, by="Connect_ID")
table(recr_survey1$d_650516960) #534621077 645
recr_survey1 <- recr_survey1[which(recr_survey1$d_650516960==534621077),]
#BioCol_Starttime*wk*wk_date*RcrtES_Site_v1r0
#Table 18. Number of Blood Collection Completions By the Final Collection day of the week of Chicago Site
##to check the days of week for the collection in Chicago site
#d_556788178	as BioRec_CollectFinalTime_v1r0,
#d_678166505	as BioCol_ColTime_v1r0 "Collection Date/Time"
# if RcrtES_Site_v1r0=809703864 then Chicago=1;
# else chicago=0;
# if BioRec_CollectFinalTime_v1r0 ^=. and RcrtV_VerificationTm_V1R0 ^=. then do;
# BioRec_CollectFinalWeekDay_v1r0 =weekday(datepart(BioRec_CollectFinalTime_v1r0));
# attrib BioRec_CollectFinalWeekDay_v1r0 label="day of the week for Collection Entry Finalized" format=wkdayfmt.;
# end;
recr_survey1 <- recr_survey1 %>% mutate(weekday = weekdays(as.POSIXct(ymd_hms(d_556788178))),
                                    chicago = ifelse(d_827220437.y == 809703864, "Chicago","non Chicago"),
                                    start.date = min(as.POSIXct(ymd_hms(d_678166505))),
                                    current.date=max(as.POSIXct(ymd_hms(d_678166505))),
                                    BioRec_CollectScheduled = ifelse(as.Date(as.POSIXct(ymd_hms(d_556788178))) == as.Date(as.POSIXct(ymd_hms(d_914594314))),1,0))
                                    
                                    
recr_survey1$visit.wk <- ceiling(as.numeric(difftime(as.POSIXct(ymd_hms(recr_survey1$d_678166505)),as.POSIXct(ymd_hms(recr_survey1$start.date)), units="weeks")))
visit_wk <- recr_survey1[,c("Connect_ID","d_678166505","d_827220437.y","d_556788178","start.date","visit.wk","weekday","chicago")]

visit_wk_site <- as.data.frame(CrossTable(visit_wk$d_827220437.y,visit_wk$visit.wk, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)$t)

visit_wk_site$start.date <- unique(visit_wk$start.date)
week.date <- as.data.frame(seq(as.Date(as.POSIXct(ymd_hms(unique(visit_wk$start.date)))),as.Date(as.POSIXct(ymd_hms(unique(recr_survey1$current.date)))),by='week'))
names(week.date) <- "week.date"
week.date$week <- rownames(week.date)
visit_wk_site <- visit_wk_site[order(visit_wk_site$x),]
visit_wk_site$week.date <- week.date$week.date
visit_wk_site <- visit_wk_site %>% mutate(Site= case_when(x ==125001209 ~ "KPCO", 
                                                          x == 327912200 ~ "KPGA", 
                                                          x == 452412599 ~ "KPNW", 
                                                          x == 303349821 ~ "Marshfield",
                                                          x == 300267574 ~ "KPHI",
                                                          x == 531629870 ~ "HP", 
                                                          x == 548392715 ~ "HFHS",
                                                          x == 657167265 ~ "SH",
                                                          x == 809703864 ~ "UoCh", 
                                                          x == 517700004 ~ "NIH",
                                                          x == 181769837 ~ "Others"))

ggplot(visit_wk_site, aes(x=as.Date(week.date), y=Freq,fill=Site, color=Site)) +
  geom_line() + 
  geom_point() +
  xlab("Date") + ylab("Number of Visits")+ scale_fill_brewer(palette="Dark2") + 
  ggtitle(label="Number of biospecimen collection visits over time by site") +
  #theme_ipsum() +
  theme(panel.background = element_blank(),
        legend.title = element_text(size=7),
        axis.line = element_line(size=0.2),
        axis.text.x = element_text(angle=60, hjust = 0.5,size = 8, face = "bold"),                                                            
        plot.title = element_text(hjust = 0.5,size = 12, face = "bold")) +
  scale_x_date(limit=c(as.Date("2022-06-10"),as.Date("2022-10-16"))) + scale_y_continuous(breaks = seq(0, 30, by = 3))


wk_visit<-ggplot(visit_wk_site[which(visit_wk_site$Freq>0),], aes(x=as.Date(week.date), y=Freq,fill=Site, color=Site)) +
  geom_line() + 
  geom_point() +
  xlab("Date") + ylab("Number of Visits")+ scale_fill_brewer(palette="Dark2") + 
  ggtitle(label="Number of biospecimen collection visits over time by site") +
  #theme_ipsum() +
  theme(panel.background = element_blank(),
        legend.title = element_text(size=7),
        axis.line = element_line(size=0.2),
        axis.text.x = element_text(angle=60, hjust = 1,size = 8, face = "bold"),                                                            
        plot.title = element_text(hjust = 0.5,size = 12, face = "bold")) +
  scale_x_date(limit=c(as.Date("2022-06-13"),as.Date("2022-10-16")),date_breaks = "1 week", date_labels = "%Y %b %d") +
  scale_y_continuous(breaks = seq(0, 30, by = 3))

visit_wk_site1 <- cbind(visit_wk_sit,rep(week.date,6))



#Table 18. Table 18. Number of Blood Collection Completions By the Final Collection day of the week of Chicago site
# if datepart(BioRec_CollectFinalTime_v1r0)=datepart(RcrtV_VerificationTm_V1R0) then BioRec_CollectScheduled=0;
# else  BioRec_CollectScheduled=1;

#attrib BioRec_CollectScheduled label="Biospecimen collections by walk-in or scheduled" format=collschedulefmt.;
recr

recr_chicago <- filter(recr_survey1,chicago=="Chicago")
table(recr_chicago$weekday,recr_chicago$BioFin_BaseBLDComplt_v1r0)
recr_chicago <- apply_labels(recr_chicago,
                            BioFin_BaseBLDComplt_v1r0 = "Baseline Blood collection completion",
                            BioFin_BaseBLDComplt_v1r0 = c("No Blood Tubes Collected"= 0,"PartialBloodTubesCollected"= 1,"All Blood Tubes Collected"=2),
                            BioFin_BaseBLDCol_v1r0 = "Baseline Blood collection",
                            BioFin_BaseBLDCol_v1r0 = c("No Blood Tubes Collected"=0,"Any BloodTubesCollected"= 1),
                            BioRec_CollectScheduled = "Biospecimen collections by walk-in or scheduled",
                            BioRec_CollectScheduled = c("walk-in"=0,"scheduled"=1))

biospe1$RcrtES_Site_v1r0 <- factor(biospe1$d_827220437, exclude = NULL) 
recr_chicago$BioFin_BaseBLDComplt_v1r0 <- factor(recr_chicago$BioFin_BaseBLDComplt_v1r0,exclude=NULL)
recr_chicago$BioRec_CollectScheduled <- factor(recr_chicago$BioRec_CollectScheduled,exclude=NULL)
library(gtsummary)
table19 <- recr_chicago %>% select(weekday,BioFin_BaseBLDComplt_v1r0) %>% 
  tbl_summary(by=BioFin_BaseBLDComplt_v1r0, missing="no") %>% add_n() %>%
  bold_labels() %>%
  italicize_levels()  %>% as_kable(include=everything(),caption="Table 18. Number of Blood Collection Completions By the Final Collection day of the week of Chicago site")
  
#Table 19. Number of Blood Collection Completions By the Final Collection Schedule/Walk-in 
"Table19. Number of Blood Collection Completions By the Final Collection Schedule/Walk-in"

recr_chicago <- recr_chicago[]
table18 <- recr_chicago %>%select(BioFin_BaseBLDComplt_v1r0,BioRec_CollectScheduled) %>%
     tbl_summary(by=BioRec_CollectScheduled,missing="no") %>% add_n() %>% bold_labels() %>% italicize_levels() %>% 
  as_kable(include=everything(),caption="Table 19. Number of Blood Collection Completions By the Final Collection Schedule/Walk-in of Chicago site")
  as_gt() %>%
  gt::tab_header(title ="Table 19. Number of Blood Collection Completions By the Final Collection Schedule/Walk-in of Chicago site")
  #tab_header(title = "Patient Characteristics", subtitle = "Presented by treatment")

  display.brewer.all(colorblindFriendly = TRUE) 
barplot(1:10,col = brewer.pal(n = 10, name = "Set2"))
col = brewer.pal(n = 10, name = "Spectral")
display.brewer.all()  


table(biospe$bldcol) #08012022
#0   4   5 
# 5   1 102 
table(biospe$blddev) #08012022
#0  1  2  3  4  5 
#90 10  4  1  1  2 

table(biospe$blddid)
#tubediscard <- melt(biospe,)


table(biospe$d_331584571) ##all baseline biospecimen collections
###to merge with recruit verified
recr_veri <- data1[which(data1$d_821247024==197316935),select=biovar]
recr_veri$site <- recode(recr_veri$d_827220437, '125001209'="KPCO", '327912200'="KPGA", '452412599'="KPNW", '303349821'="Marshfield",
                         '300267574'="KPHI",'531629870'="HP",'548392715'="HFHS",'657167265'="SH",'809703864'="UoCh", 
                         '517700004'="NIH",'181769837'="Others")

biospe$urine <- ifelse(biospe$d_973670172_d_593843561== 353358909,1,0) ##1 not collected only
biospe$mw <- ifelse(biospe$d_143615646_d_593843561== 353358909,1,0) ##all connected
biospe$blood <-ifelse(biospe$bldcol == 5, 2, ifelse( biospe$bldcol<5 & biospe$bldcol>0,1,0)) #blood collection completion
table(recrver_bio$blood)
recrver_bio <- merge(recr_veri,biospe,by="Connect_ID",all.x=TRUE) ###join left
###to create the Table1 for the Percent (and number) of verified participants with baseline biospecimen collections by site
recrver_bio$urine <- ifelse(recrver_bio$d_973670172_d_593843561== 353358909,1,0) ##1 not collected only
recrver_bio$mw <- ifelse(recrver_bio$d_143615646_d_593843561== 353358909,1,0) ##all connected
recrver_bio$blood <-ifelse(recrver_bio$bldcol == 5, 2, ifelse( recrver_bio$bldcol<5 & recrver_bio$bldcol>0,1,0))
recrver_bio <- recrver_bio[,c("blood","urine","mw")] %>% mutate_at(vars(blood, urine, mw), ~replace_na(., 0))

long.ls <- c("d_593843561","d_678857215", "d_825582494","d_883732523","d_762124027","d_338286049","d_536710547")



























recrver_bio <- read.sas7bdat("~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_recrbio_merged_09192022.sas7bdat")



time.var <- c("BioCol_ColTime_v1r0", "BioRec_CollectFinalTime_v1r0", "BL_BioFin_BBTime_v1r0","BL_BioFin_BMTime_v1r0","BL_BioFin_BUTime_v1r0",
              "BL_BioChk_Time_v1r0","BL_BioFin_CheckOutTime_v1r0")

biotime <-recrver_bio[,c("Connect_ID","BioSpm_ColIDEntered_v1r0",time.var)]

##to remove the duplicate connect_ID
recrver_bio1 <- recrver_bio[order(recrver_bio$BioCol_ColTime_v1r0,decreasing=TRUE),]
recrver_bio1 <- recrver_bio1 [!(duplicated(recrver_bio1$Connect_ID)),]

###Table 1 Percent (and number) of verified participants with baseline biospecimen collections by site
recrver_bio1$RcrtES_Site_v1r0 <- dplyr::recode(as.character(recrver_bio1$RcrtES_Site_v1r0), "125001209" = "KPCO", "327912200"="KPGA", "452412599"="KPNW", 
                                        "303349821" ="Marshfield","300267574"="KPHI","531629870"="HP","548392715"="HFHS","657167265"="SH",
                                        "809703864"="UoCh", "517700004"="NIH","181769837"="Others")
# recrver_bio1 <- apply_labels(recrver_bio1,
#                              RcrtSI_RecruitType_v1r0 = "Recruitment type",
#                              RcrtSI_RecruitType_v1r0=c(	"Not active"=180583933,  
#                                                          "Active"= 486306141, 
#                                                           "Passive"=854703046),
#                              RcrtV_Verification_v1r0 = "Verification status",
#                              RcrtV_Verification_v1r0 = c("Not yet verified" =875007964,
#                                                             "Verified"=197316935,  
#                                                              "Cannot be verified"=219863910, 
#                                                             "Duplicate"=922622075 , 
#                                                             "Outreach timed out"= 160161595),
#                              RcrtES_Site_v1r0 = "Site",
#                              RcrtES_Site_v1r0 = c("HealthPartners"= 531629870, "Henry Ford Health System"=548392715, "Kaiser Permanente Colorado" = 125001209,
#                                   "Kaiser Permanente Georgia" = 327912200,"Kaiser Permanente Hawaii" = 300267574,"Kaiser Permanente Northwest" = 452412599,
#                                   "Marshfield Clinic Health System" = 303349821,"Sanford Health" = 657167265, "University of Chicago Medicine" = 809703864,
#                              "National Cancer Institute" = 517700004,"National Cancer Institute" = 13,"Other" = 181769837),
#                              RcrtV_VerificationTm_V1R0 = "Verification status time",
#                              BioFin_BaseBloodCol_v1r0 = "Baseline blood sample collected",
#                              BioFin_BaseBloodCol_v1r0 = c( "No"=104430631, "Yes"=353358909 ),
#                              BL_BioFin_BBTime_v1r0 = "Date/time Blood Collected",
#                              BioFin_BaseMouthCol_v1r0 = "Baseline Mouthwash Collected",
#                              BioFin_BaseMouthCol_v1r0 = c( "No"=104430631, "Yes"=353358909 ),
#                              BL_BioFin_BMTime_v1r0 = "Date/time Mouthwash Collected",
#                              BioFin_BaseUrineCol_v1r0 = "Baseline Urine Collected",
#                              BioFin_BaseUrineCol_v1r0 = c( "No"=104430631, "Yes"=353358909 ),
#                              BL_BioFin_BUTime_v1r0 = "Baseline Date/time Urine Collected",
#                              BL_BioChk_Complete_v1r0 = "Baseline Check-In Complete",
#                              BL_BioChk_Complete_v1r0 =  c( "No"=104430631, "Yes"=353358909 ),
#                              BL_BioChk_Time_v1r0 = "Date/Time Baseline Check-In Complete",
#                              BL_BioFin_CheckOutTime_v1r0 = "Time Baseline check out complete",
#                              BL_BioSpm_BloodSetting_v1r0 = "Blood Collection Setting",
#                              BL_BioSpm_BloodSetting_v1r0 =c("Research"=534621077, "Clinical"= 664882224,"Home" =103209024),
#                              BL_BioSpm_UrineSetting_v1r0 = "Urine Collection Setting",
#                              BL_BioSpm_UrineSetting_v1r0 =c("Research"=534621077, "Clinical"= 664882224,"Home" =103209024),
#                              BL_BioSpm_MWSetting_v1r0 = "Mouthwash Collection Setting",
#                              BL_BioSpm_MWSetting_v1r0 =c("Research"=534621077, "Clinical"= 664882224,"Home" =103209024),
#                              SrvBLM_ResSrvCompl_v1r0 = "Blood/urine/mouthwash combined research survey-Complete",
#                              SrvBLM_ResSrvCompl_v1r0 = c(	"Not Started" =	972455046, "Started"= 615768760,"Submitted"= 231311385),
#                              SrvBLM_TmStart_v1r0 = "Placeholder (Autogenerated) - Date/time Status of Start of blood/urine/mouthwash research survey",
#                              SrvBLM_TmComplete_v1r0 = "Placeholder (Autogenerated)- Date/Time blood/urine/mouthwash research survey completed"
# )


explanatory = "RcrtES_Site_v1r0"
dependent = 'BioFin_BaseBloodCol_v1r0'


recrver_bio1$d_827220437 <- labelled(c("125001209",""), c(yes = 1, no = 2))
#site_long <- site_long %>%  mutate(value_trans = ifelse (site_long$variable == "total active participants", as.numeric(value)/1000, as.numeric(value)))

recrver1 <- recrver1 %>% mutate(BldCollection = ifelse(recrver_bio1$BioFin_BaseBloodCol_v1r0 == 353358909, "YES", "No"))


recrver_bio1 = apply_labels(recrver1,
                            RcrtES_Site_v1r0 = "Site",
                            BioFin_BaseBloodCol_v1r0 = "Baseline blood sample collected"
)
explanatory = "RcrtES_Site_v1r0"
dependent = 'BldCollection'

# var_lab(nps) = ""
# val_lab(nps) = num_lab("
#             -1 Detractors
#              0 Neutralists    
#              1 Promoters    
#")

recrver_bio1 %>%
  summary_factorlist(dependent, explanatory, 
                     p=FALSE, add_dependent_label=TRUE) -> t1

t1[10,c(3,4)] <- table(recrver_bio1$BldCollection)
t1 <- t1 %>% replace_na(list(` ` =  "Total"))
t1$YES[t1$YES == ''] <- "0 (0.0)"

knitr::kable(t1, row.names=FALSE, align=c("l", "l", "r", "r"))
###any biospecimen collection
recrver_bio1 <- recrver_bio1 %>% mutate(BiospeCollection = ifelse((recrver_bio1$BioFin_BaseMouthCol_v1r0 == 353358909 | recrver_bio1$BioFin_BaseBloodCol_v1r0 == 353358909 
                                                                  | recrver_bio1$BioFin_BaseUrineCol_v1r0 == 353358909), "Any biospecimen Collected","No biospecimen collected"))

recrver_bio1 <- recrver_bio1 %>% mutate(BioCollections_v1r0 =case_when((recrver_bio1$BioFin_BaseMouthCol_v1r0 == 353358909 & recrver_bio1$BioFin_BaseBloodCol_v1r0 == 353358909 
                                                                        & recrver_bio1$BioFin_BaseUrineCol_v1r0 == 353358909) ~ "all blood, urine and mouthwash",
                                                                       (recrver_bio1$BioFin_BaseMouthCol_v1r0 == 353358909 & recrver_bio1$BioFin_BaseBloodCol_v1r0 == 353358909 
                                                                        & recrver_bio1$BioFin_BaseUrineCol_v1r0 == 104430631) ~ "Mouthwash and blood, no urine",
                                                                       (recrver_bio1$BioFin_BaseMouthCol_v1r0 == 353358909 & recrver_bio1$BioFin_BaseBloodCol_v1r0 == 104430631 
                                                                        & recrver_bio1$BioFin_BaseUrineCol_v1r0 == 104430631) ~ "Only mouthwash,no blood or urine",
                                                                       (recrver_bio1$BioFin_BaseMouthCol_v1r0 == 104430631 & recrver_bio1$BioFin_BaseBloodCol_v1r0 == 353358909 
                                                                        & recrver_bio1$BioFin_BaseUrineCol_v1r0 == 353358909) ~ "Blood and urine, no mouthwash",
                                                                       (recrver_bio1$BioFin_BaseMouthCol_v1r0 == 104430631 & recrver_bio1$BioFin_BaseBloodCol_v1r0 == 104430631 
                                                                        & recrver_bio1$BioFin_BaseUrineCol_v1r0 == 353358909) ~ "Only urine, no blood or mouthwash",
                                                                       (recrver_bio1$BioFin_BaseMouthCol_v1r0 == 353358909 & recrver_bio1$BioFin_BaseBloodCol_v1r0 == 104430631 
                                                                        & recrver_bio1$BioFin_BaseUrineCol_v1r0 == 353358909) ~ "Mouthwash and urine, no blood",
                                                                       (recrver_bio1$BioFin_BaseMouthCol_v1r0 == 104430631 & recrver_bio1$BioFin_BaseBloodCol_v1r0 == 353358909 
                                                                        & recrver_bio1$BioFin_BaseUrineCol_v1r0 == 104430631) ~ "Only blood, no mouthwash or urine"))
                                        
##Table2
recrver_bio1 = apply_labels(recrver_bio1,
                            RcrtES_Site_v1r0 = "Site",
                            BiospeCollection = "Baseline biospecimen collected"
)


explanatory = "RcrtES_Site_v1r0"
dependent = 'BiospeCollection'
recrver_bio1 %>%
  summary_factorlist(dependent, explanatory, 
                     p=FALSE, add_dependent_label=TRUE) -> t1

t1[10,c(3,4)] <- table(recrver_bio1$BldCollection)
t1 <- t1 %>% replace_na(list(` ` =  "Total"))
t1$YES[t1$YES == ''] <- "0 (0.0)"

###for Baseline biospecimen collection status among verified participants, two more variables in the contingency tables via ftable
label.BioFin_BaseMouthCol_v1r0(BioFin_BaseMouthCol_v1r0, "Baseline Mouthwash Collected") 
label.BioFin_BaseMouthCol_v1r0 <-list(No="104430631", Yes="353358909")
label.BioFin_BaseUrineCol_v1r0 (BioFin_BaseMouthCol_v1r0, "Baseline Urine Collected")
label.BioFin_BaseBloodCol_v1r0 (BioFin_BaseMouthCol_v1r0, "Baseline Blood Collected")


ftable(recrver_bio1$BioFin_BaseBloodCol_v1r0, recrver_bio1$BioFin_BaseUrineCol_v1r0, recrver_bio1$BioFin_BaseMouthCol_v1r0)
#                      104430631 353358909
# 
# 104430631 104430631       2071         0
# 353358909          0        18
# 353358909 104430631          0         7
# 353358909          1       385

box_auth(client_id = "627lww8un9twnoa8f9rjvldf7kb56q1m",
         client_secret = "gSKdYKLd65aQpZGrq9x4QVUNnn5C8qqm") 
box_setwd(dir_id = 170816197126) 

bptl <- box_read(file_id=1025345093210)

###time
# ReceiptToFrozenTm = Date_Frozen - Date_Received
bptl$Rpt2FreezenTm <- difftime(as.POSIXct(ymd_hms(bptl$`Date Frozen`)), as.POSIXct(ymd_hms(bptl$`Date Received`)),units="secs")
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# -40500    9900   11580   17064   14280  212520    2888 

# NeedleToFreezerTm = Date_Frozen - Date_Drawn
bptl$Needle2FreezenTm <- difftime(as.POSIXct(ymd_hms(bptl$`Date Frozen`)), as.POSIXct(ymd_hms(bptl$`Date Drawn`)),units="secs")
# > summary(as.numeric(bptl$Needle2FreezenTm))
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#   35880   93960  101640  118579  111420  438120    2888 
bptl$Needle2FreezenHrs <- difftime(as.POSIXct(ymd_hms(bptl$`Date Frozen`)), as.POSIXct(ymd_hms(bptl$`Date Drawn`)),units="hours")
# > summary(as.numeric(bptl$Needle2FreezenHrs))
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#   9.967  26.100  28.233  32.939  30.950 121.700    2888 

bptl$NeedleToFreezerCatM <- ifelse(bptl$Needle2FreezenHrs >= 96, 7, 
                                   ifelse(72 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 96, 6,
                                          ifelse(48 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 72, 5,
                                                 ifelse(36 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 48, 4,
                                                        ifelse(30 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 36, 3,
                                                               ifelse(24 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs < 30, 2,
                                                                      ifelse(0 <= bptl$Needle2FreezenHrs & bptl$Needle2FreezenHrs <24, 1,NA)))))))
table(bptl$NeedleToFreezerCatM)


bptl_bld <-bptl[which(bptl$`Material Type` %in% c("PLASMA","SERUM")),]
needle_freezen_bld <- bptl_bld %>%
  group_by(`Material Type`,NeedleToFreezerCatM) %>%
  dplyr::summarize(count=n()/sum(n()))

table1 <- CrossTable(bptl_bld$NeedleToFreezerCatM,bptl_bld$`Material Type`, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)

pct <- as.data.frame(cbind(table1$prop.col,table1$t))
Tmcat <- c("<24 Hours","24 to < 30 Hours","30 to < 36 Hours", "36 to < 48 Hours","48 to < 72 Hours", "72 to < 96 Hours","greater than 96 Hours")

pct$Tmcat <- Tmcat  
colnames(pct)
tb_serum <- pct[,c(2,4,5)]
names(tb_serum) <- c("serum_pct","serum_N","Needle_to_Freezer_Time")

tb_serum$Percent <- paste0(round(100*tb_serum$serum_pct,2),"%")
tb_serum <- tb_serum %>% arrange(desc(Needle_to_Freezer_Time)) 
tb_serum$text_y <- cumsum(tb_serum$serum_pct) - tb_serum$serum_pct/2


tb_plasma <- pct[,c(1,3,5)]
names(tb_plasma) <- c("plasma_pct","plasma_N","Needle_to_Freezer_Time")

tb_plasma$Percent <- paste0(round(100*tb_plasma$plasma_pct,2),"%")
tb_plasma <- tb_plasma %>% arrange(desc(Needle_to_Freezer_Time)) 
tb_plasma$text_y <- cumsum(tb_plasma$plasma_pct) - tb_plasma$plasma_pct/2

# pct <- as.data.frame(table1$prop.col)
# 
# colnames(pct) <- c("NeedleToFreezerCatM","Material Type","percentage")
# pct <- pct %>% mutate(Tmcat=case_when(NeedleToFreezerCatM ==1 ~ "<24 Hours",
#                                       NeedleToFreezerCatM ==2 ~ "24 to < 30 Hours",
#                                       NeedleToFreezerCatM ==3 ~ "30 to < 36 Hours",
#                                       NeedleToFreezerCatM ==4 ~ "36 to < 48 Hours",
#                                       NeedleToFreezerCatM ==5 ~ "48 to < 72 Hours Hours",
#                                       NeedleToFreezerCatM ==6 ~ "72 to < 96 Hours Hours",
#                                       NeedleToFreezerCatM ==7 ~ "             > 96 Hours",
#                                       is.na(NeedleToFreezerCatM) ~ "", ),
#                       percent=paste0(round(100*percentage,2),"%"))

mycolors <- brewer.pal(7,"RdYlGn")
mycolors <- c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026")
barplot(c(1:7),col=mycolors)
names(mycolors) <- levels(tb_serum$Needle_to_Freezer_Time)
mycolors[7]
my_color <- setNames(mycolors, nam)

library(ggrepel)
library(ggmap)
ggplot(data=tb_serum, aes(x=" ", y=serum_pct,  fill=Needle_to_Freezer_Time))+
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start = 0)+
  geom_text(aes(y =  serum_pct, label =Percent), color = "white")+
  scale_fill_manual(values = mycolors) +
  theme_void()

ggplot(data = tb_serum, aes(x=" ", y=serum_pct,  fill=Needle_to_Freezer_Time)) +
  geom_col(color = "black") + geom_bar(width = 0.6, stat = "identity") +
  coord_polar("y", start=0) +
  geom_text(aes(x=1.6, label=Percent),
            position =  position_stack(vjust=0.6), size=3) +
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5, size = 18)) +
  scale_fill_manual(values =c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026"))  + 
  ggtitle("Subtypes of HPV in GDC TCGA cervical cancer (CESC)")

outputpathname <- "~/Documents/CONNECT_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/R_Programming/plots/"

serumF <- ggplot(data = tb_serum, aes(x=" ", y=serum_pct,  fill=Needle_to_Freezer_Time)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  geom_label_repel(data=tb_serum,aes(label=Percent , y =text_y ),nudge_x = 0.8,
                   colour="white", segment.colour="black", size = 4, show.legend = F) + 
  ggtitle(label = "Needle to Freezer Time",
          subtitle="Connect for Cancer Prevention Study
                    Five Site
                    06/13/2022-09/27/2022
                    Material Type=Serum") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  scale_fill_manual(values =c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026"))  


plasmaF <- ggplot(data = tb_plasma, aes(x=" ", y=plasma_pct,  fill=Needle_to_Freezer_Time)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  geom_label_repel(data=tb_plasma,aes(label=Percent, y=text_y),nudge_x = 0.8,
                   colour="white", segment.colour="black", size = 4, show.legend = F) + 
  ggtitle(label = "Needle to Freezer Time",
          subtitle="Connect for Cancer Prevention Study
                    Five Site
                    06/13/2022-09/27/2022
                    Material Type=Serum") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  scale_fill_manual(values =c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026"))  


biospe_plot1 <- list(serumF,plasmaF)
out1 <- paste(outputpathname,"Biospecimen_freezer_receipt_time_forMN_09302022.pdf",sep="")
png(out1,height=800,width=1200) 
grid.arrange(grobs = biospe_plot1, ncol = 2) ## display plot
ggsave(file = out1, arrangeGrob(grobs = biospe_plot1, ncol = 2))  

###for the ReceiptToProcessedTm = "Time From Receipt of Sample to Processed
#IF ReceiptToProcessedTm = . THEN DELETE;
#ELSE IF ReceiptToProcessedTm < 0 THEN DELETE;

# 1 = "<30 minutes" 
# 2 = "30 min to 1 hour"
# 3 = "1 to 1.5 hours"
# 4 = "1.5 to 2 hours"
# 5 = "2 to 2.5 hours"
# 6 = "2.5 to 3 hours"
# 7 = "3 to 3.5 hours"
# 8 = "3.5 to 4 hours"
# 9 = "4 to 8 hours"
# 10 = "8 to 20 hours"
# 11 = "20 to 24 hours"
# 12 = "24 to 48 hours"
# 13 = "48 to 72 hours"
# 14 = "72 to 96 hours"
# 15 = "Over 96 hours"
# IF ReceiptToProcessedHrs = . THEN ReceiptToProcessedCatM = .;
# ELSE IF ReceiptToProcessedHrs < 0.5 THEN ReceiptToProcessedCatM = 1;
# ELSE IF 0.5 LE ReceiptToProcessedHrs < 1 THEN ReceiptToProcessedCatM = 2;
# ELSE IF 1 LE ReceiptToProcessedHrs < 1.5 THEN ReceiptToProcessedCatM = 3;
# ELSE IF 1.5 LE ReceiptToProcessedHrs < 2 THEN ReceiptToProcessedCatM = 4;
# ELSE IF 2 LE ReceiptToProcessedHrs < 2.5 THEN ReceiptToProcessedCatM = 5;
# ELSE IF 2.5 LE ReceiptToProcessedHrs < 3 THEN ReceiptToProcessedCatM = 6;
# ELSE IF 3 LE ReceiptToProcessedHrs < 3.5 THEN ReceiptToProcessedCatM = 7;
# ELSE IF 3.5 LE ReceiptToProcessedHrs < 4 THEN ReceiptToProcessedCatM = 8;
# ELSE IF 4 LE ReceiptToProcessedHrs < 8 THEN ReceiptToProcessedCatM = 9;
# ELSE IF 8 LE ReceiptToProcessedHrs < 20 THEN ReceiptToProcessedCatM = 10;
# ELSE IF 20 LE ReceiptToProcessedHrs < 24 THEN ReceiptToProcessedCatM = 11;
# ELSE IF 24 LE ReceiptToProcessedHrs < 48 THEN ReceiptToProcessedCatM = 12;
# ELSE IF 48 LE ReceiptToProcessedHrs < 72 THEN ReceiptToProcessedCatM = 13;
# ELSE IF 72 LE ReceiptToProcessedHrs < 96 THEN ReceiptToProcessedCatM = 14;
# ELSE IF ReceiptToProcessedHrs GE 96 THEN ReceiptToProcessedCatM = 15;
# LABEL ReceiptToProcessedCatM = "Time";

bptl$RptToProcessedHrs <-  difftime(as.POSIXct(ymd_hms(bptl$`Date Processed`)), as.POSIXct(ymd_hms(bptl$`Date Received`)),units="hours")
bptl$RptToProcessedCatM <- ifelse(bptl$RptToProcessedHrs >= 96, 15, 
                            ifelse(72 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 96, 14,
                             ifelse(48 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 72, 13,
                              ifelse(24 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 48, 12,
                               ifelse(20 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 24, 11,
                                ifelse(8 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 20, 10,
                                 ifelse(4 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 8.0, 9,                                   
                                  ifelse(3.5 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 4.0, 8,
                                   ifelse(3 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 3.5, 7,
                                    ifelse(2.5 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 3.0, 6,
                                     ifelse(2 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 2.5, 5,
                                      ifelse(1.5 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 2.0, 4,
                                        ifelse(1 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 1.5, 3,
                                         ifelse(0.5 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs < 1.0, 2,
                                          ifelse(0 <= bptl$RptToProcessedHrs & bptl$RptToProcessedHrs <0.5, 1,NA                                             
                                                           )))))))))))))))

table(bptl$RptToProcessedCatM)
tapply(as.numeric(bptl$Rpt2ProcessedTm),as.character(bptl$RptToProcessedCatM),summary)
table2 <- CrossTable(bptl_bld$RptToProcessedCatM,bptl_bld$`Material Type`, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)

pct2 <- as.data.frame(cbind(table2$prop.col,table2$t))
#
PrTmcat <- c("< 0.5 Hours","0.5 to < 1 Hours","1 to < 1.5 Hours", "1.5 to < 2 Hours","2 to < 2.5 Hours", "2.5 to < 3 Hours", "3 to < 3.5 Hours",
             "3.5 to < 4 Hours","4 to < 8 Hours", "8 to < 20 Hours","20 to < 24 Hours", "24 to < 48 Hours","48 to < 72 Hours", "72 to < 96 Hours","greater than 96 Hours")
pct2$PrTmcat <- PrTmcat[c(1:6,8:11,13)]


mycolors <- brewer.pal(11,"RdBu")
mycolors <- c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026")
barplot(c(1:11),col=mycolors)
brewer.pal(n = 11, name = "RdBu")
##[1] "#67001F" "#B2182B" "#D6604D" "#F4A582" "#FDDBC7" "#F7F7F7" "#D1E5F0" "#92C5DE" "#4393C3" "#2166AC" "#053061"
mycolors <- c("#67001F", "#B2182B", "#D6604D", "#F4A582", "#FDDBC7", "#F7F7F7", "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC", "#053061")
names(mycolors) <- fct_rev(tb_serum$Receipt_to_Processing_Time)

type <- c("SERUM","PLASMA")

pct2$PrTmcat <- PrTmcat  
colnames(pct2) #[1] "PLASMA"  "SERUM"   "PLASMA"  "SERUM"   "PrTmcat"
tb_serum <- pct2[,c(2,4,5)]
names(tb_serum) <- c("serum_pct","serum_N","Receipt_to_Processing_Time")

tb_serum$Percent <- paste0(round(100*tb_serum$serum_pct,2),"%")
tb_serum <- tb_serum %>% arrange(desc(Receipt_to_Processing_Time)) 
tb_serum$text_y <- cumsum(tb_serum$serum_pct) - tb_serum$serum_pct/2

serum1 <- ggplot(data = tb_serum[which(tb_serum$serum_N !=0),], aes(x=" ", y=serum_pct,  fill=Receipt_to_Processing_Time)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  geom_label_repel(data=tb_serum[which(tb_serum$serum_N !=0),],aes(label=Percent , y =text_y ),nudge_x = 1,nudge_y=0.1,
                   colour="white", segment.colour="black", size = 4, show.legend = F) + 
  ggtitle(label = "Receipt to Processing Time",
          subtitle="Connect for Cancer Prevention Study
                    Five Site
                    06/13/2022-09/27/2022
                    Material Type=Serum") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  scale_fill_manual(values =mycolors)


pct2$PrTmcat <- PrTmcat  
colnames(pct2) #[1] "PLASMA"  "SERUM"   "PLASMA"  "SERUM"   "PrTmcat"
tb_serum <- pct2[,c(1,3,5)]
names(tb_serum) <- c("serum_pct","serum_N","Receipt_to_Processing_Time")

tb_serum$Percent <- paste0(round(100*tb_serum$serum_pct,2),"%")
tb_serum <- tb_serum %>% arrange(desc(Receipt_to_Processing_Time)) 
tb_serum$text_y <- cumsum(tb_serum$serum_pct) - tb_serum$serum_pct/2

serum1 <- ggplot(data = tb_serum[which(tb_serum$serum_N !=0),], aes(x=" ", y=serum_pct,  fill=Receipt_to_Processing_Time)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  geom_label_repel(data=tb_serum[which(tb_serum$serum_N !=0),],aes(label=Percent , y =text_y ),nudge_x = 1,nudge_y=0.1,
                   colour="green", segment.colour="black", size = 4, show.legend = F) + 
  ggtitle(label = "Receipt to Processing Time",
          subtitle="Connect for Cancer Prevention Study
                    Five Site
                    06/13/2022-09/27/2022
                    Material Type=Serum") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  scale_fill_manual(values =mycolors)

print(serum1)

tb_plasma <- pct2[,c(1,3,5)]
names(tb_plasma) <- c("plasma_pct","plasma_N","Receipt_to_Processing_Time")

tb_plasma$Percent <- paste0(round(100*tb_plasma$plasma_pct,2),"%")
tb_plasma <- tb_plasma %>% arrange(desc(Receipt_to_Processing_Time)) 
tb_plasma$text_y <- cumsum(tb_plasma$plasma_pct) - tb_plasma$plasma_pct/2

plasma1 <- ggplot(data = tb_plasma[which(tb_plasma$plasma_N !=0),], aes(x=" ", y=plasma_pct,  fill=Receipt_to_Processing_Time)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  geom_label_repel(data=tb_plasma[which(tb_plasma$plasma_N !=0),],aes(label=Percent , y =text_y ),nudge_x = 1,nudge_y=-0.1,
                   colour="green", segment.colour="black", size = 4, show.legend = F) + 
  ggtitle(label = "Receipt to Processing Time",
          subtitle="Connect for Cancer Prevention Study
                    Five Site
                    06/13/2022-09/27/2022
                    Material Type=Plasma") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  scale_fill_manual(values =mycolors)


biospe_plot2 <- list(serum1,plasma1)
out2 <- paste(outputpathname,"Biospecimen_processing_receipt_time_forMN_09302022.pdf",sep="")
png(out2,height=800,width=1200) 
grid.arrange(grobs = biospe_plot2, ncol = 2) ## display plot
ggsave(file = out2, arrangeGrob(grobs = biospe_plot2, ncol = 2))  




par(mai = c(2,1))
layout(c(0.5,1),heights=c(0.5,1))

par(mar = c(0, 0, 0, 0))
plot.new()
pie(tb_serum$serum_pct, labels = tb_serum$Percent, col=mycolors[7:1] ,  edges = 100, 
    radius = 0.8)



legend(
  "topright", 
  title = "Needle to Freezer Time",
  legend = c("<24 Hours","24 to < 30 Hours","30 to < 36 Hours", "36 to < 48 Hours","48 to < 72 Hours", "72 to < 96 Hours","> 96 Hours"),
  fill = c("#006837","#1A9850","#66BD63","#A6D96A","#D9EF8B","#D73027","#A50026" ),
  horiz = FALSE,
  cex = 0.6, # PROPER PARAMETER FOR TEXT SIZE
  text.width = 0.7 # SET THE BOX WIDTH
  )
 title (main = "Needle to Freezer Time\n
          Connect for Cancer Prevention Study\n
                      Five Site\n
              06/13/2022-09/27/2022\n
              Material Type=Serum\n")

legend(
  x = 1.2, # DELIBERATE POSITION
  y = 0.5, # DELIBERATE POSITION
  inset = .05, 
  title = "Primary Crime Type", 
  legend = names(Type), # YOU WERE PASSING IN _ALL_ THE REPEAT NAMES
  fill = viridis::viridis_pal(option = "magma", direction=-1)(length(Type)),  # USE THE SAME COLOR PALETTE
  horiz = FALSE,
  cex = 0.6, # PROPER PARAMETER FOR TEXT SIZE
  text.width = 0.7 # SET THE BOX WIDTH
)

ggplot(data=pct, aes(x=" ", y=percent, color=Tmcat, fill=Tmcat))+
  geom_col(aes(Tmcat))+geom_bar(width=1, stat="identity")
  coord_polar("y", start=0)  +
  geom_text(aes(label = percent),
            position = position_stack(vjust = 0.5)) + 
  facet_grid(.~ `Material Type`) +theme_void() + scale_colour_manual(names="Needle to Freezer Time range",values=mycolors)


serum <- pct[which(pct$`Material Type` =="SERUM"),]
ggplot(serum,aes(x = "", y = percent,fill=Tmcat)) + 
  geom_col(aes(colour = Tmcat),width = 1, color = 1) +
  scale_colour_hue("Tmcat") +
  labs(  fill = "Tmcat" ) +
  coord_polar(theta = "y") +
  theme_void()


# needle_freezen_bld$pctcol <- do.call(rbind,)
# needle_freezen_bld <- needle_freezen_bld  %>% mutate(Tmcat=case_when(NeedleToFreezerCatM ==1 ~ "<24 Hours",
#                                      NeedleToFreezerCatM ==2 ~ "24 to < 30 Hours",
#                                      NeedleToFreezerCatM ==3 ~ "30 to < 36 Hours",
#                                      NeedleToFreezerCatM ==4 ~ "36 to < 48 Hours",
#                                      NeedleToFreezerCatM ==5 ~ "48 to < 72 Hours Hours",
#                                      NeedleToFreezerCatM ==6 ~ "72 to < 96 Hours Hours",
#                                      NeedleToFreezerCatM ==7 ~ "> 96 Hours",
#                                      is.na(NeedleToFreezerCatM) ~ "", 
# ))

needle_freezen_bld1 <- merge(needle_freezen_bld, pct, by.x=c("`Material Type`","NeedleToFreezerCatM"), by.y=c("y","x"))

ggplot(data=na.omit(needle_freezen_bld), aes(x=" ", y=count, group=Tmcat, colour=Tmcat, fill=Tmcat)) +

  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  scale_colour_gradient2() + 
  facet_grid(.~ `Material Type`) +theme_void()


# ReceiptToProcessedTm = Date_Processed - Date_Received
bptl$ReceiptToProcessedTm <- difftime(as.POSIXct(ymd_hms(bptl$`Date Processed`)), as.POSIXct(ymd_hms(bptl$`Date Received`)),units="secs")
# > summary(as.numeric(bptl$ReceiptToProcessedTm))
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max.     NA's 
# -2676720     2160     2880    -8896     4440   174480      307 
# received_neg <- bptl[which(bptl$ReceiptToProcessedTm < 0),]
# table(received_neg$`Sample Collection Center`)
# 
# HP Research Clinic                  Marshfield         SF Cancer Center LL University of Chicago, IPPH 
# 205                         139                          48                          69 

# NeedleToFreezerHrs = NeedleToFreezerTm / 3600;

# 
# PROC FORMAT;
# VALUE NeedleToFreezerCatMFmt 
# 1 = "<24 Hours"
# 2 = "24 to <30 Hours"
# 3 = "30 to <36 Hours"
# 4 = "36 to <48 Hours"
# 5 = "48 to <72 Hours"
# 6 = "72 to <96 Hours"
# 7 = "Over 96 Hours"
# IF NeedleToFreezerHrs = . THEN NeedleToFreezerCatM = .;
# ELSE IF NeedleToFreezerHrs < 24 THEN NeedleToFreezerCatM = 1;
# ELSE IF 24 LE NeedleToFreezerHrs < 30 THEN NeedleToFreezerCatM = 2;
# ELSE IF 30 LE NeedleToFreezerHrs < 36 THEN NeedleToFreezerCatM = 3;
# ELSE IF 36 LE NeedleToFreezerHrs < 48 THEN NeedleToFreezerCatM = 4;
# ELSE IF 48 LE NeedleToFreezerHrs < 72 THEN NeedleToFreezerCatM = 5;
# ELSE IF 72 LE NeedleToFreezerHrs < 96 THEN NeedleToFreezerCatM = 6;
# ELSE IF NeedleToFreezerHrs GE 96 THEN NeedleToFreezerCatM = 7;
# LABEL NeedleToFreezerCatM = "Time";
# FORMAT NeedleToFreezerCatM NeedleToFreezerCatMFmt.;
# 
# if Material_Type=' ' then Material_Type='Overall'
# if Collection_Center=' ' then Collection_Center='Overall';
# IF ReceiptToFrozenTm = . THEN DELETE;
# ELSE IF ReceiptToFrozenTm < 0 THEN DELETE;

##Time From Needle to Frozen Data Processing
bptl$Rpt2FreezenTm <- difftime(as.POSIXct(ymd_hms(bptl$`Date Drawn`)), as.POSIXct(ymd_hms(bptl$`Date Frozen`)),units="secs")


biospe1 = apply_labels(biospe1,
                       d_827220437 = "Site",#RcrtES_Site_v1r0
                       d_827220437 = c("HealthPartners"= 531629870, "Henry Ford Health System"=548392715, "Kaiser Permanente Colorado" = 125001209,
                                       "Kaiser Permanente Georgia" = 327912200,"Kaiser Permanente Hawaii" = 300267574,"Kaiser Permanente Northwest" = 452412599,
                                       "Marshfield Clinic Health System" = 303349821,"Sanford Health" = 657167265, "University of Chicago Medicine" = 809703864,
                                       "National Cancer Institute" = 517700004,"National Cancer Institute" = 13,"Other" = 181769837),
                        BioFin_BaseBLDComplt_v1r0 = "Baseline Blood collection completion",
                        BioFin_BaseBLDComplt_v1r0 = c("No Blood Tubes Collected"= 0,"PartialBloodTubesCollected"= 1,"All Blood Tubes Collected"=2),
                       BioFin_BaseBLDCol_v1r0 = "Baseline Blood collection",
                       BioFin_BaseBLDCol_v1r0 = c("No Blood Tubes Collected"=0,"Any BloodTubesCollected"= 1)
                       #d_973670172 ="Baselin Urine Collection",
                       #d_973670172 =c("No Blood Tubes Collected"=0,"Any Urine Tubes Collected"= 1),
                       #"Urine,"d_143615646

                       )

# # biospe1$RcrtES_Site_v1r0 <- factor(biospe1$d_827220437, exclude = NULL) 
# recr_biospe$BioFin_BaseBLDComplt_v1r0 <- factor(recr_biospe$BioFin_BaseBLDComplt_v1r0,exclude=NULL)
# table(recr_biospe$RcrtES_Site_v1r0,recr_biospe$BioFin_BaseBLDComplt_v1r0)
# 
# summary(biospe1$RcrtES_Site_v1r0)
# recrver1 = apply_labels(biospe1,
#                         RcrtES_Site_v1r0 = "Site",
#                         BioFin_BaseBLDComplt_v1r0 = "Baseline Blood collection completion"
# )
# 
# explanatory = "RcrtES_Site_v1r0"
# dependent = 'BioFin_BaseBLDComplt_v1r0'
# biospe1 %>%
#   summary_factorlist(dependent, explanatory, 
#                      p=FALSE, add_dependent_label=TRUE) -> t5


str(Table17)
# Table17_dev <- biospe %>% mutate(deviation=ifelse(tubedev>0,"Any Deviation","No Deviation")) %>% 
#   select(Site,deviation) %>%
#  tbl_cross(    col = deviation,
#                row = Site,
#                percent = "row",
#                label=deviation ~ 'Biospecimen Collection Deviations',
#                missing='ifany') %>%
#  bold_labels() %>%
#  italicize_levels() %>% 
#  modify_header() %>%
#  modify_caption("**Table 17. Number (and percent) of tubes with any deviation by site**") %>%
#  as_kable()#tab_header(title = "Patient Characteristics", subtitle = "Presented by treatment")

# tb10 <- as.data.frame(CrossTable(biospe1$tubedev,biospe1$d_827220437,prop.t=FALSE, prop.r=FALSE, prop.c=FALSE,prop.chisq=FALSE)$t)
# tb10_w <- reshape(tb10, idvar="y",timevar="x",direction="wide")
# tb10_w$total <- 7*(tb10_w$Freq.0+tb10_w$Freq.1+tb10_w$Freq.2+tb10_w$Freq.3+tb10_w$Freq.4+tb10_w$Freq.5)
# tb10_w$deviation <- tb10_w$Freq.1+2*tb10_w$Freq.2+3*tb10_w$Freq.3+4*tb10_w$Freq.4+5*tb10_w$Freq.5
# tb10_w[6,c(2:9)] <- apply(tb10_w[,c(2:9)],2,sum)
# tb10_w$Nodeviation_n_pct = paste(7*tb10_w$Freq.0, "(", round(700*tb10_w$Freq.0/tb10_w$total,2), "%)",sep=" ")
# tb10_w$deviation_n_pct = paste(tb10_w$deviation, "(", round(100*tb10_w$deviation/tb10_w$total,2), "%)",sep=" ")
# tb10_w$total_n_pct = paste(tb10_w$total, "(", round(100*tb10_w$total/3304,2), "%)",sep=" ")
# Total <- sum(tb10_w$total)
# tb10_w <- tb10_w %>%  mutate(site=case_when(y == "303349821" ~ "Marshfield Clinic Health System",
#                                         y == "531629870" ~ "HealthPartners",
#                                        y == "548392715" ~ "Henry Ford Health System",
#                                        y == "657167265" ~ "Sanford Health",
#                                        y == "809703864" ~ "University of Chicago Medicine",
#                                        is.na(y)  ~ "Total"))
# tb10_dev <- matrix(data=NA,ncol=4,byrow=TRUE)
# tb10_dev <-tb10_w[,c(13,11,10,12)]

####Table 11. Number of deviations by biospecimen type and by tube type
#d_143615646_d_338286049	as MWTube1_BioCol_NotCollNotes,
###         CID         Variable Label    Variable Name

# 2: 299553921 Serum Separator Tube 1 BioCol_0001_v1r0
# 9: 703954371 Serum Separator Tube 2 BioCol_0002_v1r0
# 3: 376960806 Serum Separator Tube 3 BioCol_0011_v1r0
# 1: 232343615 Serum Separator Tube 4 BioCol_0012_v1r0 
# 5: 589588440 Serum Separator Tube 5 BioCol_0021_v1r0 
# 6: 652357376             ACD Tube 1 BioCol_0005_v1r0
# 4: 454453939            EDTA Tube 1 BioCol_0004_v1r0
# 7: 677469051            EDTA Tube 2 BioCol_0014_v1r0
# 8: 683613884            EDTA Tube 3 BioCol_0024_v1r0 
# 10: 838567176         Heparin Tube 1 BioCol_0003_v1r0
# 11: 958646668         Heparin Tube 2 BioCol_0013_v1r0 

deviation <- grep("d_248868659",names(biospe),value=TRUE)  

devia_type <- grep("678857215",colnames(biospe),value=TRUE)
devia_notes <- grep("536710547",colnames(biospe),value=TRUE)
tube_id <- grep("825582494",colnames(biospe),value=TRUE)
tube_col <- grep("593843561",colnames(biospe),value=TRUE)
tube_notcol <- grep("")
tubedev <- ifelse(biospe[,paste(bios.ls[i],"d_678857215",sep="_")]==104430631 | is.na(biospe[,paste(bios.ls[i],"d_678857215",sep="_")]),0,1)
data_dev <- biospe[which(biospe$tubedev !=0 ),c("Connect_ID","d_820476880",devia_type,devia_notes,"tubedev","tubecol")] #76



devtube <- melt(biospe[,c("Connect_ID","d_820476880",devia_type)],
                # ID variables - all the variables to keep but not split apart on
                id.vars=c("Connect_ID","d_820476880"),
                # The source columns
                measure.vars=devia_type,
                # Name of the destination column that will identify the original
                # column that the measurement came from
                variable.name="deviation_tube",
                value.name="deviation")

coltube <- melt(biospe[,c("Connect_ID","d_820476880",tube_col)],
                # ID variables - all the variables to keep but not split apart on
                id.vars=c("Connect_ID","d_820476880"),
                # The source columns
                measure.vars=tube_col,
                # Name of the destination column that will identify the original
                # column that the measurement came from
                variable.name="collected_tube",
                value.name="collected")

notcol <- melt(biospe[,c("Connect_ID","d_820476880",tube_col)],
               # ID variables - all the variables to keep but not split apart on
               id.vars=c("Connect_ID","d_820476880"),
               # The source columns
               measure.vars=tube_col,
               # Name of the destination column that will identify the original
               # column that the measurement came from
               variable.name="collected_tube",
               value.name="collected")

devnotes <- melt(biospe[,c("Connect_ID","d_820476880",devia_notes)],
                 # ID variables - all the variables to keep but not split apart on
                 id.vars=c("Connect_ID","d_820476880"),
                 # The source columns
                 measure.vars=devia_notes,
                 # Name of the destination column that will identify the original
                 # column that the measurement came from
                 variable.name="deviation_tube",
                 value.name="deviation_notes"
)

reshape(biospe[,c("Connect_ID","d_820476880",devia_type,devia_notes)],direction="long",varying=c(devia_type,devia_notes),v.names ="tube_deviation", timevar=c("tube_id"),times=c(devia_type,devia_notes))
