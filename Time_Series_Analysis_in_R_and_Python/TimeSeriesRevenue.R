# need to have daily sales revenue data ready
# by combining estimate C orders and all invoice data on a daily time span.
# date column not necessary
# need to start from 1/1/2015
# would be better to 
setwd("C:/Users/jh/Desktop")
library(timeDate)
library(timeSeries)
library("TTR")
library(zoo)
library(xts)
library(forecast)
options(scipen = 999)
list.files()
dat <- read.csv("ts.csv",header=T)
revenue <- dat$revenue
tsdat<- ts(revenue,frequency = 365, start=c(2015,1))
ts <- xts(revenue, as.Date(dat$date,"%m/%d/%Y"))
ts_m = apply.monthly(ts,FUN=sum)
ts_df <- as.data.frame(ts_m)
ts_df <- ts_df[-nrow(ts_df),]
ts_m <- ts(ts_df, frequency = 12, start=c(2015,1))
plot.ts(ts_m, xlim=c(2014,2021))
logtsdat <- log(ts_m)
plot.ts(logtsdat, xlim=c(2014,2021))
tsdat <- ts_m

# SMA
non_na_tsdat <- na.omit(tsdat)
plot.ts(non_na_tsdat)
class(non_na_tsdat)
revenueSMA <- SMA(non_na_tsdat,n=3)
class(revenueSMA)
plot.ts(revenueSMA)

# decomposing seasonal and non-seasonal elements additive
decompose_revenue_components <- decompose(non_na_tsdat)
plot(decompose_revenue_components)
revenue_seasonal_adjusted <- non_na_tsdat - decompose_revenue_components$seasonal
plot(revenue_seasonal_adjusted)

# decompose multiplicative 
m_decompose_revenue_components <- decompose(non_na_tsdat, type="add")
plot(m_decompose_revenue_components)
m_revenue_seasonal_adjusted <- non_na_tsdat - m_decompose_revenue_components$seasonal
plot(m_revenue_seasonal_adjusted)
 
#in conclusion, multiplicative modeling is better
#due to smaller residual and less spread in seasonal adjusted graph

# forecasting using exponential smoothing
# simple forecast beta is exponential smoothing, gamma is non-seasonal modeling
rev_forecast <- HoltWinters(non_na_tsdat, beta=FALSE,gamma=F)
plot(rev_forecast)
# SSE, for sum of squared error
rev_forecast$SSE
# RMSE

HoltWinters(non_na_tsdat,beta=F,gamma=F,l.start=10694.24) # first cash order in est

# use forecast library and HoltWinters
revenue_forecast <- forecast:::forecast.HoltWinters(rev_forecast, h=6)
revenue_forecast
forecast:::plot.forecast(revenue_forecast)
acf(revenue_forecast$residuals, na.action=na.pass,lag.max=20)

# lag 8 is touching the significance bound, use Ljung-box test
Box.test(revenue_forecast$residuals, lag=20, type='Ljung-Box')
# check for constant residuals over time
plot.ts(revenue_forecast$residuals)


# the function is to check for forecast errors are normally distributed
plotForecastErrors <- function(forecasterrors)
{
  # make a histogram of the forecast errors:
  mybinsize <- IQR(forecasterrors)/4
  mysd   <- sd(forecasterrors)
  mymin  <- min(forecasterrors) - mysd*5
  mymax  <- max(forecasterrors) + mysd*3
  # generate normally distributed data with mean 0 and standard deviation mysd
  mynorm <- rnorm(10000, mean=0, sd=mysd)
  mymin2 <- min(mynorm)
  mymax2 <- max(mynorm)
  if (mymin2 < mymin) { mymin <- mymin2 }
  if (mymax2 > mymax) { mymax <- mymax2 }
  # make a red histogram of the forecast errors, with the normally distributed data overlaid:
  mybins <- seq(mymin, mymax, mybinsize)
  hist(forecasterrors, col="red", freq=FALSE, breaks=mybins)
  # freq=FALSE ensures the area under the histogram = 1
  # generate normally distributed data with mean 0 and standard deviation mysd
  myhist <- hist(mynorm, plot=FALSE, breaks=mybins)
  # plot the normal curve as a blue line on top of the histogram of forecast errors:
  points(myhist$mids, myhist$density, type="l", col="blue", lwd=2)
}

# use ARIMA model might be useful to reduce noise
non_na_tsdatdiff1 <- diff(non_na_tsdat, differences=1)
plot.ts(non_na_tsdatdiff1)
non_na_tsdatdiff2 <- diff(non_na_tsdat, differences=2)
plot.ts(non_na_tsdatdiff2)
acf(non_na_tsdat,lag.max=20)
acf(non_na_tsdat,lag.max=20,plot=F)
# this shows that after lag 19 the auto-correlation approximates 0.
# therefore, MA(19) this means that data is just too fluctuated
# also check for partial correlogram
pacf(non_na_tsdat, lag.max=20)
#pacf shows after lag 7 the auto-correlation approximates 0. -->AR(7)
revenue_arima1 <- arima(non_na_tsdat, order=c(6,2,8))
tsdiag(revenue_arima1)
revenue_arima
predict(revenue_arima1,6)
revenue_forecast

#auto arima
revenue_auto_arima <- auto.arima(revenue_seasonal_adjusted,ic="aic")
auto_arima_forecast <- forecast(revenue_auto_arima,h=6)
auto_arima_forecast
forecast_df <- as.data.frame(auto_arima_forecast)
plot(auto_arima_forecast,col="red")
class(auto_arima_forecast)
plot(auto_arima_forecast$residuals)
acf(auto_arima_forecast$residuals,lag.max=20)
pacf(auto_arima_forecast$residuals,lag.max=20)
ts_forecast <- rbind(non_na_tsdat, auto_arima_forecast)

# add fitted line
fittedline <- tslm(non_na_tsdat~decompose_revenue_components$seasonal+decompose_revenue_components$trend)


# add forecast with ts together and output to csv
ts_df <- data.frame(non_na_tsdat,row.names=as.yearmon(time(non_na_tsdat)))
forecast_df <- as.dataframe(revenue_forecast)
df <- data.frame(0)
ts_df$Forecast <- 0
ts_df$High95 <- 0
ts_df$Low95 <- 0
df <- rbind.fill(ts_df[c("Forecast","High95","Low95")],forecast_df[c("Point Forecast", "Hi 95", "Lo 95")])
df$ts <- 0
for (i in seq(1,nrow(ts_df),by=1)) {df$ts[i] <- ts_df$non_na_tsdat[i]}
df[c("Forecast","High95","Low95")] <- NULL
write.csv(df,"prediction.csv")


# make sales ups and downs in terms of return
return <- ts(start=c(2015,2),frequency=12)
for (i in seq(2,length(non_na_tsdat))) {return[i-1] <- non_na_tsdat[i]/non_na_tsdat -1}
