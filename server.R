# Load data from CSV files

data <- read.csv("faillites.csv", header=TRUE)
pop <- read.csv("population2014.csv", header=TRUE)
data$population <- pop[match(data$NUTS_ID, pop$GEO), "obsValue"]
dates <- tolower(gsub(".", " ", colnames(data), fixed=TRUE))
provinces <- gsub("Province de |Province d'|Région ", "", data[,1])
# Map treatment

library(rgdal)
library(sp)
library(RColorBrewer)
library(maptools)

# Get map file from Eurostat (@ EuroGeographics), unpack it and put shapefiles current working directory
## Warning: these shapefiles are not licenced for commercial usage.

eu_nuts <- readOGR(dsn="./data", layer = "NUTS_RG_03M_2010")

# The following modifies slightly the projection of the map so it looks nicer. We also extract
# only boundaries for regions of level 2 (NUTS2) for Belgium only.

eu_sp <- spTransform(eu_nuts,
                     CRS("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0
                          +units=m +nadgrids=@null +no_defs"))
eu_nuts2 <- eu_sp[eu_sp@data$STAT_LEVL_ == 2 & substr(eu_sp@data$NUTS_ID, 1, 2) == "BE",]
be_nuts2 <- eu_nuts2

my_colours <- rev(brewer.pal(8, "RdYlGn"))
breaks <- c(4, 50, 60, 70, 80, 90, 110, 150, 200)

shinyServer(function(input, output) {
 
  output$firstdata <- renderText ({ dates[3] })
  output$lastdata <- renderText ({ tail(head(dates,-1), 1) })

  output$mapplot <- renderPlot ({ 
    
    month <- input$month + 2
    map_data <- head(data[,c(2, month)], -1)
    title <- "Nombre de faillites"
    if (input$capita == TRUE)
    {
      map_data[,2] <- 1e6*map_data[,2] / head(data$population, -1)
      title <- paste0(title, " par million d'habitants")
    }
    title <- paste0(title, " en ", dates[month])

    be_nuts2@data <- data.frame(eu_nuts2@data,
                                faillites=map_data[match(eu_nuts2@data[, "NUTS_ID"],
                                                         map_data$NUTS_ID), 2])
   
    mapplot <- plot(be_nuts2, col = my_colours[findInterval(be_nuts2@data$faillites,
                                                          breaks, all.inside=TRUE)],
                  axes=FALSE, xlim=c(275436, 745853), ylim=c(6364866, 6739279),
                  border="grey", lwd=0.7, main=title)

    mapplot <- legend("topleft", inset=0.05, #x = 7000961, 6507220,
                      legend = leglabs(round(breaks, digits=2),
                                       between = "à", under="Moins que", over="Plus que"),
                      fill = my_colours, bty="n", cex=1.0, x.intersp=0.5, y.intersp=0.9)
}, width=1000, height=600)
  
  output$summary <- renderDataTable ({

    month <- input$month + 2
    data.frame("Province"=provinces,
               "Population"=data[,ncol(data)],
               "Faillites"=data[,month],
               "Par 10⁵ habitants"=round(1e6*data[,month]/data$population, digits=1),
               check.names=FALSE)
  
  }, options=list(searching=FALSE, paging=FALSE, info=FALSE,
                  rowCallback = I('function(row, data) {
                                            $("th").css("font-size", "13px");
                                            $("td", row).css("text-align", "right");
                                  }')
                  
                  )
    )
  
})
