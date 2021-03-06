\name{evaluation.strip.data}
\alias{evaluation.strip.data}
\alias{evaluation.strip.plot}

\title{Evaluation strips for ensemble suitability mapping}

\description{
These functions provide a dataframe which can subsequently be used to evaluate the relationship between environmental variables and the fitted probability of occurrence of individual or ensemble suitability modelling algorithms. The \code{biomod2} package provides an alternative implementation of this approach (\code{response.plot2}). 
}

\usage{
evaluation.strip.data(xn = NULL, ext = NULL,
    models.list = NULL, 
    input.weights = models.list$output.weights,
    vars = models.list$vars, factors = models.list$factors, 
    dummy.vars = models.list$dummy.vars, 
    steps=50
)

evaluation.strip.plot(data, 
    modelnames = c("MAXENT", "GBM", "GBMSTEP", "RF", "GLM", "GLMSTEP", "GAM", 
        "GAMSTEP", "MGCV", "MGCVFIX", "EARTH", "RPART", "NNET", "FDA", 
        "SVM", "SVME", "BIOCLIM", "DOMAIN", "MAHAL"), 
    variable = NULL, model = NULL, ...
)

}

\arguments{
  \item{xn}{ RasterStack object (\code{\link[raster]{stack}}) containing all layers that correspond to explanatory variables of an ensemble calibrated earlier with \code{\link{ensemble.test}}. See also \code{\link[raster]{predict}}.   }
  \item{ext}{ an Extent object to limit the prediction to a sub-region of \code{xn} and the selection of background points to a sub-region of \code{x}, typically provided as c(lonmin, lonmax, latmin, latmax); see also \code{\link[raster]{predict}}, \code{\link[dismo]{randomPoints}} and \code{\link[raster]{extent}} }
  \item{models.list}{ list with 'old' model objects such as \code{MAXENT} or \code{RF}. }
  \item{input.weights}{ array with numeric values for the different modelling algorithms; if \code{NULL} then values provided by parameters such as \code{MAXENT} and \code{GBM} will be used. As an alternative, the output from \code{ensemble.test.splits} can be used. }
  \item{vars}{ Vector that indicates which variables should be included as columns in the data frame. Only variables that correspond to layers of the rasterStack will be included. }
  \item{factors}{ vector that indicates which variables are factors; see also \code{\link[dismo]{prepareData}} and \code{\link{ensemble.formulae}}  }
  \item{dummy.vars}{ vector that indicates which variables are dummy variables (coded 0 or 1 to indicate presence of specific level of a categorical variable; see also \code{\link{ensemble.formulae}} }
  \item{steps}{ number of steps within the range of a continuous explanatory variable }

  \item{data}{ data set with ranges of environmental variables and fitted suitability models, typically returned by \code{evaluation.strip.data} }
  \item{modelnames}{ abbreviated names of the individual suitability models that are fitted. Should correspond to the names used in ensemble.grd. }
  \item{variable}{ focal explanatory variable for plots with evaluation strips }
  \item{model}{ focal model for plots with evaluation strips }
  \item{...}{ Other arguments passed to \code{\link[graphics]{plot}} }
}

\details{
These functions are mainly intended to be used internally by the ensemble.raster function.

\code{evaluation.strip.data} creates a data frame with variables (columns) corresponding to the environmental variables encountered in the RasterStack object (\code{x}) and the suitability modelling approaches that were defined. The variable of \code{focal.var} is an index of the variable for which values are ranged. The variable of \code{categorical} is an index for categorical (factor) variables.

A continuous (numeric) variable is ranged between its minimum and maximum values in the number of steps defined by argument \code{steps}. When a continuous variable is not the focal variable, then the average (\code{\link[base]{mean}}) is used.

A categorical (factor) variable is ranged for all the encountered levels (\code{\link[base]{levels}}) for this variable. When a categorical variable is not the focal variable, then the most frequent level is used.
}

\value{
function \code{evaluation.strip.data} creates a data frame, function code{evaluation.strip.data} allows for plotting. 
}

\references{
Elith J, Ferrier S, Huettmann F & Leathwick J. 2005. The evaluation strip: A new and robust method for plotting predicted responses from species distribution models. Ecological Modelling 186: 280-289 
}

\author{ Roeland Kindt (World Agroforestry Centre) }

\seealso{
\code{\link{ensemble.raster}}
}

\examples{
\dontrun{

# get predictor variables
library(dismo)
predictor.files <- list.files(path=paste(system.file(package="dismo"), '/ex', sep=''),
    pattern='grd', full.names=TRUE)
predictors <- stack(predictor.files)
# subset based on Variance Inflation Factors
predictors <- subset(predictors, subset=c("bio5", "bio6", 
    "bio16", "bio17", "biome"))
predictors
predictors@title <- "base"

# presence points
presence_file <- paste(system.file(package="dismo"), '/ex/bradypus.csv', sep='')
pres <- read.table(presence_file, header=TRUE, sep=',')[,-1]

# the kfold function randomly assigns data to groups; 
# groups are used as calibration (1/5) and training (4/5) data
groupp <- kfold(pres, 5)
pres_train <- pres[groupp !=  1, ]
pres_test <- pres[groupp ==  1, ]

# choose background points
ext <- extent(-90, -32, -33, 23)
background <- randomPoints(predictors, n=1000, ext=ext, extf=1.00)
colnames(background)=c('lon', 'lat')
groupa <- kfold(background, 5)
backg_train <- background[groupa != 1, ]
backg_test <- background[groupa == 1, ]

# calibrate the models
ensemble.calibrate <- ensemble.test(x=predictors, ext=ext,
    p=pres_train, a=backg_train, 
    pt=pres_test, at=backg_test,
    ENSEMBLE.min=0.6,
    MAXENT=1, GBM=1, GBMSTEP=1, RF=1, GLM=1, GLMSTEP=1, GAM=1, 
    GAMSTEP=1, MGCV=1, MGCVFIX=1, EARTH=1, RPART=1, NNET=1, FDA=1, 
    SVM=1, SVME=1, BIOCLIM=1, DOMAIN=1, MAHAL=1,
    Yweights="BIOMOD", factors="biome",
    PLOTS=FALSE, models.keep=TRUE)

# obtain data for plotting the evaluation strip
strip.data <- evaluation.strip.data(xn=predictors, ext=ext,
    models.list=ensemble.calibrate$models)


# create graphs
evaluation.strip.plot(data=strip.data, variable="bio5", type="o", col="red")
evaluation.strip.plot(data=strip.data, model="ENSEMBLE", type="o", col="red")

}
}
