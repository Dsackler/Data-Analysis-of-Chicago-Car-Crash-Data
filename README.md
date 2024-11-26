# Analyzing Chicago Vehicle Crash Data

The below code analyzes the City of Chicago’s vehicle crash data, which can be accessed here:  
[City of Chicago Traffic Crash Data](https://data.cityofchicago.org/Transportation/Traffic-Crashes-Crashes/85ca-t3if/about_data)

## Pre-Processing

**Question:** How was the crashes dataset prepared for analysis?  

&nbsp;&nbsp;&nbsp;&nbsp; I began by importing the crashes dataset into R using the CSV import feature and created a new column to represent the number of serious injuries for each crash. This was achieved by aggregating `INJURIES_FATAL` and `INJURIES_INCAPACITATING` in the dataset. I ensured that complete weeks were defined as spanning from Sunday to Saturday and then aggregated the number of serious injuries for each complete week. This pre-processing work was completed prior to analyzing the data.

---

## Analyzing the Distribution of the Data

**Question:** How well does the Poisson Distribution model the weekly crash data?  

&nbsp;&nbsp;&nbsp;&nbsp; I fitted a Poisson Distribution to the data using Maximum Likelihood Estimation, obtaining a parameter estimate of λ=46.792 with a standard error of 0.424. Running the Kolmogorov-Smirnov (K-S) test on this Poisson distribution parameter estimate, with a significance threshold of α=0.01, yielded a p-value of 2.55×10^(−6) < 0.01. This allowed me to reject the null hypothesis that the crash data can be adequately modeled by a Poisson Distribution.

&nbsp;&nbsp;&nbsp;&nbsp; The p-value indicates that, under a Poisson Distribution, a sample as unusual as the given weekly crash data would occur only 0.000255% of the time, far below the 1% threshold needed to fail to reject the null hypothesis.

&nbsp;&nbsp;&nbsp;&nbsp; I also overlaid the theoretical counts from the best-fitting Poisson Distribution on a histogram of the weekly crash data. Visual inspection showed significant discrepancies, with the Poisson Distribution either overshooting or undershooting the observed values. This confirmed that the Poisson Distribution is not a good fit for the data.

---

## The Negative Binomial Distribution as a Better Alternative

**Question:** What alternative model better explains the weekly crash data, and why?  

&nbsp;&nbsp;&nbsp;&nbsp; I explored the Negative Binomial Distribution as an alternative model for the weekly crash data. This approach was motivated by the observed overdispersion in the data, where the variance (139.7) is significantly greater than the mean (47.07). The Poisson Distribution assumes equal mean and variance, making it unsuitable for data with such disparity.

&nbsp;&nbsp;&nbsp;&nbsp; Using the Negative Binomial Distribution, I obtained parameter estimates of size = 20.54 with a standard error of 2.65 and μ = 46.79 with a standard error of 0.76. The K-S test, with α=0.01, yielded a p-value of 0.0426 > 0.010, leading me to fail to reject the null hypothesis. This indicates that a sample similar to the weekly crash data would occur more than 4% of the time under the Negative Binomial Distribution, making it a suitable model.

&nbsp;&nbsp;&nbsp;&nbsp; I overlaid the theoretical counts from the best-fitting Negative Binomial Distribution on the weekly crash data histogram. The theoretical counts matched the observed values closely, further confirming that the Negative Binomial Distribution is a good fit for the data.

---

## Explaining the Top 5% of Weekly Serious Injuries

**Question:** How well do the Poisson and Negative Binomial Distributions explain the extreme weekly serious injuries?  

&nbsp;&nbsp;&nbsp;&nbsp; I used the cumulative distribution functions (CDFs) of both distributions to assess the percent of weeks where serious injuries are so high that they would occur only 5% of the time.

&nbsp;&nbsp;&nbsp;&nbsp; Under the Poisson Distribution, I found that 16.9% of weeks had extreme serious injuries, significantly higher than the expected 5%. This result aligns with the K-S test result (p-value = 2.55×10^(−6)) that rejected the Poisson model.

&nbsp;&nbsp;&nbsp;&nbsp; In contrast, under the Negative Binomial Distribution, 2.9% of weeks were classified as extreme, which is close to the expected 5%. The K-S test for the Negative Binomial Distribution yielded a p-value of 0.042, which supports the conclusion that the Negative Binomial model is a better fit for the data.

---

## Confidence Interval for Texting-Related Injuries

**Question:** What is the confidence interval for the proportion of serious injuries related to texting?  

&nbsp;&nbsp;&nbsp;&nbsp; After filtering the data to include only serious injuries related to texting, I calculated a 95% one-sided confidence interval using both normal approximation and exact methods.

&nbsp;&nbsp;&nbsp;&nbsp; Using the normal approximation, assuming that the proportion of serious injuries is a random variable with μ=0 and σ=1, the confidence interval was [0, 0.003289636]. Using the exact method, I simulated data from various distributions and found the Binomial Distribution to be the best fit, confirmed by a K-S test (p-value = 0.9764 > 0.010). With the Binomial Distribution, the exact confidence interval was [0, 0.003450642].

&nbsp;&nbsp;&nbsp;&nbsp; This indicates a confidence of 95% that the true proportion of people seriously injured under the texting category falls between 0 and 0.0034 when a Binomial Distribution is fit to the data.
