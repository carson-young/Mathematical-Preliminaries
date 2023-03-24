Instrumental variables estimation and two-stage least squares
================
*Carson Young*

March 2023

Consider the standard linear regression model with a single regressor.
Let $\beta_1$ be the causal effect of $X$ on $Y$. The standard linear
regression model relating the dependent variable $Y_i$ and regressor
$X_i$ is

$$ Y_i = \beta_0+\beta_1X_i+u_i,\: i=1,...,n $$

where $u_i$ is the error term representing omitted factors that
determine $Y_i$.

When a single regressor $X_i$, is correlated with the error $u_i$, – the
ordinarly least squares(OLS) estimator is inconsistent. That is the
estimator does not converge to the true parameter value as sample size
increases. This correlation can stem from various sources:

1.  Omitted variables
2.  Errors in variables (measurement errors in the regressors)
3.  Simultaneous causality

When one or more of the above occurs. The situation is refereed to as
endogenous.

Intuitively, IVs are used when an explanatory variable of interest is
correlated with the error term, in which case ordinary least squares and
ANOVA give biased results.

Variables correlated with the error term are called *endogenous*
variables

Variables uncorrelated with the error term are called *exogenous*
variables

## Instrument Variable

A valid instrument $Z$ is related with the explanatory variable but has
no independent effect on the dependent variable, allowing a researcher
to uncover the causal effect of the explanatory variable on the
dependent variable. Mathematically,

1.  Instrument relevance: $corr(Z_i,X_i) \neq 0$
2.  Instrument exogeneity: $corr(Z_i,U_i) = 0$

## Two Stage Least Squares Estimnator

If an instrument $Z$ satisfies the two conditions, we can estimate
$\beta_1$

### First Stage

Linking $X$ andf

$$X_i = \underbrace{\pi_0+\pi_1Z_1}_{\text{uncorrelated with the error } u_i}+\underbrace{v_i}_{\text {may be correlated with }u_i} $$

The idea is to use the problem free component of $X_i$ $\pi_0+\pi_1Z_1$
and ignore $v_i$.

We now simply find the usual OLS estimate for $\pi_0$ and $\pi_1$ and
estimate $X_i$

$$\hat{X_i} = \hat{\pi_0}+\hat{\pi_1}Z_1$$

### Second Stage

Run a standard linear regression model relating the dependent variable
$Y_i$ and regressor $\hat{X_i}$. i.e we use $\hat{X_i}$ instead of $X_i$
previously.

$$ Y_i = \beta_0+\beta_1\hat{X_i}+u_i,\: i=1,...,n $$

Performing OLS yields estimators for $\beta_0$ and $\beta_1$. For
clarity we denote them as ${\hat{\beta_0}^{TSLS}}$ and
${\hat{\beta_1}^{TSLS}}$

## General Two Stage Least Squares Estimnator

Now we consider the case where there is an arbitrary number of
regressors.

$$ Y_i = \beta_0+\beta_1X_{1i}+\ldots +\beta_kX_{ki}+\beta_{k+1}W_{1i}+\beta_{k+r}W_{ri}+u_i,\: i=1,...,n $$

- $\beta_0$, $\beta_1$,…,$\beta_{k+r}$ are the unknown regression
  coefficients
- $X_{1i},...,X_{ki}$ are $k$ endogenous regressors, which could be
  correlted with the error $u_i$
- $W_{1i},...,W_{ki}$ are $r$ exogenous regressors, which could be
  uncorrelted with the error $u_i$
- $Z_{1i},...,W_{mi}$ are $m$ instrument variables

There must be at least as many instrumental variables as regressors.
Namely, $m\geq k$

### Case with a single endogenous regressor

$$ Y_i = \beta_0+\beta_1X_{i}+\beta_{2}W_{1i}+\ldots+\beta_{1+r}W_{ri}+u_i,\: i=1,...,n $$
First stage is to relate $X_i$ with the instruments $Z_i$ and exogenous
variables $W_i$ and perform OLS.
$$X_i = \pi_0+\pi_1Z_{1i}+\ldots+\pi_mZ_{mi}+\pi_{m+1}W_{1i}+\ldots+\pi_{m+r}W_{ri}+v_i$$
Predicted values are $\hat{X_i}$

Second Stage regress $Y_i$ on the predicted values
$$ Y_i = \beta_0+\beta_1\hat{X_{i}}+\beta_{2}W_{1i}+\ldots+\beta_{1+r}W_{ri}+u_i,\: i=1,...,n $$
Performing OLS will yield the desired TSLS estimators.

### Conditions on valid instruments

## Example- Demand for Cigarettes

