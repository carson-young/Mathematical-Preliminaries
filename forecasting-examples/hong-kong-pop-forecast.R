library(fpp3)
library(prophet)
library(fable)
library(ggplot2)

hkg_economy <- global_economy |>
  filter(Code == "HKG") |>
  mutate(Pop = Population/1e6)

autoplot(hkg_economy, Pop) +
  labs(y = "Millions", title = "Hong Kong population")



# ETS Models 
hkg_economy |>
  model(
    `Holt's method` = ETS(Pop ~ error("A") +
                            trend("A") + season("N")),
    `Damped Holt's method` = ETS(Pop ~ error("A") +
                                   trend("Ad", phi = 0.9) + season("N"))
  ) |>
  forecast(h = 15) |>
  autoplot(hkg_economy, level = NULL) +
  labs(title = "Hong Kong population",
       y = "Millions") +
  guides(colour = guide_legend(title = "Forecast"))




# Compare ARIMA() and ETS() on non-seasonal data (population of Hong Kong)
hkg_economy |>
  slice(-n()) |>
  stretch_tsibble(.init = 10) |>
  model(
    ETS(Pop),
    ARIMA(Pop)
  ) |>
  forecast(h = 1) |>
  accuracy(hkg_economy) |>
  select(.model, RMSE:MAPE)




hkg_economy |>
  model(arima = ARIMA(Pop),ets = ETS(Pop)) |>
  forecast(h = "10 years") |>
  autoplot(hkg_economy |> filter(Year >= 1960)) +
  labs(title = "Hong Kong population",
       y = "People (millions)")



