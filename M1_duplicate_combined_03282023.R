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
library(expss) ###to add labels
library(epiDisplay) ##recommended applied here crosstable, tab1
library(summarytools) ##recommended
library(gmodels) ##recommended
library(magrittr)
library(arsenal)
library(gtsummary)
library(lubridate)
library(rio)

dictionary <- rio::import("https://episphere.github.io/conceptGithubActions/aggregate.json",format = "json")
dd <- dplyr::bind_rows(dictionary,.id="CID")
dd <-rbindlist(dictionary,fill=TRUE,use.names=TRUE,idcol="CID")
dd$`Variable Label`[is.na(dd$`Variable Label`)] <- replace_na(dd$'Variable Name')

dd <- as.data.frame.matrix(do.call("rbind",dictionary)) 
dd$CID <- rownames(dd)
#https://shaivyakodan.medium.com/7-useful-r-packages-for-analysis-7f60d28dca98
devtools::install_github("tidyverse/reprex")
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
var.matched <- M1_V1.var[which(M1_V1.var %in% M1_V2.var)]
length(var.matched)  #1275 #1278 vars 01112023

V1_only_vars <- colnames(M1_V1)[colnames(M1_V1) %nin% var.matched] #232 #229 01112023
V2_only_vars <- colnames(M1_V2)[colnames(M1_V2) %nin% var.matched] #253 #253 01112023

length(M1_V1$Connect_ID[M1_V1$Connect_ID %in% M1_V2$Connect_ID])
#[1] 59 with the completion of two versions of Module1 
#[1] 62 with completing both versions of M1 ###double checked 03/28/2023

common.IDs <- M1_V1$Connect_ID[M1_V1$Connect_ID %in% M1_V2$Connect_ID]
M1_V1_common <- mod1_v1[,var.matched]

M1_V2_common <- mod1_v2[,var.matched]
M1_V1_common$version <- 1
M1_V2_common$version <- 2


#to check the empty columns in both version common part
empty_columns_V1 <- colSums(is.na(M1_V1_common) |M1_V1_common == "") == nrow(M1_V1_common)
empty_columns_V2 <- colSums(is.na(M1_V2_common) |M1_V2_common == "") == nrow(M1_V2_common)
length(colnames(M1_V1_common[,empty_columns_V1]))
#[1] "COMPLETED"               "COMPLETED_TS"            "D_317093647_D_206625031" "D_317093647_D_261863326"
#[5] "D_406011084_D_197994844" "D_406011084_D_380275309" "D_593017220_D_106010694" "D_593017220_D_434556295"

summary(M1_V1[,colnames(M1_V2_common[,empty_columns_V2])])
length(colnames(M1_V2_common[,empty_columns_V2]))
# [1] "COMPLETED"                                                                    
# [2] "COMPLETED_TS"                                                                 
# [3] "D_317093647_D_206625031"                                                      
# [4] "D_317093647_D_261863326"                                                      
# [5] "D_384881609_1_1_D_206625031_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1"
# [6] "D_483975329_1_1_D_206625031_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1_1"
# [7] "D_527057404_D_206625031"                                                      
# [8] "D_750420077_D_505282171"                                                      
# [9] "D_750420077_D_578416151"                                                      
# [10] "D_750420077_D_846483618" 

dd[grepl("317093647|206625031|261863326|384881609|483975329|750420077|505282171|578416151|846483618", dd$CID),c("CID","Variable Label")]
# Variable Label
# 206625031                                                                                                                                                         Skin cancer diagnosis age
# 261863326                                                                                                                                                        Skin cancer diagnosis year
# 317093647                                      Mother - How old was your mother when they were first told by a doctor or other health professional that they have or had esophageal cancer?
#   384881609    Sibling 1 - How old was your [SIBLING INITIALS OR NICKNAME/YOUR SIBLING] when they were first told by a doctor or other health professional that they have or had anal cancer?
#   483975329 Sibling 1 - How old was your [SIBLING INITIALS OR NICKNAME/YOUR SIBLING] when they were first told by a doctor or other health professional that they have or had bladder cancer?
#   505282171                                                                                                                                                                            Cervix
# 578416151                                                                                                                                                                            Uterus
# 750420077                                                                                                                             Please select the body parts that you were born with.
# 846483618                                                                                                                                                                            Vagina
summary(M1_V2_common[,colnames(M1_V1_common[,empty_columns_V1])])

