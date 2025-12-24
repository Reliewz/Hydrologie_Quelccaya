#=================================================================================================================
# hr_precipitation_analysis.R
# Goal: Time series analysis meteorological Station Quelccaya from SENAMHI.
# Meteorological variables: Temperature, Precipitation, Wind speed, Wind direction, Relative Humidity, Solar Radiation
# Author: Kai Albert Zwießler
# Date: 2025.11.02
# Input Dataset: hr_analysis.xlsx
# Outputs: 
    # figures/.png
    #

#=================================================================================================================

library(ggplot2)
library (readxl)
library(renv)
hr_data <- read_excel("D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QUELCCAYA\\Daten_meteorologisch\\hr_analysis.xlsx")
library(lubridate)  # Paket für Datum/Zeit
library(scales) # verbesserte Achsenformatierung in ggplot2
#warning still active?
hr_data$Date <- ymd_hms(hr_data$Date)


hr_data$Precip_Tot_cum <- cumsum(hr_data$Precip_Tot)

##accumulated precip, precip_2 and hr_data Total precipitation
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = precip_cumsum, color = "accumulated precipitation Sensor 1")) +
  geom_line(aes(y = precip2_cumsum, color = "accumulated precipitation Sensor 2")) +
  geom_line(aes(y = hr_data$`Precip_Tot [mm]`, color = "Total precipitation")) +
  scale_color_manual(values = c("accumulated precipitation Sensor 1" = "blue", 
                                "accumulated precipitation Sensor 2" = "red",
                                "Total precipitation" = "brown")) +
  scale_x_datetime(date_breaks = "1 months", date_labels = "%b %Y") +
  labs(
    title = "Precipitation Total vs. Menge Sensor 1 & 2",
    x = "Date",
    y = "mm",
    color = "Messung"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")



