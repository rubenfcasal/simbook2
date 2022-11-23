# Extensiones del bootstrap uniforme {#modunif}




<!-- 
---
title: "Extensiones del bootstrap uniforme"
author: "Simulación Estadística (UDC)"
date: "Máster en Técnicas Estadísticas"
output: 
  bookdown::html_document2:
    pandoc_args: ["--number-offset", "9,0"]
    toc: yes 
    # mathjax: local            # copia local de MathJax, hay que establecer:
    # self_contained: false     # las dependencias se guardan en ficheros externos 
  bookdown::pdf_document2:
    keep_tex: yes
    toc: yes 
---

bookdown::preview_chapter("10-Bootstrap_ext.Rmd")
knitr::purl("10-Bootstrap_ext.Rmd", documentation = 2)
knitr::spin("10-Bootstrap_ext.R",knit = FALSE)

Pendiente: 
5. Métodos de remuestreo	
	5.1 Introducción al remuestreo
	5.2 Bootstrap uniforme
	5.4 Herramientas disponibles en R 
	5.3 Modificaciones del bootstrap uniforme
	  Deficiencias del bootstrap uniforme

Selección del estadístico
  Interesaría un estadístico pivotal
  Bootstrap percentil: invariante frente a transformaciones monótonas, aunque debería ser insesgada y con varianza independiente del parámetro
  Bootstrap básico o natural: varianza independiente del parámetro
  Boostrap estudentizado
  
Esto da pie a una de las consideraciones más importantes a la hora
de diseñar un buen método de remuestreo bootstrap: ha de procurarse que el bootstrap imite todas
las condiciones que cumple la población original.  
-->


***Work in progress***

---

El bootstrap uniforme (o naïve) es aquel en el que remuestreamos a
partir de la función de distribución empírica. Eso es muy razonable
cuando no tenemos ninguna información adicional sobre la función de
distribución poblacional, ya que la distribución empírica es el
estimador máximo verosímil no paramétrico de la función de distribución
poblacional. Sin embargo, cuando en el contexto en el que nos
encontremos conozcamos alguna propiedad adicional de dicha distribución
poblacional, entonces debemos incorporarla en el método de remuestreo,
dando lugar a otro método bootstrap que ya no debemos llamar uniforme o
naïve. Veremos algunos de ellos.

## Deficiencias del bootstrap uniforme {#deficien-unif}


## Bootstrap paramétrico {#modunif-boot-par}

Supongamos que sabemos que la función de distribución poblacional
pertenece a cierta familia paramétrica. Es decir $F=F_{\theta }$ para
algún vector $d$-dimensional $\theta \in \Theta$. En ese caso parece
lógico estimar $\theta$ a partir de la muestra (denotemos
$\hat{\theta}$ un estimador de $\theta$, por ejemplo el de máxima
verosimilitud) y obtener remuestras de $F_{\hat{\theta}}$ no de $F_n$.
Entonces, el bootstrap uniforme se modifica de la siguiente forma, dando
lugar al llamado bootstrap paramétrico:

1.  Dada la muestra
    $\mathbf{X}=\left( X_1,\ldots ,X_n \right)$, calcular
    $\hat{\theta}$

2.  Para cada $i=1,\ldots ,n$ arrojar $X_i^{\ast}$ a partir de
    $F_{\hat{\theta}}$

3.  Obtener $\mathbf{X}^{\ast}=\left( X_1^{\ast},\ldots
    ,X_n^{\ast} \right)$

4.  Calcular $R^{\ast}=R\left( \mathbf{X}^{\ast},F_{\hat{\theta}} \right)$

Así utilizaremos las distribución en el remuestreo de $R^{\ast}$ para
aproximar la distribución en el muestreo de $R$. Lógicamente, cuando no
sea posible obtener una expresión explícita para la distribución
bootstrap de $R^{\ast}$ utilizaremos una aproximación de Monte Carlo de
la misma:

1. Dada la muestra
$\mathbf{X}=\left( X_1,\ldots ,X_n \right)$, calcular
$\hat{\theta}$

2. Para cada $i=1,\ldots ,n$ arrojar $X_i^{\ast}$ a partir de
$F_{\hat{\theta}}$

3. Obtener $\mathbf{X}^{\ast}=\left( X_1^{\ast},\ldots
,X_n^{\ast} \right)$

4. Calcular
$R^{\ast}=R\left( \mathbf{X}^{\ast},F_{\hat{\theta}
} \right)$

