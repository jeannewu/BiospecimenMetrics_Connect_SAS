###Aug. 2, 2022, this is Kelsey's CCC weekly metrics report code. Based on Michelle's comments to add the number of participants in each module, I will go
###through her code to extend the table with "N" of each table here.
###all the numbers should be the one reported on Aug. 1st, 2022 consistent with recruitment1 n=1257

## CCC WEEKLY METRICS REPORT 

library(bigrquery)
library(data.table)
library(boxr)
library(tidyverse)
library(dplyr)
library(reshape)  
library(foreach)
library(listr)
library(sqldf)
library(lubridate)
library(stringr)
library(plyr)
library(rmarkdown)
library(sas7bdat)
library(bit64)
library(epiDisplay) ##recommended applied here crosstable, tab1
library(summarytools) ##recommended
library(gmodels) ##recommended
bq_auth()

###to add the recruitment table (verified part from yesterday's table 08012022 here)
#recr <- read.csv("~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/prod_recrument1_WL_NM_noinactive_08012022.csv",header=T)
#veriid <- as.integer64(recrveri$Connect_ID)

#box_auth(client_id = "627lww8un9twnoa8f9rjvldf7kb56q1m",
#         client_secret = "gSKdYKLd65aQpZGrq9x4QVUNnn5C8qqm") 
#box_setwd(dir_id = 161836233301) 
# box.com working directory changed to 'Team File Share'
# 
# id: 161836233301
# tree: All Files/Connect_CCC/Team File Share
# owner: robertsamm@nih.gov
# contents: 4 files, 1 folders
#recr <- box_read(file_id=991839277333)

############### MODULE 1 ########################################
project = "nih-nci-dceg-connect-prod-6d04"
billing= "nih-nci-dceg-connect-prod-6d04"

