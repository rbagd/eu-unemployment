This application illustrates evolution in the number of company bankruptcies in Belgium at provincial level in the last 13 months. Bankruptcy data is taken from SPF Economie whereas population data was taken from Eurostat and stands for population estimates in 2014.

To run the app, install the necessary dependencies and be sure that geospatial data is read correctly. If you clone the repo, replace
```
eu_nuts <- readOGR(dsn="./data", layer= "NUTS_RG_03M_2010")
```
with
```
eu_nuts <- readOGR(dsn="../data", layer= "NUTS_RG_03M_2010")
```
so that it is pointed to the correct directory. Current directory is still there for deploying the app with `shinyapps`. You may check it out [here](https://rytis.shinyapps.io/bankruptcies).
