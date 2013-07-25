D<-read.table("C:/Users/Kathi/Dropbox/Skydiver/j1.txt")
Dsm<-read.table("C:/Users/Kathi/Dropbox/Skydiver/filter/generateddata1.txt")
Dpicked<-D[,2]
Dsmooth<-Dsm

Ddifference<-read.table("C:/Users/Kathi/Dropbox/Skydiver/filter/generateddifferencedata1.txt")


arima(Ddifference,order=c(5,1,5))