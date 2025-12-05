library(openxlsx)
##Temperaturdaten Prüfung auf Normalverteilung##
#Station INAIGEM Qori-Kalis
setwd("~/RProjekte/Hydrologie Quelccaya/Datenquellen/QoriKalis Wetterstation")
INAIGEM <- read.xlsx("Joint_Data_QoriKalis_14_09_2024_06_08_2024.xlsx", sheet = "Tageswerte")
INAIGEM$Date <- as.Date(INAIGEM$Date, origin = "1900-01-01")
INAIGEM$Date <- INAIGEM$Date - 2 
colnames(INAIGEM) <- c("Date", "Temperature", "Precipitation")

#Station SENAMHI GLACIER
setwd("~/RProjekte/Hydrologie Quelccaya/Datenquellen/ESTACIÓN SENAMHIICE")
SENAMHIICE <- read.xlsx("ENTER Dataname", sheet = "Tageswerte")
SENAMHIICE$FECHA <- as.Date(SENAMHI$FECHA, origin = "1900-01-01")
SENAMHIICE$FECHA <- SENAMHI$FECHA - 2 
colnames(SENAMHIICE) <- c("Date", "Temperature", "Precipitation")

setwd("~/RProjekte/Hydrologie Quelccaya/Datenquellen/ESTACIÓN SIBINACHOCHA_W")
# Beispiel: Lese das Tabellenblatt "Sheet1" ein
SIBINA <- read.xlsx("SIBINACHOCHA_joint.xlsx", sheet = "Tageswerte")
#Excel Datum umwandeln
# Umwandlung in Datumsformat (Excel: Basistag 1900-01-01)
SIBINA$Date <- as.Date(SIBINA$Date, origin = "1900-01-01")
# Subtrahiere zwei Tage, um die Verschiebung zu korrigieren
SIBINA$Date <- SIBINA$Date - 2 
# Neue Spaltennamen als Vektor definieren
colnames(SIBINA) <- c("Date", "Temperature", "Precipitation")

#Überprüfung
str(SIBINA$FECHA)  
head(SIBINA$FECHA)
#Import QUISO
setwd("~/RProjekte/Hydrologie Quelccaya/Datenquellen/ESTACIÓN QUISOQUEPINA_N")
QUISO <- read.xlsx("QUISOQUEPINA_joint.xlsx", sheet = "Tageswerte")
QUISO$FECHA <- as.Date(QUISO$FECHA, origin = "1900-01-01")
QUISO$FECHA <- QUISO$FECHA - 2
colnames(QUISO) <- c("Date", "Temperature")


#Import CARAB
setwd("~/RProjekte/Hydrologie Quelccaya/Datenquellen/ESTACIÓN CARABAYA_O")
CARAB <- read.xlsx("CARABAYA_joint.xlsx", sheet = "Tageswerte")
CARAB$FECHA <- as.Date(CARAB$FECHA, origin = "1900-01-01")
CARAB$FECHA <- CARAB$FECHA - 2
colnames(CARAB) <- c("Date", "Temperature", "Precipitation")

#Import Temp logger
#Temperatura TMS4 1 monat LR
setwd("~/RProjekte/Hydrologie Quelccaya/Datenquellen/Temperatura TMS4 1 monat LR")
TL1 <- read.xlsx("Joint_Data_QoriKalis_14_09_2024_06_08_2024.xlsx", sheet = "Tageswerte")
TL1$FECHA <- as.Date(SENAMHI$FECHA, origin = "1900-01-01")
TL1$FECHA <- SENAMHI$FECHA - 2 
colnames(TL1) <- c("Date", "Temperature", "Precipitation")

####Statistische Aanalyse der Datensätze####
#Außreiseranalyse
boxplot(SIBINA$Temperature, main = "Außreiseranalyse SIBINA", ylab = "Temperatur (°C)")
boxplot(QUISO$Temperature, main = "Außreiseranalyse QUISO", ylab = "Temperatur (°C)")
boxplot(CARAB$Temperature, main = "Außreiseranalyse CARAB", ylab = "Temperatur (°C)")
boxplot(INAIGEM$Temperature, main = "Außreiseranalyse INAIGEM", ylab = "Temperatur (°C)")
boxplot(SENAMHIICE$Temperature, main = "Außreiseranalyse SENAMHIICE", ylab = "Temperatur (°C)")

