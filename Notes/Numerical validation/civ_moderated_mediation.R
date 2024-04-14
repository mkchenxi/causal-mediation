# simulate data 
set.seed(123456789)
n <- 50000

# simulate IVs
D <- rnorm(n)
Z <- rnorm(n,0.5,1)

# simulate errors
U <- rnorm(n)
V2 <- rnorm(n,0,0.5*exp(D))
V3 <- rnorm(n)
e2 <- U + V2
e3 <- 0.5*U + V3

# set the coefficients and get M and Y
b_m <- list(a2 = 1, b21 = 0.5, b22 = 0.5, g2 = 0.5)
M <- b_m$a2 + b_m$b21*D + b_m$b22*D*Z + b_m$g2*Z + e2

b_y <- list(a3 = 1, b31 = 0.1, b32 = 0.2, 
            b41 = -10, b42 = 0.4, g3 = 0.5)
Y <- b_y$a3 + b_y$b31*D + b_y$b32*D*Z + 
  b_y$b41*M + b_y$b42*M*Z + b_y$g3*Z + e3

# Naive regression results 
model.0 <- lm(Y~D+Z+D:Z+M+M:Z,data)
summary(model.0)

# the 2sls with the civ  
model.M <- lm(M~D*Z,data)
M_civ <- (D-mean(D))*model.M$residuals

model.11 <- lm(M~D+Z+D:Z+M_civ)
Mhat <- predict(model.11)

# the second regression of MZ: forbidden regression 
model.12 <- lm(I(M*Z)~D+Z+I(Z^2)+I(D*Z)+I(D*(Z^2))+M_civ)
MZhat <- predict(model.12)

model.12 <- lm(Y~D+Z+D:Z+Mhat+MZhat)
summary(model.12)