M1_common  <- rbind(M1_V1_common, M1_V2_common)
M1_response <- matrix(data=NA, nrow=118, ncol=967)

m1_v1_only <- mod1_v1[,c("Connect_ID", V1_only_vars)]
m1_v2_only <- mod1_v2[,c("Connect_ID", V2_only_vars)]
m1_v1_only$version <- 1
m1_v2_only$version <- 2
#for (i in 1:length)

#library(janitor)

m1_common <- rbind(M1_V1_common,M1_V2_common)
m1_common_v1 <- merge(m1_common, m1_v1_only, by=c("Connect_ID","version"),all.x=TRUE)
m1_combined_v1v2 <- merge(m1_common_v1,m1_v2_only,by=c("Connect_ID","version"),all.x=TRUE)

write.csv(m1_combined_v1v2,"~/Documents/Connect_projects/Biospecimen_Feb2022/Jing_projects/biospecQC_03082022/data/Module1_twoversions_combined_12102022.csv",row.names=F, na="")

###below here, the analysis is to check the variables of both versions among these 62 participants with duplicate completion of both moduels
###based on their complete rate in each section: v1_only, common part of two versions, and v2 version to select the more completversion with more compl
verson_dup <- m1_common[which(m1_common$Connect_ID %in% common.IDs),]

empty_columns <- colSums(is.na(verson_dup) |verson_dup == "") == nrow(verson_dup)
length(colnames(verson_dup[empty_columns])) #310 #313 01112023

verson_dup1 <- verson_dup[,colnames(verson_dup[!empty_columns])]

verson_dup1 <- verson_dup1[order(verson_dup1$Connect_ID),] 
veron_dup1 <- verson_dup1[order(verson_dup1$version),]
var.match.CID <- as.data.frame(cbind(colnames(verson_dup1),sapply(strsplit(colnames(verson_dup1),"_"),tail,1)))
var.match.CID$last.CID <- substring(sapply(strsplit(colnames(verson_dup1),"D_"),tail,1),1,9)
var.match.CID$first.CID <- substring(colnames(verson_dup1),3,11)

var.match.dd <- merge(var.match.CID, dd[,c("CID","Variable Label")],by.x="last.CID",by.y="CID",all.x=TRUE)
var.match.dd <- var.match.dd %>% dplyr::rename(Label.last.CID="Variable Label")
var.match.dd <- merge(var.match.dd, dd[,c("CID","Variable Label")],by.x="first.CID",by.y="CID",all.x=TRUE)
var.match.dd <- var.match.dd %>% dplyr::rename(Label.first.CID="Variable Label")


label_cid <- function(cid){unique(dd$`Variable Label`[grepl(cid,dd$cid)])}
# var.match.CID <- var.match.CID %>% mutate(Label.1st = map(.,label_cid(first.CID))
# var.match.CID$Label.1st <- dd$`Variable Label`[grepl(unique(var.match.CID$first.CID),dd$CID)]
# Label.1st <- dd$`Variable Label`[(grepl(paste(unique(var.match.CID$first.CID),collapse="|"),dd$CID)]


dup_nas <- sapply(veron_dup1, function(x) all(is.na(x) | x == '' ))

var <- colnames(verson_dup1)
verson_dup1$version_check <- 0
for (i in 1:length(colnames(verson_dup1))){
  
  check <- ifelse(is.na(verson_dup1[,var[i]]) ,0,1)
  verson_dup1$version_check <- verson_dup1$version_check + check
}
tapply(verson_dup1$version_check,verson_dup1$version,summary)
# $`1`
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 6.0    93.5   165.0   152.8   202.0   403.0 
# 
# $`2`
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 6.0   247.5   281.0   279.4   311.0   422.0 
var[962:967]
#[1] "D_992987417"   "treeJSON"      "uid"           "date"          "version"       "version_check"
diff_dup <- NULL
for (i in 2:962){
  #x <- verson_dup1[which(verson_dup1$version==1),var[i]]]
  tmp <- verson_dup1[,c("Connect_ID","version",var[i])]
  diff <- dcast(tmp, Connect_ID ~ version, value.var=var[i])
  
  #eval(parse(text=paste("diff <- dcast(verson_dup1, Connect_ID ~ version, value.var = \"",var[i],"\")",sep="")))
  colnames(diff)[2] <- "v1"
  colnames(diff)[3] <- "v2"
  diff$v1 = ifelse(numbers_only(diff$v1), as.numeric(as.character(diff$v1)),diff$v1)
  diff$v2 = ifelse(numbers_only(diff$v2), as.numeric(as.character(diff$v2)),diff$v2)  
  
  diff$sum <- ifelse(mode(diff$v1)=="numeric" & mode(diff$v2)=="numeric", rowSums(diff[,c(2,3)],na.rm=TRUE), NA)
  diff <- diff %>% mutate(diff_v1v2 = ifelse( is.na(v1) & is.na(v2), 0,
                                         ifelse( is.na(v1) &  v2 > 0, 2 ,
                                                 ifelse(v1 >0 & is.na(v2), 1,
                                                        ifelse(v1 != v2,4, 3)))))
  
  diff$var <- var[[i]]
  #colnames(diff) <- paste(var[i],colnames(diff),sep="_")
  diff_dup <- rbind(diff_dup,diff[which(diff$diff_v1v2!=3 & diff$diff_v1v2!= 0),])
  #diff_dup <- cbind(diff_dup,diff[,c(1,4,5)])
}

