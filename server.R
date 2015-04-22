data <- read.csv("faillites.csv", header=TRUE)
pop <- read.csv("population2014.csv", header=TRUE)
data$population <- pop[match(data$NUTS_ID, pop$GEO), "obsValue"]
# Map treatment

library(rgdal)
library(sp)
library(RColorBrewer)
library(maptools)

# Get map file from Eurostat (@ EuroGeographics), unpack it and put shapefiles current working directory
## Warning: these shapefiles are not licenced for commercial usage.

eu_nuts <- readOGR(dsn="./data", layer = "NUTS_RG_03M_2010")

# The following modifies slightly the projection of the map so it looks nicer. We also extract
# only boundaries for regions of level 2 (NUTS2) as well as country boundaries.

eu_sp <- spTransform(eu_nuts,
         CRS("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"))
eu_nuts2 <- eu_sp[eu_sp@data$STAT_LEVL_ == 2 & substr(eu_sp@data$NUTS_ID, 1, 2) == "BE",]
be_nuts2 <- eu_nuts2

shinyServer(function(input, output) {
  
  
  output$mapplot <- renderPlot ({ 
    map_data <- head(data[,c(2, as.numeric(input$month))], -1)
    
    if (input$capita == TRUE) { map_data[,2] <- 1000000*map_data[,2] / head(data$population, -1) }
    
    be_nuts2@data <- data.frame(eu_nuts2@data,
                                faillites=map_data[match(eu_nuts2@data[, "NUTS_ID"], map_data$NUTS_ID), 2])
    my_colours <- brewer.pal(8, "RdPu")
    breaks <- c(4, 50, 60, 70, 80, 90, 110, 150, 200)
    
  mapplot <- plot(be_nuts2, col = my_colours[findInterval(be_nuts2@data$faillites, breaks, all.inside=TRUE)],
                  axes=FALSE, xlim=c(275436, 745853), ylim=c(6364866, 6739279),
                  border="grey", lwd=0.5, main="Faillites")
  mapplot <- legend(x = 70961, 6737220, legend = leglabs(round(breaks, digits=2), between = "to "),
                    fill = my_colours, bty="n", cex=0.8, x.intersp=0.5, y.intersp=0.9)
  })
  
  output$summary <- renderTable ({
    
    data[,c(1, as.numeric(input$month), 16)]  
    
  })
  
})