###According to the request from Mia, Nicole and Michelle on the race/ethnicity in Connect Recruitment table and reference of Kelsey's code, 
###I am going to create the pie chart on the race/ethnicity of all verified participants in Connect based on their self-report race/ethniciity
###in Module1 and recruitment participants table.
###the race variables are masked under "D_384191091" with ten individual CIDs, along with the race reports by site: state_d_684926335,state_d_849518448,state_d_119643471
###########################################################
library(bigrquery)
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
library(janitor) #to get the summary sum
library(sas7bdat) ###input data
library(finalfit) #https://cran.r-project.org/web/packages/finalfit/vignettes/export.html t
library(expss) ###to add labels
library(epiDisplay) ##recommended applied here crosstable, tab1
library(summarytools) ##recommended
library(gmodels) ##recommended
library(magrittr)
library(arsenal)
library(gtsummary)

bq_auth()
#The bigrquery package is requesting access to your Google account.
#Select a pre-authorised account or enter '0' to obtain a new token.
#Press Esc/Ctrl + C to cancel.

#1: wuj12@nih.gov
project <- "nih-nci-dceg-connect-prod-6d04"
billing <- "nih-nci-dceg-connect-prod-6d04" ##project and billing should be consistent

sql_M1_1 <- bq_project_query(project, query="SELECT * FROM `nih-nci-dceg-connect-prod-6d04.FlatConnect.module1_v1_JP`")
sql_M1_2 <- bq_project_query(project, query="SELECT * FROM `nih-nci-dceg-connect-prod-6d04.FlatConnect.module1_v2_JP`")

M1_V1 <- bq_table_download(sql_M1_1,bigint = "integer64") #1436 #1436 vars: 1507 01112023
M1_V2 <- bq_table_download(sql_M1_2,bigint = "integer64") #2333 #3033 01112023 var:1531

# Check that it doesn't match any non-number
numbers_only <- function(x) !grepl("\\D", x)
mod1_v1 <- M1_V1
cnames <- names(M1_V1)
###to check variables and convert to numeric
for (i in 1: length(cnames)){
  varname <- cnames[i]
  var<-pull(mod1_v1,varname)
  mod1_v1[,cnames[i]] <- ifelse(numbers_only(var), as.numeric(as.character(var)), var)
}
mod1_v2 <- M1_V2
cnames <- names(M1_V2)
###to check variables and convert to numeric
for (i in 1: length(cnames)){
  varname <- cnames[i]
  var<-pull(mod1_v2,varname)
  mod1_v2[,cnames[i]] <- ifelse(numbers_only(var), as.numeric(as.character(var)), var)
}

M1_V1.var <- colnames(M1_V1)
M1_V2.var <- colnames(M1_V2)
var.matched <- M1_V1.var[which(M1_V1.var %in% M1_V2.var)] ###common variables between two versions of Module 1

dictionary <- rio::import("https://episphere.github.io/conceptGithubActions/aggregate.json",format = "json")
dd <- dplyr::bind_rows(dictionary,.id="CID")

unique(dd[grepl(paste(sapply(strsplit(var.matched[grepl("384191091",var.matched)],"_"),tail,1),collapse = "|"),dd$CID),c("CID","Variable Label")])
# CID       `Variable Label`                    `Variable Name`         
# <chr>     <chr>                               <chr>                   
#   1 412790539 White                               SrvBOH_White_v1r0       
# 2 458435048 Black, African American, or African SrvBOH_Black_v1r0       
# 3 583826374 American Indian or Alaska Native    SrvBOH_AlaskaNative_v1r0
# 4 586825330 Hawaiian or other Pacific Islander  SrvBOH_Hawaiian_v1r0    
# 5 636411467 Asian                               SrvBOH_Asian_v1r0       
# 6 706998638 Hispanic, Latino, or Spanish        SrvBOH_Hispanic_v1r0    
# 7 746038746 Prefer not to answer                SrvBOH_PrefNoAnsRE_v1r0 
# 8 747350323 None of these fully describe me. Please describe [text box]
# 9 807835037 None of these fully describe me. Please describe           
# 10 973565052 Middle Eastern or North African     