CigarettesSW data set contains cigarette consumption for the 48
continental US States from 1985–1995.As always we look at some basic
statistics to get an overview of the data.

``` r
library(AER)
data("CigarettesSW")
summary(CigarettesSW)
```

    ##      state      year         cpi          population           packs       
    ##  AL     : 2   1985:48   Min.   :1.076   Min.   :  478447   Min.   : 49.27  
    ##  AR     : 2   1995:48   1st Qu.:1.076   1st Qu.: 1622606   1st Qu.: 92.45  
    ##  AZ     : 2             Median :1.300   Median : 3697472   Median :110.16  
    ##  CA     : 2             Mean   :1.300   Mean   : 5168866   Mean   :109.18  
    ##  CO     : 2             3rd Qu.:1.524   3rd Qu.: 5901500   3rd Qu.:123.52  
    ##  CT     : 2             Max.   :1.524   Max.   :31493524   Max.   :197.99  
    ##  (Other):84                                                                
    ##      income               tax            price             taxs       
    ##  Min.   :  6887097   Min.   :18.00   Min.   : 84.97   Min.   : 21.27  
    ##  1st Qu.: 25520384   1st Qu.:31.00   1st Qu.:102.71   1st Qu.: 34.77  
    ##  Median : 61661644   Median :37.00   Median :137.72   Median : 41.05  
    ##  Mean   : 99878736   Mean   :42.68   Mean   :143.45   Mean   : 48.33  
    ##  3rd Qu.:127313964   3rd Qu.:50.88   3rd Qu.:176.15   3rd Qu.: 59.48  
    ##  Max.   :771470144   Max.   :99.00   Max.   :240.85   Max.   :112.63  
    ## 

``` r
# compute real per capita prices
CigarettesSW$rprice <- with(CigarettesSW, price / cpi)

#  compute the sales tax
CigarettesSW$salestax <- with(CigarettesSW, (taxs - tax) / cpi)

# generate a subset for the year 1995
c1995 <- subset(CigarettesSW, year == "1995")
```

``` r
cor(CigarettesSW[, sapply(CigarettesSW, is.numeric)])
```

    ##                    cpi  population      packs     income        tax      price
    ## cpi         1.00000000  0.04758017 -0.4994643  0.2317893  0.6857145  0.9116556
    ## population  0.04758017  1.00000000 -0.2112834  0.9573113  0.1659856  0.1458604
    ## packs      -0.49946432 -0.21128337  1.0000000 -0.3317847 -0.6421176 -0.6524732
    ## income      0.23178932  0.95731126 -0.3317847  1.0000000  0.3372751  0.3375339
    ## tax         0.68571446  0.16598557 -0.6421176  0.3372751  1.0000000  0.8993727
    ## price       0.91165558  0.14586043 -0.6524732  0.3375339  0.8993727  1.0000000
    ## taxs        0.70412144  0.18891721 -0.6574167  0.3582307  0.9853330  0.9203278
    ## rprice      0.69228787  0.21419526 -0.7005665  0.3793241  0.9467849  0.9252452
    ## salestax    0.42384639  0.22754697 -0.4813715  0.3083566  0.5503316  0.6141228
    ##                  taxs     rprice   salestax
    ## cpi         0.7041214  0.6922879  0.4238464
    ## population  0.1889172  0.2141953  0.2275470
    ## packs      -0.6574167 -0.7005665 -0.4813715
    ## income      0.3582307  0.3793241  0.3083566
    ## tax         0.9853330  0.9467849  0.5503316
    ## price       0.9203278  0.9252452  0.6141228
    ## taxs        1.0000000  0.9688919  0.6810292
    ## rprice      0.9688919  1.0000000  0.7035012
    ## salestax    0.6810292  0.7035012  1.0000000

Note the high correlation between sales tax and price.

Suppose we are interested in the model

$$\ln(Q_i)=\beta_0+\beta_1\ln(P_i)+u_i$$ where $Q_i$ is the number of
cigarette packs per capital sold and $P_i$ is the after-tax average
price of cigarettes in state $i$.

Since price is correlated sales tax (which is not in the model), it is
sipped over to the error term. We have the perfect example to employ two
stage least sqaures.

``` r
# perform the first stage regression
model1 <- lm(log(rprice) ~ salestax, data = c1995)
summary(model1)
```

    ## 
    ## Call:
    ## lm(formula = log(rprice) ~ salestax, data = c1995)
    ## 
    ## Residuals:
    ##       Min        1Q    Median        3Q       Max 
    ## -0.221027 -0.044324  0.000111  0.063730  0.210717 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 4.616546   0.029108   158.6  < 2e-16 ***
    ## salestax    0.030729   0.004802     6.4 7.27e-08 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.09394 on 46 degrees of freedom
    ## Multiple R-squared:  0.471,  Adjusted R-squared:  0.4595 
    ## F-statistic: 40.96 on 1 and 46 DF,  p-value: 7.271e-08

