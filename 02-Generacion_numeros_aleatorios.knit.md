<!--

---
title: "Generaci�n de n�meros pseudoaleatorios"
author: "Simulaci�n Estad�stica (UDC)"
date: "M�ster en T�cnicas Estad�sticas"
output: 
  bookdown::html_document2:
    pandoc_args: ["--number-offset", "1,0"]
    toc: yes 
    # mathjax: local            # copia local de MathJax, hay que establecer:
    # self_contained: false     # las dependencias se guardan en ficheros externos 
  bookdown::pdf_document2:
    includes:
      in_header: preamble.tex
    keep_tex: yes
    toc: yes 
---

bookdown::preview_chapter("02-Generacion_numeros_aleatorios.Rmd")
knitr::purl("02-Generacion_numeros_aleatorios.Rmd", documentation = 2)
knitr::spin("02-Generacion_numeros_aleatorios.R",knit = FALSE)

PENDIENTE:
- Redactar ejemplo repetici�n de contrastes
-->

# Generaci�n de n�meros pseudoaleatorios {#gen-pseudo}




Como ya se coment�, los distintos m�todos de simulaci�n requieren disponer de secuencias de n�meros pseudoaleatorios que imiten las propiedades de generaciones independientes de una distribuci�n $\mathcal{U}(0,1)$. 
En primer lugar nos centraremos en el caso de los generadores congruenciales. A pesar de su simplicidad, podr�an ser adecuados en muchos casos y constituyen la base de los generadores avanzados habitualmente considerados.
Posteriormente se dar� una visi�n de las diferentes herramientas para estudiar la calidad de un generador de n�meros pseudoaleatorios.

## Generadores congruenciales lineales {#gen-cong}

<!-- 
Pendiente: Incluir nota sobre generadores implementados en ordenadores que trabajan con n�meros enteros o bits
-->

En los generadores congruenciales lineales se considera una combinaci�n lineal de los �ltimos $k$ enteros generados y se calcula su resto al dividir por un entero fijo $m$. 
En el m�todo congruencial simple (de orden $k = 1$), partiendo de una semilla inicial $x_0$, el algoritmo secuencial es el siguiente:
$$\begin{aligned}
x_{i}  & = (ax_{i-1}+c) \bmod m \\
u_{i}  & = \dfrac{x_{i}}{m} \\
i  & =1,2,\ldots
\end{aligned}$$ 
donde $a$ (*multiplicador*), $c$ (*incremento*) y $m$ (*m�dulo*) son enteros positivos^[Se supone adem�s que $a$, $c$ y $x_0$ son menores que $m$, ya que, dadas las propiedades algebraicas de la suma y el producto en el conjunto de clases de resto m�dulo $m$ (que es un anillo), cualquier otra elecci�n de valores mayores o iguales que $m$ tiene un equivalente verificando esta restricci�n.] fijados de antemano (los par�metros de este generador). Si $c=0$ el generador se denomina congruencial *multiplicativo* (Lehmer, 1951) y en caso contrario se dice que es *mixto* (Rotenburg, 1960).

Obviamente los par�metros y la semilla determinan los valores generados, que tambi�n se pueden obtener de forma no recursiva:
$$x_{i}=\left( a^{i}x_0+c\frac{a^{i}-1}{a-1}\right) \bmod m$$