var.matched[grepl("384191091",var.matched)] #to check whether the race responses are in the commone part of two versions of Module 1 
# [1] "D_384191091_D_384191091_D_412790539" "D_384191091_D_384191091_D_458435048" "D_384191091_D_384191091_D_583826374"
# [4] "D_384191091_D_384191091_D_586825330" "D_384191091_D_384191091_D_636411467" "D_384191091_D_384191091_D_706998638"
# [7] "D_384191091_D_384191091_D_746038746" "D_384191091_D_384191091_D_807835037" "D_384191091_D_384191091_D_973565052"
# [10] "D_384191091_D_747350323"  

M1_race_v1 <- mod1_v1[,which(grepl("384191091|Connect_ID",colnames(M1_V1)))] #1436
M1_race_v1$version  <- 1

M1_race_v2 <- mod1_v2[,which(grepl("384191091|Connect_ID",colnames(M1_V2)))] #4956
M1_race_v2$version  <- 2
###participants with duplicate entries on the Module 1 on two versions
common.IDs <- M1_V1$Connect_ID[M1_V1$Connect_ID %in% M1_V2$Connect_ID]

race_M1dup<- as.data.frame(rbind(M1_race_v1,M1_race_v2)) %>% filter(.,Connect_ID %in% common.IDs) %>% 
  mutate(response= rowSums(across(starts_with("D_384191091_D_384191091"))))
unique_responseID <- race_M1dup$Connect_ID[is.na(race_M1dup$response)]
race_M1dup1 <- subset(race_M1dup, race_M1dup$Connect_ID %nin%unique_responseID)

race.var <- colnames(race_M1dup1)[grepl("384191091",colnames(race_M1dup))]
diff_race <- NULL
for (i in 1:length(race.var)){
  #x <- race_M1dup[which(race_M1dup$version==1),var[i]]]
  tmp <- race_M1dup1[,c("Connect_ID","version",race.var[i])]
  diff <- dcast(tmp, Connect_ID ~ version, value.var=race.var[i])
  #eval(parse(text=paste("diff <- dcast(tmp, Connect_ID ~ version, value.var = \"",race.var[i],"\")",sep="")))
  colnames(diff)[2] <- "v1"
  colnames(diff)[3] <- "v2"
  diff$sum <- ifelse(mode(diff$v1)=="numeric" & mode(diff$v2)=="numeric", rowSums(diff[,c(2,3)],na.rm=TRUE), NA)
  diff$diff_v1v2 <- ifelse( is.na(diff$v1) & is.na(diff$v2), 0,
                                         ifelse( is.na(diff$v1) &  diff$v2 > 0, 2 ,
                                                 ifelse(diff$v1 >0 & is.na(diff$v2), 1,
                                                        ifelse(diff$v1 != diff$v2, 4, 3))))
  #print(diff[which(diff$diff==4),])
  diff$var <- race.var[[i]]
  #colnames(diff) <- paste(race.var[i],colnames(diff),sep="_")
  diff_race <- rbind(diff_race,diff[which(diff$diff_v1v2==4),])
  #diff_race <- rbind(diff_race,diff[,c(1,4,5)])
}

diff_race
#    Connect_ID v1 v2 sum diff_v1v2                                 var
#1: 1137648664  1  0   1         4 D_384191091_D_384191091_D_412790539
# 2: 1322312513  1  0   1         4 D_384191091_D_384191091_D_412790539
# 3: 1322312513  1  0   0         4 D_384191091_D_384191091_D_458435048
# 4: 9904077888  0  1   0         4 D_384191091_D_384191091_D_458435048
# 5: 9904077888  1  0   0         4 D_384191091_D_384191091_D_746038746
# 6: 1137648664  0  1   1         4 D_384191091_D_384191091_D_807835037
# 7: 1322312513  0  1   1         4 D_384191091_D_384191091_D_807835037
# 8: 9708950713  1  0   0         4 D_384191091_D_384191091_D_973565052
racediff <- race_M1dup[which(race_M1dup$Connect_ID %in% diff_race$Connect_ID),]

parts <- "SELECT Connect_ID, token, d_512820379, d_471593703, state_d_934298480, d_230663853,
d_335767902, d_982402227, d_919254129, d_699625233, d_564964481, d_795827569, d_544150384,
d_371067537, d_430551721, d_821247024, d_914594314,  d_827220437,
d_949302066 , d_517311251, d_205553981, d_117249500, state_d_849518448, state_d_119643471, state_d_684926335  FROM `nih-nci-dceg-connect-prod-6d04.FlatConnect.participants_JP` 
where Connect_ID IS NOT NULL"
parts_table <- bq_project_query(project, parts)
parts_data <- bq_table_download(parts_table, bigint = "integer64")