table(diff_dup$diff_v1v2)

#1    2    4 
#244 4019  544 ##the difference between two versions: version 2 are more complete than version 1

table(diff_dup$Connect_ID,diff_dup$diff_v1v2)

#              1   2   4
# 1035842173   0 103   0
# 1137648664   3  21  20
# 1254510349  11  63   9
# 1322312513   5  65   4
# 1448181276   0 170   0
# 1596738642   9  53   9
# 1745183594   0  97   0
# 2225741914   1 119   4
# 2434106769   2  41  28
# 2503474663   3 117  12
# 2801868875   2   5  20
# 2980632837   8  10  26
# 3012249625   0  13   0
# 3124201981   4  64   5
# 3192425824   0  53  10
# 3202201265  24  60  16
# 3934969608   0  76  11
# 3977547925   2  42  10
# 3983492332   8  26  32
# 4178910664   6  77   9
# 4249216023   0 106   0
# 4491438652   0  73   0
# 4670161070   0  99   0
# 4853507897   7 100  11
# 4887607966   7  36  21
# 5028262383   1  38  12
# 5770553465   0  63   2
# 5961056153   0   5  10
# 6330599580   1  39  11
# 6442875968   0  47   3
# 6480399310   3  10  22
# 6490089737   2   1   5
# 6657539133   0 113   0
# 6698262334   0  43  10
# 6795636698   0  46   7
# 6830758400   2  68   8
# 6943407333   4  72  10
# 7041419170   3  65   6
# 7074192548   0 119   0
# 7154937817   0  52  12
# 7268730494   0 134   0
# 7378395603  73   0   0
# 7666852403   0  89   7
# 7857043877   1  63  10
# 7996726682   0  87   2
# 8048162478   0 113   0
# 8158275604   8   5  25
# 8381653219   0  95   0
# 8455823558   0  84   2
# 8824377567   3 118   4
# 8903103822   2  58   7
# 8930825906   3  40  12
# 8959852505   7  16   8
# 9007620392   5   5  26
# 9050790502   0  79   5
# 9325568364   4   4  23
# 9425034222   2 110   3
# 9484125194   0 135   2
# 9529174240   2  51  13
# 9708950713   4   8  13
# 9904077888  12 146   5
# 9981369134   0 109   2

verson_dup1[which(verson_dup1$Connect_ID==7378395603),c("version","version_check")] #will 
# # A tibble: 2 × 2
# version version_check[,"Connect_ID"]
# <dbl>                        <dbl>
#   1       1                          185
#   2       2                            6
###based on the current comparison results between two versions, most of 62 participants had more completion parts in version 2, except Connect_ID=7378395603
###Now, I am going to check the differences with the each question with the different answers from dd
diff_dup$last.CID <- substring(sapply(strsplit(diff_dup$var,"D_"),tail,1),1,9)
diff_dup$first.CID <- substring(diff_dup$var,3,11)


diff_dup <- merge(diff_dup, dd[,c("CID","Variable Label")],by.x="last.CID", by.y="CID",all.x=TRUE)
colnames(diff_dup)[which(colnames(diff_dup)=="Variable Label")] <- "last.CID.Label"
diff_dup <- merge(diff_dup, dd[,c("CID","Variable Label")],by.x="first.CID", by.y="CID",all.x=TRUE)

