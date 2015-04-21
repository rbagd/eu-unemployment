This is a snippet of code to replicate in `R` [an unemployment tracker](http://blogs.ft.com/ftdata/2015/04/17/eu-unemployment-tracker/) published by Financial Times. I wanted in particular to illustrate how easy `rsdmx` renders data processing part. Financial Times graphs were done with `d3`, so obviously there is no intention to compete. [This website](http://rstudio-pubs-static.s3.amazonaws.com/8955_871d064627354ed489b8c28b78ef1d0b.html) was very useful to get the hang of how to get spatial Eurostat data into `R`.

![Unemployment in Europe](eu_unemployment.png)

To obtain the map drawing, it suffices to run `Rscript map.R` provided that all the necessary packages are installed.

As a side note, Financial Times map contains data for European regions as defined by NUTS3. Unfortunately, I was not able to locate any kind of unemployment rates for NUTS3 within Eurostat tables, only for NUTS2. If someone can pinpoint to a correct table, the fix is very quick as Eurostat shapefiles contain already spatial data for NUTS3.

For completeness, geographic shapefiles are included in `data` directory. Unfortunately, these are not public domain as specified [here](http://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units) and commercial usage is prohibited. They are property of **© EuroGeographics for the administrative boundaries**.