cnames <- names(parts_data)
# to check variables in recr_noinact_wl1
for (i in 1: length(cnames)){
  varname <- cnames[i]
  var<-pull(parts_data,varname)
  parts_data[,cnames[i]] <- ifelse(numbers_only(var), as.numeric(as.character(var)), var)
}

parts_data[which(parts_data$Connect_ID %in% diff_race$Connect_ID),c("state_d_849518448", "state_d_119643471", "state_d_684926335","d_949302066")]
parts_data$Connect_ID <- as.numeric(parts_data$Connect_ID) ###need to convert type- m1... is double and parts is character

table(parts_data$d_949302066[which(parts_data$Connect_ID %in% unique_responseID)])
###231311385 615768760 
##9         2 
table(parts_data$d_949302066[which(parts_data$Connect_ID %in% common.IDs)])
#231311385 615768760 
#57         5 
merged= left_join(m1_combined_v1v2_nodup, parts_data, by="Connect_ID") 

responseID_v1_toremove <- race_M1dup$Connect_ID[which(is.na(race_M1dup$response) & race_M1dup$version==1)] #  10 without v1 but with to v2
unique_responseID_v2 <- race_M1dup$Connect_ID[which(is.na(race_M1dup$response) & race_M1dup$version==2)] #7378395603 without v2, only v1
#to keep v2
dup_v2ID <- unique(race_M1dup$Connect_ID[race_M1dup$Connect_ID %nin% unique_responseID_v2])
###for the duplicate response on Race: to keep the response of version 2 of these 51 participants with same responses (between v1 and v2
###for the other 11 partcipants with one set of response: 10 participants with v2, and 1 with v1 (above)

M1_race_v1_nodup <- M1_race_v1[which(M1_race_v1$Connect_ID %nin% dup_v2ID),] #1426
race_M1_nodup <- as.data.frame(rbind(M1_race_v1_nodup,M1_race_v2[which(M1_race_v2$Connect_ID %nin% unique_responseID_v2),])) %>% 
  mutate(response= rowSums(across(starts_with("D_384191091_D_384191091")),na.rm=TRUE)) #6330
table(race_M1_nodup$response,race_M1_nodup$version)
#to merge with participants table
parts_race_M1 <- merge(parts_data,race_M1_nodup,by="Connect_ID",all.x=TRUE,all.y=TRUE)

table(parts_race_M1$d_949302066,parts_race_M1$response)
##              1    2    3    4    5
# 231311385 5595  295   48    4    2
# 615768760  283   23    3    0    0
# 972455046    0    0    0    0    0

table(race_M1_nodup$response,race_M1_nodup$version)
# 
#     1    2
# 0   15   62
# 1 1297 4581
# 2   55  263
# 3    7   44
# 4    1    3
# 5    0    2

###update the variable names with labels
urlfile<- "https://raw.githubusercontent.com/episphere/conceptGithubActions/master/csv/masterFile.csv" ###to grab the updated dd from github
y <- read.csv(urlfile)