diff_dup <- diff_dup %>% dplyr::rename( "first.CID.Label"=  `Variable Label`)

urlfile <- "https://raw.githubusercontent.com/episphere/conceptGithubActions/master/csv/masterFile.csv" ###to grab the updated dd from github
y <- read.csv(urlfile)

unique(y[grepl("181769837|475665841|584368278|756948639", y$conceptId.4),c("conceptId.4","Current.Format.Value")])
###     conceptId.4        Current.Format.Value
# 12     181769837                  55 = Other
# 59     181769837                    55=Other
# 2206   584368278                  0= Retired
# 2207   475665841              1= A homemaker
# 2209   756948639 3= Unable to work (diabled)
unique(y[grepl("220083334|265452386|510148951|541300533|878286618|910745276|915528806", y$conceptId.4),c("conceptId.4","Current.Format.Value")])
# conceptId.4               Current.Format.Value
# 1203   220083334                  0 = Very feminine
# 1204   541300533                1 = Mostly feminine
# 1205   878286618              2 = Somewhat feminine
# 1206   910745276 3 = Equally feminine and masculine
# 1207   510148951             4 = Somewhat masculine
# 1208   265452386               5 = Mostly masculine
# 1209   915528806                 6 = Very masculine
length(unique(diff_dup$Connect_ID))
#[1] 62
length(unique(diff_dup$Connect_ID[which(diff_dup$diff_v1v2==1)])) ##with entries in version 1 only
#[1] 36
length(unique(diff_dup$Connect_ID[which(diff_dup$diff_v1v2==2)])) # with entries in version 2 only
#[1] 61
length(unique(diff_dup$Connect_ID[which(diff_dup$diff_v1v2==4)])) # different entries in both versions
#[1] 49
## to combine the response counts by participants
tmp <- verson_dup1[,c("Connect_ID","version","version_check")]
diff_check <- dcast(tmp, Connect_ID ~ version, value.var="version_check")

#eval(parse(text=paste("diff <- dcast(verson_dup1, Connect_ID ~ version, value.var = \"",var[i],"\")",sep="")))
colnames(diff_check)[2] <- "version_check_v1"
colnames(diff_check)[3] <- "version_check_v2"
summary(diff_check[,c("version_check_v1", "version_check_v2")])
diff_check <- diff_check %>% mutate(diff_v1v2 = ifelse( version_check_v1== version_check_v2, 3,ifelse( version_check_v1 > version_check_v2,1,
                                                        2)))
table(diff_check$diff_v1v2)
# 1  2  3 
# 6 54  2 

diff_check$Connect_ID[which(diff_check$diff_v1v2==3)]
#[1] 9007620392 9325568364

diff_dup <- merge(diff_dup,diff_check[,c(1:3)],by="Connect_ID")
diff_dup_4 <- filter(diff_dup, diff_v1v2==4)

unique(y[grepl("209571450|212249150|742032816|745561936|746038746|777814771|913602274|922395188", y$conceptId.4), c("conceptId.4","Current.Format.Value")])
conceptId.4       #Current.Format.Value
# 25     746038746                99=Declined
# 955    746038746              99 = Declined
# 2318   745561936   2 = $25,000-$34,999/year
# 2319   209571450   3 = $35,000-$49,999/year
# 2320   212249150   4 = $50,000-$74,999/year
# 2321   777814771   5 = $75,000-$99,999/year
# 2322   922395188 6 = $100,000-$149,999/year
# 2323   913602274 7 = $150,000-$199,999/year
# 2324   742032816  8 = $200,000 or more/year
# 2489   746038746               99= Declined

###to check the response in each version only data
var <- colnames(m1_v1_only)
m1_v1_only$version_check <- 0
for (i in 2:length(colnames(m1_v1_only))){ #except the "Connect_ID"
  
  check <- ifelse((is.na(m1_v1_only[,var[i]]) | m1_v1_only[,var[i]]=="NA") ,0,1)
  m1_v1_only$version_check <- m1_v1_only$version_check + check
}

summary(m1_v1_only$version_check)
# D_122887481_TUBLIG_D_232595513
# Min.   : 2.00                 
# 1st Qu.:10.00                 
# Median :12.00                 
# Mean   :11.55                 
# 3rd Qu.:13.00                 
# Max.   :55.00 

summary(m1_v1_only$version_check[which(m1_v1_only$Connect_ID %in% common.IDs)])
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 2.00    5.00    8.00    7.21    9.00   14.00 

