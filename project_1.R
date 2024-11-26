#0. PACKAGE INSTALLATION AND SETUP
install.packages('lubridate') 
install.packages('fitdistrplus') 
install.packages('sf')
install.packages("sf")
install.packages("ggplot2")
library(ggplot2)
require(lubridate)
require(fitdistrplus)
require(sf)
require(dplyr)

#1. PREPARE CRASH DATA FOR ANALYSIS
#1.1 read in crash data, aggregate deaths+serious injuries to weekly level
crashes <- read.csv('crashes.csv',stringsAsFactors=TRUE)
crashes_copy <- crashes               

#creates a new column holding the sum of fatal and incapacitating injuries
crashes_copy$SERIOUS_INJURIES <- crashes$INJURIES_FATAL + crashes$INJURIES_INCAPACITATING 

#convert crash date into a date type:
crashes_copy$CRASH_DATE <- as.Date(crashes_copy$CRASH_DATE, format = "%Y-%m-%d")

# Create a week column using floor_date
# Floor date just gets the first date of the week. Takes units (week) and date that the week starts (Sunday, 7)
crashes_copy$WEEK <- floor_date(crashes_copy$CRASH_DATE, unit = "week", week_start = 7)

# Determine the range of crash dates
start_date <- min(crashes_copy$CRASH_DATE)
end_date <- max(crashes_copy$CRASH_DATE)

# Calculate the first and last complete week
first_complete_week <- start_date + (7 - as.numeric(format(start_date, "%u"))) # Adjust to first Sunday
last_complete_week <- end_date - as.numeric(format(end_date, "%u")) # Adjust to last Saturday


# Filter for complete weeks
complete_weeks <- crashes_copy[crashes_copy$CRASH_DATE >= first_complete_week & crashes_copy$CRASH_DATE <= last_complete_week, ]

# Aggregate serious injuries per complete week
weekly_totals_complete_weeks <- aggregate(SERIOUS_INJURIES ~ WEEK, data = complete_weeks, sum)

# Added a column for the week number. The first week of the year is 1, second is 2, and so on.
# Might be useful later on. So I added it.
weekly_totals_complete_weeks$WEEK_NUM <- as.numeric(format(weekly_totals_complete_weeks$WEEK, "%U")) # Week number


#Fitting poisson on entire data
best.pois <- fitdist(weekly_totals_complete_weeks$SERIOUS_INJURIES,ppois,method='mle')
best.pois
#Use the ks test to determine the likelihood of the distribution being possion distributed
ks.test(x=weekly_totals_complete_weeks$SERIOUS_INJURIES,y=ppois,lambda=best.pois$estimate[1])
# Very low p-value. Reject the null hypothesis that the data came from a poisson distribution. 
#Parameter is D = 0.16155


par(mfrow = c(1, 2))  # Set up a grid of plots (1 row, 5 columns)

hist(weekly_totals_complete_weeks$SERIOUS_INJURIES, ylim=c(0,150))
points(x=seq(5,90,10),y=length(weekly_totals_complete_weeks$SERIOUS_INJURIES)*(ppois(seq(10,90,10),lambda=best.pois$estimate[1])-
                                                                                 ppois(seq(0,80,10),lambda=best.pois$estimate[1])),
       col='#800000',pch=1)


print(best.pois)
print(ks.test(x=weekly_totals_complete_weeks$SERIOUS_INJURIES,y=ppois,lambda=best.pois$estimate[1]))
#Since it is below 1%, 2.55e-06, we reject the null hypothesis

#parameters: D=0.16155
#test output: 2.55e-06

hist(weekly_totals_complete_weeks$SERIOUS_INJURIES, ylim=c(0,150))
best.negative = fitdist(weekly_totals_complete_weeks$SERIOUS_INJURIES,pnbinom,method='mle')
print(best.negative)

