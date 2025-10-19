# Install packages if not already installed
install.packages("quantmod")
install.packages("openxlsx")
install.packages("here")

# Load packages
library(quantmod)
library(openxlsx)
library(here)

# SET VARIABLES 
# Define output path
path <- here()

# Define asset names
names <- c(
  # Equities
  "LVMH",
  "Allianz",
  "NVIDIA",
  "Costco",
  "Tesla",
  "Rheinmetall",
  "BMW",
  "Sony",
  "Samsung",
  "Bayer",
  "PepsiCo",
  "iShares_REITS",
  "iShares_EAFE",
  
  # Commodities
  "Copper",
  
  # FX
  "USD_to_EUR",
  "Gold",
  "JPN_to_EUR",
  
  # Crypto
  "Bitcoin"
)

# Define asset symbols
symbols <- c(
  # Equities
  "MOH.F", # LVMH Moët Hennessy
  "ALV.DE", # Allianz SE
  "NVD.F", # NVIDIA Corporation 
  "CTO0.F", # Costco Wholesale Corporation 
  "TL0.F", # Tesla, Inc.
  "RHM.DE", # Rheinmetall AG
  "BMW.DE", # Bayerische Motoren Werke Aktiengesellschaft
  "SON1.F", # Sony Group Corporation
  "SSUN.F", # Samsung Electronics Co., Ltd.
  "BAYN.DE", # Bayer Aktiengesellschaft
  "PEP.F", # PepsiCo, Inc.
  "EXI5.DE", # iShares STOXX Europe 600 Real Estate UCITS ETF (DE)
  "IEFA", # iShares Core MSCI EAFE ETF (in USD)
  
  # Commodities
  "HG=F", # Copper Future contracts, Spot price per pound (in USD) 
  
  # FX
  "EUR=X", # FX USD to EUR
  "4GLD.DE", # One unit of Gold to EUR (on XETRA)
  "JPYEUR=X", # FX JPY to EUR
  
  # Crypto
  "BTC-EUR" # One Bitcoin to EUR 
  
)

# Define the last trading date
end_date <- as.Date("2025-10-07")

# Define the number of trading days
trading_days <- 1000

# Calculate the start date based on trading_days before end_date
start_date <- end_date - trading_days

# Fetch data from all symbols 
# getSymbols(symbols, from = start_date, to = end_date)

# Fetch data from all asset symbols listed in 'symbols'
# Using getSymbols() from quantmod to download historical data
# auto.assign = FALSE prevents automatic variable assignment and returning data instead
# lappy() applies getSymbols to each symbol, resulting in a list of xts objects
data_list <- lapply(symbols, 
                    function(sym) getSymbols(sym, 
                                             from = start_date,
                                             to = end_date,
                                             auto.assign = FALSE))
# Check one of the data
View(data_list[[8]])

# Change the currency here




# Merge the adjusted close price from all assets
# lappy() applies merge to each xts object in 'data_list'
# Use Ad for the adjusted close price
prices <- do.call(merge, lapply(data_list, Ad))

# Rename columns of 'prices' to match symbols
colnames(prices) <- names

# Calculate the price range (min and max) per asset
# apply() applies functions across columns of the 'prices' object
# Min_Price: applies min() and ignores missing data (na.rm = TRUE) to get the lowest price per asset
# Max_Price: applied max() similarly to get the highest price per asset
# Results are combined into a data frame 
price_range <- data.frame(
  Asset = colnames(prices),
  Min_Price = apply(prices, 2, min, na.rm = TRUE),
  Max_Price = apply(prices, 2, max, na.rm = TRUE)
)
# print(price_range)
write.xlsx(price_range, "price_range.xlsx")

# # Count missing values (NA) per asset
# missing_counts <- data.frame(
#   Asset = colnames(prices),
#   Missing_Values = apply(prices, 2, function(x) sum(is.na(x)))
# )
# print(missing_counts)


# Evaluate mising values (NA) per assets
# Initialize an empty list to hold missing rows xts objects per asset
missing_rows_list <- list()

for (name in names) {
  # Count missing values for this symbol
  missing_count <- sum(is.na(prices[, name]))
  cat("Missing rows for:", name, "-", missing_count, "\n")
  
  # Extract rows with NA for this symbol (remains as xts)
  missing_rows <- prices[is.na(prices[, name]), ]
  
  # Store in list
  missing_rows_list[[name]] <- missing_rows
}

# View the missing rows
current_asset <- "Sony"
View(missing_rows_list[[current_asset]][, current_asset, drop = FALSE])

thuy anh adds some code hier
