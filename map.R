# Download data from Eurostat via SDMX protocol

library(rsdmx)

period <- "?startPeriod=2004-01&endPeriod=2015-04"

keys <- list()
keys$regional_unemp <- "lfst_r_lfu3rt/A.PC.Y_GE15.T.."
keys$harm_unemp_tot <- "ei_lmhr_m/M.RT.SA.LM-UN-T-TOT.."
keys$harm_unemp_youth <- "ei_lmhr_m/M.RT.SA.LM-UN-T-LE25.."
keys$long_term_unemp <- "tesem130/A.T.LTU_ACT_RT.."

data_url <- "http://ec.europa.eu/eurostat/SDMX/diss-web/rest/data"
urls <- paste(data_url, keys, period, sep="/")

xml_data <- lapply(urls, readSDMX)
df_data <- lapply(xml_data, as.data.frame)

# Simple time series plots
## Downloaded data contains more countries than the European Union. It is easy to specify those
## which are of interest. I didn't bother.

library(lattice)

xyplot(obsValue ~ as.Date(paste0(obsTime, "-01")) | GEO, data=df_data[[2]], type='l', xlab="", ylab="", ylim=c(2,29))
xyplot(obsValue ~ as.Date(paste0(obsTime, "-01")) | GEO, data=df_data[[3]], type='l', xlab="", ylab="", ylim=c(2,65))
xyplot(obsValue ~ as.Date(paste0(obsTime, "-01-01")) | GEO, data=df_data[[4]], type='l', xlab="", ylab="", ylim=c(0,20))

# Map treatment
## While here year is prespecified, it is easy to create a Shiny wrapper which allows for
## interactive selection.

library(rgdal)
library(sp)
library(RColorBrewer)
library(maptools)

year <- 2013
map_data <- subset(df_data[[1]], obsTime == year)

# Get map file from Eurostat (@ EuroGeographics), unpack it and put shapefiles current working directory
## http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/NUTS_2010_60M_SH.zip
## Warning: these shapefiles are not licenced for commercial usage.

eu_nuts <- readOGR(dsn="./data", layer = "NUTS_RG_60M_2010")

# The following modifies slightly the projection of the map so it looks nicer. We also extract
# only boundaries for regions of level 2 (NUTS2) as well as country boundaries.

eu_sp <- spTransform(eu_nuts,
         CRS("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"))

country_borders <- eu_sp[eu_sp@data$STAT_LEVL_==0, ]
eu_nuts2 <- eu_sp[eu_sp@data$STAT_LEVL_ == 2,]

# Match regions with previously downloaded data

eu_nuts2@data <- data.frame(eu_nuts2@data,
                         unemployment=map_data[match(eu_nuts2@data[, "NUTS_ID"], map_data$GEO), "obsValue"])
my_colours <- brewer.pal(7, "RdPu")
breaks <- c(4, 5, 6, 7, 8, 9, 11, 15)

# Plot the map

png(filename="eu_unemployment.png")
mapplot <- plot(eu_nuts2, col = my_colours[findInterval(eu_nuts2@data$unemployment, breaks, all.inside=TRUE)],
                axes=FALSE, border = NA, xlim=c(-1406961, 3208068), ylim=c(4205243, 11221112),
                main=paste0("Unemployment rate (%) in ", year))
mapplot <- plot(country_borders, add = TRUE)
mapplot <- legend(x = -2706961, 8730220, legend = leglabs(round(breaks, digits=2), between = "to "),
               fill = my_colours, bty="n", cex=0.7)
dev.off()

# Barplot on the side

par(mar=c(1.5,1.5,6.5,1.5))
barplot(sort(eu_nuts2@data$unemployment), horiz=TRUE, axes=FALSE,
        main=paste0("Total regional unemployment rate (%), ", year)); grid()
axis(3)