ks.test(x=weekly_totals_complete_weeks$SERIOUS_INJURIES,y=pnbinom,size = best.negative$estimate[1], mu = best.negative$estimate[2])
#parameters: D=0.086031
#test output: 0.04262.....fail to reject null
points(x=seq(5,90,10),y=length(weekly_totals_complete_weeks$SERIOUS_INJURIES)*(pnbinom(seq(10,90,10),size = best.negative$estimate[1], mu = best.negative$estimate[2])-
                                                                                 pnbinom(seq(0,80,10),size = best.negative$estimate[1], mu = best.negative$estimate[2])),
       col='#800000',pch=1)



less_than_95_pois <- qpois(0.95, lambda=best.pois$estimate[1]) #95% of values from this distribution are less than the resulting value. Uses the CDF.
print(less_than_95)
# 95% of values from this distribution are less than 58

overfiftyeight <- weekly_totals_complete_weeks[weekly_totals_complete_weeks$SERIOUS_INJURIES > less_than_95_pois, ] #gives us 44 weeks

percentofweekspoiss <- length(overfiftyeight$WEEK)/length(weekly_totals_complete_weeks$WEEK) 
print(percentofweekspoiss)
#.16923
#16.9 percent is much higher than 5%. So this tells us that the poisson dist is unreasonable.
#If the possion dist fit it perfectly, than the number would be much closer to 5%.

less_than_95_nbinom <- qnbinom(0.95, size = best.negative$estimate[1], mu = best.negative$estimate[2])
oversixtynine <- weekly_totals_complete_weeks[weekly_totals_complete_weeks$SERIOUS_INJURIES > less_than_95_nbinom, ] #gives us 6 weeks
percentofweeksneg <- length(oversixtynine$WEEK)/length(weekly_totals_complete_weeks$WEEK) 
print(percentofweeksneg)
#2.3%
#much closer to 5%.


#Question 5

cell_phone_crashes <- crashes_copy[(crashes_copy$PRIM_CONTRIBUTORY_CAUSE == 'TEXTING' | 
                                      crashes_copy$PRIM_CONTRIBUTORY_CAUSE == 'CELL PHONE USE OTHER THAN TEXTING') & 
                                     !is.na(crashes_copy$SERIOUS_INJURIES) &
                                     crashes_copy$SERIOUS_INJURIES > 0, ]
# Sample size
total_serious_injuries <- sum(crashes_copy$SERIOUS_INJURIES > 0, na.rm = TRUE)

# Number of crashes with serious injuries or deaths caused by cell phone use
x <- nrow(cell_phone_crashes)

#normal approximation

# Proportion of such crashes
p_hat <- x / total_serious_injuries

# Z-value for 95% one-sided confidence interval
z_value <- qnorm(0.95)

# Margin of error
margin_of_error <- z_value * sqrt((p_hat * (1 - p_hat)) / total_serious_injuries)

# Upper bound of confidence interval
upper_bound <- p_hat + margin_of_error

# Print the one-sided confidence interval (lower bound is 0)
approx_normal_CI <- c(0, upper_bound)
cat("Upper bound for approximate normal distribution", upper_bound, "\n")



# Simulate a binomial distribution based on the observed proportion
set.seed(123)  # For reproducibility
simulated_data <- rbinom(10000, total_serious_injuries, p_hat)

# Perform the KS test to compare observed data to the binomial distribution
ks_result <- ks.test(x = x, y = simulated_data)

# Print KS test results
print(ks_result)

# Interpret the result
if (ks_result$p.value > 0.05) {
  cat("The KS test does not reject the null hypothesis. The observed data fits the binomial distribution well.\n")
} else {
  cat("The KS test rejects the null hypothesis. The observed data does not fit the binomial distribution well.\n")
}


# Exact one-sided 95% confidence interval using binom.test
result <- binom.test(x, total_serious_injuries, conf.level = 0.95, alternative = "less")  # "less" for one-sided upper bound

# Extract the confidence interval
exact_upper_bound <- result$conf.int[2]

# Print the one-sided confidence interval (lower bound is 0)
exact_CI <- c(0, exact_upper_bound)
cat("Upper bound for exact distribution", exact_CI, "\n")


