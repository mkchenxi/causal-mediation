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
first create a data frame:

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

# Simulation for the Constructed IV Approach

This section runs the simulation for the constructed IV approach. The
data generating process follows what’s assumed in the constructed IV
approach. With the data generated, two estimation procedures are run: 1)
a direct regression of $Y \sim D + M$, and 2) the constructed IV
procedure. The comparison focuses on $\beta_4$, the coefficient of $M$,
as $\beta_2$ can be consistently estimated in both LSEM and the
constructed IV. The simulation is more of a “proof of concept.”

## Data-generating process

The data-generating process builds on the assumptions of the constructed
IV method for the triangular system:

$$
\begin{equation}
\begin{cases}
M & =\alpha_{2}+\beta_{2}D+e_{2}\\
Y & =\alpha_{3}+\beta_{3}D+\beta_{4}M+e_{3}
\end{cases}
\end{equation}
$$

The values of coefficients are as below:

- $\alpha_2=\alpha_3=1$.
- $\beta_2=1$ and $\beta_3=0.5$.
- $\beta_4=0.5$

The error terms $e_2$ and $e_3$ are generated with:

$$
\begin{equation}
\begin{cases}
e_{2} & =U+V_{2}\\
e_{3} & =0.5U+V_{3}
\end{cases}
\end{equation}
$$

By the assumptions of the constructed IV approach, $V_2$ is assumed to
be heteroskedastic with $D$. That is, the treatment group error
$V_2(D=1)$ has different variance from that of the control group
$V_2(D=0)$. In addition, $U$ and $V_3$ are homoskedastic (note that
$V_3$ needs not to be homoskedastic; here specified for simplicity).

The errors are simulated from the following distributions:

- $U$ and $V_3$ from $N(0,1)$.
- $V_2(D=1)$ from $N(0,2)$.
- $V_2(D=0)$ from $N(0,1)$.

The ratio of the standard deviations of $V_2(D=1)$ and $V_2(D=0)$
determines the extent of heteroskedasticity and the strength of the
constructed IV.

First, we simulate the treatment $D$ and the errors:

``` r
# the sample size
ns <- 5000

# simulate D
D <- c(rep(1,ns/2),rep(0,ns/2))

# simulate errors
U <- rnorm(ns)
V3 <- rnorm(ns)
V2 <- c(2*rnorm(ns/2),rnorm(ns/2))
```

With the treatment and the errors, we calculate the values of the
mediator and the outcome:

``` r
# calculate M and Y
M <- 1 + D + U + V2
Y <- 1 + 0.5*D + 0.5*M + 0.5*U + V3 

# pack into a data frame
data <- data.frame(D = D, M = M, Y = Y)
```

## Estimation

We first estimate $\beta_4$ with a direct regression of $Y ~ D + M$:

``` r
summary(lm(Y~D+M, data))
```

    ## 
    ## Call:
    ## lm(formula = Y ~ D + M, data = data)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -4.2225 -0.7391  0.0114  0.7298  3.2940 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 0.848160   0.023399   36.25   <2e-16 ***
    ## D           0.347472   0.031727   10.95   <2e-16 ***
    ## M           0.644151   0.008118   79.34   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.09 on 4997 degrees of freedom
    ## Multiple R-squared:  0.5913, Adjusted R-squared:  0.5911 
    ## F-statistic:  3614 on 2 and 4997 DF,  p-value: < 2.2e-16

The coefficient $\beta_4$ is overestimated with the direct regression.
Now we apply the constructed IV approach:

``` r
# first regress M ~ D
instrument <- lm(M~D, data)$residuals*(data$D-mean(data$D))

# use the instrument to run a 2SLS of Y ~ D + M
stage1 <- lm(data$M ~ data$D + instrument)
Mhat <- predict(stage1)

# with Mhat run a second stage regression 
stage2 <- lm(data$Y ~ data$D + Mhat)
summary(stage2)
```

    ## 
    ## Call:
    ## lm(formula = data$Y ~ data$D + Mhat)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -6.3752 -1.0828 -0.0058  1.0489  5.3061 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  0.98543    0.04361  22.599   <2e-16 ***
    ## data$D       0.46843    0.05206   8.997   <2e-16 ***
    ## Mhat         0.51304    0.02854  17.979   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.588 on 4997 degrees of freedom
    ## Multiple R-squared:  0.1324, Adjusted R-squared:  0.1321 
    ## F-statistic: 381.4 on 2 and 4997 DF,  p-value: < 2.2e-16

From this regression, we can see that the bias is corrected and the
estimation result is much closer the the true value 0.5.