##Datenanalyse Prüfung auf Normalverteilung##
###Analyse SIBINA###
# QQ-Plot für Temperature
qqnorm(SIBINA$Temperature)
qqline(SIBINA$Temperature, col = "red")  # Rote Linie für die Normalverteilung
# QQ-Plot für Precipitation
qqnorm(SIBINA$Precipitation)
qqline(SIBINA$Precipitation, col = "red")
# 2. Histogramm für Temperature und Precipitation
# Histogramm für Temperature
hist(SIBINA$Temperature, breaks = 30, main = "Histogramm Temperature", xlab = "Temperature", col = "lightblue", border = "black")
# Histogramm für Precipitation
hist(SIBINA$Precipitation, breaks = 30, main = "Histogramm Precipitation", xlab = "Precipitation", col = "lightgreen", border = "black")
# 3. Shapiro-Wilk-Test auf Normalverteilung
# Shapiro-Wilk-Test für Temperature
shapiro.test(SIBINA$Temperature)
print(shapiro_test_temperature)
# Shapiro-Wilk-Test für Precipitation
shapiro.test(SIBINA$Precipitation)
# 4. Kolmogorov-Smirnov-Test auf Normalverteilung
# Kolmogorov-Smirnov-Test für Temperature
ks.test(SIBINA$Temperature, "pnorm", mean(SIBINA$Temperature), sd(SIBINA$Temperature))
# Kolmogorov-Smirnov-Test für Precipitation
ks.test(SIBINA$Precipitation, "pnorm", mean(SIBINA$Precipitation), sd(SIBINA$Precipitation))

###Analysis QUISO###
# Datenanalyse Prüfung auf Normalverteilung
# QQ-Plot für Temperature
qqnorm(QUISO$Temperature)
qqline(QUISO$Temperature, col = "red")  # Rote Linie für die Normalverteilung
# 2. Histogramm für Temperature
hist(QUISO$Temperature, breaks = 30, main = "Histogramm Temperature", xlab = "Temperature", col = "lightblue", border = "black")
# 3. Shapiro-Wilk-Test auf Normalverteilung
# Shapiro-Wilk-Test für Temperature
shapiro.test(QUISO$Temperature)
# 4. Kolmogorov-Smirnov-Test auf Normalverteilung
# Kolmogorov-Smirnov-Test für Temperature
ks.test(QUISO$Temperature, "pnorm", mean(QUISO$Temperature), sd(QUISO$Temperature))


###Analysis CARAB###

# Datenanalyse Prüfung auf Normalverteilung
# QQ-Plot für Temperature
qqnorm(CARAB$Temperature)
qqline(CARAB$Temperature, col = "red")  # Rote Linie für die Normalverteilung
# QQ-Plot für Precipitation
qqnorm(CARAB$Precipitation)
qqline(CARAB$Precipitation, col = "red")
# 2. Histogramm für Temperature und Precipitation
# Histogramm für Temperature
hist(CARAB$Temperature, breaks = 30, main = "Histogramm Temperature", xlab = "Temperature", col = "lightblue", border = "black")
# Histogramm für Precipitation
hist(CARAB$Precipitation, breaks = 30, main = "Histogramm Precipitation", xlab = "Precipitation", col = "lightgreen", border = "black")
# 3. Shapiro-Wilk-Test auf Normalverteilung
# Shapiro-Wilk-Test für Temperature
shapiro.test(CARAB$Temperature)
# Shapiro-Wilk-Test für Precipitation
shapiro.test(CARAB$Precipitation)
# 4. Kolmogorov-Smirnov-Test auf Normalverteilung
# Kolmogorov-Smirnov-Test für Temperature
ks.test(CARAB$Temperature, "pnorm", mean(CARAB$Temperature), sd(CARAB$Temperature))
# Kolmogorov-Smirnov-Test für Precipitation
ks.test(CARAB$Precipitation, "pnorm", mean(CARAB$Precipitation), sd(CARAB$Precipitation))


####Analysis INAIGEM####

