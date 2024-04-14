# simulate data for serial mediation 
set.seed(123456789)
n <- 5000
D <- rnorm(n)

# parameters 
eqn2 <- list(a21 = 1, b21 = 0.2)
eqn4 <- list(a31 = 1, b31 = 0.3, g = 0.4)
eqn5 <- list(a32 = 1, b32 = 0.5, b41 = 0.6, b42 = 0.7)

# simulate M1 
U <- rnorm(n)
V2 <- rnorm(n)
e2 <- V2
M1 <- eqn2$a21 + eqn2$b21*D + e2

# simulate M2: M2 is exogenous
V4 <- rnorm(n, 0, 0.5*exp(D))
e4 <- U + V4 
M2 <- eqn4$a31 + eqn4$b31*D + eqn4$g*M1 + e4

# simulate Y 
V5 <- rnorm(n)
e5 <- U + V5
Y <- eqn5$a32 + eqn5$b32*D + eqn5$b41*M1 + eqn5$b42*M2 + e5

# bias corrections to get b42
CIV2 <- lm(M2~D+M1)$residuals*(D-mean(D))
M2hat <- predict(lm(M2~D+M1+CIV2))

summary(lm(Y~D+M1+M2hat))
