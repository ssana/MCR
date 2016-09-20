library(openxlsx)
library(plyr)
ericData <- read.xlsx("C:/MerchantRating/merchant_chargebacks_report.xlsx", 1)

ericData <- ericData[ericData$Original.Retail.Sales.Count > 0, ]
ericData <- ericData[ericData$Visa.Provided.Merchant.Outlet.Name != "NOT APPLICABLE", ]

requiredColumns <- c("Visa.Provided.Merchant.Outlet.Name", 
                     "Original.Retail.Sales.Amount.EUR_S",
                     "Original.Retail.Sales.Count",
                     "Processed.Chargebacks.Count",
                     "Processed.Refunds.Count")

finalData <- ericData[requiredColumns]

names(finalData) <- c("MerchantName", "SalesAmount", "SalesCount", "ChargebacksCount", "RefundsCount")

aggregatedData <- ddply(finalData, ~MerchantName, summarise, SalesAmount=sum(SalesAmount), SalesCount=sum(SalesCount), ChargebacksCount=sum(ChargebacksCount), RefundsCount=sum(RefundsCount))

aggregatedData$RepresentmentsCount <- 0
aggregatedData$NormalizedScore <- ifelse(aggregatedData$ChargebacksCount + aggregatedData$RefundsCount == 0, 9000, aggregatedData$SalesCount/(aggregatedData$RefundsCount*10 + aggregatedData$ChargebacksCount*20))
aggregatedData$Score <- ifelse(aggregatedData$NormalizedScore*100/148 > 100, 100, aggregatedData$NormalizedScore*100/148)
aggregatedData <- aggregatedData[, -c(7)]


library(DBI)
library(RSQLite)
library(dplyr)
library(sqldf)

merchantRatingDB <- dbConnect(SQLite(),"C:/data/MerchantRating.db")
dbSendQuery(merchantRatingDB, 
            "drop table IF EXISTS Merchant_Rating")
dbSendQuery(merchantRatingDB, 
            "create table Merchant_Rating(MerchantName TEXT, SalesAmount REAL, SalesCount INTEGER, ChargebacksCount INTEGER, RefundsCount INTEGER, RepresentmentsCount INTEGER, Score REAL)")
dbDisconnect(merchantRatingDB)

db_conn <- src_sqlite("C:/data/MerchantRating.db", create = TRUE)
db_insert_into( con = db_conn$con, table = "Merchant_Rating", values = aggregatedData)
