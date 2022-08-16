rm(list = ls())
library(bigrquery)
library(data.table)
library(boxr)
library(tidyverse)
library(dplyr)
library(reshape)  
library(foreach)
library(stringr)
library(plyr)
library(bit64)

bq_auth()
#The bigrquery package is requesting access to your Google account.
#Select a pre-authorised account or enter '0' to obtain a new token.
#Press Esc/Ctrl + C to cancel.

#1: wuj12@nih.gov
project <- "nih-nci-dceg-connect-prod-6d04"
billing <- "nih-nci-dceg-connect-prod-6d04" ##project and billing should be consistent

tb <- bq_project_query(project, query= "SELECT Connect_ID, token, d_821247024 FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` WHERE d_512820379 != '180583933'")
tb_id <- bq_table_download(tb, bigint="integer64")

sql <- "SELECT * EXCEPT (d_153211406,d_231676651,d_348474836,d_371067537,d_388711124,d_399159511,d_421823980,d_436680969,d_438643922,d_442166669,d_471168198,d_479278368,d_521824358,d_544150384,d_564964481,d_634434746,d_635101039,d_703385619,d_736251808,d_765336427,
d_793072415,d_795827569,d_826240317,d_849786503,d_869588347,d_892050548,d_996038075) FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` WHERE d_512820379 != '180583933'"
recr_tb_noinact <- bq_project_query(project, sql)

#recr_tb_noinact <- bq_project_query(project, query="SELECT * EXCEPT (d_153211406,d_231676651,d_348474836,d_371067537,d_388711124,d_399159511,d_421823980,d_436680969,d_438643922,d_442166669,d_471168198,d_479278368,d_521824358,d_544150384,d_564964481,d_634434746,d_635101039,d_703385619,d_736251808,d_765336427,
#d_793072415,d_795827569,d_826240317,d_849786503,d_869588347,d_892050548,d_996038075) FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` WHERE d_512820379 != '180583933'")
recru_noinact_wl <- bigrquery::bq_table_download(recr_tb_noinact,bigint="integer64")

###Option B, chop the big data into small pieces and via bigrquery to download by piece and combine them together in a for loop to generate a list of small
###datasets 
recrvar <- read.csv("~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_recrument1_WL_varnames_08102022.csv",head=T)

nvar = floor((length(recrvar$column_name))/4) ##to define the number of variables in each sql extract from GCP
nvar

# Start column for each split data frame
start = seq(1,length(recrvar$column_name),nvar)

# Split bqdata into a bunch of separate data frames

recrbq <- list()
for (i in (1:length(start)))  {
  select <- paste(recrvar$column_name[start[i]:(min(start[i]+nvar-1,202))],collapse=",")
  tmp <- eval(parse(text=paste("bq_project_query(project, query=\"SELECT", select,"FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` Where d_512820379 != '180583933'\")",sep=" ")))
  recrbq[[i]] <- bq_table_download(tmp, bigint="integer64") 
}

recr_noinact_wl <- do.call(cbind,recrbq)

###Option B2. here below is the alternative option to download the data if it is too big to download as a whole
  select <- paste(recrvar$column_name[1,50],collapse=",")
  tmp <- eval(parse(text=paste("bq_project_query(project, query=\"SELECT", select,"FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` Where d_512820379 != '180583933'\")",sep=" ")))
  tmp1 <- bq_table_download(tmp, bigint="integer64")

  select <- paste(recrvar$column_name[51:100],collapse=",")
  tmp <- eval(parse(text=paste("bq_project_query(project, query=\"SELECT", select,"FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` Where d_512820379 != '180583933'\")",sep=" ")))
  tmp2 <- bq_table_download(tmp, bigint="integer64")
  
  select <- paste(recrvar$column_name[101:150],collapse=",")
  tmp <- eval(parse(text=paste("bq_project_query(project, query=\"SELECT", select,"FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` Where d_512820379 != '180583933'\")",sep=" ")))
  tmp3 <- bq_table_download(tmp, bigint="integer64")
  
  select <- paste(recrvar$column_name[151:202],collapse=",")
  tmp <- eval(parse(text=paste("bq_project_query(project, query=\"SELECT", select,"FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` Where d_512820379 != '180583933'\")",sep=" ")))
  tmp4 <- bq_table_download(tmp, bigint="integer64")
  
  recr_noinact_wl<- cbind(tmp1,tmp2,tmp3,tmp4)  

 ###convert the numeric
 ### Check that it doesn't match any non-number
 numbers_only <- function(x) !grepl("\\D", x)

 data1 <- recr_noinact_wl
 cnames <- names(recr_noinact_wl)
 ###to check variables in recr_noinact_wl
 for (i in 1: length(cnames)){
   varname <- cnames[i]
   var<-pull(data1,varname)
   data1[,cnames[i]] <- ifelse(numbers_only(var), as.numeric(as.character(var)), var)
 }
 ###to download the data to box as csv file
 ###write the prod.recruitment1_WL to box folder
 box_auth(client_id = "627lww8un9twnoa8f9rjvldf7kb56q1m",
          client_secret = "gSKdYKLd65aQpZGrq9x4QVUNnn5C8qqm") 
 box_setwd(dir_id = 161836233301) 
 # box.com working directory changed to 'Team File Share'
 # 
 # id: 161836233301
 # tree: All Files/Connect_CCC/Team File Share
 # owner: robertsamm@nih.gov
 # contents: 5 files, 1 folders
 
 box_write(object = data1, file_name = "prod_recrument1_WL_bio3var_NM_noinactive_07212022csv",
           description = "Connect Prod flat Recruitment1_WL, July 21: verified=1090")