5. Repetir $B$ veces los pasos 2-4 para obtener las réplicas bootstrap
$R^{\ast (1)}$, $\ldots$, $R^{\ast (B)}$

6. Utilizar esas réplicas bootstrap para aproximar la distribución en el
muestreo de $R$

## Bootstrap suavizado {#modunif-boot-suav}

## Bootstrap basado en modelos {#boot-reg}

En ocasiones nos pueden interesar modelos semiparamétricos, en los que se asume una componente paramétrica pero no se especifica por completo la distribución de los datos. 
Una de las situaciones más habituales es en regresión, donde se puede considerar un modelo para la tendencia pero sin asumir una forma concreta para la distribución del error.

Nos centraremos en el caso de regresión y consideraremos como base el siguiente modelo general: 
\begin{equation} 
  Y = m(\mathbf{X}) + \varepsilon,
  (\#eq:modelogeneral)
\end{equation}
donde $Y$ es la respuesta, $\mathbf{X}=(X_1, X_2, \ldots, X_p)$ es el vector de variables explicativas, $m(\mathbf{x}) = E\left( \left. Y\right\vert_{\mathbf{X}=\mathbf{x}} \right)$ es la media condicional, denominada función de regresión (o tendencia), y $\varepsilon$ es un error aleatorio de media cero y varianza $\sigma^2$, independiente de $\mathbf{X}$ (errores homocedásticos independientes).

Supondremos que el objetivo es, a partir de una muestra:
$$\left\{ \left( X_{1i}, \ldots, X_{pi}, Y_{i} \right)  : i = 1, \ldots, n \right\},$$
realizar inferencias sobre la distribución condicional 
$\left.Y \right\vert_{\mathbf{X}=\mathbf{x}}$.

El modelo \@ref(eq:modelogeneral) se corresponde con el denominado *diseño aleatorio*, mas general.
Alternativamente se podría asumir que los valores de las variables explicativas no son aleatorios (por ejemplo han sido fijados por el experimentador), hablaríamos entonces de *diseño fijo*.
Para realizar inferencias sobre modelos de regresión con errores homocedásticos se podrían emplear dos algoritmos bootstrap (e.g. [Canty, 2002](http://cran.fhcrc.org/doc/Rnews/Rnews_2002-3.pdf), y subsecciones siguientes).
El primero consistiría en utilizar directamente bootstrap uniforme, remuestreando las observaciones, y sería adecuado para el caso de diseño aleatorio.
La otra alternativa, que podría ser más adecuada para el caso de diseño fijo, sería lo que se conoce como *remuestreo residual*, *remuestreo basado en modelos* o *bootstrap semiparamétrico*.
En esta aproximación se mantienen fijos los valores de las variables explicativas y se remuestrean los residuos.
Una de las aplicaciones del bootstrap semiparamétrico es el contraste de hipótesis en regresión, que se tratará en la Sección \@ref(contrastes-semiparametricos). 

Se puede generalizar el modelo \@ref(eq:modelogeneral) de diversas formas, por ejemplo asumiendo que la distribución del error depende de $X$ únicamente a través de la varianza (error heterocedástico independiente).
En este caso se suele reescribir como:
$$Y = m(\mathbf{X}) + \sigma(\mathbf{X}) \varepsilon,$$
siendo $\sigma^2(\mathbf{x}) = Var\left( \left. Y\right\vert_{\mathbf{X}=\mathbf{x}} \right)$ la varianza condicional y suponiendo adicionalmente que $\varepsilon$ tiene varianza uno.
Se podría modificar el bootstrap residual para este caso pero habría que modelizar y estimar la varianza condicional.
Alternativamente se podría emplear el denominado  *Wild Bootstrap* que se describirá en la Sección \@ref(wild-bootstrap) para el caso de modelos de regresión no paramétricos.

En esta sección nos centraremos en el caso de regresión lineal:
$$m_{\boldsymbol{\beta}}(\mathbf{x}) =  \beta_{0} + \beta_{1}X_{1} + \beta_{2}X_{2} + \cdots + \beta_{p}X_{p},$$ 
siendo $\boldsymbol{\beta} = \left(  \beta_{0}, \beta_{1}, \ldots, \beta_{p} \right)^{T}$ el vector de parámetros (desconocidos).
Su estimador mínimo cuadrático es:
$$\boldsymbol{\hat{\beta}} = \left( X^{T}X\right)^{-1}X^{T}\mathbf{Y},$$
siendo $\mathbf{Y} = \left( Y_{1}, \ldots, Y_{n} \right)^{T}$ el vector de observaciones de la variable $Y$ y $X$ la denominada *matriz del diseño* de las variables regresoras, cuyas filas son los valores observados de las variables explicativas.


En regresión lineal múltiple, bajo las hipótesis estructurales del modelo de normalidad y homocedásticidad, se dispone de resultados teóricos que permiten realizar inferencias sobre características de la distribución condicional. Si alguna de estas hipótesis no es cierta se podrían emplear aproximaciones basadas en resultados asintóticos, pero podrían ser poco adecuadas para tamaños muestrales no muy grandes. Alternativamente se podría emplear bootstrap.
Con otros métodos de regresión, como los modelos no paramétricos descritos en el Capítulo \@ref(npreg), es habitual emplear bootstrap para realizar inferencias sobre la distribución condicional.

En esta sección se empleará el conjunto de datos `Prestige` del paquete `carData`, considerando como variable respuesta `prestige` (puntuación de ocupaciones obtenidas a partir de una encuesta) y como variables explicativas: `income` (media de ingresos en la ocupación) y `education` (media de los años de educación).
Para ajustar el correspondiente modelo de regresión lineal podemos emplear el siguiente código:


```r
data(Prestige, package = "carData")
# ?Prestige
modelo <- lm(prestige ~ income + education, data = Prestige)
summary(modelo)
```

```
## 
## Call:
## lm(formula = prestige ~ income + education, data = Prestige)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -19.4040  -5.3308   0.0154   4.9803  17.6889 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept) -6.8477787  3.2189771  -2.127   0.0359 *  
## income       0.0013612  0.0002242   6.071 2.36e-08 ***
## education    4.1374444  0.3489120  11.858  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 7.81 on 99 degrees of freedom
## Multiple R-squared:  0.798,	Adjusted R-squared:  0.7939 
## F-statistic: 195.6 on 2 and 99 DF,  p-value: < 2.2e-16
```

Como ejemplo, consideraremos que el objetivo es realizar inferencias sobre el coeficiente de determinación ajustado:


```r
res <- summary(modelo)
names(res)
```

```
##  [1] "call"          "terms"         "residuals"     "coefficients" 
##  [5] "aliased"       "sigma"         "df"            "r.squared"    
##  [9] "adj.r.squared" "fstatistic"    "cov.unscaled"
```

```r
res$adj.r.squared
```

```
## [1] 0.7939201
```

### Remuestreo de las observaciones {#boot-unif-reg}

Como ya se comentó, en regresión podríamos emplear bootstrap uniforme multidimensional para el caso de diseño aleatorio, aunque hay que tener en cuenta que con este método la distribución en el remuestreo de $\left. Y^{\ast}\right\vert _{X^{\ast}=X_i}$ es degenerada.

En este caso, podríamos realizar inferencias sobre el coeficiente de determinación ajustado empleando el siguiente código:


```r
library(boot)

case.stat <- function(data, i) {
  fit <- lm(prestige ~ income + education, data = data[i, ])
  summary(fit)$adj.r.squared
}

set.seed(1)
boot.case <- boot(Prestige, case.stat, R = 1000)
boot.case
```

```
## 
## ORDINARY NONPARAMETRIC BOOTSTRAP
## 
## 
## Call:
## boot(data = Prestige, statistic = case.stat, R = 1000)
## 
## 
## Bootstrap Statistics :
##      original      bias    std. error
## t1* 0.7939201 0.002495631   0.0315275
```

```r
# plot(boot.case)
boot.ci(boot.case, type = c("basic", "perc", "bca"))
```

```
## BOOTSTRAP CONFIDENCE INTERVAL CALCULATIONS
## Based on 1000 bootstrap replicates
## 
## CALL : 
## boot.ci(boot.out = boot.case, type = c("basic", "perc", "bca"))
## 
## Intervals : 
## Level      Basic              Percentile            BCa          
## 95%   ( 0.7331,  0.8570 )   ( 0.7308,  0.8547 )   ( 0.7203,  0.8497 )  
## Calculations and Intervals on Original Scale
```


### Bootstrap residual {#boot-residual}

Como ya se comentó, en el caso de diseño fijo podemos realizar un remuestreo de los residuos:
$$\mathbf{r} = \mathbf{Y} - X\hat{\mathbf{\beta}} = \mathbf{Y} - \hat{\mathbf{Y}}$$
obteniéndose las réplicas bootstrap:
$$\mathbf{Y}^{\ast} = \hat{\mathbf{Y}} + \mathbf{r}^{\ast}.$$
Por ejemplo, adaptando el código en Canty (2002) para este conjunto de datos, podríamos emplear:


```r
pres.dat <- Prestige
pres.dat$fit <- fitted(modelo)
pres.dat$res <- residuals(modelo)

mod.stat <- function(data, i) {
    data$prestige <- data$fit + data$res[i]
    fit <- lm(prestige ~ income + education, data = data)
    summary(fit)$adj.r.squared
}

set.seed(1)
boot.mod <- boot(pres.dat, mod.stat, R = 1000)
boot.mod
```

```
## 
## ORDINARY NONPARAMETRIC BOOTSTRAP
## 
## 
## Call:
## boot(data = pres.dat, statistic = mod.stat, R = 1000)
## 
## 
## Bootstrap Statistics :
##      original      bias    std. error
## t1* 0.7939201 0.004401997  0.02671996
```

```r
# plot(boot.mod)
boot.ci(boot.mod, type = c("basic", "perc", "bca"))
```

```
## BOOTSTRAP CONFIDENCE INTERVAL CALCULATIONS
## Based on 1000 bootstrap replicates
## 
## CALL : 
## boot.ci(boot.out = boot.mod, type = c("basic", "perc", "bca"))
## 
## Intervals : 
## Level      Basic              Percentile            BCa          
## 95%   ( 0.7407,  0.8464 )   ( 0.7415,  0.8471 )   ( 0.7244,  0.8331 )  
## Calculations and Intervals on Original Scale
## Some BCa intervals may be unstable
```

Sin embargo, la variabilidad de los residuos no reproduce la de los verdaderos errores, por lo que podría ser preferible (especialmente si el tamaño muestral es pequeño) emplear la modificación descrita en Davison y Hinkley (1997, Alg. 6.3, p. 271).
Teniendo en cuenta que:
$$\mathbf{r} = \left( I - H \right)\mathbf{Y},$$
siendo $H = X\left( X^{T}X\right)^{-1}X^{T}$ la matriz de proyección.
La idea es remuestrear los residuos reescalados (de forma que su varianza sea constante) y centrados $e_i - \bar{e}$, siendo:
$$e_i = \frac{r_i}{\sqrt{1 - h_{ii}}},$$
donde $h_{ii}$ es el valor de influencia o leverage, el elemento $i$-ésimo de la diagonal de $H$.

En `R` podríamos obtener estos residuos mediante los comandos^[Para reescalar los 
residuos de un modelo `gam` del paquete `mgcv`, como no implementa un método `hatvalues()`, 
habrá que emplear `influence.gam()` (o directamente `modelo.gam$hat`).]:


```r
pres.dat$sres <- residuals(modelo)/sqrt(1 - hatvalues(modelo))
pres.dat$sres <- pres.dat$sres - mean(pres.dat$sres)
```

Sin embargo puede ser más cómodo emplear la función `Boot()` del paquete `car` (que internamente llama a la función `boot()`), 
como se describe en el apéndice "Bootstrapping Regression Models in R" del libro "An R Companion to Applied Regression" de Fox y Weisberg (2018), disponible [aquí](https://socialsciences.mcmaster.ca/jfox/Books/Companion/appendices/Appendix-Bootstrapping.pdf).

Esta función es de la forma:

```r
Boot(object, f = coef, labels = names(f(object)), R = 999, 
     method = c("case", "residual"))
```
donde:

- `object`: es un objeto que contiene el ajuste de un modelo de regresión.

- `f`: es la función de estadísticos (utilizando el ajuste como argumento).

- `method`: especifíca el tipo de remuestreo: remuestreo de observaciones (`"case"`)
  o de residuos (`"residual"`), empleando la modificación descrita anteriormente.


\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:boot-car"><strong>(\#exr:boot-car) </strong></span></div>\EndKnitrBlock{exercise}
Emplear la función `Boot()` del paquete `car` para hacer inferencia sobre 
el coeficiente de determinación ajustado del modelo de regresión lineal 
que explica `prestige` a partir de `income` y `education` 
(obtener una estimación del sesgo y de la predicción,
y una estimación por intervalo de confianza de este estadístico).


```r
library(car)

# set.seed(DNI)
# ...
```