# Datenanalyse Prüfung auf Normalverteilung
# QQ-Plot für Temperature
qqnorm(INAIGEM$Temperature)
qqline(INAIGEM$Temperature, col = "red")  # Rote Linie für die Normalverteilung
# QQ-Plot für Precipitation
qqnorm(INAIGEM$Precipitation)
qqline(INAIGEM$Precipitation, col = "red")
# 2. Histogramm für Temperature und Precipitation
# Histogramm für Temperature
hist(INAIGEM$Temperature, breaks = 30, main = "Histogramm Temperature", xlab = "Temperature", col = "lightblue", border = "black")
# Histogramm für Precipitation
hist(INAIGEM$Precipitation, breaks = 30, main = "Histogramm Precipitation", xlab = "Precipitation", col = "lightgreen", border = "black")
# 3. Shapiro-Wilk-Test auf Normalverteilung
# Shapiro-Wilk-Test für Temperature
shapiro.test(INAIGEM$Temperature)
# Shapiro-Wilk-Test für Precipitation
shapiro.test(INAIGEM$Precipitation)
# 4. Kolmogorov-Smirnov-Test auf Normalverteilung
# Kolmogorov-Smirnov-Test für Temperature
ks.test(INAIGEM$Temperature, "pnorm", mean(INAIGEM$Temperature), sd(INAIGEM$Temperature))
# Kolmogorov-Smirnov-Test für Precipitation
ks.test(INAIGEM$Precipitation, "pnorm", mean(INAIGEM$Precipitation), sd(INAIGEM$Precipitation))


###Analysis SENAMHIICE###

# Datenanalyse Prüfung auf Normalverteilung
# QQ-Plot für Temperature
qqnorm(SENAMHIICE$Temperature)
qqline(SENAMHIICE$Temperature, col = "red")  # Rote Linie für die Normalverteilung
# QQ-Plot für Precipitation
qqnorm(SENAMHIICE$Precipitation)
qqline(SENAMHIICE$Precipitation, col = "red")
# 2. Histogramm für Temperature und Precipitation
# Histogramm für Temperature
hist(SENAMHIICE$Temperature, breaks = 30, main = "Histogramm Temperature", xlab = "Temperature", col = "lightblue", border = "black")
# Histogramm für Precipitation
hist(SENAMHIICE$Precipitation, breaks = 30, main = "Histogramm Precipitation", xlab = "Precipitation", col = "lightgreen", border = "black")
# 3. Shapiro-Wilk-Test auf Normalverteilung
# Shapiro-Wilk-Test für Temperature
shapiro.test(SENAMHIICE$Temperature)
# Shapiro-Wilk-Test für Precipitation
shapiro.test(SENAMHIICE$Precipitation)
# 4. Kolmogorov-Smirnov-Test auf Normalverteilung
# Kolmogorov-Smirnov-Test für Temperature
ks.test(SENAMHIICE$Temperature, "pnorm", mean(SENAMHIICE$Temperature), sd(SENAMHIICE$Temperature))
# Kolmogorov-Smirnov-Test für Precipitation
ks.test(SENAMHIICE$Precipitation, "pnorm", mean(SENAMHIICE$Precipitation), sd(SENAMHIICE$Precipitation))



##Datenframe erstellen
# Funktion zur Umrechnung von DMS in Dezimalgrad
dms_to_decimal <- function(degrees, minutes, seconds, direction) {
  decimal <- degrees + (minutes / 60) + (seconds / 3600)
  if (direction %in% c("S", "W")) decimal <- -decimal
  return(decimal)
}
#INAIGEM
inaigem_lat <- -13.8936
inaigem_lon <- -70.8616
inaigem_height <- 4934

#SENAMHIICE
senamhiice_lat <- -13.8936
senamhiice_lon <- -70.8616
senamhiice_height <- 4934

# CARAB: Umrechnung der Koordinaten
carab_lat <- dms_to_decimal(13, 52, 22.03, "S")
carab_lon <- dms_to_decimal(70, 40, 3.34, "W")
carab_height <- 4175


# QUISO: Umrechnung der Koordinaten
quiso_lat <- dms_to_decimal(13, 47, 42.2, "S")
quiso_lon <- dms_to_decimal(70, 53, 10.4, "W")
quiso_height <- 5157

# SIBINA: Umrechnung der Koordinaten
sibina_lat <- dms_to_decimal(13, 55, 19.7, "S")
sibina_lon <- dms_to_decimal(71, 1, 5.63, "W")
sibina_height <- 4880

# Spalten zu den DataFrames hinzufügen
INAIGEM$Latitude <- inaigem_lat
INAIGEM$Longtitude <- inaigem_lon
INAIGEM$Height <- inaigem_height

SENAMHIICE$Latitude <- inaigem_lat
SENAMHIICE$Longtitude <- inaigem_lon
SENAMHIICE$Height <- inaigem_height

SIBINA$Latitude <- sibina_lat
SIBINA$Longitude <- sibina_lon
SIBINA$Height <- sibina_height