part_raceM1_CID <- unique(y[grepl(paste(sapply(strsplit(colnames(parts_race_M1),"_"),tail,1),collapse = "|"),y$conceptId.3),c("conceptId.3","Variable.Label","Variable.Name","conceptId.4","Current.Format.Value")])
# CID       `Variable Label`                    `Variable Name`         
# <chr>     <chr>                               <chr>                   
#   1 412790539 White                               SrvBOH_White_v1r0       
# 2 458435048 Black, African American, or African SrvBOH_Black_v1r0       
# 3 583826374 American Indian or Alaska Native    SrvBOH_AlaskaNative_v1r0
# 4 586825330 Hawaiian or other Pacific Islander  SrvBOH_Hawaiian_v1r0    
# 5 636411467 Asian                               SrvBOH_Asian_v1r0       
# 6 706998638 Hispanic, Latino, or Spanish        SrvBOH_Hispanic_v1r0    
# 7 746038746 Prefer not to answer                SrvBOH_PrefNoAnsRE_v1r0 
# 8 747350323 None of these fully describe me. Please describe [text box]
# 9 807835037 None of these fully describe me. Please describe           
# 10 973565052 Middle Eastern or North African   
###based on the CDC race/ethnicity definition: https://www.govinfo.gov/content/pkg/FR-1997-10-30/pdf/97-28653.pdf, updated the names of Hawaiian in labels
parts_race_M1 <- expss::apply_labels(parts_race_M1,d_827220437 = "Site",#RcrtES_Site_v1r0
                              d_827220437 = c("HealthPartners"= 531629870, "Henry Ford Health System"=548392715, 
                                              "Kaiser Permanente Colorado" = 125001209, "Kaiser Permanente Georgia" = 327912200,
                                              "Kaiser Permanente Hawaii" = 300267574,"Kaiser Permanente Northwest" = 452412599, 
                                              "Marshfield Clinic Health System" = 303349821,"Sanford Health" = 657167265, 
                                              "University of Chicago Medicine" = 809703864, "National Cancer Institute" = 517700004,
                                              "National Cancer Institute" = 13,"Other" = 181769837),
                              D_384191091_D_384191091_D_412790539 = "White",
                              D_384191091_D_384191091_D_458435048 = "Black, African American, or African",
                              D_384191091_D_384191091_D_583826374 = "American Indian or Alaska Native",
                              D_384191091_D_384191091_D_586825330 = "Hawaiian or other Pacific Islander",
                              D_384191091_D_384191091_D_636411467 = "Asian",
                              D_384191091_D_384191091_D_706998638 = "Hispanic, Latino, or Spanish",
                              D_384191091_D_384191091_D_746038746 = "Prefer not to answer",
                              D_384191091_D_384191091_D_807835037 = "None of these fully describe me. Please describe",
                              D_384191091_D_384191091_D_973565052 = "Middle Eastern or North African",
                              D_384191091_D_747350323 = "None of these fully describe me. Please describe [text box]")

parts_race_M1$Site <-  factor(parts_race_M1$d_827220437,exclude=NULL,
                                 levels=c("HealthPartners", "Henry Ford Health System","Marshfield Clinic Health System",
                                          "Sanford Health", "University of Chicago Medicine","Kaiser Permanente Colorado",
                                          "Kaiser Permanente Georgia","Kaiser Permanente Hawaii","Kaiser Permanente Northwest",
                                          "National Cancer Institute","Other"))
parts_race_M1 <- parts_race_M1 %>% 
  mutate(verified = case_when(d_821247024 == 875007964 ~ "Not yet verified",
                              d_821247024 == 197316935  ~ "Verified",
                              d_821247024 ==  219863910 ~ "Cannot be verified",
                              d_821247024 ==  922622075 ~ "Duplicate",
                              d_821247024 ==  160161595 ~ "Outreach timed out"),                                 
         race = case_when(state_d_684926335 == 635279662 | state_d_849518448 == 768826601 | state_d_119643471 == 635279662 ~ "White" ,#768826601
                          state_d_684926335 %in% c(232334767,401335456) | state_d_849518448 == 181769837 |
                          state_d_119643471 == 232334767| state_d_119643471  ==211228524|state_d_119643471 ==308427446| 
                          state_d_119643471  ==432722256| state_d_119643471  ==232663805| state_d_119643471  ==785578696| 
                            state_d_119643471  ==200929978| state_d_119643471  ==490725843| state_d_119643471  == 965998904 ~ "Other", #181769837
                          state_d_684926335 == 178420302  | state_d_849518448 ==178420302 | state_d_119643471 == 986445321| 
                            state_d_119643471  == 746038746| state_d_119643471  == 178420302 | 
                            (is.na(state_d_119643471) & d_827220437== 657167265) ~ "Unknown"),
         race_ethnic = case_when(response==1 & D_384191091_D_384191091_D_412790539 == 1 ~ "White",
                                 response==1 & D_384191091_D_384191091_D_458435048 == 1 ~ "Black, African American, or African",
                                 response==1 & D_384191091_D_384191091_D_583826374 == 1 ~ "American Indian or Alaska Native",
                                 response==1 & D_384191091_D_384191091_D_586825330 == 1 ~ "Native Hawaiian or Other Pacific Islander",
                                 response==1 & D_384191091_D_384191091_D_636411467 == 1 ~ "Asian",
                                 response==1 & D_384191091_D_384191091_D_706998638 == 1 ~ "Hispanic, Latino, or Spanish",
                                 response==1 & D_384191091_D_384191091_D_973565052 == 1 ~ "Middle Eastern or North African",
                                 response==1 & D_384191091_D_384191091_D_807835037 == 1 ~ "Other Race",
                                 response ==1 & D_384191091_D_384191091_D_746038746 == 1 ~ "Denied,Skipped on Race questions",
                                 response >1 & D_384191091_D_384191091_D_746038746 %in% c(0, NA) ~ "More Than One Race",
                                 response == 0  & is.na(D_384191091_D_747350323) ~ "Unknown,Skipped on Race questions"),
         race_ethnic1 = case_when(response==1 & D_384191091_D_384191091_D_412790539 == 1 ~ "White",
                                 response==1 & D_384191091_D_384191091_D_458435048 == 1 ~ "Black, African American, or African",
                                 response==1 & D_384191091_D_384191091_D_583826374 == 1 ~ "American Indian or Alaska Native",
                                 response==1 & D_384191091_D_384191091_D_586825330 == 1 ~ "Native Hawaiian or Other Pacific Islander",
                                 response==1 & D_384191091_D_384191091_D_636411467 == 1 ~ "Asian",
                                 response==1 & D_384191091_D_384191091_D_706998638 == 1 ~ "Hispanic, Latino, or Spanish",
                                 response==1 & D_384191091_D_384191091_D_973565052 == 1 ~ "Middle Eastern or North African",
                                 response==1 & D_384191091_D_384191091_D_807835037 == 1 ~ "Other Race",
                                 response >1 & D_384191091_D_384191091_D_746038746 %in% c(0, NA) ~ "More Than One Race",
                                 (response ==1 & D_384191091_D_384191091_D_746038746 == 1) | response == 0  & is.na(D_384191091_D_747350323) ~ "Unknown"))

