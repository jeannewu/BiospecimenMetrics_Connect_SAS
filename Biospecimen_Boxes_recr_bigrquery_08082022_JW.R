rm(list = ls())
library(bigrquery)
library(data.table)
library(boxr)
library(tidyverse)
library(dplyr)
library(reshape)  
library(sqldf)
library(lubridate)
library(stringr)
library(plyr)


bq_auth()
project <- "nih-nci-dceg-connect-prod-6d04"
billing <- "nih-nci-dceg-connect-prod-6d04" ##project and billing should be consistent


##to select biospecimen data in recruitment;
biovar <- c("Connect_ID","studyId","d_878865966","d_827220437","d_512820379","d_821247024","d_684635302","d_822499427","d_222161762","d_265193023",
            "d_167958071","d_173836415_d_266600170_d_561681068","d_173836415_d_266600170_d_448660695","d_173836415_d_266600170_d_592099155",
            "d_173836415_d_266600170_d_718172863","d_173836415_d_266600170_d_847159717","d_173836415_d_266600170_d_915179629", 
            "d_331584571_d_266600170_d_135591601","d_331584571_d_266600170_d_840048338","d_331584571_d_266600170_d_343048998")

tb <- bq_project_query(project, query="SELECT Connect_ID,studyId,d_878865966,d_827220437,d_512820379,d_821247024,
d_684635302,d_822499427,d_222161762,d_265193023,
d_167958071,d_173836415,
d_173836415_d_266600170_d_561681068,d_173836415_d_266600170_d_448660695,d_173836415_d_266600170_d_592099155,d_173836415_d_266600170_d_718172863,d_173836415_d_266600170_d_847159717,d_173836415_d_266600170_d_915179629,
d_331584571, d_331584571_d_266600170_d_135591601,
d_331584571_d_266600170_d_840048338,
d_331584571_d_266600170_d_343048998
FROM `nih-nci-dceg-connect-prod-6d04.recruitment.recruitment1_WL` WHERE d_821247024 = '197316935'")

data <- bq_table_download(tb,bigint="integer64") 

###the boxes and biospecimen data
bio_tb <- bq_project_query(project, query="SELECT * FROM `nih-nci-dceg-connect-prod-6d04.Biospecimens.flat_biospecimen_KD`")
biospe <- bq_table_download(bio_tb,bigint="integer64")


tb_box <- bq_project_query(project, query="SELECT * FROM `nih-nci-dceg-connect-prod-6d04.Biospecimens.flatBoxes_WL`")
box_wl_flat <- bigrquery::bq_table_download(tb_box,bigint = "integer64")

# Check that it doesn't match any non-number
numbers_only <- function(x) !grepl("\\D", x)
cnames <- names(box_wl_flat)
###to check variables in recr_noinact_wl1
data1 <- box_wl_flat
for (i in 1: length(cnames)){
  varname <- cnames[i]
  var<-pull(data1,varname)
  data1[,cnames[i]] <- ifelse(numbers_only(var), as.numeric(as.character(var)), var)
}

write.csv(data1,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_flatBoxes_07182022.csv",row.names = F,na="")
write.csv(biospe,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_biospecimen_07182022.csv",row.names = F,na="")

write.csv(data,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/prod_recrverified_bio_07182022.csv",row.names = F,na="")