Este m�todo est� implementado^[Aunque de forma no muy eficiente. Para evitar problemas computacionales, se recomienda realizar el c�lculo de los valores empleando el m�todo de Schrage (ver Bratley *et al.*, 1987; L'Ecuyer, 1988).] en la funci�n `rlcg()` del paquete [`simres`](https://rubenfcasal.github.io/simres), imitando el funcionamiento del generador uniforme de R (ver tambi�n `simres::rng()`; fichero [*rng.R*](R/rng.R)):


```r
simres::rlcg
```

```
## function(n, seed = as.numeric(Sys.time()), a = 7^5, c = 0, m = 2^31 - 1) {
##   u <- numeric(n)
##   for(i in 1:n) {
##     seed <- (a * seed + c) %% m
##     u[i] <- seed/m # (seed + 1)/(m + 1)
##   }
##   # Almacenar semilla y par�metros
##   assign(".rng", list(seed = seed, type = "lcg",
##           parameters = list(a = a, c = c, m = m)), envir = globalenv())
##   # .rng <<- list(seed = seed, type = "lcg", parameters = list(a = a, c = c, m = m))
##   # Para continuar con semilla y par�metros:
##   #   with(.rng, rlcg(n, seed, parameters$a, parameters$c, parameters$m))
##   # Devolver valores
##   return(u)
## }
## <bytecode: 0x0000000032cf3718>
## <environment: namespace:simres>
```


Ejemplos de par�metros:

-   $c=0$, $a=2^{16}+3=65539$ y $m=2^{31}$, generador *RANDU* de IBM
    (**no recomendable**).

-   $c=0$, $a=7^{5}=16807$ y $m=2^{31}-1$ (primo de Mersenne), Park y Miller (1988)
    *minimal standar*, empleado por las librer�as IMSL y NAG.
    
-   $c=0$, $a=48271$ y $m=2^{31}-1$ actualizaci�n del *minimal standar* 
    propuesta por Park, Miller y Stockmeyer (1993).
    

A pesar de su simplicidad, una adecuada elecci�n de los par�metros permite obtener de manera eficiente secuencias de n�meros "aparentemente" i.i.d. $\mathcal{U}(0,1)$.
Durante los primeros a�os, el procedimiento habitual consist�a en escoger $m$ de forma que se pudiera realizar eficientemente la operaci�n del m�dulo, aprovechando la arquitectura del ordenador (por ejemplo $m = 2^{31}$ si se emplean enteros con signo de 32 bits). 
Posteriormente se seleccionaban $c$ y $a$ de forma que el per�odo $p$ fuese lo m�s largo posible (o suficientemente largo), empleando los resultados mostrados a continuaci�n.


\BeginKnitrBlock{theorem}\iffalse{-91-72-117-108-108-32-121-32-68-111-98-101-108-108-44-32-49-57-54-50-93-}\fi{}<div class="theorem"><span class="theorem" id="thm:hull-dobell"><strong>(\#thm:hull-dobell)  \iffalse (Hull y Dobell, 1962) \fi{} </strong></span><br>
Un generador congruencial tiene per�odo m�ximo ($p=m$) si y solo si:

1.  $c$ y $m$ son primos relativos (i.e. $m.c.d.(c, m) = 1$).

2.  $a-1$ es m�ltiplo de todos los factores primos de $m$ (i.e.
    $a \equiv 1 \bmod q$, para todo $q$ factor primo de $m$).

3.  Si $m$ es m�ltiplo de $4$, entonces $a-1$ tambi�n lo ha de
    ser (i.e. $m \equiv 0 \bmod 4\Rightarrow a \equiv
    1 \bmod 4$).
 </div>\EndKnitrBlock{theorem}

Algunas consecuencias:

-   Si $m$ primo, $p=m$ si y solo si $a=1$.

-   Un generador multiplicativo no cumple la condici�n 1 ($m.c.d.(0, m)=m$).


\BeginKnitrBlock{theorem}<div class="theorem"><span class="theorem" id="thm:unnamed-chunk-3"><strong>(\#thm:unnamed-chunk-3) </strong></span><br>
Un generador multiplicativo tiene per�odo m�ximo ($p=m-1$) si:

1.  $m$ es primo.

2.  $a$ es una raiz primitiva de $m$ (i.e. el menor entero $q$ tal
    que $a^{q}=1 \bmod m$ es $q=m-1$).
   </div>\EndKnitrBlock{theorem}

Adem�s de preocuparse de la longitud del ciclo, las secuencias generadas deben aparentar muestras i.i.d. $\mathcal{U}(0,1)$. 

Uno de los principales problemas es que los valores generados pueden mostrar una clara estructura reticular.
Este es el caso por ejemplo del generador RANDU de IBM muy empleado en la d�cada de los 70 (ver Figura \@ref(fig:randu))^[Alternativamente se podr�a utilizar la funci�n `plot3d` del paquete `rgl`, y rotar la figura (pulsando con el rat�n) para ver los hiperplanos:
`rgl::plot3d(xyz)`].
Por ejemplo, el conjunto de datos `randu` contiene 400 tripletas de n�meros sucesivos obtenidos con la implementaci�n de VAX/VMS 1.5 (1977).


```r
library(simres)
system.time(u <- rlcg(n = 9999, 
          seed = 543210, a = 2^16 + 3, c = 0, m = 2^31))
```

```
##    user  system elapsed 
##    0.01    0.00    0.02
```

```r
# xyz <- matrix(u, ncol = 3, byrow = TRUE)
xyz <- stats::embed(u, 3)
library(plot3D)
# points3D(xyz[,1], xyz[,2], xyz[,3], colvar = NULL, phi = 60, 
#          theta = -50, pch = 21, cex = 0.2)
points3D(xyz[,3], xyz[,2], xyz[,1], colvar = NULL, phi = 60, 
         theta = -50, pch = 21, cex = 0.2)
```

<div class="figure" style="text-align: center">
<img src="02-Generacion_numeros_aleatorios_files/figure-html/randu-1.png" alt="Grafico de dispersi�n de tripletas del generador RANDU de IBM (contenidas en 15 planos)." width="70%" />
<p class="caption">(\#fig:randu)Grafico de dispersi�n de tripletas del generador RANDU de IBM (contenidas en 15 planos).</p>
</div>

En general todos los generadores de este tipo van a presentar estructuras reticulares.
Marsaglia (1968) demostr� que las $k$-uplas de un generadores multiplicativo est�n contenidas en a lo sumo $\left(k!m\right)^{1/k}$ hiperplanos paralelos (para m�s detalles sobre la estructura reticular, ver por ejemplo Ripley, 1987, secci�n 2.7).
Por tanto habr�a que seleccionar adecuadamente $m$ y $c$ ($a$ solo influir�a en la pendiente) de forma que la estructura reticular sea imperceptible teniendo en cuenta el n�mero de datos que se pretende generar (por ejemplo de forma que la distancia m�nima entre los puntos sea pr�xima a la esperada en teor�a).

<!-- 
PENDIENTE: 
Ejercicio aleatoriedad d�gitos menos significativos (ejemplo sample)
9*a(n-2)-6*a(n-1)+a(n) = 0 mod 2^31 en RANDU con periodo 2^29
$a$ es una raiz primitiva de $m$ en Park y Miller
-->

Se han propuesto diversas pruebas (ver Secci�n \@ref(calgen)) para
determinar si un generador tiene problemas de este tipo y se han
realizado numerosos estudios para determinadas familias (e.g. Park y
Miller, 1988, estudiaron que par�metros son adecuados para $m=2^{31}-1$).

-   En ciertos contextos muy exigentes (por ejemplo en criptograf�a), se recomienda
    considerar un "periodo de seguridad" $\approx \sqrt{p}$ para evitar este tipo 
    de problemas.

-   Aunque estos generadores tienen limitaciones en su capacidad para
    producir secuencias muy largas de n�meros i.i.d. $\mathcal{U}(0,1)$,
    son un elemento b�sico en generadores m�s avanzados (siguiente secci�n).

    
\BeginKnitrBlock{example}<div class="example"><span class="example" id="exm:congru512"><strong>(\#exm:congru512) </strong></span></div>\EndKnitrBlock{example}

Consideramos el generador congruencial, de ciclo m�ximo, definido por: 
$$\begin{aligned}
x_{n+1}  & =(5x_{n}+1)\ \bmod\ 512,\nonumber\\
u_{n+1}  & =\frac{x_{n+1}}{512},\ n=0,1,\dots\nonumber
\end{aligned}$$


a)  Generar 500 valores de este generador, obtener el tiempo de CPU,
    representar su distribuci�n mediante un histograma (en escala
    de densidades) y compararla con la densidad te�rica.
   
    
    ```r
    set.rng(321, "lcg", a = 5, c = 1, m = 512)  # Establecer semilla y par�metros
    nsim <- 500
    system.time(u <- rng(nsim)) 
    ```
    
    ```
    ##    user  system elapsed 
    ##       0       0       0
    ```
    
    ```r
    hist(u, freq = FALSE)
    abline(h = 1)                   # Densidad uniforme
    ```
    
    <div class="figure" style="text-align: center">
    <img src="02-Generacion_numeros_aleatorios_files/figure-html/ejcona-1.png" alt="Histograma de los valores generados." width="70%" />
    <p class="caption">(\#fig:ejcona)Histograma de los valores generados.</p>
    </div>

    En este caso concreto la distribuci�n de los valores generados es aparentemente m�s uniforme de lo que cabr�a esperar, lo que inducir�a a sospechar de la calidad de este generador (ver Ejemplo \@ref(exm:congru512b) en Secci�n \@ref(calgen)).

b)  Calcular la media de las simulaciones (`mean`) y compararla con
    la te�rica.
    
    La aproximaci�n por simulaci�n de la media te�rica es:
    
    
    ```r
    mean(u)
    ```
    
    ```
    ## [1] 0.4999609
    ```
    
    La media te�rica es 0.5. 
    Error absoluto $3.90625\times 10^{-5}$.

c)  Aproximar (mediante simulaci�n) la probabilidad del intervalo
    $(0.4;0.8)$ y compararla con la te�rica.

    La probabilidad te�rica es 0.8 - 0.4 = 0.4
    
    La aproximaci�n mediante simulaci�n:
    
    
    ```r
    sum((0.4 < u) & (u < 0.8))/nsim
    ```
    
    ```
    ## [1] 0.402
    ```
    
    ```r
    mean((0.4 < u) & (u < 0.8))     # Alternativa
    ```
    
    ```
    ## [1] 0.402
    ```

## Extensiones 

Se han considerado diversas extensiones del generador congruencial lineal simple:

-   Lineal m�ltiple: 
    $x_{i}= a_0 + a_1 x_{i-1} + a_2 x_{i-2} + \cdots + a_{k} x_{i-k} \bmod m$,
    con periodo $p\leq m^{k}-1$.

-   No lineal: 
    $x_{i} = f\left(  x_{i-1}, x_{i-2}, \cdots, x_{i-k} \right) \bmod m$. 
    Por ejemplo $x_{i} = a_0 + a_1 x_{i-1} + a_2 x_{i-1}^2 \bmod m$.

-   Matricial: 
    $\boldsymbol{x}_{i} = A_0 + A_1\boldsymbol{x}_{i-1} 
    + A_2\boldsymbol{x}_{i-2} + \cdots 
    + A_{k}\boldsymbol{x}_{i-k} \bmod m$.

Un ejemplo de generador congruencia lineal m�ltiple es el denominado *generador de Fibonacci retardado* (Fibonacci-lagged generator; Knuth, 1969):
$$x_n = (x_{n-37} + x_{n-100}) \bmod 2^{30},$$
con un per�odo aproximado de $2^{129}$ y que puede ser empleado en R (lo cual no ser�a en principio recomendable; ver [Knuth Recent News 2002](https://www-cs-faculty.stanford.edu/~knuth/news02.html#rng)) estableciendo `kind` a `"Knuth-TAOCP-2002"` o `"Knuth-TAOCP"` en la llamada a `set.seed()` o `RNGkind()`.
    
El generador *Mersenne-Twister* (Matsumoto y Nishimura, 1998), empleado por defecto en R, de periodo $2^{19937}-1$ y equidistribution en 623 dimensiones, se puede expresar como un generador congruencial matricial lineal.
En cada iteraci�n (*twist*) genera 624 valores (los �ltimos componentes de la semilla son los 624 enteros de 32 bits correspondientes, el segundo componente es el �ndice/posici�n correspondiente al �ltimo valor devuelto; el conjunto de enteros solo cambia cada 624 generaciones).


```r
set.seed(1)
u <- runif(1)
seed <- .Random.seed
u <- runif(623)
sum(seed != .Random.seed) 
```

```
## [1] 1
```

```r
# Solo cambia el �ndice: 
seed[2]; .Random.seed[2]
```

```
## [1] 1
```

```
## [1] 624
```

```r
u <- runif(1)
# Cada 624 generaciones cambia el conjunto de enteros y el �ndice se inicializa
sum(seed != .Random.seed)
```

```
## [1] 624
```

```r
seed[2]; .Random.seed[2]
```

```
## [1] 1
```

```
## [1] 1
```


Un caso particular del generador lineal m�ltiple son los denominados *generadores de registros desfasados* (m�s relacionados con la criptograf�a).
Se generan bits de forma secuencial considerando $m=2$ y $a_{i} \in \left \{ 0,1\right \}$ y se van combinando $l$ bits para obtener valores en el intervalo $(0, 1)$, por ejemplo $u_i = 0 . x_{it+1} x_{it+2} \ldots x_{it+l}$, siendo $t$ un par�metro denominado *aniquilaci�n* (Tausworthe, 1965). 
Los c�lculos se pueden realizar r�pidamente mediante operaciones l�gicas (los sumandos de la combinaci�n lineal se traducen en un "o" exclusivo XOR), empleando directamente los registros del procesador (ver por ejemplo, Ripley, 1987, Algoritmo 2.1).

Otras alternativas consisten en la combinanci�n de varios generadores, las m�s empleadas son:

-   Combinar las salidas: por ejemplo $u_{i}=\sum_{l=1}^L u_{i}^{(l)} \bmod 1$, donde $u_{i}^{(l)}$ es el $i$-�simo valor obtenido con el generador $l$.

-   Barajar las salidas: por ejemplo se crea una tabla empleando un generador y se utiliza otro para seleccionar el �ndice del valor que se va a devolver y posteriormente actualizar.

<!-- 
PENDIENTE:  
Ejemplo combinar salidas  generador Wichmann-Hill (1982)  https://en.wikipedia.org/wiki/Wichmann%E2%80%93Hill 
-->


El generador *L'Ecuyer-CMRG* (L'Ecuyer, 1999), empleado como base para la generaci�n de m�ltiples secuencias en el paquete `parallel`, combina dos generadores concruenciales lineales m�ltiples de orden $k=3$ (el periodo aproximado es $2^{191}$).


## An�lisis de la calidad de un generador {#calgen}

Para verificar si un generador tiene las propiedades estad�sticas deseadas hay disponibles una gran cantidad de test de hip�tesis y m�todos gr�ficos,
incluyendo m�todos gen�ricos (de bondad de ajuste y aleatoriedad) y contrastes espec�ficos para generadores aleatorios.
Se trata principalmente de contrastar si las muestras generadas son i.i.d. $\mathcal{U}\left(0,1\right)$ (an�lisis univariante).
Aunque los m�todos m�s avanzados tratan de contrastar si las $d$-uplas:

$$(U_{t+1},U_{t+2},\ldots,U_{t+d}); \ t=(i-1)d, \ i=1,\ldots,m$$

son i.i.d. $\mathcal{U}\left(0,1\right)^{d}$ (uniformes independientes en el hipercubo; an�lisis multivariante).
En el Ap�ndice \@ref(gof-aleat) se describen algunos de estos m�todos.

En esta secci�n emplearemos �nicamente m�todos gen�ricos, ya que tambi�n pueden ser de utilidad para evaluar generadores de variables no uniformes y para la construcci�n de modelos del sistema real (e.g. para modelar variables que se tratar�n como entradas del modelo general). 
Sin embargo, los m�todos cl�sicos pueden no ser muy adecuados para evaluar generadores de n�meros pseudoaleatorios (ver L�Ecuyer y Simard, 2007).
La recomendaci�n ser�a emplear bater�as de contrastes recientes, como las descritas en la Subsecci�n \@ref(baterias).

Hay que destacar algunas diferencias entre el uso de este tipo de m�todos en inferencia y en simulaci�n. 
Por ejemplo, si empleamos un constrate de hip�tesis del modo habitual, desconfiamos del generador si la muestra (secuencia) no se ajusta a la distribuci�n te�rica ($p$-valor $\leq \alpha$).
En simulaci�n, adem�s, tambi�n se sospecha si se ajusta demasiado bien a la distribuci�n te�rica ($p$-valor $\geq1-\alpha$), lo que indicar�a que no reproduce adecuadamente la variabilidad.

Uno de los contrastes m�s conocidos es el test chi-cuadrado de bondad de ajuste (`chisq.test` para el caso discreto). 
Aunque si la variable de inter�s es continua, habr�a que discretizarla (con la correspondiente perdida de informaci�n). 
Por ejemplo, se podr�a emplear la funci�n `simres::chisq.cont.test()` (fichero [*test.R*](R/test.R)), que imita a las incluidas en R:


```r
simres::chisq.cont.test
```

```
## function(x, distribution = "norm", nclass = floor(length(x)/5),
##                             output = TRUE, nestpar = 0, ...) {
##   # Funci�n distribuci�n
##   q.distrib <- eval(parse(text = paste("q", distribution, sep = "")))
##   # Puntos de corte
##   q <- q.distrib((1:(nclass - 1))/nclass, ...)
##   tol <- sqrt(.Machine$double.eps)
##   xbreaks <- c(min(x) - tol, q, max(x) + tol)
##   # Gr�ficos y frecuencias
##   if (output) {
##     xhist <- hist(x, breaks = xbreaks, freq = FALSE,
##                   lty = 2, border = "grey50")
##     # Funci�n densidad
##     d.distrib <- eval(parse(text = paste("d", distribution, sep = "")))
##     curve(d.distrib(x, ...), add = TRUE)
##   } else {
##     xhist <- hist(x, breaks = xbreaks, plot = FALSE)
##   }
##   # C�lculo estad�stico y p-valor
##   O <- xhist$counts  # Equivalente a table(cut(x, xbreaks)) pero m�s eficiente
##   E <- length(x)/nclass
##   DNAME <- deparse(substitute(x))
##   METHOD <- "Pearson's Chi-squared test"
##   STATISTIC <- sum((O - E)^2/E)
##   names(STATISTIC) <- "X-squared"
##   PARAMETER <- nclass - nestpar - 1
##   names(PARAMETER) <- "df"
##   PVAL <- pchisq(STATISTIC, PARAMETER, lower.tail = FALSE)
##   # Preparar resultados
##   classes <- format(xbreaks)
##   classes <- paste("(", classes[-(nclass + 1)], ",", classes[-1], "]",
##                    sep = "")
##   RESULTS <- list(classes = classes, observed = O, expected = E,
##                   residuals = (O - E)/sqrt(E))
##   if (output) {
##     cat("\nPearson's Chi-squared test table\n")
##     print(as.data.frame(RESULTS))
##   }
##   if (any(E < 5))
##     warning("Chi-squared approximation may be incorrect")
##   structure(c(list(statistic = STATISTIC, parameter = PARAMETER, p.value = PVAL,
##                    method = METHOD, data.name = DNAME), RESULTS), class = "htest")
## }
## <bytecode: 0x0000000036191378>
## <environment: namespace:simres>
```

\BeginKnitrBlock{example}\iffalse{-91-97-110-225-108-105-115-105-115-32-100-101-32-117-110-32-103-101-110-101-114-97-100-111-114-32-99-111-110-103-114-117-101-110-99-105-97-108-44-32-99-111-110-116-105-110-117-97-99-105-243-110-93-}\fi{}<div class="example"><span class="example" id="exm:congru512b"><strong>(\#exm:congru512b)  \iffalse (an�lisis de un generador congruencial, continuaci�n) \fi{} </strong></span></div>\EndKnitrBlock{example}

Continuando con el generador congruencial del Ejemplo \@ref(exm:congru512): 


```r
set.rng(321, "lcg", a = 5, c = 1, m = 512)  # Establecer semilla y par�metros
nsim <- 500
u <- rng(nsim)
```

Al aplicar el test chi-cuadrado obtendr�amos:

<!-- PENDIENTE: evitar r-markdown en t�tulo figura -->


```r
chisq.cont.test(u, distribution = "unif", 
                nclass = 10, nestpar = 0, min = 0, max = 1)
```

<div class="figure" style="text-align: center">
<img src="02-Generacion_numeros_aleatorios_files/figure-html/chisq-test-unif-1.png" alt="Gr�fico resultante de aplicar la funci�n `chisq.cont.test()` comparando el histograma de los valores generados con la densidad uniforme." width="70%" />
<p class="caption">(\#fig:chisq-test-unif)Gr�fico resultante de aplicar la funci�n `chisq.cont.test()` comparando el histograma de los valores generados con la densidad uniforme.</p>
</div>

```
## 
## Pearson's Chi-squared test table
##                          classes observed expected  residuals
## 1  (-1.490116e-08, 1.000000e-01]       51       50  0.1414214
## 2  ( 1.000000e-01, 2.000000e-01]       49       50 -0.1414214
## 3  ( 2.000000e-01, 3.000000e-01]       49       50 -0.1414214
## 4  ( 3.000000e-01, 4.000000e-01]       50       50  0.0000000
## 5  ( 4.000000e-01, 5.000000e-01]       51       50  0.1414214
## 6  ( 5.000000e-01, 6.000000e-01]       51       50  0.1414214
## 7  ( 6.000000e-01, 7.000000e-01]       49       50 -0.1414214
## 8  ( 7.000000e-01, 8.000000e-01]       50       50  0.0000000
## 9  ( 8.000000e-01, 9.000000e-01]       50       50  0.0000000
## 10 ( 9.000000e-01, 9.980469e-01]       50       50  0.0000000
```

```
## 
## 	Pearson's Chi-squared test
## 
## data:  u
## X-squared = 0.12, df = 9, p-value = 1
```

Alternativamente, por ejemplo si solo se pretende aplicar el contraste, se podr�a emplear  la funci�n `simres::freq.test()` (fichero [*test.R*](R/test.R))  para este caso particular (ver Secci�n \@ref(freq-test)).

Como se muestra en la Figura \@ref(fig:chisq-test-unif) el histograma de la secuencia generada es muy plano (comparado con lo que cabr�a esperar de una muestra de tama�o 500 de una uniforme), y consecuentemente el $p$-valor del contraste chi-cuadrado es pr�cticamente 1, lo que indicar�a que este generador no reproduce adecuadamente la variabilidad de una distribuci�n uniforme.   

Otro contraste de bondad de ajuste muy conocido es el test de Kolmogorov-Smirnov, implementado en `ks.test` (ver Secci�n \@ref(ks-test)). 
Este contraste de hip�tesis compara la funci�n de distribuci�n bajo la hip�tesis nula con la funci�n de distribuci�n emp�rica (ver Secci�n \@ref(empdistr)), representadas en la Figura \@ref(fig:empdistrunif):
    

```r
# Distribuci�n emp�rica
curve(ecdf(u)(x), type = "s", lwd = 2)
curve(punif(x, 0, 1), add = TRUE)
```

<div class="figure" style="text-align: center">
<img src="02-Generacion_numeros_aleatorios_files/figure-html/empdistrunif-1.png" alt="Comparaci�n de la distribuci�n emp�rica de la secuencia generada con la funci�n de distribuci�n uniforme." width="70%" />
<p class="caption">(\#fig:empdistrunif)Comparaci�n de la distribuci�n emp�rica de la secuencia generada con la funci�n de distribuci�n uniforme.</p>
</div>
Podemos realizar el contraste con el siguiente c�digo:

```r
# Test de Kolmogorov-Smirnov
ks.test(u, "punif", 0, 1)
```

```
## 
## 	One-sample Kolmogorov-Smirnov test
## 
## data:  u
## D = 0.0033281, p-value = 1
## alternative hypothesis: two-sided
```

En la Secci�n \@ref(gof) se describen con m�s detalle estos contrastes de bondad de ajuste.

Adicionalmente podr�amos estudiar la aleatoriedad de los valores generados (ver Secci�n \@ref(diag-aleat)), por ejemplo mediante un gr�fico secuencial y el de dispersi�n retardado.


```r
plot(as.ts(u))
```

<div class="figure" style="text-align: center">
<img src="02-Generacion_numeros_aleatorios_files/figure-html/plot-sec-1.png" alt="Gr�fico secuencial de los valores generados." width="70%" />
<p class="caption">(\#fig:plot-sec)Gr�fico secuencial de los valores generados.</p>
</div>


```r
plot(u[-nsim],u[-1])
```

<div class="figure" style="text-align: center">
<img src="02-Generacion_numeros_aleatorios_files/figure-html/plot-ret-1.png" alt="Gr�fico de dispersi�n retardado de los valores generados." width="70%" />
<p class="caption">(\#fig:plot-ret)Gr�fico de dispersi�n retardado de los valores generados.</p>
</div>

Tambi�n podemos analizar las autocorrelaciones (las correlaciones de $(u_{i},u_{i+k})$, con $k=1,\ldots,K$): 


```r
acf(u)
```

<div class="figure" style="text-align: center">
<img src="02-Generacion_numeros_aleatorios_files/figure-html/plot-acf-1.png" alt="Autocorrelaciones de los valores generados." width="70%" />
<p class="caption">(\#fig:plot-acf)Autocorrelaciones de los valores generados.</p>
</div>
    
Por ejemplo, para contrastar si las diez primeras autocorrelaciones son nulas podr�amos emplear el test de Ljung-Box:
    

```r
Box.test(u, lag = 10, type = "Ljung")
```

```
## 
## 	Box-Ljung test
## 
## data:  u
## X-squared = 22.533, df = 10, p-value = 0.01261
```


### Repetici�n de contrastes

Los contrastes se plantean habitualmente desde el punto de vista de la inferencia estad�stica: se realiza una prueba sobre la �nica muestra disponible. 
Si se realiza una �nica prueba, en las condiciones de $H_0$ hay una probabilidad $\alpha$ de rechazarla.
En simulaci�n tiene mucho m�s sentido realizar un gran n�mero de pruebas:

-   La proporci�n de rechazos deber�a aproximarse al valor de
    $\alpha$ (se puede comprobar para distintos valores de $\alpha$).

-   La distribuci�n del estad�stico deber�a ajustarse a la te�rica
    bajo $H_0$ (se podr�a realizar un nuevo contraste de bondad
    de ajuste).

-   Los $p$-valores obtenidos deber�an ajustarse a una
    $\mathcal{U}\left(0,1\right)$ (se podr�a realizar tambi�n un
    contraste de bondad de ajuste).

Este procedimiento es tambi�n el habitual para validar un m�todo de
contraste de hip�tesis por simulaci�n (ver Secci�n \@ref(contrastes)).

\BeginKnitrBlock{example}<div class="example"><span class="example" id="exm:rep-test-randu"><strong>(\#exm:rep-test-randu) </strong></span></div>\EndKnitrBlock{example}

Continuando con el generador congruencial RANDU, podemos pensar en estudiar la uniformidad de los valores generados empleando repetidamente el test chi-cuadrado:


```r
# Valores iniciales
set.rng(543210, "lcg", a = 2^16 + 3, c = 0, m = 2^31)  # Establecer semilla y par�metros
# set.seed(543210)
n <- 500
nsim <- 1000
estadistico <- numeric(nsim)
pvalor <- numeric(nsim)

# Realizar contrastes
for(isim in 1:nsim) {
  u <- rng(n)    # Generar
  # u <- runif(n)
  tmp <- freq.test(u, nclass = 100)
  # tmp <- chisq.cont.test(u, distribution = "unif", nclass = 100, 
  #     output = FALSE, nestpar = 0, min = 0, max = 1)
  estadistico[isim] <- tmp$statistic
  pvalor[isim] <- tmp$p.value
}
```

Por ejemplo, podemos comparar la proporci�n de rechazos observados con los que cabr�a esperar con los niveles de significaci�n habituales:


```r
{
cat("Proporci�n de rechazos al 1% =", mean(pvalor < 0.01), "\n") # sum(pvalor < 0.01)/nsim
cat("Proporci�n de rechazos al 5% =", mean(pvalor < 0.05), "\n")   # sum(pvalor < 0.05)/nsim
cat("Proporci�n de rechazos al 10% =", mean(pvalor < 0.1), "\n")   # sum(pvalor < 0.1)/nsim
}
```

```
## Proporci�n de rechazos al 1% = 0.014 
## Proporci�n de rechazos al 5% = 0.051 
## Proporci�n de rechazos al 10% = 0.112
```

Las proporciones de rechazo obtenidas deber�an comportarse como una aproximaci�n por simulaci�n de los niveles te�ricos.
En este caso no se observa nada extra�o, por lo que no habr�a motivos para sospechar de la uniformidad de los valores generados (aparentemente no hay problemas con la uniformidad de este generador).


Adicionalmente, si queremos estudiar la proporci�n de rechazos (el *tama�o del contraste*) para los posibles valores de $\alpha$, podemos emplear la distribuci�n emp�rica del $p$-valor (proporci�n de veces que result� menor que un determinado valor):


```r
# Distribuci�n emp�rica
plot(ecdf(pvalor), do.points = FALSE, lwd = 2, 
     xlab = 'Nivel de significaci�n', ylab = 'Proporci�n de rechazos')
abline(a = 0, b = 1, lty = 2)   # curve(punif(x, 0, 1), add = TRUE)
```

<div class="figure" style="text-align: center">
<img src="02-Generacion_numeros_aleatorios_files/figure-html/rep-test-ecdf-1.png" alt="Proporci�n de rechazos con los distintos niveles de significaci�n." width="70%" />
<p class="caption">(\#fig:rep-test-ecdf)Proporci�n de rechazos con los distintos niveles de significaci�n.</p>
</div>

<!-- 
curve(ecdf(pvalor)(x), type = "s", lwd = 2) 
-->


Tambi�n podemos estudiar la distribuci�n del estad�stico del contraste.
En este caso, como la distribuci�n bajo la hip�tesis nula est� implementada en R, podemos compararla f�cilmente con la de los valores generados (deber�a ser una aproximaci�n por simulaci�n de la distribuci�n te�rica):


```r
# Histograma
hist(estadistico, breaks = "FD", freq = FALSE, main = "")
curve(dchisq(x, 99), add = TRUE)
```

<div class="figure" style="text-align: center">
<img src="02-Generacion_numeros_aleatorios_files/figure-html/rep-test-est-1.png" alt="Distribuci�n del estad�stico del constraste." width="70%" />
<p class="caption">(\#fig:rep-test-est)Distribuci�n del estad�stico del constraste.</p>
</div>

Adem�s de la comparaci�n gr�fica, podr�amos emplear un test de bondad de ajuste para contrastar si la distribuci�n del estad�stico es la te�rica bajo la hip�tesis nula:


```r
# Test chi-cuadrado (chi-cuadrado sobre chi-cuadrado)
# chisq.cont.test(estadistico, distribution="chisq", nclass=20, nestpar=0, df=99)
# Test de Kolmogorov-Smirnov
ks.test(estadistico, "pchisq", df = 99)
```

```
## 
## 	One-sample Kolmogorov-Smirnov test
## 
## data:  estadistico
## D = 0.023499, p-value = 0.6388
## alternative hypothesis: two-sided
```

En este caso la distribuci�n observada del estad�stico es la que cabr�a esperar de una muestra de este tama�o de la distribuci�n te�rica, por tanto, seg�n este criterio, aparentemente no habr�a problemas con la uniformidad de este generador (hay que recordar que estamos utilizando contrastes de hip�tesis como herramienta para ver si hay alg�n problema con el generador, no tiene mucho sentido hablar de aceptar o rechazar una hip�tesis).

En lugar de estudiar la distribuci�n del estad�stico de contraste  siempre podemos analizar la distribuci�n del $p$-valor.
Mientras que la distribuci�n te�rica del estad�stico depende del contraste y puede ser complicada, la del $p$-valor es siempre una uniforme.


```r
# Histograma
hist(pvalor, freq = FALSE, main = "")
abline(h=1) # curve(dunif(x,0,1), add=TRUE)
```

<div class="figure" style="text-align: center">
<img src="02-Generacion_numeros_aleatorios_files/figure-html/rep-test-pval-1.png" alt="Distribuci�n del $p$-valor del constraste." width="70%" />
<p class="caption">(\#fig:rep-test-pval)Distribuci�n del $p$-valor del constraste.</p>
</div>

```r
# Test chi-cuadrado
# chisq.cont.test(pvalor, distribution="unif", nclass=20, nestpar=0, min=0, max=1)
# Test de Kolmogorov-Smirnov
ks.test(pvalor, "punif",  min = 0, max = 1)
```

```
## 
## 	One-sample Kolmogorov-Smirnov test
## 
## data:  pvalor
## D = 0.023499, p-value = 0.6388
## alternative hypothesis: two-sided
```

Como podemos observar, obtendr�amos los mismos resultados que al analizar la distribuci�n del estad�stico. 

Alternativamente podr�amos emplear la funci�n [`rephtest()`](https://rubenfcasal.github.io/simres/reference/rephtest.html) del paquete `simres`:









