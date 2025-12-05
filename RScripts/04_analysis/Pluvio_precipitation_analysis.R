#=================================================================================================================
# pluvio_precipitation_analysis.R
# Goal: Plausibility and Time series analysis meteorological Station Quelccaya from SENAMHI. #hourly and daily data
# Meteorological variables: Precipitation, Precipitation_2, Bucket, Bucket_2.
# Author: Kai Albert Zwießler
# Date: 2025.11.01
# Input Dataset: Daten_meteorologisch/pluvio_analysis.xlsx
# Outputs: 
    # figures/.png
    #

#=================================================================================================================

library(ggplot2)
library (readxl)
library(renv)
pluvio <- read_excel("D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QUELCCAYA\\Daten_meteorologisch\\Pluvio_analysis.xlsx")
library(lubridate)  # Package time/date transformations
library(scales) # better labeling of axis in ggplot2

# Transformation Date form CHR to POSIXct format
pluvio$Date <- ymd_hms(pluvio$Date)  # Jahr-Monat-Tag Stunde:Minute:Sekunde

#Row count
nrow(pluvio)


##visualization of Bucket over time period
ggplot(pluvio, aes(x = Date, y = `Bucket`)) + geom_line(color = "blue") +
  labs(titel = "Bucket_1 Füllstand über Zeit", x = "Date", y = "Bucket_1 (mm)") +
  scale_x_datetime(date_breaks = "2 month", date_labels = "%b %Y")
  theme_minimal()


#NA assignment of unrealistic Outerlier
pluvio$Bucket[pluvio$Bucket < 80] <- NA


ggplot(pluvio, aes(x = Date, y = `Bucket`)) + geom_line(color = "blue") +
  labs(titel = "Bucket_1 cumulative Weightvalue over time", x = "Date", y = "Bucket_1 (mm)") +
  scale_x_datetime(date_breaks = "2 month", date_labels = "%b %Y") +
theme_minimal()

###Begin of hourly precipitation analysis
# Calculate cumulative precipitation
pluvio$precip_cumsum <- cumsum(pluvio$`Precip`)
pluvio$precip2_cumsum <- cumsum(pluvio$`Precip_2`)


### Transforming Bucket values in precipitation values
# Area = 0.159 m², 1 mm bucket weight = 20g
pluvio$bucket_as_precip <- pluvio$`Bucket` * 20 / 1000 / 0.159
pluvio$bucket_2_as_precip <- pluvio$`Bucket_2` * 20 / 1000 / 0.159

#Bucket_as_üreciü_1 vs cumulative precipitation
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = bucket_as_precip, color = "Bucket (as precip)")) +
  geom_line(aes(y = precip_cumsum, color = "Precip kumulativ")) +
  scale_color_manual(values = c("Bucket (as precip)" = "blue", 
                                "Precip kumulativ" = "red")) +
  scale_x_datetime(date_breaks = "2 months", date_labels = "%b %Y") +
  labs(
    title = "Bucket vs. cumulative Precipitation",
    x = "Date",
    y = "mm",
    color = "Messung"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")

#Bucket 1 vs Bucket 2 -as Precip-

ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = bucket_as_precip, color = "Bucket (as precip)")) +
  geom_line(aes(y = bucket_2_as_precip, color = "Bucket_2 (as precip)")) +
  scale_color_manual(values = c("Bucket (as precip)" = "blue", 
                                "Bucket_2 (as precip)" = "red")) +
  scale_x_datetime(date_breaks = "2 months", date_labels = "%b %Y") +
  labs(
    title = "Bucket vs. Bucket_2",
    x = "Date",
    y = "mm",
    color = "Messung"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")

#Correlation spearman between transformed as_precip) bucket and bucket_2. r = 0.9999992
cor(pluvio$bucket_as_precip, pluvio$bucket_2_as_precip)

#Correlation spearman between cumulative precipitation and precip_2. = r= 0.9956669
cor(pluvio$precip_cumsum, pluvio$precip2_cumsum)
#grafical display of precipitation accumulation
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = precip_cumsum, color = "Precipitation accumulative")) +
  geom_line(aes(y = precip2_cumsum, color = "Precipitation_2 accumulative")) +
  scale_color_manual(values = c("Precipitation accumulative" = "blue", 
                                "Precipitation_2 accumulative" = "red")) +
  scale_x_datetime(date_breaks = "2 months", date_labels = "%b %Y") +
  labs(
    title = "precip (acc) vs precip_2 (acc)",
    x = "Date",
    y = "mm",
    color = "Messung"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")

#Grafic display of precipitations
# Good to detect systematical diviations
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = `Precip`, color = "Sensor 1"), alpha = 0.7) +
  geom_line(aes(y = `Precip_2`, color = "Sensor 2"), alpha = 0.7) +
  scale_color_manual(values = c("Sensor 1" = "blue", "Sensor 2" = "red")) +
  scale_x_datetime(date_breaks = "2 months", date_labels = "%b %Y") +
  labs(
    title = "Hourly Precipitation - Both Sensors",
    x = "Date",
    y = "Precipitation in [mm]",
    color = "Sensor"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
#statistical description
cor(pluvio$`Precip`, pluvio$`Precip_2`)

#Sensor-temperature over time
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = `Temp`, color = "Sensortemperature"), alpha = 0.7) +
    scale_color_manual(values = c("Sensortemperature" = "magenta")) +
  scale_x_datetime(date_breaks = "1.5 months", date_labels = "%b %Y") +
  labs(
    title = "Sensortemperature over timeperiod",
    x = "Date",
    y = "Temperature in (°C)",
    color = "Sensortemperature"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#### total plot
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = `Total`, color = "Accumulated Total precipitation"), alpha = 0.7) +
  scale_color_manual(values = c("Accumulated Total precipitation" = "darkblue")) +
  scale_x_datetime(date_breaks = "1.5 months", date_labels = "%b %Y") +
  labs(
    title = "Accumulated Precipitation over timeperiod",
    x = "Date",
    y = "Precipitation in [mm]",
    color = "Accumulated Total precipitation"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))




#Visualizing Total accumulated precipitation
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = pluvio$Total_acc, color = "Accumulated Total precipitation"), alpha = 0.7) +
  scale_color_manual(values = c("Accumulated Total precipitation" = "darkblue")) +
  scale_x_datetime(date_breaks = "1.5 months", date_labels = "%b %Y") +
  labs(
    title = "Accumulated Total precipitation",
    x = "Date",
    y = "Accumulated total precipitation in [mm]",
    color = "Accumulated Total precipitation"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))




#Erstellen von pluvio$Total_acc fortlaufende niederschlagsakkumulation über 2 Jahre
pluvio$Total_acc <- NA
valid_idx <- which(!is.na(pluvio$Total_diff))
if(length(valid_idx) > 0){
  pluvio$Total_acc[valid_idx] <- cumsum(pluvio$Total_diff[valid_idx])
}

#######Total Precipitation and algorithmic precipitation plausibility of different time periods####
#Time Period 1: 11.10.2023 17:00:00 - 02.12.2023 08:00:00; Startvalue: 221.6; Endvalue: 499.2 mm
#Define timeperiod
start_tp1 <- as.POSIXct("2023-10-11 17:00:00", tz = "UTC")
end_tp1   <- as.POSIXct("2023-12-02 08:00:00", tz = "UTC")

#Indices for this time period
idx_tp1 <- which(pluvio$Date >= start_tp1 & pluvio$Date <= end_tp1)

#Calculate diferences. First diference 0 for time step t_0
diff_tp1 <- c(0, diff(pluvio$Total[idx_tp1]))

#Cumulative differences
cum_tp1 <- cumsum(diff_tp1)

#Add all periods to existing dataframe pluvio 
#Generate rows with NA

pluvio$Total_diff <- rep(NA, nrow(pluvio))
pluvio$Total_cum  <- rep(NA, nrow(pluvio))
#Column as numeric.
pluvio$Total_diff <- as.numeric(pluvio$Total_diff)
pluvio$Total_cum  <- as.numeric(pluvio$Total_cum)

#Add data to dataframe
pluvio$Total_diff[idx_tp1] <- diff_tp1
pluvio$Total_cum[idx_tp1]  <- cum_tp1

#TP 2: 02.12.2023 09:00:00 - 27.01.2024 03:00:00  Startvalue: 5.572; Endvalue: 462.7
#Define time period
start_tp2 <- as.POSIXct("2023-12-02 09:00:00", tz = "UTC")
end_tp2   <- as.POSIXct("2024-01-27 03:00:00", tz = "UTC")

#indices for this time period
idx_tp2 <- which(pluvio$Date >= start_tp2 & pluvio$Date <= end_tp2)

#Calculate difference according to time step logic. Use first start value from first indice $Total
diff_tp2 <- c(pluvio$Total[idx_tp2][1], diff(pluvio$Total[idx_tp2]))

#Cumulative differences
cum_tp2 <- cumsum(diff_tp2)

#Add data to data frame
pluvio$Total_diff[idx_tp2] <- diff_tp2
pluvio$Total_cum[idx_tp2]  <- cum_tp2



#TP 3: 27.01.2024 04:00:00 - 01.02.2024 02:00:00 Startvalue: 63.53 Endvalue: 459.8 mm
#High startvalue. Explained with a high intesity precipitation event during the transition across the 500 mm mark.
#Define time period
start_tp3 <- as.POSIXct("2024-01-27 04:00:00", tz = "UTC")
end_tp3   <- as.POSIXct("2024-02-01 02:00:00", tz = "UTC")

#Indices for this time period
idx_tp3 <- which(pluvio$Date >= start_tp3 & pluvio$Date <= end_tp3)

#Calculate difference according to time step logic. Use first start value from first indice $Total
diff_tp3 <- c(pluvio$Total[idx_tp3][1], diff(pluvio$Total[idx_tp3]))

#Cumulative differences
cum_tp3 <- cumsum(diff_tp3)

#Add data to data frame
pluvio$Total_diff[idx_tp3] <- diff_tp3
pluvio$Total_cum[idx_tp3]  <- cum_tp3




#TP 4: 01.02.2024 03:00:00 - 03.02.2024 12:00:00 Startvalue: 1.535; Endvalue: 489.8
#High intesitive precipitation event on transition to 500 mm mark.
#Define time period
start_tp4 <- as.POSIXct("2024-02-01 03:00:00", tz = "UTC")
end_tp4   <- as.POSIXct("2024-02-03 12:00:00", tz = "UTC")

#Indices for this time period
idx_tp4 <- which(pluvio$Date >= start_tp4 & pluvio$Date <= end_tp4)

#Calculate difference according to time step logic. Use first start value from first indice $Total
diff_tp4 <- c(pluvio$Total[idx_tp4][1], diff(pluvio$Total[idx_tp4]))

#Cumulative differences
cum_tp4 <- cumsum(diff_tp4)

#Add data to data frame
pluvio$Total_diff[idx_tp4] <- diff_tp4
pluvio$Total_cum[idx_tp4]  <- cum_tp4


#TP 5: 03.02.2024 13:00:00 - 25.02.2024 02:00:00 Startvalue: 3.318; Endvalue: 499.4
#Define time period
start_tp5 <- as.POSIXct("2024-02-03 13:00:00", tz = "UTC")
end_tp5   <- as.POSIXct("2024-02-25 02:00:00", tz = "UTC")

#Indices for this time period
idx_tp5 <- which(pluvio$Date >= start_tp5 & pluvio$Date <= end_tp5)

#Calculate difference according to time step logic. Use first start value from first indice $Total
diff_tp5 <- c(pluvio$Total[idx_tp5][1], diff(pluvio$Total[idx_tp5]))

#Cumulative differences
cum_tp5 <- cumsum(diff_tp5)

#Add data to data frame
pluvio$Total_diff[idx_tp5] <- diff_tp5
pluvio$Total_cum[idx_tp5]  <- cum_tp5


#TP 6: 25.02.2024 03:00:00 - 08.05.2024 19:00:00; Startvalue: 11.35; Endvalue: 499.9 mm
#Define time period
start_tp6 <- as.POSIXct("2024-02-25 03:00:00", tz = "UTC")
end_tp6   <- as.POSIXct("2024-05-08 19:00:00", tz = "UTC")

#Indices for this time period
idx_tp6 <- which(pluvio$Date >= start_tp6 & pluvio$Date <= end_tp6)

#Calculate difference according to time step logic. Use first start value from first indice $Total
diff_tp6 <- c(pluvio$Total[idx_tp6][1], diff(pluvio$Total[idx_tp6]))

#Cumulative differences
cum_tp6 <- cumsum(diff_tp6)

#Add data to data frame
pluvio$Total_diff[idx_tp6] <- diff_tp6
pluvio$Total_cum[idx_tp6]  <- cum_tp6


#TP 7: 08.05.2024 20:00:00 - 22.11.2024 21:00:00 Startvalue: 0.049; Endvalue: 499.4 mm
#Unplausible values in the Endphase. 
# => Outlier removal 22.11.2024 22:00:00, 22.11.2024 23:00:00, 23.11.2024 00:00:00, 23.11.2024 01:00:00, 
#23.11.2024 02:00:00, 23.11.2024 03:00:00, 23.11.2024 04:00:00. Removed to N/A
#Define time period
start_tp7 <- as.POSIXct("2024-05-08 20:00:00", tz = "UTC")
end_tp7   <- as.POSIXct("2024-11-22 21:00:00", tz = "UTC")

#Indices for this time period
idx_tp7 <- which(pluvio$Date >= start_tp7 & pluvio$Date <= end_tp7)