parts_race_M1$race_ethnic <- factor(parts_race_M1$race_ethnic,levels=c("White","Black, African American, or African","Hispanic, Latino, or Spanish",
                                                                      "Asian","Native Hawaiian or Other Pacific Islander","American Indian or Alaska Native",
                                                                      "Middle Eastern or North African","Other Race","More Than One Race","Denied,Skipped on Race questions",
                                                                      "Unknown,Skipped on Race questions"))
table(parts_race_M1$race_ethnic, parts_race_M1$race)

# Other Unknown White
# American Indian or Alaska Native       14       1     0
# Asian                                 256      23     0
# Black, African American, or African   822      79     4
# Denied,Skipped on Race questions       12       5    11
# Hawaiian or other Pacific Islander     13       1     1
# Hispanic, Latino, or Spanish          117      19    17
# Middle Eastern or North African         5       4     7
# More Than One Race                    199      35   141
# Other                                  27       2    14
# Unknown,Skipped on Race questions      27       8    42
# White                                  64     202  4156

table(parts_race_M1$d_949302066,parts_race_M1$d_821247024)

# 197316935 219863910 875007964 922622075
# 231311385      5918         8        11        11
# 615768760       393         2         3         4
# 972455046       840        82       255       453

parts_race_M1$race_ethnic1 <- factor(parts_race_M1$race_ethnic1,levels=c("White","Black, African American, or African","Hispanic, Latino, or Spanish",
                                                                       "Asian","Native Hawaiian or Other Pacific Islander","American Indian or Alaska Native",
                                                                       "Middle Eastern or North African","Other Race","More Than One Race",
                                                                       "Unknown"))


M1_race_complt <- filter(parts_race_M1, d_949302066==231311385 & d_821247024 == 197316935) %>% arrange(race_ethnic1)#n=5918

table(M1_race_complt$race_ethnic, M1_race_complt$race)

#                                       Other Unknown White
# American Indian or Alaska Native       14       1     0
# Asian                                 239      22     0
# Black, African American, or African   748      76     4
# Denied,Skipped on Race questions       10       5     8
# Hawaiian or other Pacific Islander     12       1     1
# Hispanic, Latino, or Spanish          111      18    14
# Middle Eastern or North African         5       4     7
# More Than One Race                    184      33   131
# Other                                  25       2    12
# Unknown,Skipped on Race questions       1       0     3
# White                                  60     189  3977
table(M1_race_complt$race_ethnic1, M1_race_complt$race)
# Other Unknown White
# White                                        60     189  3977
# Black, African American, or African         748      76     4
# Hispanic, Latino, or Spanish                111      18    14
# Asian                                       239      22     0
# Native Hawaiian or Other Pacific Islander    12       1     1
# American Indian or Alaska Native             14       1     0
# Middle Eastern or North African               5       4     7
# Other Race                                   25       2    12
# More Than One Race                          184      33   131
# Unknown                                      11       5    11
race_M1complt <- M1_race_complt  %>% 
  arrange(race_ethnic1) %>%
  group_by(race_ethnic1) %>% dplyr::summarise(count=n()) 
