# Analisis dan Peramalan Jumlah Penumpang dengan SARIMA

Repositori ini berisi proyek analisis *time series* (deret waktu) untuk meramalkan (forecasting) jumlah penumpang menggunakan model **Seasonal ARIMA (SARIMA)**. Proyek ini dibangun menggunakan bahasa pemrograman **R**.

## Struktur Repositori
*   **`Anls SARIMA.R`**: Script utama R yang berisi seluruh alur analisis (preparasi data, uji stasioneritas, pemodelan, evaluasi, dan forecasting).
*   **`Data Penumpang.xlsx`**: Dataset mentah berisi data historis jumlah penumpang bulanan (Januari 2017 - November 2026).
*   **`hasil_forecast_sarima.csv`**: File *output* berisi hasil prediksi jumlah penumpang untuk 12 bulan ke depan beserta interval kepercayaannya (95%).
*   **`README.md`**: Dokumentasi proyek (file ini).

## Metodologi Analisis
Analisis ini mengikuti standar *best practice* peramalan deret waktu, yang meliputi:
1.  **Uji Stasioneritas**: Menggunakan uji *Augmented Dickey-Fuller (ADF)* dan *KPSS*.
2.  **Pemodelan**: Menggunakan fungsi `auto.arima` untuk menemukan kombinasi parameter SARIMA terbaik.
3.  **Validasi**: Membagi data menjadi *Train* dan *Test* (12 bulan terakhir) untuk menguji akurasi model menggunakan metrik *MAPE, RMSE, dan MAE*.
4.  **Uji Diagnostik**: Menguji residual model menggunakan uji *Ljung-Box* untuk memastikan model telah menangkap seluruh pola data (bersifat *white noise*).
5.  **Forecasting**: Meramalkan jumlah penumpang 12 bulan ke depan beserta visualisasi grafiknya.

## Cara Menjalankan Script
1. Pastikan Anda telah menginstal R dan RStudio.
2. Instal *package* R yang dibutuhkan dengan perintah:
   ```R
   install.packages(c("readxl", "forecast", "dplyr", "lubridate", "ggplot2", "tseries"))
