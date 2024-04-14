
# simulate data for serial mediation 
seed(123456789)
n <- 5000
D <- rnorm(n)

# parameters 
eqn2 <- list(a21 = 1, b21 = 0.2)
eqn4 <- list(a31 = 1, b31 = 0.3, g = 0.4)
eqn5 <- list(a32 = 1, b32 = 0.5, b41 = 0.6, b42 = 0.7)

# simulate errors and variables 
e2 <- rnorm(n)
M1 <- eqn2$a21 + eqn2$b21*D + e2
e4 <- 0.1*e2 + rnorm(n)
M2 <- eqn4$a31 + eqn4$b31*D + eqn4$g*M1 + e4

# get e3 and e5 and Y
e3 <- lm(M2~D)$residuals
e5 <- 0.2*e2 + 0.3*e3 + 0.5*rnorm(n)
Y <- eqn5$a32 + eqn5$b32*D + eqn5$b41*M1 + eqn5$b42*M2 + e5

# calculating the sd and correlations of errors
e1 <- lm(Y~D)$residuals
se <- list(s1 = sd(e1), 
           s2 = sd(e2), 
           s3 = sd(e3), 
           s5 = sd(e5))
rho <- list(r12 = cor(e1,e2), 
            r13 = cor(e1,e3),
            r23 = cor(e2,e3),
            r24 = cor(e2,e4),
            r25 = cor(e2,e5),
            r35 = cor(e3,e5))

# checking the gamma equation
abs(eqn4$g - se$s3/se$s2*(rho$r23-rho$r24*
                            sqrt((1-rho$r23^2)/(1-rho$r24^2))))

# checking the first equation in Eqn (31)
abs(rho$r12*se$s1 - eqn5$b41*se$s2 - 
      eqn5$b42*rho$r23*se$s3 - rho$r25*se$s5)

# checking the second equation in Eqn (31)
abs(rho$r13*se$s1 - eqn5$b41*rho$r23*se$s2 - 
      eqn5$b42*se$s3 - rho$r35*se$s5)

# check the third equation in Eqn (31)
abs(var(e1) - ((eqn5$b41^2)*var(e2)+(eqn5$b42^2)*var(e3) + var(e5)) - 
      2*eqn5$b41*eqn5$b42*cov(e2,e3) - 2*eqn5$b41*cov(e2,e5) - 
      2*eqn5$b42*cov(e3,e5))
