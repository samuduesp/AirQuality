library("readxl")
library(mlbench)
library(lubridate)
library(tidyverse)  # data manipulation
library(cluster)    # clustering algorithms
library(factoextra) # clustering algorithms & visualization
library("dplyr")
library(rpart)
install.packages("e1071")
library(e1071)

AirQ <- read_excel("AirQualityUCI-1.xlsx")
dim(AirQ)
head(AirQ)
head(AirQ, n=100)
levels(AirQ)
sapply(AirQ,class)
cbind
summary(AirQ)

# list the structure of mydata
str(AirQ)
#Find missing values in each attribute
colSums(is.na(AirQ))

# remove the column
AirQ1 <- AirQ[ , ! names(AirQ) %in% c("NMHC(GT)")]  
str(AirQ1)
colSums(is.na(AirQ1))

colnames(AirQ1)

##### Rename one column name #####

colnames(AirQ1)[colnames(AirQ1) == "CO(GT)"] <- "CO"
colnames(AirQ1)[colnames(AirQ1) == "NOx(GT)"] <- "NOx"
colnames(AirQ1)[colnames(AirQ1) == "NO2(GT)"] <- "NO2"
colnames(AirQ1)[colnames(AirQ1) == "PT08.S1(CO)"] <- "S1CO"
colnames(AirQ1)[colnames(AirQ1) == "C6H6(GT)"] <- "C6H6"
colnames(AirQ1)[colnames(AirQ1) == "PT08.S2(NMHC)"] <- "NMHC"
colnames(AirQ1)[colnames(AirQ1) == "PT08.S3(NOx)"] <- "s3NOx"
colnames(AirQ1)[colnames(AirQ1) == "PT08.S4(NO2)"] <- "S4NO2"
colnames(AirQ1)[colnames(AirQ1) == "PT08.S5(O3)"] <- "S5O3"
AirQ2 <- AirQ1 


# Duplicate data frame
AirQ2$CO[is.na(AirQ2$CO)] <- mean(AirQ2$CO, na.rm = TRUE)  # Replace NA in one column
AirQ2$NOx[is.na(AirQ2$NOx)] <- mean(AirQ2$NOx, na.rm = TRUE)
AirQ2$NO2[is.na(AirQ2$NO2)] <- mean(AirQ2$NO2, na.rm = TRUE)
colSums(is.na(AirQ2))

str(AirQ2)

#remove rows which has 
AirQ3 <- na.omit(AirQ2)
colSums(is.na(AirQ3))


colnames(AirQ2)

library(lubridate)

#Change the format
AirQ3$time <- format(as.POSIXct(AirQ3$Time),format = "%H,%M,%S")

str(AirQ3)

#Remove the column
AirQ4 <- AirQ3[ , ! names(AirQ3) %in% c("Time")] 
str(AirQ4)

#reorder data column
AirQ5 <- AirQ4[ ,c(1,14,2,3,4,5,6,7,8,9,10,11,12,13)] #Reorder data columns
str(AirQ5)
#finally data table

# Apply the multiple linear regression for model.
# check the linearity among dependent variables and independent variables before linear regression start

mod <- lm(T ~ CO, data =AirQ5)
mod
summary(mod)


mod <- lm(T ~ S1CO, data =AirQ5)
mod
summary(mod)

#mod1 <- lm(RH ~ CO+S1CO+C6H6+NMHC+NOx+s3NOx+S5O3+NO2+S4NO2+S5O3, data =AirQ5)
#mod1
#so result

summary(mod1)
mod1 <- lm(T ~ CO+S1CO+C6H6+NMHC+NOx+s3NOx+S5O3+NO2+S4NO2+S5O3+RH, data =AirQ5)
mod1
#so result
summary(mod1)



plot(AirQ5)


mod2 <- lm(T ~ CO+S1CO+C6H6+NMHC+NOx+s3NOx+S5O3+NO2+S4NO2+S5O3, data =AirQ5)
mod2
#so result
summary(mod2)

#Comparing Models
#we can compare nested models with the anova( ) function. The following code provides a simultaneous test that x3 and x4 add to linear prediction above and beyond x1 and x2.
#mod1 <- lm(RH ~ CO+S1CO+C6H6+NMHC+NOx+s3NOx+S5O3+NO2+S4NO2+S5O3, data =AirQ5)
#mod1

#mod2 <- lm(RH ~ S1CO+C6H6+NMHC+NOx+s3NOx+S5O3+NO2+S4NO2+S5O3, data =AirQ5)
#mod2
#summary(mod2)
#summary(mod1)
#anova(mod1, mod2) # mod2 is better R2


### remove co due to high P vaule



#other useful functions
coefficients(mod1) # model coefficients

confint(mod1, level=0.95) # CIs for model parameters
fit1ted(mod1) # predicted values
residuals(mod1) # residuals
anova(mod1) # anova table
vcov(mod1) # covariance matrix for model parameters
influence(mod1) # regression diagnostics


## o.59 slope
## pr value null hypon rejected

## make a histrogram

attributes(mod1)
mod1$residuals
hist(mod1$residuals)

attributes(mod1)
mod1$residuals
plot(mod1$residuals)

# this is semestricly ideal one

#we can do predictions

new_airpollution_rates <- data.frame(CO =c(3.6,4,2.2))
predict(mod,new_airpollution_rates) %>% round(1)

new_airpollution_temperature1 <- data.frame(CO =c(3.6),S1CO= c(1361),C6H6 =c(11.80),
                                      NMHC =c(1040),NOx= c(160),
                                      s3NOx= c(1050),S5O3= c(1200),
                                      NO2=c(110),S4NO2= c(1600) ,
                                      S5O3 =c(1200),RH= c(47.5))
predict(mod1,new_airpollution_temperature1) %>% round(1)
install.packages("dplyr")
library("dplyr")
#try to install dplyr but still not working propely
#error-Error in predict(mod1, new_airpollution_rates) %>% round(1) : 
#could not find function "%>%"

#########################################################
########### Decistion Tree for regresstion ##############
#########################################################

# https://www.geeksforgeeks.org/decision-tree-for-regression-in-r-programming/

# Load the package
library(rpart)

#Fit the model for decision tree for regression
# Create decision tree using regression
fit <- rpart(T ~ CO+S1CO+C6H6+NMHC+NOx+s3NOx+S5O3+NO2+S4NO2+S5O3,RH,method = "anova", data =AirQ5)

#Plot the tree

# Output to be present as PNG file
png(file = "decTreeGFG.png", width = 600, 
    height = 600)

# Plot
plot(fit, uniform = TRUE,
     main = "Temperature Decision Tree using Regression")
text(fit, use.n = TRUE, cex = .7)

# Saving the file
dev.off()

#Print the decision tree model
# Print model
print(fit)

# Create test data
df  <- data.frame (Species = 'air', 
                   CO  = 2.2,
                   S1CO  = 1200,
                   C6H6  = 10,
                   NMHC =900,
                   NOx = 100,
                   s3NOx=900,
                   S5O3=800,
                   NO2=90, S4NO2 =1500, S5O3=900,RH=47.5 )


# Predicting  air content
# using testing data and model
# method anova is used for regression
cat("Predicted value:\n")
predict(fit, df, method = "anova")

##############################################################################################

