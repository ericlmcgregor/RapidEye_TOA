library(raster)
library(rjson)
library(satellite)

####This script converts RapidEye imagery to Top-Of-Atmosphere reflectance 
###based on equation found in Planet documentation. 
###https://assets.planet.com/docs/1601.RapidEye.Image.Product.Specs_Jan16_V6.1_ENG.pdf
###1) convert to radiance using scale factor (0.01)
###2) convert to TOA reflectance
###Requires the following parameters:
###-Exo-Atmospheric Irradiance
###-Earth-Sun Distance at the day of acquisition (in Astronomical Units)
###-Solar Zenith angle in degrees (90-sun elevation)



setwd("C:/Users/ericm/Documents/ForGithub/RapidEye_TOA/Data")

#set desired output format (based on writeRaster())
outputformat <- "GTiff"

#Fixed Exo-Atmospheric Irradiance values for the 5 RE bands
eai_b1 <- 1997.8
eai_b2 <- 1863.5
eai_b3 <- 1560.4
eai_b4 <- 1395.0
eai_b5 <- 1124.4


#list metadata json files in working directory 
metalist <- list.files(getwd(), 
                       pattern = ".json$", full.names = T)

#Loop through json files and convert the associated raster data to Top-Of-Atmosphere reflectance
for(i in 1:length(metalist)){
  #read json file i
  meta <- fromJSON(file = metalist[i])
  #open the image file corresponding to the given metadata file
  img <- stack(paste(meta$properties$grid_cell,"_", 
                     as.Date(meta$properties$acquired), "_RE5_3A.tif", sep = ""))
  #calculate Earth-Sun distance in AU for given date (using Spencer 1971)
  esd <- calcEarthSunDist(as.Date(meta$properties$acquired), formula = c("Spencer"))
  #scale image to radiance (DN*radiometric scale factor)
  img <- img*0.01
  #Convert each band to TOA reflectance 
  #Remember to multiply solar zenith degrees by pi/180 to get correct cosine value
  #pi/180 = 0.017..
  toa_b1 <- calc(img[[1]], fun=function(x){
    x*((pi*esd^2)/eai_b1*cos((90 - meta$properties$sun_elevation)*0.01745329)) 
  })
  toa_b2 <- calc(img[[2]], fun=function(x){
    x*((pi*esd^2)/eai_b2*cos((90 - meta$properties$sun_elevation)*0.01745329))
  })
  toa_b3 <- calc(img[[3]], fun=function(x){
    x*((pi*esd^2)/eai_b3*cos((90 - meta$properties$sun_elevation)*0.01745329))
  })
  toa_b4 <- calc(img[[4]], fun=function(x){
    x*((pi*esd^2)/eai_b4*cos((90 - meta$properties$sun_elevation)*0.01745329))
  })
  toa_b5 <- calc(img[[5]], fun=function(x){
    x*((pi*esd^2)/eai_b5*cos((90 - meta$properties$sun_elevation)*0.01745329))
  })
  #stack bands and write output as multi-band image, adding _TOA to the original filename
  toa <- stack(toa_b1, toa_b2, toa_b3, toa_b4, toa_b5)
  writeRaster(toa, paste(meta$id, "_TOA", sep = ""), format = outputformat)
}