var <- colnames(m1_v2_only)
m1_v2_only$version_check <- 0
for (i in 2:length(colnames(m1_v2_only))){ #except the "Connect_ID"
  var.name <- var[i]
  check <- ifelse((is.na(m1_v2_only[,var.name]) | m1_v2_only[,var.name]=="NA") ,0,1)
  m1_v2_only$version_check <- m1_v2_only$version_check + check
}

summary(m1_v2_only$version_check[which(m1_v2_only$Connect_ID %in% common.IDs)])
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 2.000   2.000   2.000   2.935   3.000  15.000 

v1_dupmore <- diff_check$Connect_ID[which(diff_check$diff_v1v2==1)] ##to check the response rate among these participants with 
##more response in duplicate parts of M1
m1_v1_only[which(m1_v1_only$Connect_ID %in% v1_dupmore),c("Connect_ID","version_check")]
# Connect_ID version_check[,"D_122887481_TUBLIG_D_232595513"]
# <dbl>                                            <dbl>
# 1 2980632837                                               14
# 2 4887607966                                               10
# 3 6490089737                                                8
# 4 7378395603                                                8
# 5 8158275604                                               13
# 6 9708950713                                               10
m1_v2_only[which(m1_v2_only$Connect_ID %in% v1_dupmore),c("Connect_ID","version_check")]
###A tibble: 6 × 2
# Connect_ID version_check[,"D_116065851_3_3_D_206625031_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3_3"]
# <dbl>                                                                                           <dbl>
# 1 2980632837                                                                                               2
# 2 4887607966                                                                                               2
# 3 6490089737                                                                                               2
# 4 7378395603                                                                                               2
# 5 8158275604                                                                                               7
# 6 9708950713                                                                                               2
###based on these participants with duplicate response on both version data, most of them had more response on the version 2
###on the version specific part, especially those 
diff_check[which(diff_check$diff_v1v2==1),]
#   Connect_ID version_check_v1 version_check_v2 diff_v1v2
# 1: 2980632837              281              275         1
# 2: 4887607966              248              246         1
# 3: 6490089737              142              141         1
# 4: 7378395603              185                6         1
# 5: 8158275604              291              290         1
# 6: 9708950713              248              240         1
###based on the counts of the responses among these 62 participants with completions of two versions of M1, only one participant had
###much more available response in version 1 and the rest of them had the responses
Id.dup_v1 <- diff_check$Connect_ID[which(diff_check$diff_v1v2==1 & diff_check$version_check_v2 <10)] #Connect_ID 7378395603
Id.dup_v2 <- common.IDs[common.IDs != Id.dup_v1]

m1_common_nodup <- rbind(M1_V1_common[which(M1_V1_common$Connect_ID %in% Id.dup_v1),],M1_V2_common[which(M1_V2_common$Connect_ID %in% Id.dup_v2),])

m1_common_nodup1 <- rbind(M1_common[which(M1_common$Connect_ID %nin% common.IDs),], m1_common_nodup)

m1_common_v1_nodup <- merge(m1_common_nodup1, m1_v1_only[which(m1_v1_only$Connect_ID %nin% Id.dup_v2),], by="Connect_ID",all.x=TRUE)
m1_combined_v1v2_nodup <- merge(m1_common_v1_nodup,m1_v2_only[which(m1_v2_only$Connect_ID %nin% "Id.dup_v1"), ],by="Connect_ID",all.x=TRUE)

##in this way above, 6 more new variables are added into the combo M1 data: version and version_check in each step  
###based on the previous step of combining two versions of M1 data
m1_common <- rbind(M1_V1_common,M1_V2_common)
m1_common_v1 <- merge(m1_common, m1_v1_only, by=c("Connect_ID","version"),all.x=TRUE)
m1_combined_v1v2 <- merge(m1_common_v1,m1_v2_only,by=c("Connect_ID","version"),all.x=TRUE)

dup_toremove <- m1_combined_v1v2[which((m1_combined_v1v2$Connect_ID %in% Id.dup_v1 & version==2) | (m1_combined_v1v2$Connect_ID %in% Id.dup_v2 & version==1)),]
m1_v1v2_combined_nodup <- m1_combined_v1v2[!which(m1_combined_v1v2$Connect_ID %in% Id.dup_v1 & m1_combined_v1v2$version=2),]


