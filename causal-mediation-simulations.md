Causal Mediation Simulations
================
Xi Chen
2023-09-24

# Sensitivity Analysis

## Setup

This section shows an example of sensitivity analysis using a dataset
from an experiment of AR usage on product returns. The treatment $D$ is
AR vs. images in online purchases, the mediator $M$ is product fit
uncertainty, measured by a 7-point Likert scale, and the outcome $Y$ is
the product return intentions, measured by a 100-point scale.

The sensitivity analysis does not add addition estimation costs. We can
use the bootstrapping procedure and save a few values at each bootstrap
iteration:

- $\beta_2$: the coefficient of $D$ of the regression $M \sim D$.
- $\sigma_1$: the standard deviation of the residual of the regression
  $Y \sim D$.
- $\sigma_2$: the standard deviation of the residual of the regression
  $M \sim D$.
- $\tilde{\rho}$: the correlation between the two residuals of
  $Y \sim D$ and $M \sim D$.

The formula for calculating the bias-corrected average causal mediation
effect (ACME, a.k.a. indirect effect or $\beta_2\beta_4$) is:
$$ ACME = \dfrac{\beta_2\sigma_1}{\sigma_2}\left[\tilde{\rho}-\rho\sqrt{\dfrac{1-\tilde{\rho}^2}{1-\rho^2}}\right]$$

First, define a function of ACME:

``` r
acme <- function(b2,sig1,sig2,trho,rho) {
  acme <- b2*sig1/sig2*(trho-rho*
                          sqrt((1-trho^2)/(1-rho^2)))
  return(acme)
}
```

With bootstrapped values of the parameters, we can apply the function
`acme()` and obtain the expected mean of ACME under different values of
$\rho$ and the 95% CI. For example, we can set values of $\rho$ from
-0.9 to 0.9 with a 0.01 interval. With the grid, we search for two
critical values of $\rho$: the value that statistically nullifies the
ACME (i.e., 95% CI containing 0) and the value that nullifies the ACME
in the limit (i.e., ACME becoming 0 in value).

## Results

First, we load the data `AR_data.xlsx` to the work space:

``` r
AR_data <- readxl::read_excel("AR_data.xlsx")
head(AR_data)
```

    ## # A tibble: 6 × 3
    ##   ar_condition return fit_uncertainty
    ##          <dbl>  <dbl>           <dbl>
    ## 1            1      0             1.6
    ## 2            1     90             5.4
    ## 3            0     35             4.2
    ## 4            1     60             3.6
    ## 5            1     34             4  
    ## 6            1     11             4.4

Suppose we run the bootstrap for 1,000 times. To store the results, we
first create a data frame to store the results:

``` r
nb <- 1000
a <- rep(0,nb)
result_lsem <- data.frame(b2 = a, sig1 = a, 
                          sig2 = a, trho = a)
rm(a)
```

Now we perform the bootstrapping and store the results:

``` r
# set seeds for replication
set.seed(123)

# start the bootstrapping
n <- dim(AR_data)[1]
for (i in 1:nb) {
  boot_AR_data <- AR_data[sample(1:n, n, replace = T),]
  reg1 <- lm(return ~ ar_condition, boot_AR_data)
  reg2 <- lm(fit_uncertainty ~ ar_condition, boot_AR_data)
  result_lsem[i,] <- c(reg2$coefficients[2],
                       sd(reg1$residuals),
                       sd(reg2$residuals),
                       cor(reg1$residuals, reg2$residuals))
}

head(result_lsem)
```

    ##           b2     sig1     sig2      trho
    ## 1 -0.9113725 33.85832 1.101199 0.3120900
    ## 2 -1.2316129 34.18578 1.091887 0.3866531
    ## 3 -0.4662281 34.00392 1.049309 0.4221012
    ## 4 -1.1695418 33.95158 1.091713 0.1895241
    ## 5 -0.9133952 36.18488 1.159313 0.4571265
    ## 6 -0.5647059 32.85685 1.030277 0.4645702

With the bootstrapping results, we can now do the sensitivity analysis,
assuming we set $\rho$ to -0.95 to +0.95 with a 0.01 interval.

``` r
#set the values of rho
rho <- seq(-0.95, 0.95, 0.01)

# create a data frame for the results
n_rho <- length(rho)
result_sensitivity <- data.frame(acme = rep(0,n_rho),
                                 acme_low = rep(0, n_rho),
                                 acme_up = rep(0,n_rho))

# calculate the values of acmes 
for (i in 1:n_rho) {
  acme_rho <- acme(result_lsem$b2,
                   result_lsem$sig1,
                   result_lsem$sig2,
                   result_lsem$trho,
                   rho[i])
  result_sensitivity[i,] <- c(mean(acme_rho),
                              quantile(acme_rho,c(0.025,0.975)))
}

result_sensitivity$rho <- rho
head(result_sensitivity)
```

    ##        acme   acme_low   acme_up   rho
    ## 1 -82.06524 -131.72457 -34.94506 -0.95
    ## 2 -75.40051 -120.88814 -32.20508 -0.94
    ## 3 -70.18034 -112.55488 -30.02608 -0.93
    ## 4 -65.93956 -105.69140 -28.21765 -0.92
    ## 5 -62.39927  -99.94528 -26.70794 -0.91
    ## 6 -59.38063  -95.04585 -25.42068 -0.90

Upon a closer examination, we can see the critical values as below:

``` r
result_sensitivity[c(96,122,140),]
```

    ##           acme   acme_low    acme_up          rho
    ## 96  -11.474140 -20.204030 -4.5618907 1.110223e-16
    ## 122  -5.226718 -12.019547  0.3829515 2.600000e-01
    ## 140  -0.105564  -6.158061  6.9880274 4.400000e-01

The ACME under the null hypothesis of no bias ($\rho=0$) is -11.71 (95%
CI: \[-20.18, -4.79\]). The first critical value of $\rho$ is 0.26,
where the 95% CI contains 0 and statistically nullifies ACME. To
quantitatively nullify the ACME, $\rho$ is equal to 0.44, where the ACME
becomes close to 0 (0.057). In a way, for this particular data, the
conventional analysis with LSEM is non-credible, as a mild level of
correlation 0.26 would statistically nullify the result.