race_M1complt$count_pct <- paste0(race_M1complt$count," (", round(100*race_M1complt$count/sum(race_M1complt$count),digits=2),"%)")
race_M1complt$percent <- round(100*race_M1complt$count/sum(race_M1complt$count),digits=2)

race_M1complt <- race_M1complt[order(-race_M1complt$count),]
#race_M1complt$midpoint = cumsum(race_M1complt$count) - (race_M1complt$count / 2)
race_M1complt$midpoint <- ifelse(race_M1complt$count<20, race_M1complt$count, cumsum(race_M1complt$count) - (race_M1complt$count / 2))
race_M1complt$midpoint

race_M1complt <- race_M1complt %>% mutate(race_ethnic1=factor(race_ethnic1,
                                          levels= c("White","Black, African American, or African","Hispanic, Latino, or Spanish",
                                                    "Asian","Native Hawaiian or Other Pacific Islander","American Indian or Alaska Native",
                                                    "Middle Eastern or North African","Other Race","More Than One Race","Unknown")))
display.brewer.all(colorblindFriendly = TRUE) 
mycolors <- c("#053061","#999999","#F16913","#FD8D3C","#FFD92F","#0072B2","#009E73","#D55E00","#B35806","#F0E442", "#FFFFBF")
barplot(c(1:11),col=mycolors)


# barplot(c(1:11),col=brewer.pal(11,"RdBu"))
# barplot(c(1:9),col=brewer.pal(9,"Blues"))

# levels(race_M1complt$race_ethnic) <- c("White","Black, African American, or African","Hispanic, Latino, or Spanish",
#                                      "Asian","Native Hawaiian or Other Pacific Islander","American Indian or Alaska Native",
#                                       "Middle Eastern or North African","Other Race","More Than One Race","Denied,Skipped on Race questions",
#                                       "Unknown,Skipped on Race questions")
names(mycolors) <- levels(race_M1complt$race_ethnic1)

barplot(c(1:11),col=c("#053061","#999999","#F16913","#FD8D3C","#FFD92F","#0072B2","#009E73","#D55E00","#B35806","#F0E442", "#FFFFBF"))
col=c("#E69F00","#56B4E9","#F46D43","#A6D96A","#08519C")


#label outside
# ggplot(race_M1complt, aes(x = "", y = count, fill = fct_rev(race_ethnic))) +
#   geom_bar(width = 1, stat = "identity") +
#   coord_polar(theta = "y", start = 0) +
#   scale_fill_manual(values = mycolors,name = "Race Ethnicity") +
#   scale_colour_manual(values= mycolors) +
#   labs(x = "", y = "", title = "Distribution of Race and Ethnicity Among Connect Verified Participants",
#        fill = "race_ethnic") + 
#   geom_text(aes(x=1.9, label=count_pct),
#             position =  position_stack(vjust=0.6), size=3, color="black",fontface = "bold") +
#   theme(panel.background = element_blank(),
#         plot.title = element_text(hjust = 0.0, face="bold"), 
#         axis.ticks = element_blank(),axis.text = element_blank(),
#         legend.title = element_text(hjust = 0.5, face="bold", size = 10))
# 
# ggplot(race_M1complt, aes(x = "", y = count, fill = fct_rev(levels(race_ethnic1)))) +
#   geom_bar(width = 1, stat = "identity") +
#   coord_polar(theta = "y", start = 0) +
#   scale_fill_manual(values = mycolors,name = "Race Ethnicity") +
#   scale_colour_manual(values= mycolors) +
#   labs(x = "", y = "", title = "Distribution of Race and Ethnicity Among Connect Verified Participants",
#        fill = "race_ethnic") + 
#   geom_text(aes(x=1.8, label=percent),
#             position =  position_stack(vjust=0.8), size=3, color="black",fontface = "bold") +
#   theme(panel.background = element_blank(),
#         plot.title = element_text(hjust = 0.0, face="bold"), 
#         axis.ticks = element_blank(),axis.text = element_blank(),
#         legend.title = element_text(hjust = 0.5, face="bold", size = 10))