#Calculate difference according to time step logic
# First difference = start value of the period (if NA, remains NA)
diff_tp7 <- rep(NA, length(idx_tp7)) # init vector
valid_idx <- which(!is.na(pluvio$Total[idx_tp7]))
if(length(valid_idx) > 0){
  diff_tp7[valid_idx] <- c(pluvio$Total[idx_tp7][valid_idx][1], diff(pluvio$Total[idx_tp7][valid_idx]))
}

#Cumulative differences (NA values bleiben erhalten)
cum_tp7 <- rep(NA, length(idx_tp7))
if(length(valid_idx) > 0){
  cum_tp7[valid_idx] <- cumsum(diff_tp7[valid_idx])
}

#Add data to data frame
pluvio$Total_diff[idx_tp7] <- diff_tp7
pluvio$Total_cum[idx_tp7]  <- cum_tp7


#TP 8: Total value drop 23.11.2024 05:00:00 - 23.11.2024 22:00:00 497.9 Startvalue: 490.2; Endvalue: 497.9 mm
#Define time period
start_tp8 <- as.POSIXct("2024-11-23 05:00:00", tz = "UTC")
end_tp8   <- as.POSIXct("2024-11-23 22:00:00", tz = "UTC")

#Indices for this time period
idx_tp8 <- which(pluvio$Date >= start_tp8 & pluvio$Date <= end_tp8)

#Calculate difference according to time step logic
diff_tp8 <- c(pluvio$Total[idx_tp8][1], diff(pluvio$Total[idx_tp8]))

#Cumulative differences
cum_tp8 <- cumsum(diff_tp8)

#Add data to data frame
pluvio$Total_diff[idx_tp8] <- diff_tp8
pluvio$Total_cum[idx_tp8]  <- cum_tp8


#TP 9: 23.11.2024 23:00:00 - 09.02.2025 02:00:00 Startvalue: 1.351; Envalue: 498.2
#Define time period
start_tp9 <- as.POSIXct("2024-11-23 23:00:00", tz = "UTC")
end_tp9   <- as.POSIXct("2025-02-09 02:00:00", tz = "UTC")

#Indices for this time period
idx_tp9 <- which(pluvio$Date >= start_tp9 & pluvio$Date <= end_tp9)

#Calculate difference according to time step logic. Use first start value from first indice $Total
diff_tp9 <- c(pluvio$Total[idx_tp9][1], diff(pluvio$Total[idx_tp9]))

#Cumulative differences
cum_tp9 <- cumsum(diff_tp9)

#Add data to data frame
pluvio$Total_diff[idx_tp9] <- diff_tp9
pluvio$Total_cum[idx_tp9]  <- cum_tp9

#TP 10: 09.02.2025 03:00:00 - 04.05.2025 18:00:00 Startvalue: 0.515; Endvalue: 498.4 mm
#Define time period
start_tp10 <- as.POSIXct("2025-02-09 03:00:00", tz = "UTC")
end_tp10   <- as.POSIXct("2025-05-04 18:00:00", tz = "UTC")

#Indices for this time period
idx_tp10 <- which(pluvio$Date >= start_tp10 & pluvio$Date <= end_tp10)

#Calculate difference according to time step logic. Use first start value from first indice $Total
diff_tp10 <- c(pluvio$Total[idx_tp10][1], diff(pluvio$Total[idx_tp10]))

#Cumulative differences
cum_tp10 <- cumsum(diff_tp10)

#Add data to data frame
pluvio$Total_diff[idx_tp10] <- diff_tp10
pluvio$Total_cum[idx_tp10]  <- cum_tp10

#TP 11: 04.05.2025 19:00:00 - 28.09.2025 16:00:00 Startvalue: 0.078; Endvalue: 283.3 mm
#Define time period
start_tp11 <- as.POSIXct("2025-05-04 19:00:00", tz = "UTC")
end_tp11   <- as.POSIXct("2025-09-28 16:00:00", tz = "UTC")

#Indices for this time period
idx_tp11 <- which(pluvio$Date >= start_tp11 & pluvio$Date <= end_tp11)

#Calculate difference according to time step logic. Use first start value from first indice $Total
diff_tp11 <- c(pluvio$Total[idx_tp11][1], diff(pluvio$Total[idx_tp11]))

#Cumulative differences
cum_tp11 <- cumsum(diff_tp11)

#Add data to data frame
pluvio$Total_diff[idx_tp11] <- diff_tp11
pluvio$Total_cum[idx_tp11]  <- cum_tp11


# Safe as CSV with ";"
write.table(
  pluvio,
  file = "pluvio_processed.csv",
  sep = ";",        # Spaltentrenner
  dec = ".",        # Dezimaltrennzeichen
  row.names = FALSE,
  na = "",          # NA als leere Zelle
  quote = FALSE,    # keine Anführungszeichen
  col.names = TRUE
)