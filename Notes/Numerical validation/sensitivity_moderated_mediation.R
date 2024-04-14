
# simulate data 
set.seed(123456789)
n <- 5000

# simulate IVs
D <- rnorm(n)
Z <- rnorm(n,0.5,1)

# simulate errors 
e2 <- 0.5*rnorm(n)
e3 <- 0.5*e2 + 0.2*rnorm(n)

# re-centered e2 and e3
e2 <- e2-mean(e2)
e3 <- e3-mean(e3)

# set the coefficients and get M and Y
b_m <- list(a2 = 1, b21 = 0.5, b22 = 0.5, g2 = 0.5)
M <- b_m$a2 + b_m$b21*D + b_m$b22*D*Z + b_m$g2*Z + e2

b_y <- list(a3 = 1, b31 = 0.1, b32 = 0.2, 
            b41 = 0.3, b42 = 0.4, g3 = 0.5)
Y <- b_y$a3 + b_y$b31*D + b_y$b32*D*Z + 
  b_y$b41*M + b_y$b42*M*Z + b_y$g3*Z + e3

# pack into a data frame 
data <- data.frame(D = D, Z = Z, M = M, Y = Y)

# getting two matrix 
X1 <- cbind(rep(1,n), D, Z, D*Z)
X2 <- cbind(M, M*Z)
X <- cbind(X1,X2)

# calculate the co-variance matrix
Q11 <- t(X1)%*%X1/n
Q12 <- t(X1)%*%X2/n
Q21 <- t(X2)%*%X1/n
Q22 <- t(X2)%*%X2/n

Q22.1 <- Q22 - Q21%*%solve(Q11)%*%Q12

# get the estimated coefficients
bhat <- solve(t(X)%*%X)%*%t(X)%*%Y
hb4 <- bhat[5:6]

# get the bias 
bias <- solve(Q22.1)%*%cov(X2,e3)

# get the true value 
b4 <- hb4 - bias

# checking the equations (Eqn 24)
e1 <- lm(Y~D*Z+I(D*(Z^2))+I(Z^2),data)
e1 <- e1$residuals

# checking the first equation 
x <- b4[1] + mean(Z)*b4[2]
Q <- solve(Q22.1)
q1 <- Q[1,1] + Q[1,2]*mean(Z)
q2 <- Q[2,1] + Q[2,2]*mean(Z)
s23 <- (hb4[1]+hb4[2]*mean(Z)-x)/(q1+q2*mean(Z))
b42 <- hb4[2]-q2*s23
eq1 <- c((x^2+b42^2*var(Z))*var(e2)+var(e3)+2*x*cov(e2,e3),
         var(e1))

# checking the second equation 
eq2 <- c(x*var(e2)+cov(e2,e3),cov(e1,e2))


