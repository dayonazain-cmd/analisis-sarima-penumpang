library(readxl)
library(forecast)
library(dplyr)
library(lubridate)
library(ggplot2)
library(tseries)

# --- 1. DATA PREPARATION ---
raw <- read_excel("Data Penumpang.xlsx", sheet = "Data Penumpang", skip = 1)
colnames(raw) <- c("Periode", "Total")
raw <- raw %>% filter(!is.na(Periode), !is.na(Total))

bulan_map <- c("Jan"=1, "Feb"=2, "Mar"=3, "April"=4, "Mei"=5, "Jun"=6, 
               "Jul"=7, "Agst"=8, "Sep"=9, "Okt"=10, "Nop"=11, "Des"=12)

raw$Tanggal <- as.Date(sapply(raw$Periode, function(x) {
  x <- trimws(gsub("-", " ", as.character(x)))
  parts <- strsplit(x, "\\s+")[[1]]
  if (length(parts) < 2) return(NA)
  bln <- bulan_map[parts[1]]
  thn <- parts[length(parts)]
  if (is.na(bln)) return(NA)
  sprintf("%s-%02d-01", thn, bln)
}), origin = "1970-01-01")

raw$Total <- as.numeric(raw$Total)
raw <- raw %>% filter(!is.na(Tanggal)) %>% arrange(Tanggal)

ts_data <- ts(raw$Total, start = c(year(raw$Tanggal[1]), month(raw$Tanggal[1])), frequency = 12)

# --- 2. UJI STASIONERITAS & EDA ---
cat("\n--- UJI STASIONERITAS ---\n")
print(adf.test(ts_data, alternative = "stationary")) # H0: Tidak Stasioner
print(kpss.test(ts_data))                            # H0: Stasioner

autoplot(ts_data) + ggtitle("Data Aktual Penumpang (2017-2026)")
ggtsdisplay(ts_data, main = "ACF & PACF Data Asli")

# --- 3. TRAIN & TEST SPLIT ---
n_train <- length(ts_data) - 12
train <- window(ts_data, end = time(ts_data)[n_train])
test  <- window(ts_data, start = time(ts_data)[n_train + 1])

# --- 4. PEMODELAN & EVALUASI ---
cat("\n--- EVALUASI MODEL (DATA TEST) ---\n")
model_train <- auto.arima(train, seasonal = TRUE, stepwise = FALSE, approximation = FALSE, D = NA)
forecast_test <- forecast(model_train, h = 12)

akurasi_test <- accuracy(forecast_test, test)
print(akurasi_test) # Cek nilai MAPE (semakin kecil semakin baik)

autoplot(forecast_test) +
  autolayer(test, series = "Aktual (Test)") +
  ggtitle("Validasi Model (Train vs Test)")

# --- 5. FINAL MODEL & DIAGNOSTIK ---
o <- arimaorder(model_train)
fit_final <- Arima(ts_data, order = c(o[1], o[2], o[3]), 
                   seasonal = list(order = c(o[4], o[5], o[6]), period = 12))

cat("\n--- MODEL SARIMA FINAL ---\n")
cat(sprintf("SARIMA(%d,%d,%d)(%d,%d,%d)[12]\n\n", o[1], o[2], o[3], o[4], o[5], o[6]))
print(summary(fit_final))

cat("\n--- UJI LJUNG-BOX (p-value > 0.05 = White Noise) ---\n")
print(Box.test(residuals(fit_final), type = "Ljung-Box", lag = 12))
checkresiduals(fit_final)

# --- 6. FORECASTING & EXPORT ---
future_fc <- forecast(fit_final, h = 12, level = c(80, 95))

autoplot(future_fc) +
  ggtitle("Forecast SARIMA 12 Bulan ke Depan") +
  ylab("Jumlah Penumpang") + xlab("Tahun")

hasil_tabel <- data.frame(
  Periode = format(as.Date(time(future_fc$mean), origin = "1970-01-01"), "%b %Y"),
  Forecast = round(as.numeric(future_fc$mean), 0),
  Bawah_95 = round(as.numeric(future_fc$lower[, 2]), 0),
  Atas_95 = round(as.numeric(future_fc$upper[, 2]), 0)
)

print(hasil_tabel)
write.csv(hasil_tabel, "hasil_forecast_sarima.csv", row.names = FALSE)