QUISO$Latitude <- quiso_lat
QUISO$Longitude <- quiso_lon
QUISO$Height <- quiso_height

CARAB$Latitude <- carab_lat
CARAB$Longitude <- carab_lon
CARAB$Height <- carab_height

# Prüfe die Ergebnisse (z. B. für SIBINA)
head(SIBINA)

#####Spezielle Vorprüfung für IDW - Methode#####
###Geoanalyse Variogramm###
# Notwendige Bibliothek laden
library(gstat)

# Funktion zur Erstellung und zum Plotten von Variogrammen
create_variogram <- function(df, value_column, df_name) {
  # Koordinaten zuweisen
  coordinates(df) <- ~ Longitude + Latitude
  
  # Variogramm berechnen
  variogram_model <- variogram(as.formula(paste(value_column, "~ 1")), data = df)
  
  # Variogramm plotten
  plot(variogram_model, main = paste("Variogramm für", value_column, "in", df_name),
       xlab = "Entfernung", ylab = "Semivarianz")
}

# 1. Variogramm für INAIGEM
create_variogram(INAIGEM, "Temperature", "INAIGEM")
create_variogram(INAIGEM, "Precipitation", "INAIGEM")

# 2. Variogramm für SENAMHIICE
create_variogram(SENAMHIICE, "Temperature", "SENAMHIICE")
create_variogram(SENAMHIICE, "Precipitation", "SENAMHIICE")

# 3. Variogramm für SIBINA
create_variogram(SIBINA, "Temperature", "SIBINA")
create_variogram(SIBINA, "Precipitation", "SIBINA")

# 4. Variogramm für QUISO (nur Temperature vorhanden)
create_variogram(QUISO, "Temperature", "QUISO")

# 5. Variogramm für CARAB
create_variogram(CARAB, "Temperature", "CARAB")
create_variogram(CARAB, "Precipitation", "CARAB")


###Trendprüfung###
#Variieren die Werte,Temperatur, Niederschlag systematisch mit Höhe oder geografischer Position

# Bibliothek für Visualisierung
library(ggplot2)
# Funktion zur Trendprüfung
trend_analysis <- function(df, value_column, df_name) {
  # 1. Scatterplot für Longitude vs. Value
  ggplot(df, aes(x = Longitude, y = .data[[value_column]])) +
    geom_point() +
    geom_smooth(method = "lm", col = "red") +
    labs(
      title = paste("Trendprüfung:", value_column, "vs. Longitude in", df_name),
      x = "Longitude", y = value_column
    ) +
    theme_minimal()
  
  # 2. Scatterplot für Latitude vs. Value
  ggplot(df, aes(x = Latitude, y = .data[[value_column]])) +
    geom_point() +
    geom_smooth(method = "lm", col = "red") +
    labs(
      title = paste("Trendprüfung:", value_column, "vs. Latitude in", df_name),
      x = "Latitude", y = value_column
    ) +
    theme_minimal()
  
  # 3. Lineares Regressionsmodell
  model <- lm(as.formula(paste(value_column, "~ Longitude + Latitude")), data = df)
  print(summary(model))
  
  # Rückgabe des Modells (optional)
  return(model)
}

# Anwendung auf alle DataFrames

# 1. INAIGEM
trend_analysis(INAIGEM, "Temperature", "INAIGEM")
trend_analysis(INAIGEM, "Precipitation", "INAIGEM")

# 2. SENAMHIICE
trend_analysis(SENAMHIICE, "Temperature", "SENAMHIICE")
trend_analysis(SENAMHIICE, "Precipitation", "SENAMHIICE")

# 3. SIBINA
trend_analysis(SIBINA, "Temperature", "SIBINA")
trend_analysis(SIBINA, "Precipitation", "SIBINA")

# 4. QUISO (nur Temperature vorhanden)
trend_analysis(QUISO, "Temperature", "QUISO")

# 5. CARAB
trend_analysis(CARAB, "Temperature", "CARAB")
trend_analysis(CARAB, "Precipitation", "CARAB")


###Kreuzvalidierung###

# Lösche nur die durch den Prozess erstellten Variablen
rm(carab_lat, carab_lon, carab_height, 
   quiso_lat, quiso_lon, quiso_height, 
   sibina_lat, sibina_lon, sibina_height, DEM, study_area_frame, BasinDetail, inaigem_lat, inaigem_lon, inaigem_height)
rm(dms_to_decimal)