library(ggrepel)

# ggplot(race_M1complt, aes(x = "", y = count, fill = fct_rev(race_ethnic1))) +
#   geom_bar(width = 1, stat = "identity") +
#   coord_polar(theta = "y", start = 0) +
#   scale_fill_manual(values = mycolors,name = "Race Ethnicity") +
#   scale_colour_manual(values= mycolors) +
#   labs(x = "", y = "", title = "Distribution of Race and Ethnicity Among Connect Verified Participants",
#        fill = "race_ethnic") + 
#   geom_text(aes(x=1.8, label=percent),
#             position =  position_stack(vjust=0.8), size=3, color="black",fontface = "bold") +  
#   theme(panel.background = element_blank(),
#         plot.title = element_text(hjust = 0.0, face="bold"), 
#         axis.ticks = element_blank(),axis.text = element_blank(),
#         legend.title = element_text(hjust = 0.5, face="bold", size = 10))

race_M1complt <- race_M1complt %>% arrange(midpoint)

names(mycolors) <- levels(race_M1complt$race_ethnic1)
##this is the best plot I can make

  race_M1plot <- race_M1complt %>%
  mutate(csum = rev(cumsum(rev(count))), 
         pos = count/2 + lead(csum, 1),
         pos = if_else(is.na(pos), count/2, pos),
         percentage = count/sum(count)) %>% 
  ggplot(aes(x = "", y = count, fill = fct_inorder(race_ethnic1))) + 
  scale_fill_manual(values = mycolors,name = "Race Ethnicity") +
  scale_colour_manual(values= mycolors) +
  labs(x = "", y = "", title = "Distribution of Race and Ethnicity Among Connect Verified Participants",
       fill = "race_ethnic") +   
  geom_col(width = 3.5, color = 1) +
  geom_label_repel(aes(y = pos,
                       label = percent, 
                       fill = race_ethnic1),
                   size = 3,color="red",
                   nudge_x = 3,
                   show.legend = FALSE) +
  labs(  fill = "Subtype" ) +
  coord_polar(theta = "y") +   theme_void() 
  
  
race_M1complt$percent <- round(100*race_M1complt$count/sum(race_M1complt$count),digits=2)
#race_M1complt$RaceEthnicity <- as.factor(race_M1complt$race_ethnic1)  ##to redefine the exact levels of this variable
race_M1complt <- race_M1complt %>% arrange(desc(as.numeric(race_ethnic1)))
race_M1complt$text_y <- cumsum(race_M1complt$percent) - race_M1complt$percent/2
#names(mycolors) <- fct_rev(tb_serum$Receipt_to_Processing_Time) #remove this line JW

raceM1_plot <- ggplot(data = race_M1complt, aes(x=" ", y=percent,  fill=race_ethnic1)) +
  geom_col(color = "black") + geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) + 
  #Adding color instead of black text to percentages- using geom_label instead of geom_text
  #geom_text_repel(data=tb_serum[which(tb_serum$serum_N !=0),],aes(label=Percent , y =text_y ),nudge_x = 1,nudge_y=0.1,
  # size = 4, show.legend = F) + 
  geom_label_repel(data=race_M1complt,aes(label=percent , y =text_y ),nudge_x = 1,nudge_y=0.05,force=0.1,
                   colour="green", segment.colour="black", size = 4, show.legend = F) +
  ggtitle(label = "Distribution Of Race and Ethnicity Among Connect Verified Participants",
          subtitle="Connect for Cancer Prevention Study
                    Nine Sites 03/21/2023") + 
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5,size=12),
        plot.caption = element_text(color = "green", face = "italic")) +
  scale_fill_manual(values = mycolors,name = "Race Ethnicity") +
  scale_colour_manual(values= mycolors) ##to replace the previous line above Jing


library(plotly)

p <- plot_ly(race_M1complt, labels = ~race_ethnic1, values = ~percent, type = 'pie',textposition = 'outside',textinfo = 'label+percent') %>%
  layout(title = 'Letters',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))