``` r
pricepred <- model1$fitted.values
```

This gives predicted values for $P_i$
$$\widehat{\log(P_i)} = {4.62} + {0.031} SalesTax_i$$ Now we run stage
two

``` r
model2 <- lm(log(c1995$packs) ~ pricepred)
summary(model2)
```

    ## 
    ## Call:
    ## lm(formula = log(c1995$packs) ~ pricepred)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -0.63180 -0.15802  0.00524  0.13574  0.61434 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)   9.7199     1.8012   5.396  2.3e-06 ***
    ## pricepred    -1.0836     0.3766  -2.877  0.00607 ** 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.2264 on 46 degrees of freedom
    ## Multiple R-squared:  0.1525, Adjusted R-squared:  0.1341 
    ## F-statistic: 8.277 on 1 and 46 DF,  p-value: 0.006069

The final model is $$\ln(Q_i)=9.72-1.08\ln(P_i)$$

Note the standard errors reported for the second-stage regression, does
not take into account using predictions from the first-stage regression
as regressors in the second-stage regression.The errors are invalid.

Like everything, there is an R package that does it all.

``` r
model3 <- ivreg(log(packs) ~ log(rprice) | salestax, data = c1995)
summary(model3)
```

    ## 
    ## Call:
    ## ivreg(formula = log(packs) ~ log(rprice) | salestax, data = c1995)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -0.64619 -0.07732  0.02981  0.11283  0.41904 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)   9.7199     1.5141   6.420 6.79e-08 ***
    ## log(rprice)  -1.0836     0.3166  -3.422  0.00131 ** 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.1904 on 46 degrees of freedom
    ## Multiple R-Squared: 0.4011,  Adjusted R-squared: 0.3881 
    ## Wald test: 11.71 on 1 and 46 DF,  p-value: 0.001313

TSLS suggest demand for cigarettes are elastic. An 1% increase in price
reduceds consumption by 1.08%. Obviosuly common sense tells us something
is off.

Indeed, demand of cigareetes probably depends on income as well, but it
was not included in the model, so its effect is once again “spilled” to
the error term and not accounted for. Plausible that this TSLS model
estimate is biased

### Including income

state income, which impact the demand for cigarettes and correlate with
the sales tax. States with high personal income tend to generate tax
revenues by income taxes and less by sales taxes. Consequently, state
income should be included in the regression model as a exogenous
variable.

$$\log(Q_) = \beta_0 + \beta_1 \log(P_i) + \beta_2 \log(income_i) + u_i$$

``` r
# add rincome to the dataset
CigarettesSW$rincome <- with(CigarettesSW, income / population / cpi)

c1995 <- subset(CigarettesSW, year == "1995")
# estimate the model
model4 <- ivreg(log(packs) ~ log(rprice) + log(rincome) | log(rincome) + 
                    salestax, data = c1995)
summary(model4)
```

    ## 
    ## Call:
    ## ivreg(formula = log(packs) ~ log(rprice) + log(rincome) | log(rincome) + 
    ##     salestax, data = c1995)
    ## 
    ## Residuals:
    ##       Min        1Q    Median        3Q       Max 
    ## -0.611000 -0.086072  0.009423  0.106912  0.393159 
    ## 
    ## Coefficients:
    ##              Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)    9.4307     1.3584   6.943 1.24e-08 ***
    ## log(rprice)   -1.1434     0.3595  -3.181  0.00266 ** 
    ## log(rincome)   0.2145     0.2686   0.799  0.42867    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.1896 on 45 degrees of freedom
    ## Multiple R-Squared: 0.4189,  Adjusted R-squared: 0.3931 
    ## Wald test: 6.534 on 2 and 45 DF,  p-value: 0.003227

The final fitted model
$$\widehat{\log(Q_i)} = 9.42-1.14\log(P_i)+0.21\log(income_i)$$ We
should not trust our estimates naïvely. Checking the validity of the
instruments and knowledge of the domain will inform us whether this
model is appropriate.

## Bibliography

Stock, J. H., & Watson, M. W. (2019). *Introduction to econometrics,
Global edition.* Pearson Education.

Hanck, C., Arnold, M., Gerber, A., & Schmelzer, M. (2019). *Introduction
to Econometrics with R.* University of Duisburg-Essen.
