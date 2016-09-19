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

aggregatedData$score <- with(aggregatedData, (SalesCount/(RefundsCount*10 + ChargebacksCount*20)))
aggregatedData$normalizedScore <- with(aggregatedData, score*100/148)

merchantScores <- aggregatedData[c("MerchantName", "normalizedScore")]

library(DBI)
library(RSQLite)
library(dplyr)
library(sqldf)

db_conn <- src_sqlite("C:/data/MerchantRating.db")
sqldf("drop table IF EXISTS Merchant_Rating;")
sqldf("create table Merchant_Rating(MerchantName varchar(100), Score double);")
db_insert_into( con = db_conn$con, table = "Merchant_Rating", values = merchantScores)