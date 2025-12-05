###Pluvio Plausibility
#Total acc pluvio vs Precip and Precip_2
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = precip_cumsum, color = "accumulated precipitation Sensor 1")) +
  geom_line(aes(y = precip2_cumsum, color = "accumulated precipitation Sensor 2")) +
  geom_line(aes(y = Total_acc, color = "accumulated Total precipitation column")) +
  scale_color_manual(values = c("accumulated precipitation Sensor 1" = "blue", 
                                "accumulated precipitation Sensor 2" = "red",
                                "accumulated Total precipitation column" = "brown")) +
  scale_x_datetime(date_breaks = "1 months", date_labels = "%b %Y") +
  labs(
    title = "Precipitation Total column vs. Precip (accumulated) & Precip_2 (acc)",
    x = "Date",
    y = "mm",
    color = "Messung"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
  legend.position = "bottom")
## Precip & precip_2 vs Total column
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = precip_cumsum, color = "Precip accumulated")) +
  geom_line(aes(y = precip2_cumsum, color = "Precip_2 accumulated")) +
  geom_line(aes(y = Total_cum, color = "Total precipitation column")) +
  scale_color_manual(values = c("Precip accumulated" = "blue", 
                                "Precip_2 accumulated" = "red",
                                "Total precipitation column" = "lightgrey")) +
  scale_x_datetime(date_breaks = "1 months", date_labels = "%b %Y") +
  labs(
    title = "Precipitation Total column vs. Precip (accumulated) & Precip_2 (acc)",
    x = "Date",
    y = "mm",
    color = "Devices"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")

##hr_data Total vs precip and precip_2
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = precip_cumsum, color = "accumulated precipitation Sensor 1")) +
  geom_line(aes(y = precip2_cumsum, color = "accumulated precipitation Sensor 2")) +
  geom_line(aes(y = hr_data$Precip_Tot_cum, color = "Total precipitation")) +
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


## hr_data total vs pluvio total
ggplot(pluvio, aes(x = Date)) +
    geom_line(aes(y = hr_data$Precip_Tot_cum, color = "accumulated Precip_Tot hr data-set")) +
    geom_line(aes(y = Total_acc, color = "accumulated Total column pluvio data-set")) +
   scale_color_manual(values = c("accumulated Precip_Tot hr data-set" = "black", 
                                 "accumulated Total column pluvio data-set" = "grey")) +
  scale_x_datetime(date_breaks = "1 months", date_labels = "%b %Y") +
  labs(
    title = "Precip_Tot hr_data vs. Precipitation Total column (pluvio)",
    x = "Date",
    y = "mm",
    color = "Measurment"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")


##precip_cum _precip_2_cum
ggplot(pluvio, aes(x = Date)) +
  geom_line(aes(y = precip_cumsum, color = "Precip accumulative")) +
  geom_line(aes(y = precip2_cumsum, color = "Precip_2 accumulative")) +
  scale_color_manual(values = c("Precip accumulative" = "blue", 
                                "Precip_2 accumulative" = "red")) +
  scale_x_datetime(date_breaks = "1 months", date_labels = "%b %Y") +
  labs(
    title = "precip (acc) vs precip_2 (acc)",
    x = "Date",
    y = "mm",
    color = "Devices"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")
