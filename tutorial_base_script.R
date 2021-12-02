# Tutorial Creation Assignment: Visualizing multiple plots: How can we use R visualization features do add multiple layers to plots?
# Author: Emily Tanner
# Email: s1765125@ed.ac.uk
# Date: November 28, 2021

# 3 approaches to visualizing multiple layers of data in one plot space
# key focus: how can we visualize multiple data aspects in a susinct and efficient manner? Plots with multiple layers are a useful way to do this. R offers many ways to layer plots, including the ggplot2 package, which allows enables you to layer statistical information on top of a plot. Plotting two figures on the same axis using the "par" feature is also useful way to display information. And thirdly, the datasets package allows us to overlay plots.

# Load libraries ---- 
## if you haven't installed them before, run the code install.packages("package_name")
library(ggplot2)  # used to create multilayer plots
library(datasets)  # used to for NYC airquality data 
library (dplyr)  # used for data manipulation; pipes
library(tidyverse)  # used to reshape data; converting from wide to long format 

# Load data ----
View(airquality)  # let's take a look at the data - notice anything problematic?

# Data manipulation ----
airquality1 <- as_tibble(airquality %>%  # creating a local copy of our data via a tibble object for good practice
  dplyr::mutate(Date = as.Date(paste("1973",Month,Day,sep="/"))))  # let's transform the current day / month structure into useful year-month-day 
## this will facilitate plotting because R can now recognize the continuity of our data over time

summary(airquality1) # let's take another look long data - is it how we want it? 
## Hint: Anything at the bottom of the Ozone and Solar.R sections that might cause trouble later?


airquality1 <- airquality1 %>%  # overwriting the airquality1 object via a pipe
  na.omit(airquality1)  # let's get rid of "NA" values in the dataset       
summary(airquality1)  # Check again - NA's are gone! 
str(airquality1)  # Let's see the structure of the data - what kind of variables is R assigning for our data? 

# 1. multilayer plots in ggplot package ----

(prelim_plot <- ggplot(airquality1, aes(x = Date, y = Ozone, colour = Month)) +
   geom_point(colour = "#8B5A00") +
     xlab("Date") +
     ylab("Ozone (ppb)") +
     ggtitle("Most Basic GGplot: New York Air Quality (1973)"))
ggsave("prelim_plot_tut.png", width = 6, height = 5)  # save

## Additional layer: Solar radiation as a colour
(ggplot(airquality1, aes(x = Date, y = Ozone, colour=Solar.R)) + 
  geom_point() +
  xlab("Date") +
  ylab("Ozone (ppb)") +
  ggtitle("Less Basic GGplot: New York Air Quality (1973): Ozone and Solar Radiation"))
ggsave("less_prelim_plot_tut.png", width = 6, height = 5)  # save


# Using "geom" functions to add additional layers
(ggplot(airquality1, aes(x = Date, y = Ozone, colour=Solar.R)) +
  geom_point() + 
  geom_smooth() +
  xlab("Date") +
  ylab("Ozone (ppb)") +
  ggtitle("GGplot: New York Air Quality Trends (1973): Ozone and Solar Radiation"))  
ggsave("prelim3_plot_tut.png", width = 6, height = 5)  # save

# long transformation
air_long <- airquality1 %>%
  dplyr::select(-Month, -Day) %>%              # Removing Month and Day columns
  tidyr::gather(variable, value, -Date)
str(air_long)  # Let's see the structure of the data
View(air_long)  # you can use this to view the entirety of the data, opening it in a new tab

ggplot(air_long,
       aes(x = Date, y = value, 
             colour=variable)) +
      geom_point() + 
      geom_line()

ggplot(air_long, 
       aes(x = Date, y = value, 
           linetype = variable,
           color = variable, 
           group = variable)) +  
       geom_line() +  # adding in lines to connect data points
       ggtitle("New York Air Quality Parameters")  # let's add in a title

# Visualizing by variable
ggplot(air_long, 
       aes(x = Date, y = value)) +
  geom_point(size=1) +
  geom_smooth(se=F, colour="grey") +  # adding in a grey smoothed conditional mean, with no standard error confidence interval
  facet_wrap("variable") +  # facet_wrap based on variable
  ggtitle("Visualizing by Variable: New York Air Quality Data")
 
ggplot(air_long, 
       aes(x = Date, y = value, 
           linetype = variable,
           color = variable,  # adding in color by variable
           group = variable)) +
  geom_point() +  geom_smooth(se=F, colour="black") +
  facet_wrap("variable") +
  ggtitle("Visualizing by Variable: New York Air Quality Data")

# 2. par function to split plotting ----

# par function is used to set graphical parameters for the plotting device 
par(mfrow=c(2,2))  # listing rows first and columns second --> e.g. 2 rows 1 column 
plot(airquality1$Date, airquality1$Ozone, type="l", xlab="Date",
     ylab="Ozone")
plot(airquality1$Date, airquality1$Solar.R, type="l", xlab="Date",
     ylab="Solar Radiation" )
plot(airquality1$Date, airquality1$Temp, type="l", xlab="Date",
     ylab="Temperature" )
plot(airquality1$Date, airquality1$Wind, type="l", xlab="Date",
     ylab="Wind" )
dev.off()   # turning the device operator off, this an important step because otherwise our plotting device will continue plotting with parameters set above


# 3. Overlaying plots ----
hist(airquality1$Solar.R)

# Creating Density Plot
hist(airquality1$Solar.R,
     breaks = 12,
     freq   = FALSE,       # We can change our hist to a density plot by changing axis to show density, not frequency
     col    = "thistle4"   # specifying colour for histogram
     main   = ("Solar Radiation Density Plot),
     xlab   = "Solar Radiation (lang)")


# Add a normal distribution
curve(dnorm(x, mean = mean(airquality1$Solar.R), sd = sd(airquality1$Solar.R)),
      col = "green",     # Colour of curve
      lwd = 2,           # Line width of 2 pixels
      add = TRUE)        # Superimpose on previous graph
      
# Add kernel density estimator
lines(density(airquality1$Solar.R), col = "blue", lwd = 2)

# Add a rug plot
rug(airquality1$Solar.R, lwd = 2, col = "gray")

# the end