tb <- bq_project_query(project, query="SELECT * EXCEPT (d_153211406,d_231676651,d_348474836,d_371067537,d_388711124,d_399159511,d_421823980,d_436680969,d_438643922,d_442166669,d_471168198,d_479278368,d_521824358,d_544150384,d_564964481,d_634434746,d_635101039,d_703385619,d_736251808,d_765336427,
d_793072415,d_795827569,d_826240317,d_849786503,d_869588347,d_892050548,d_996038075) FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` WHERE d_821247024 = '197316935'")

recr_veri <- bq_table_download(tb,bigint="integer64")

query.select <- c("d_512820379", "d_821247024", "d_914594314", "d_949302066", "d_517311251", "d_205553981", "d_536735468", 
                  "d_832139544", "d_541836531", "d_976570371", "d_386488297", "d_770257102", "d_663265240","d_264644252", 
                  "d_452942800","d_914594314") #"d_517311251" in the recruitment 821247024 == 197316935
recrveri_select <- recr_veri[,which(names(recr_veri) %in% c("Connect_ID",query.select))]
# Check that it doesn't match any non-number
numbers_only <- function(x) !grepl("\\D", x)
cnames <- names(recrveri_select)
###to check variables in recr_noinact_wl1
for (i in 1: length(cnames)){
  varname <- cnames[i]
  var<-pull(recrveri_select,varname)
  recrveri_select[,cnames[i]] <- ifelse(numbers_only(var), as.numeric(as.character(var)), var)
}

#recr_veri <- recr.select[which(recr.select$d_821247024 == 197316935),]

querymod <- "SELECT * FROM `nih-nci-dceg-connect-prod-6d04.flat.module1_scheduledqueries` where Connect_ID IS NOT NULL"

###for module1 working in module2
#querymod1 <- "SELECT Connect_ID, token, D_407056417, D_289664241, D_613744428, D_784967158
#FROM `nih-nci-dceg-connect-prod-6d04.flat.module1_scheduledqueries` where Connect_ID IS NOT NULL"
###for module1 working in module4
# querymod1 <- "SELECT Connect_ID, token, D_407056417, D_289664241, D_784967158 FROM `nih-nci-dceg-connect-prod-6d04.flat.module1_scheduledqueries` where Connect_ID IS NOT NULL"

#queryrec <- "SELECT  Connect_ID, d_512820379, d_821247024, d_914594314,  
#d_949302066 , d_205553981, d_536735468 , d_976570371, d_663265240
#FROM `nih-nci-dceg-connect-prod-6d04.Connect.participants` where Connect_ID IS NOT NULL"

mod1_table <- bq_project_query(project, querymod)
#rec_table <- bq_project_query(project, queryrec)

mod1_data <- bq_table_download(mod1_table, bigint = "integer64") #1555
#rec_data <- bq_table_download(rec_table, bigint = "integer64")

merged=merge(mod1_data, recrveri_select, by.x="Connect_ID", by.y="Connect_ID", all.y=T)  #tidyverse has left join
table(merged$d_512820379)
# 486306141 854703046 
# 1250       135

merged$d_949302066 <- recode(merged$d_949302066,'972455046'	="Not Started",
                             '615768760'	= "Started",
                             '231311385' ="Submitted")
#merged$d_512820379 <- recode(merged$d_512820379, )

#active <- merged %>% filter(d_512820379==486306141)
#passive <- merged %>% filter(d_512820379==854703046)

#TIME STAMP FOR REFERENCE- ADD TO THE TOP OF THE REPORT
currentTime <- Sys.time()
print(currentTime)

##for overall recruitment type with d_949302066 (SrvBOH_BaseStatus_v1r0) Baseline Survey Status - Module Background and Overall Health
T1 <- tab1(merged$d_949302066, sort.group = "decreasing", cum.percent = TRUE)$output.table
T1
# Frequency Percent Cum. percent
# Submitted         963    69.5         69.5
# Not Started       312    22.5         92.1
# Started           110     7.9        100.0
#Total          1385   100.0        100.0
mod1_cross <- CrossTable(merged$d_949302066, merged$d_512820379, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)
# 
# Cell Contents
# |-------------------------|
#   |                       N |
#   |           N / Col Total |
#   |-------------------------|
#   
#   
#   Total Observations in Table:  1385 
# 
# 
# | merged$d_512820379 
# merged$d_949302066 | 486306141 | 854703046 | Row Total | 
#   -------------------|-----------|-----------|-----------|
#   Not Started |       259 |        53 |       312 | 
#   |     0.207 |     0.393 |           | 
#   -------------------|-----------|-----------|-----------|
#   Started |       102 |         8 |       110 | 
#   |     0.082 |     0.059 |           | 
#   -------------------|-----------|-----------|-----------|
#   Submitted |       889 |        74 |       963 | 
#   |     0.711 |     0.548 |           | 
#   -------------------|-----------|-----------|-----------|
#   Column Total |      1250 |       135 |      1385 | 
#   |     0.903 |     0.097 |           | 
#   -------------------|-----------|-----------|-----------|
# 2.	Time from verification to completion of each module- Hours 25, 50, 75 percentile (active, passive and total)  <<rows 34-41 in ltd file
#d_914594314 verified
#d_517311251 Mod1 completion time stamp
#d_536735468 SrvMRE_BaseStatus_v1r0 Flag for Baseline Module Medications, Reproductive Health, Exercise and Sleep
library(lubridate)

time.var1 <- c("d_914594314","d_517311251.y")

merged_complete <- merged[which(merged$d_536735468 == 231311385),]
table(merged_complete$d_512820379)
merged_clptime <- merged_complete[complete.cases(merged_complete[ , time.var1]),c("Connect_ID","d_512820379","d_914594314","d_517311251.y") ]
table(merged_clptime$d_512820379)
#486306141 854703046  Total
# 525        47       572
merged_clptime$d_914594314 <- as.POSIXct(ymd_hms(merged_clptime$d_914594314))
merged_clptime$d_517311251 <- as.POSIXct(ymd_hms(merged_clptime$d_517311251.y))
merged_clptime$completionA <- difftime(merged_clptime$d_517311251, merged_clptime$d_914594314, units="hours")

tapply(as.numeric(merged_clptime$completionA), as.factor(merged_clptime$d_512820379), summary)
# $`486306141`
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -283.807  -14.743   -0.250  105.232    4.792 6192.102 
# 
# $`854703046`
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -69.928    1.017   19.520  198.600  120.392 2301.249 

summary(as.numeric(merged_clptime$completionA))
#    Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#-283.807  -13.910   -0.041  112.904    7.615 6192.102 

# 3.	Duration from start to submitted for each module (active, passive and total)  <<rows 44-48 in ltd file
#d_205553981 time stamp started
#d_517311251 time stamp finished 

time.var.1 <- c("d_205553981","d_517311251.y")

merged_duration <- merged_complete[complete.cases(merged_complete[ , time.var.1]),c("Connect_ID","d_512820379",time.var.1)]
merged_duration$d_205553981 <- as.POSIXct(ymd_hms(merged_duration$d_205553981))
merged_duration$d_517311251 <- as.POSIXct(ymd_hms(merged_duration$d_517311251.y))
merged_duration$Mod1completionA <- difftime(merged_duration$d_517311251, merged_duration$d_205553981, units="hours")

tapply(as.numeric(merged_duration$Mod1completionA), as.factor(merged_duration$d_512820379), summary)
# $`486306141`
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 0.002132 0.259322 0.340831 0.407252 0.456282 4.315592 
# 
# $`854703046`
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.01258 0.22483 0.32474 0.39944 0.49011 1.94850 
summary(as.numeric(merged_duration$Mod1completionA))
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 0.002132 0.253893 0.339926 0.406610 0.457130 4.315592 


#############################################

#############################################

##### ALL MODULES #####

# 4.	% Submission of surveys modules by active recruits who cannot be verified   <<rows 51-53 in ltd file
cannot_verify <- merged %>% filter(d_512820379==486306141 & d_821247024==219863910)
table(merged$d_512820379,merged$d_821247024)
#dim(cannot_verify) 
#Only 1 active participant that cannot be verified
#[1]   0 981 ##no "cannot be verified" Jing updated 08032022
#>Any survey modules submitted
#active_NV_SB <- active %>% filter(as.integer64(d_821247024)==219863910) %>% filter(d_949302066==231311385 | d_536735468==231311385 | d_976570371==231311385 | d_663265240==231311385)
#dim(active_NV_SB) #no


#>No survey modules submitted
active <- data1[which(data1$d_512820379==486306141),]
active_NV_NS <- active %>% filter(d_821247024==219863910) %>% filter(d_949302066==972455046 & d_536735468==972455046 & d_976570371==972455046 & d_663265240==972455046)
dim(active_NV_NS)




#5. Survey status: None Completed, Some Completed (Combinations), All completed 

#536735468	Baseline Survey Status- Module Medications, Reproductive Health, Exercise, and Sleep	Module2
#  Flag for Baseline Module Medications, Reproductive Health, Exercise and Sleep	SrvMRE_BaseStatus_v1r0

#976570371	Baseline Survey Status- Module Smoking, Alcohol, and Sun Exposure	Module3
#Flag for Baseline Module Smoking, Alcohol, and Sun Exposure	SrvSAS_BaseStatus_v1r0
#663265240	Baseline Survey Status- Module Where You Live and Work	Module4
#Flag for Baseline Module Where You Live and Work	SrvLAW_BaseStatus_v1r0

merged.mods <- merged[,c("Connect_ID","d_949302066","d_536735468","d_976570371","d_663265240","d_512820379")]
none <- merged  %>% filter(d_949302066==972455046 & d_536735468==972455046 & d_976570371==972455046 & d_663265240==972455046)
CrossTable(merged$d_949302066, merged$d_536735468, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)
CrossTable(merged$d_949302066, merged$d_976570371, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)
CrossTable(merged$d_949302066, merged$d_663265240, prop.t=FALSE, prop.r=FALSE, prop.c=TRUE,prop.chisq=FALSE)


dim(none) #292 981
# Module 1 only  
# One or more modules (any combination)
# Module 1&2 only  
# Module 1&3 only  
# Module 1&4 only  
# Module 1,2 and 3 only  
# Module 1,2 and 4 only  
# Module 1,3 and 4 only  
# All
# None
###table 5
modules <- merged[,c("Connect_ID","d_512820379","d_949302066","d_536735468","d_976570371","d_663265240")]
mods <- c("d_949302066","d_536735468","d_976570371","d_663265240")
modules$modules <- 0
modules$none <-0
for(i in 1:length(mods)){
  module <- modules[,mods[i]]
  count <- ifelse((!is.na(module) & module ==231311385), 1, 0)
  modules$modules <- count+modules$modules
  count1 <- ifelse((!is.na(module) & module==972455046), 1, 0)
  modules$none <- count1+modules$none
}

table(modules$modules)
# 0   1   2   3   4 
# 422 376  70 143 374 
table(modules$none)
# 0   1   2   3   4 
# 396 134  97 446 312 
table(modules$modules,modules$d_949302066)
CrossTable(modules$d_949302066, modules$modules,digits=4, prop.t=FALSE, prop.r=TRUE, prop.c=TRUE,prop.chisq=FALSE)
# | modules$modules 
# modules$d_949302066 |         0 |         1 |         2 |         3 |         4 | Row Total | 
#   --------------------|-----------|-----------|-----------|-----------|-----------|-----------|
#   231311385 |         0 |       376 |        70 |       143 |       374 |       963 | 
#   |    0.0000 |    0.3904 |    0.0727 |    0.1485 |    0.3884 |    0.6953 | 
#   |    0.0000 |    1.0000 |    1.0000 |    1.0000 |    1.0000 |           | 
#   --------------------|-----------|-----------|-----------|-----------|-----------|-----------|
#   615768760 |       110 |         0 |         0 |         0 |         0 |       110 | 
#   |    1.0000 |    0.0000 |    0.0000 |    0.0000 |    0.0000 |    0.0794 | 
#   |    0.2607 |    0.0000 |    0.0000 |    0.0000 |    0.0000 |           | 
#   --------------------|-----------|-----------|-----------|-----------|-----------|-----------|
#   972455046 |       312 |         0 |         0 |         0 |         0 |       312 | 
#   |    1.0000 |    0.0000 |    0.0000 |    0.0000 |    0.0000 |    0.2253 | 
#   |    0.7393 |    0.0000 |    0.0000 |    0.0000 |    0.0000 |           | 
#   --------------------|-----------|-----------|-----------|-----------|-----------|-----------|
#   Column Total |       422 |       376 |        70 |       143 |       374 |      1385 | 
#   |    0.3047 |    0.2715 |    0.0505 |    0.1032 |    0.2700 |           | 
#   --------------------|-----------|-----------|-----------|-----------|-----------|-----------|
length(modules[which(modules$modules==3 & modules$d_663265240==231311385 & modules$d_536735468==231311385),])
modules1 <- modules %>% mutate(process=case_when(d_949302066 == 231311385 & modules==1 ~ "module 1 only",
                                                         modules ==2 & d_536735468 == 231311385 ~ "module 1,2" ,
                                                        modules ==2 & d_976570371 == 231311385 ~ "module 1,3" ,
                                                        modules ==2 & d_663265240 == 231311385 ~ "module 1,4" ,
                                                        modules ==3 & d_536735468 == 231311385 & d_976570371 == 231311385 ~ "module 1,2,3" ,
                                                        modules ==3 & d_976570371 == 231311385 & d_663265240 == 231311385~ "module 1,3,4" ,
                                                        modules ==3 & d_536735468 == 231311385& d_663265240 == 231311385 ~ "module 1,2,4",
                                                        modules ==0 ~ "None",
                                                        modules ==4 ~ "All"))
table(modules1$process)
tab1(modules1$process, decimal=2,sort.group = "decreasing", cum.percent = TRUE)$output.table
# Frequency Percent Cum. percent
# None                422   30.47        30.47
# module 1 only       376   27.15        57.62
# All                 374   27.00        84.62
# module 1,2,3        139   10.04        94.66
# module 1,2           59    4.26        98.92
# module 1,3           11    0.79        99.71
# module 1,3,4          4    0.29       100.00
# Total            1385  100.00       100.00

############### MODULE 2 ########################################
project = "nih-nci-dceg-connect-prod-6d04"
billing= "nih-nci-dceg-connect-prod-6d04"
querymod1 <- "SELECT Connect_ID, token, D_407056417, D_289664241, D_613744428, D_784967158
FROM `nih-nci-dceg-connect-prod-6d04.flat.module1_scheduledqueries` where Connect_ID IS NOT NULL"
querymod2 <- "SELECT * FROM `nih-nci-dceg-connect-prod-6d04.M2.flatM2_WL` where Connect_ID IS NOT NULL"
queryrec <- "SELECT  Connect_ID, token, d_512820379, d_821247024, d_914594314,  
d_949302066 , d_517311251, d_205553981, d_536735468 , d_976570371, d_663265240,
d_832139544, d_541836531
FROM `nih-nci-dceg-connect-prod-6d04.Connect.participants` where Connect_ID IS NOT NULL"


mod2_table <- bq_project_query(project, querymod2)
#rec_table <- bq_project_query(project, queryrec)
mod1_table <- bq_project_query(project, querymod1)

mod1_data <- bq_table_download(mod1_table, bigint = "integer64")
#rec_data <- bq_table_download(rec_table, bigint = "integer64")
mod2_data <- bq_table_download(mod2_table, bigint = "integer64")

merge1=merge(mod2_data, recrveri_select, by.x="Connect_ID", by.y="Connect_ID", all.y=T)
merge2=merge(merge1, mod1_data, by.x="Connect_ID", by.y="Connect_ID", all.x=T) #n=1385
# 1.	Completion of baseline tasks with #(%) not started, started, submitted of each module (active, passive and total)  <<rows 18-28 in ltd file

tab1(merge2$d_512820379,decimal=2,sort.group = "decreasing", cum.percent = TRUE)$output.table
# Frequency Percent Cum. percent
# 486306141      1250   90.25        90.25
# 854703046       135    9.75       100.00
# Total        1385  100.00       100.00
CrossTable(merge2$d_512820379, merge2$d_536735468,digits=4, prop.t=FALSE, prop.r=TRUE, prop.c=TRUE,prop.chisq=FALSE)
Cell Contents
# |-------------------------|
#   |                       N |
#   |           N / Row Total |
#   |           N / Col Total |
#   |-------------------------|
#   
#   
#   Total Observations in Table:  1385 
# 
# 
# | merge2$d_536735468 
# merge2$d_512820379 | 231311385 | 615768760 | 972455046 | Row Total | 
#   -------------------|-----------|-----------|-----------|-----------|
#   486306141 |       525 |        37 |       688 |      1250 | 
#   |    0.4200 |    0.0296 |    0.5504 |    0.9025 | 
#   |    0.9178 |    0.9024 |    0.8912 |           | 
#   -------------------|-----------|-----------|-----------|-----------|
#   854703046 |        47 |         4 |        84 |       135 | 
#   |    0.3481 |    0.0296 |    0.6222 |    0.0975 | 
#   |    0.0822 |    0.0976 |    0.1088 |           | 
#   -------------------|-----------|-----------|-----------|-----------|
#   Column Total |       572 |        41 |       772 |      1385 | 
#   |    0.4130 |    0.0296 |    0.5574 |           | 
#   -------------------|-----------|-----------|-----------|-----------|


# 2.	Time from verification to completion of each module (active, passive and total)  <<rows 34-41 in ltd file
library(lubridate)
time.var2 <- c("d_914594314","d_832139544")

merged2_complete <- merge2[which(merge2$d_536735468 == 231311385),]
table(merged2_complete$d_512820379)
# 486306141 854703046 
# 525        47 
merged2_clptime <- merged2_complete[complete.cases(merged2_complete[ , time.var2]),c("Connect_ID","d_512820379",time.var2) ]
table(merged2_clptime$d_512820379)
# 486306141 854703046 
# 525        47 
merged2_clptime$d_914594314 <- as.POSIXct(ymd_hms(merged2_clptime$d_914594314))
merged2_clptime$d_832139544 <- as.POSIXct(ymd_hms(merged2_clptime$d_832139544))
merged2_clptime$Mod2completionA <- difftime(merged2_clptime$d_832139544, merged_clptime$d_914594314, units="hours")

tapply(as.numeric(merged2_clptime$Mod2completionA), as.factor(merged2_clptime$d_512820379), summary)
# $`486306141`
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -283.384  -10.251    4.349  446.454  169.926 8150.537 
# 
# $`854703046`
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# -69.64    1.39   69.32  574.80  341.76 6046.38 
summary(as.numeric(merged2_clptime$Mod2completionA))
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#-283.384   -6.857    5.283  457.001  185.607 8150.537

# 3.	Duration from start to submitted for each module (active, passive and total)  <<rows 44-48 in ltd file  

time.var.2 <- c("d_541836531","d_832139544")

merged2_duration <- merged2_complete[complete.cases(merged2_complete[ , time.var.2]),c("Connect_ID","d_512820379",time.var.2)] #572
merged2_duration$d_541836531 <- as.POSIXct(ymd_hms(merged2_duration$d_541836531))
merged2_duration$d_832139544 <- as.POSIXct(ymd_hms(merged2_duration$d_832139544))
merged2_duration$Mod2completionA <- difftime(merged2_duration$d_832139544, merged2_duration$d_541836531, units="hours")

tapply(as.numeric(merged2_duration$Mod2completionA), as.factor(merged2_duration$d_512820379), summary)
# $`486306141`
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 0.003759 0.251678 0.325614 0.402860 0.453933 6.004074 
# 
# $`854703046`
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.03886 0.21768 0.27648 0.30174 0.41029 0.65788 

summary(as.numeric(merged2_duration$Mod2completionA))
#Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#0.003759 0.246264 0.321242 0.394551 0.446359 6.004074 

############### MODULE 3 ########################################
project = "nih-nci-dceg-connect-prod-6d04"
billing= "nih-nci-dceg-connect-prod-6d04"
querymod3 <- "SELECT * FROM `nih-nci-dceg-connect-prod-6d04.M3.flatModule3_WL` where Connect_ID IS NOT NULL"
queryrec <- "SELECT  Connect_ID, token, d_512820379, d_821247024, d_914594314,  
d_949302066 , d_517311251, d_205553981, d_536735468 , d_976570371, d_663265240,
d_832139544, d_541836531, d_976570371, d_386488297, d_770257102
FROM `nih-nci-dceg-connect-prod-6d04.Connect.participants` where Connect_ID IS NOT NULL"


mod3_table <- bq_project_query(project, querymod3)
#rec_table <- bq_project_query(project, queryrec)

#rec_data <- bq_table_download(rec_table, bigint = "integer64")
mod3_data <- bq_table_download(mod3_table, bigint = "integer64") #1555

merge3=merge(mod3_data, recrveri_select, by.x="Connect_ID", by.y="Connect_ID", all.y=T) #1385
# 1.	Completion of baseline tasks with #(%) not started, started, submitted of each module (active, passive and total)  <<rows 18-28 in ltd file
CrossTable(merge3$d_976570371,merge3$d_512820379, digits=4, prop.t=FALSE, prop.r=TRUE, prop.c=TRUE,prop.chisq=FALSE)
#    Cell Contents
# |-------------------------|
#   |                       N |
#   |           N / Row Total |
#   |           N / Col Total |
#   |-------------------------|
#   
#   
#   Total Observations in Table:  1385 
# 
# 
# | merge3$d_512820379 
# merge3$d_976570371 | 486306141 | 854703046 | Row Total | 
#   -------------------|-----------|-----------|-----------|
#   231311385 |       484 |        44 |       528 | 
#   |    0.9167 |    0.0833 |    0.3812 | 
#   |    0.3872 |    0.3259 |           | 
#   -------------------|-----------|-----------|-----------|
#   615768760 |        11 |         0 |        11 | 
#   |    1.0000 |    0.0000 |    0.0079 | 
#   |    0.0088 |    0.0000 |           | 
#   -------------------|-----------|-----------|-----------|
#   972455046 |       755 |        91 |       846 | 
#   |    0.8924 |    0.1076 |    0.6108 | 
#   |    0.6040 |    0.6741 |           | 
#   -------------------|-----------|-----------|-----------|
#   Column Total |      1250 |       135 |      1385 | 
#   |    0.9025 |    0.0975 |           | 
#   -------------------|-----------|-----------|-----------|
 
tab1(merge3$d_976570371,decimal=2,sort.group = "decreasing", cum.percent = TRUE)$output.table 
# Frequency Percent Cum. percent
# 972455046       846   61.08        61.08
# 231311385       528   38.12        99.21
# 615768760        11    0.79       100.00
# Total        1385  100.00       100.00

# sum(merge3$d_512820379==486306141, na.rm=TRUE) #active
# sum(merge3$d_512820379==854703046, na.rm=TRUE) #passive
# 
# active3 <- merge3 %>% filter(d_512820379==486306141)
# passive3 <- merge3 %>% filter(d_512820379==854703046)

# 2.	Time from verification to completion of each module (active, passive and total)  <<rows 34-41 in ltd file
#d_770257102 completed
time.var3 <- c("d_914594314","d_770257102")

merged3_complete <- merge3[which(merge3$d_536735468 == 231311385),]
table(merged3_complete$d_512820379)
# 486306141 854703046 
# 525        47 

merged3_complete$d_914594314 <- as.POSIXct(ymd_hms(merged3_complete$d_914594314))
merged3_complete$d_770257102 <- as.POSIXct(ymd_hms(merged3_complete$d_770257102))
merged3_clptime <- merged3_complete[complete.cases(merged3_complete[ , time.var3]),c("Connect_ID","d_512820379",time.var3) ]
table(merged3_clptime$d_512820379)
#486306141 854703046 
#470        43 
merged3_clptime$Mod3completionA <- difftime(merged3_clptime$d_770257102, merged3_clptime$d_914594314, units="hours")

tapply(as.numeric(merged3_clptime$Mod3completionA), as.factor(merged3_clptime$d_512820379), summary)
# $`486306141`
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -283.21   -8.40    5.73  482.10  233.86 8150.62 
# 
# $`854703046`
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -69.481    1.496   69.464  567.451  375.483 6046.477 

summary(as.numeric(merged3_clptime$Mod3completionA))
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -283.212   -4.088    6.552  489.254  239.220 8150.623
# 3.	Duration from start to submitted for each module (active, passive and total)  <<rows 44-48 in ltd file
#d_770257102 completed
#d_386488297 start 

time.var.3 <- c("d_386488297","d_770257102")

merged3_complete$d_386488297 <- as.POSIXct(ymd_hms(merged3_complete$d_386488297))
merged3_duration <- merged3_complete[complete.cases(merged3_complete[,time.var.3]),c("Connect_ID","d_512820379",time.var.3)]
#merged2_duration$d_770257102 <- as.POSIXct(ymd_hms(merged2_duration$d_770257102))
merged3_duration$Mod3completionA <- difftime(merged3_duration$d_770257102, merged3_duration$d_386488297, units="hours")
table(merged3_duration$d_512820379)
# 486306141 854703046 
# 470        43 
tapply(as.numeric(merged3_duration$Mod3completionA), as.factor(merged3_duration$d_512820379), summary)
# $`486306141`
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.008914 0.117870 0.166928 0.220897 0.232589 7.374854 
# 
# $`854703046`
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.02287 0.11558 0.13699 0.15400 0.18388 0.41541 

summary(as.numeric(merged3_duration$Mod3completionA))
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.008914 0.117540 0.163510 0.215290 0.224754 7.374854 

############### MODULE 4 ########################################
project = "nih-nci-dceg-connect-prod-6d04"
billing= "nih-nci-dceg-connect-prod-6d04"
querymod1 <- "SELECT Connect_ID, token, D_407056417, D_289664241, D_784967158
FROM `nih-nci-dceg-connect-prod-6d04.flat.module1_scheduledqueries` where Connect_ID IS NOT NULL"
querymod4 <- "SELECT * FROM `nih-nci-dceg-connect-prod-6d04.Module4.flatModule4_WL` where Connect_ID IS NOT NULL"
queryrec <- "SELECT  Connect_ID, token, d_512820379, d_821247024, d_914594314,  
d_949302066 , d_517311251, d_205553981, d_536735468 ,
d_832139544, d_541836531, d_976570371, d_386488297, d_770257102, d_663265240,
d_264644252, d_452942800
FROM `nih-nci-dceg-connect-prod-6d04.Connect.participants` where Connect_ID IS NOT NULL"


mod4_table <- bq_project_query(project, querymod4)
#rec_table <- bq_project_query(project, queryrec)
mod1_table <- bq_project_query(project, querymod1)

mod1_data <- bq_table_download(mod1_table, bigint = "integer64")
#rec_data <- bq_table_download(rec_table, bigint = "integer64")
rec_mod4 <- bq_project_query(project, query="SELECT Connect_ID,token,d_264644252, d_452942800 FROM `nih-nci-dceg-connect-prod-6d04.Connect.participants` where d_821247024 =197316935")
rec_mod4time <-bq_table_download(rec_mod4,bigint="integer64")


mod4_data <- bq_table_download(mod4_table, bigint = "integer64") #1555

merge1_4=merge(mod4_data, recrveri_select, by.x="Connect_ID", by.y="Connect_ID", all.y=T)
# merge1_4$Connect_ID <- as.integer64(merge1_4$Connect_ID)
# recr_veri4 <- merge(merge1_4,rec_mod4time, by.x="Connect_ID", by.y="Connect_ID",all.x=T)
merge4 <- merge(merge1_4, mod1_data, by="Connect_ID", all.x=T)
# 1.	Completion of baseline tasks with #(%) not started, started, submitted of each module (active, passive and total)  <<rows 18-28 in ltd file
tab1(merge4$d_663265240,decimal=2,sort.group = "decreasing", cum.percent = TRUE)$output.table 
# Frequency Percent Cum. percent
# 972455046       984   71.05        71.05
# 231311385       378   27.29        98.34
# 615768760        23    1.66       100.00
# Total        1385  100.00       100.00
CrossTable(merge4$d_663265240,merge4$d_512820379, digits=4, prop.t=FALSE, prop.r=TRUE, prop.c=TRUE,prop.chisq=FALSE)
# Cell Contents
# |-------------------------|
#   |                       N |
#   |           N / Row Total |
#   |           N / Col Total |
#   |-------------------------|
#   
#   
#   Total Observations in Table:  1385 
# 
# 
# | merge4$d_512820379 
# merge4$d_663265240 | 486306141 | 854703046 | Row Total | 
#   -------------------|-----------|-----------|-----------|
#   231311385 |       344 |        34 |       378 | 
#   |    0.9101 |    0.0899 |    0.2729 | 
#   |    0.2752 |    0.2519 |           | 
#   -------------------|-----------|-----------|-----------|
#   615768760 |        22 |         1 |        23 | 
#   |    0.9565 |    0.0435 |    0.0166 | 
#   |    0.0176 |    0.0074 |           | 
#   -------------------|-----------|-----------|-----------|
#   972455046 |       884 |       100 |       984 | 
#   |    0.8984 |    0.1016 |    0.7105 | 
#   |    0.7072 |    0.7407 |           | 
#   -------------------|-----------|-----------|-----------|
#   Column Total |      1250 |       135 |      1385 | 
#   |    0.9025 |    0.0975 |           | 
#   -------------------|-----------|-----------|-----------|
# 
# sum(merge4$d_512820379==486306141, na.rm=TRUE) #active
# sum(merge4$d_512820379==854703046, na.rm=TRUE) #passive
# 
# active4 <- merge4 %>% filter(d_512820379==486306141)
# passive4 <- merge4 %>% filter(d_512820379==854703046)
# 
# 2.	Time from verification to completion of each module (active, passive and total)  <<rows 34-41 in ltd file
#264644252 completion

time.var4 <- c("d_914594314","d_264644252")
merged4_complete <- merge4[which(merge4$d_536735468 == 231311385),]
table(merged4_complete$d_512820379)
# 486306141 854703046 
# 525        47 

merged4_complete$d_914594314 <- as.POSIXct(ymd_hms(merged4_complete$d_914594314))
merged4_complete$d_264644252 <- as.POSIXct(ymd_hms(merged4_complete$d_264644252))
merged4_clptime <- merged4_complete[complete.cases(merged4_complete[ , time.var4]),c("Connect_ID","d_512820379",time.var4) ]
table(merged4_clptime$d_512820379)
#486306141 854703046 
#341        33 
merged4_clptime$Mod4completionA <- difftime(merged4_clptime$d_264644252, merged4_clptime$d_914594314, units="hours")

tapply(as.numeric(merged4_clptime$Mod4completionA), as.factor(merged4_clptime$d_512820379), summary)
# $`486306141`
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -82.425    0.173   19.854  591.603  546.277 8276.434 
# 
# $`854703046`
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 0.774    1.395   24.843  679.728  628.365 6332.009
summary(as.numeric(merged4_clptime$Mod4completionA))
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -82.425    0.527   20.368  599.379  550.641 8276.434

# 3.	Duration from start to submitted for each module (active, passive and total)  <<rows 44-48 in ltd file
#264644252 completion
#452942800 start 
time.var.4 <- c("d_452942800","d_264644252")

merged4_complete$d_452942800 <- as.POSIXct(ymd_hms(merged4_complete$d_452942800))
merged4_duration <- merged4_complete[complete.cases(merged4_complete[,time.var.4]),c("Connect_ID","d_512820379",time.var.4)]
#n=374

table(merged4_duration$d_512820379)
#486306141 854703046 
#341        33
merged4_duration$Mod4completionA <- difftime(merged4_duration$d_264644252, merged4_duration$d_452942800, units="hours")

tapply(as.numeric(merged4_duration$Mod4completionA), as.factor(merged4_duration$d_512820379), summary)
# $`486306141`
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 0.006177 0.185686 0.244612 0.305795 0.331738 3.486464 
# 
# $`854703046`
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.0238  0.1493  0.1996  0.2526  0.2703  1.7143  

summary(as.numeric(merged4_duration$Mod4completionA))
#Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#0.006177 0.181640 0.242568 0.301099 0.325970 3.486464 


