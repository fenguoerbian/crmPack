#' @include helpers.R
#' @include Data-class.R
#' @include Simulations-validity.R
#' @include CrmPackClass-class.R
NULL

# GeneralSimulations ----

## class ----

#' `GeneralSimulations`
#'
#' @description `r lifecycle::badge("stable")`
#'
#' This class captures trial simulations.
#' Here also the random generator state before starting the simulation is
#' saved, in order to be able to reproduce the outcome. For this just use
#' [`set.seed`] with the `seed` as argument before running
#' [`simulate,Design-method`].
#'
#' @slot data (`list`)\cr produced [`Data`] objects.
#' @slot doses (`numeric`)\cr final dose recommendations.
#' @slot seed (`integer`)\cr random generator state before starting the simulation.
#'
#' @aliases GeneralSimulations
#' @export
.GeneralSimulations <-
  setClass(
    Class = "GeneralSimulations",
    slots = c(
      data = "list",
      doses = "numeric",
      seed = "integer"
    ),
    prototype = prototype(
      data =
        list(
          Data(
            x = 1:2,
            y = 0:1,
            doseGrid = 1:2,
            ID = 1L:2L,
            cohort = 1L:2L
          ),
          Data(
            x = 3:4,
            y = 0:1,
            doseGrid = 3:4,
            ID = 1L:2L,
            cohort = 1L:2L
          )
        ),
      doses = c(1, 2),
      seed = 1L
    ),
    contains = "CrmPackClass",
    validity = v_general_simulations
  )

## constructor ----

#' @rdname GeneralSimulations-class
#'
#' @param data (`list`)\cr see slot definition.
#' @param doses (`numeric`)\cr see slot definition.
#' @param seed (`integer`)\cr see slot definition.
#'
#' @example examples/Simulations-class-GeneralSimulations.R
#' @export
GeneralSimulations <- function(data,
                               doses,
                               seed) {
  assert_integerish(seed)
  .GeneralSimulations(
    data = data,
    doses = doses,
    seed = as.integer(seed)
  )
}


## default constructor

#' @rdname GeneralSimulations-class
#' @note Typically, end users will not use the `.DefaultGeneralSimulations()` function.
#' @export
.DefaultGeneralSimulations <- function() {
  GeneralSimulations(
    data = list(
      Data(x = 1:3, y = c(0, 1, 0), doseGrid = 1:3, ID = 1L:3L, cohort = 1L:3L),
      Data(x = 4:6, y = c(0, 1, 0), doseGrid = 4:6, ID = 1L:3L, cohort = 1L:3L)
    ),
    doses = c(1, 2),
    seed = 123
  )
}


# Simulations ----

## class ----

#' `Simulations`
#'
#' @description `r lifecycle::badge("stable")`
#'
#' This class captures the trial simulations from model based designs.
#' Additional slots `fit`, `stop_reasons`, `stop_report`,`additional_stats` compared to
#' the general class [`GeneralSimulations`].
#'
#' @slot fit (`list`)\cr final fits
#' @slot stop_reasons (`list`)\cr stopping reasons for each simulation run
#' @slot stop_report matrix of stopping rule outcomes
#' @slot additional_stats list of additional statistical summary
#' @aliases Simulations
#' @export
.Simulations <-
  setClass(
    Class = "Simulations",
    slots = c(
      fit = "list",
      stop_report = "matrix",
      stop_reasons = "list",
      additional_stats = "list"
    ),
    prototype = prototype(
      fit =
        list(
          c(0.1, 0.2),
          c(0.1, 0.2)
        ),
      stop_report = matrix(TRUE, nrow = 2),
      stop_reasons =
        list("A", "A"),
      additional_stats =
        list(a = 1, b = 1)
    ),
    contains = "GeneralSimulations",
    validity = v_simulations
  )

## constructor ----

#' @rdname Simulations-class
#'
#' @param fit (`list`)\cr see slot definition.
#' @param stop_reasons (`list`)\cr see slot definition.
#' @param stop_report see [`Simulations`]
#' @param additional_stats (`list`)\cr see slot definition.
#' @param \dots additional parameters from [`GeneralSimulations`]
#'
#' @example examples/Simulations-class-Simulations.R
#' @export
Simulations <- function(fit,
                        stop_reasons,
                        stop_report,
                        additional_stats,
                        ...) {
  start <- GeneralSimulations(...)
  .Simulations(start,
    fit = fit,
    stop_report = stop_report,
    stop_reasons = stop_reasons,
    additional_stats = additional_stats
  )
}

## default constructor ----

#' @rdname Simulations-class
#' @note Typically, end users will not use the `.DefaultSimulations()` function.
#' @export
.DefaultSimulations <- function() {
  design <- .DefaultDesign()
  myTruth <- probFunction(design@model, alpha0 = 7, alpha1 = 8)

  simulate(
    design,
    args = NULL,
    truth = myTruth,
    nsim = 1,
    seed = 819,
    mcmcOptions = .DefaultMcmcOptions(),
    parallel = FALSE
  )
}

# DualSimulations ----

## class ----

#' `DualSimulations`
#'
#' @description `r lifecycle::badge("stable")`
#'
#' This class captures the trial simulations from dual-endpoint model based
#' designs. In comparison to the parent class [`Simulations`],
#' it contains additional slots to capture the dose-biomarker `fits`, and the
#' `sigma2W` and `rho` estimates.
#'
#' @slot rho_est (`numeric`)\cr vector of final posterior median rho estimates
#' @slot sigma2w_est (`numeric`)\cr vector of final posterior median sigma2W estimates
#' @slot fit_biomarker (`list`)\cr with the final dose-biomarker curve fits
#' @aliases DualSimulations
#' @export
.DualSimulations <-
  setClass(
    Class = "DualSimulations",
    slots = c(
      rho_est = "numeric",
      sigma2w_est = "numeric",
      fit_biomarker = "list"
    ),
    prototype = prototype(
      rho_est = c(0.2, 0.3),
      sigma2w_est = c(0.2, 0.3),
      fit_biomarker =
        list(
          c(0.1, 0.2),
          c(0.1, 0.2)
        )
    ),
    contains = "Simulations",
    validity = v_dual_simulations
  )


## constructor ----

#' @rdname DualSimulations-class
#'
#' @param rho_est (`numeric`)\cr see [`DualSimulations`]
#' @param sigma2w_est (`numeric`)\cr [`DualSimulations`]
#' @param fit_biomarker (`list`)\cr see [`DualSimulations`]
#' @param \dots additional parameters from [`Simulations`]
#'
#' @example examples/Simulations-class-DualSimulations.R
#' @export
DualSimulations <- function(rho_est,
                            sigma2w_est,
                            fit_biomarker,
                            ...) {
  start <- Simulations(...)
  .DualSimulations(start,
    rho_est = rho_est,
    sigma2w_est = sigma2w_est,
    fit_biomarker = fit_biomarker
  )
}

## default constructor ----

#' @rdname DualSimulations-class
#' @note Typically, end users will not use the `.DefaultDualSimulations()` function.
#' @export
.DefaultDualSimulations <- function() {
  DualSimulations(
    rho_est = c(0.25, 0.35),
    sigma2w_est = c(0.15, 0.25),
    fit_biomarker = list(c(0.3, 0.4), c(0.4, 0.5)),
    fit = list(
      c(0.1, 0.2),
      c(0.3, 0.4)
    ),
    stop_report = matrix(c(TRUE, FALSE), nrow = 2),
    stop_reasons = list("A", "B"),
    additional_stats = list(a = 1, b = 1),
    data = list(
      Data(
        x = 1:2,
        y = 0:1,
        doseGrid = 1:2,
        ID = 1L:2L,
        cohort = 1L:2L
      ),
      Data(
        x = 3:4,
        y = 0:1,
        doseGrid = 3:4,
        ID = 1L:2L,
        cohort = 1L:2L
      )
    ),
    doses = c(1, 2),
    seed = 123L
  )
}

# GeneralSimulationsSummary ----

# nolint start
##' Class for the summary of general simulations output
##'
##' Note that objects should not be created by users, therefore no
##' initialization function is provided for this class.
##'
##' @slot target target toxicity interval
##' @slot targetDoseInterval corresponding target dose interval
##' @slot nsim number of simulations
##' @slot propDLTs proportions of DLTs in the trials
##' @slot meanToxRisk mean toxicity risks for the patients
##' @slot doseSelected doses selected as MTD
##' @slot toxAtDosesSelected true toxicity at doses selected
##' @slot propAtTarget Proportion of trials selecting target MTD
##' @slot doseMostSelected dose most often selected as MTD
##' @slot obsToxRateAtDoseMostSelected observed toxicity rate at dose most often
##' selected
##' @slot nObs number of patients overall
##' @slot nAboveTarget number of patients treated above target tox interval
##' @slot doseGrid the dose grid that has been used
##' @slot placebo set to TRUE (default is FALSE) for a design with placebo
##'
##' @export
##' @keywords classes
.GeneralSimulationsSummary <-
  setClass(
    Class = "GeneralSimulationsSummary",
    representation(
      target = "numeric",
      targetDoseInterval = "numeric",
      nsim = "integer",
      propDLTs = "ANY",
      meanToxRisk = "numeric",
      doseSelected = "numeric",
      toxAtDosesSelected = "numeric",
      propAtTarget = "numeric",
      doseMostSelected = "numeric",
      obsToxRateAtDoseMostSelected = "numeric",
      nObs = "ANY",
      nAboveTarget = "integer",
      doseGrid = "numeric",
      placebo = "logical"
    )
  )

## default constructor ----

#' @rdname GeneralSimulationsSummary-class
#' @note Typically, end users will not use the `.DefaultGeneralSimulationsSummary()` function.
#' @export
.DefaultGeneralSimulationsSummary <- function() {
  stop(paste0("Class GeneralSimulationsSummary cannot be instantiated directly.  Please use one of its subclasses instead."))
}


##' Class for the summary of model-based simulations output
##'
##' In addition to the slots in the parent class
##' \code{\linkS4class{GeneralSimulationsSummary}}, it contains two slots with
##' model fit information.
##'
##' Note that objects should not be created by users, therefore no
##' initialization function is provided for this class.
##'
##' @slot stop_report matrix of stopping rule outcomes
##' @slot additional_stats list of additional statistical summary
##' @slot fitAtDoseMostSelected fitted toxicity rate at dose most often selected
##' @slot meanFit list with the average, lower (2.5%) and upper (97.5%)
##' quantiles of the mean fitted toxicity at each dose level
##'
##' @export
##' @keywords classes
.SimulationsSummary <-
  setClass(
    Class = "SimulationsSummary",
    representation(
      stop_report = "matrix",
      fitAtDoseMostSelected = "numeric",
      additional_stats = "list",
      meanFit = "list"
    ),
    contains = "GeneralSimulationsSummary"
  )

## default constructor ----

#' @rdname SimulationsSummary-class
#' @note Typically, end users will not use the `.DefaultSimulationsSummary()` function.
#' @export
.DefaultSimulationsSummary <- function() {
  stop(paste0("Class SimulationsSummary cannot be instantiated directly.  Please use one of its subclasses instead."))
}

# DualSimulationsSummary ----

##' Class for the summary of dual-endpoint simulations output
##'
##' In addition to the slots in the parent class
##' \code{\linkS4class{SimulationsSummary}}, it contains two slots for the
##' biomarker model fit information.
##'
##' Note that objects should not be created by users, therefore no
##' initialization function is provided for this class.
##'
##' @slot biomarkerFitAtDoseMostSelected fitted biomarker level at dose most often selected
##' @slot meanBiomarkerFit list with the average, lower (2.5%) and upper (97.5%)
##' quantiles of the mean fitted biomarker level at each dose level
##'
##' @export
##' @keywords classes
.DualSimulationsSummary <-
  setClass(
    Class = "DualSimulationsSummary",
    contains = "SimulationsSummary",
    representation =
      representation(
        biomarkerFitAtDoseMostSelected = "numeric",
        meanBiomarkerFit = "list"
      )
  )

## default constructor ----

#' @rdname DualSimulationsSummary-class
#' @note Typically, end users will not use the `.DefaultDualSimulationsSummary()` function.
#' @export
.DefaultDualSimulationsSummary <- function() {
  emptydata <- DataDual(doseGrid = c(1, 3, 5, 10, 15, 20, 25, 30))

  # Initialize the CRM model.
  my_model <- DualEndpointRW(
    mean = c(0, 1),
    cov = matrix(c(1, 0, 0, 1), nrow = 2),
    sigma2betaW = 0.01,
    sigma2W = c(a = 0.1, b = 0.1),
    rho = c(a = 1, b = 1),
    rw1 = TRUE
  )

  # Choose the rule for selecting the next dose.
  my_next_best <- NextBestDualEndpoint(
    target = c(0.9, 1),
    overdose = c(0.35, 1),
    max_overdose_prob = 0.25
  )

  # Choose the rule for the cohort-size.
  my_size1 <- CohortSizeRange(
    intervals = c(0, 30),
    cohort_size = c(1, 3)
  )
  my_size2 <- CohortSizeDLT(
    intervals = c(0, 1),
    cohort_size = c(1, 3)
  )
  my_size <- maxSize(my_size1, my_size2)

  # Choose the rule for stopping.
  my_stopping1 <- StoppingTargetBiomarker(
    target = c(0.9, 1),
    prob = 0.5
  )

  # Stop with a small number of patients for illustration.
  my_stopping <- my_stopping1 | StoppingMinPatients(10) | StoppingMissingDose()

  # Choose the rule for dose increments.
  my_increments <- IncrementsRelative(
    intervals = c(0, 20),
    increments = c(1, 0.33)
  )

  # Initialize the design.
  my_design <- DualDesign(
    model = my_model,
    data = emptydata,
    nextBest = my_next_best,
    stopping = my_stopping,
    increments = my_increments,
    cohort_size = CohortSizeConst(3),
    startingDose = 3
  )

  # Define scenarios for the TRUE toxicity and efficacy profiles.
  beta_mod <- function(dose, e0, eMax, delta1, delta2, scal) {
    maxDens <- (delta1^delta1) * (delta2^delta2) / ((delta1 + delta2)^(delta1 + delta2))
    dose <- dose / scal
    e0 + eMax / maxDens * (dose^delta1) * (1 - dose)^delta2
  }

  true_biomarker <- function(dose) {
    beta_mod(dose, e0 = 0.2, eMax = 0.6, delta1 = 5, delta2 = 5 * 0.5 / 0.5, scal = 100)
  }

  true_tox <- function(dose) {
    pnorm((dose - 60) / 10)
  }

  # Run the simulation on the desired design.
  # For illustration purposes only 1 trial outcome is generated and 5 burn-ins
  # to generate 20 samples are used here.
  simulate(
    object = my_design,
    trueTox = true_tox,
    trueBiomarker = true_biomarker,
    sigma2W = 0.01,
    rho = 0,
    nsim = 1,
    parallel = FALSE,
    seed = 3,
    startingDose = 6,
    mcmcOptions = .DefaultMcmcOptions()
  )
}


## ==============================================================================

## -------------------------------------------------------------------------------
## class for simulation using pseudo models
## ------------------------------------------------------------------------

##' Class `PseudoSimulations`
##'
##' This is a class which captures the trial simulations from designs using
##' pseudo model. The design for DLE only responses and model from \code{\linkS4class{ModelTox}}
##' class object. It contains all slots from \code{\linkS4class{GeneralSimulations}} object.
##' Additional slots fit and stopReasons compared to the general class
##' \code{\linkS4class{GeneralSimulations}}.
##'
##' @slot fit list of the final values. If samples are involved, these are the final fitted values.
##' If no samples are involved, these are included the final modal estimates of the model parameters
##' and the posterior estimates of the probabilities of the occurrence of a DLE.
##' @slot FinalTDtargetDuringTrialEstimates the vector of all final estimates (the last estimate of) the TDtargetDuringTrial at the end
##' of each simulations/when each trial stops
##' @slot FinalTDtargetEndOfTrialEstimates vector of all final estimates or the last estimate of the TDtargetEndOfTrial when each trial
##' stops
##' @slot FinalTDtargetDuringTrialAtDoseGrid vector of the dose levels at dose grid closest below the final TDtargetDuringTrial estimates
##' @slot FinalTDtargetEndOfTrialAtDoseGrid vector of  the dose levels at dose grid closest below the final TDtargetEndOfTrial estimates
##' @slot FinalTDEOTCIs is the list of all 95% credibility interval of the final estimates of the TDtargetEndOfTrial
##' @slot FinalTDEOTRatios is the vector of the ratios of the CI, the ratio of the upper to the lower 95% credibility intervals
##' of the final estimates of the TDtargetEndOfTrial
##' @slot FinalCIs list of all the final 95% credibility intervals of the TDtargetEndofTrial estimates or of the final optimal dose
##' estimates when DLE and efficacy responses are incorporated after each simulations
##' @slot FinalRatios vector of all the final ratios, the ratios of the upper to the lower 95% credibility interval of the
##' final estimates of the TDtargetEndOfTrial or of the final optimal dose estimates (when DLE and efficacy responses are
##' incorporated) after each simulations
##' @slot stopReasons add slot description
##'
##' @export
.PseudoSimulations <-
  setClass(
    Class = "PseudoSimulations",
    representation(
      fit = "list",
      FinalTDtargetDuringTrialEstimates = "numeric",
      FinalTDtargetEndOfTrialEstimates = "numeric",
      FinalTDtargetDuringTrialAtDoseGrid = "numeric",
      FinalTDtargetEndOfTrialAtDoseGrid = "numeric",
      FinalTDEOTCIs = "list",
      FinalTDEOTRatios = "numeric",
      FinalCIs = "list",
      FinalRatios = "numeric",
      stopReasons = "list"
    ),
    ## note: this prototype is put together with the prototype
    ## for GeneralSimulations
    prototype(
      FinalTDtargetDuringTrialEstimates = c(0.1, 0.1),
      FinalTDtargetEndOfTrialEstimates = c(0.1, 0.1),
      FinalTDtargetDuringTrialAtDoseGrid = c(0.1, 0.1),
      FinalTDtargetEndOfTrialAtDoseGrid = c(0.1, 0.1),
      FinalTDEOTCIs = list(c(0.1, 0.2), c(0.1, 0.2)),
      FinalTDEOTRatios = c(0.1, 0.1),
      FinalCIs = list(c(0.1, 0.2), c(0.1, 0.2)),
      FinalRatios = c(0.1, 0.1),
      stopReasons =
        list("A", "A")
    ),
    contains = "GeneralSimulations",
    validity = v_pseudo_simulations
  )
validObject(.PseudoSimulations())

##' Initialization function of the 'PseudoSimulations' class
##' @param fit please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param FinalTDtargetDuringTrialEstimates please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param FinalTDtargetEndOfTrialEstimates please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param FinalTDtargetDuringTrialAtDoseGrid please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param FinalTDtargetEndOfTrialAtDoseGrid please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param FinalTDEOTCIs please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param FinalTDEOTRatios please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param FinalCIs please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param FinalRatios please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param stopReasons please refer to \code{\linkS4class{PseudoSimulations}} class object
##' @param \dots additional parameters from \code{\linkS4class{GeneralSimulations}}
##' @return the \code{\linkS4class{PseudoSimulations}} object
##'
##' @export
PseudoSimulations <- function(fit,
                              FinalTDtargetDuringTrialEstimates,
                              FinalTDtargetEndOfTrialEstimates,
                              FinalTDtargetDuringTrialAtDoseGrid,
                              FinalTDtargetEndOfTrialAtDoseGrid,
                              FinalTDEOTCIs,
                              FinalTDEOTRatios,
                              FinalCIs,
                              FinalRatios,
                              stopReasons,
                              ...) {
  start <- GeneralSimulations(...)
  .PseudoSimulations(start,
    fit = fit,
    FinalTDtargetDuringTrialEstimates = FinalTDtargetDuringTrialEstimates,
    FinalTDtargetEndOfTrialEstimates = FinalTDtargetEndOfTrialEstimates,
    FinalTDtargetDuringTrialAtDoseGrid = FinalTDtargetDuringTrialAtDoseGrid,
    FinalTDtargetEndOfTrialAtDoseGrid = FinalTDtargetEndOfTrialAtDoseGrid,
    FinalTDEOTCIs = FinalTDEOTCIs,
    FinalTDEOTRatios = FinalTDEOTRatios,
    FinalCIs = FinalCIs,
    FinalRatios = FinalRatios,
    stopReasons = stopReasons
  )
}

## default constructor ----

#' @rdname PseudoSimulations-class
#' @note Typically, end users will not use the `.DefaultPseudoSimulations()` function.
#' @export
.DefaultPseudoSimulations <- function() {
  stop(paste0("Class PseudoSimulations cannot be instantiated directly.  Please use one of its subclasses instead."))
}

## ===============================================================================
## -------------------------------------------------------------------------------
## Class for Pseudo simulation using DLE and efficacy responses (Pseudo models except 'EffFlexi' model)
## -----------------------------------------------------------------------------------

##' Class `PseudoDualSimulations`
##'
##' This is a class which captures the trial simulations design using both the
##' DLE and efficacy responses. The design of model from \code{\linkS4class{ModelTox}}
##' class and the efficacy model from \code{\linkS4class{ModelEff}} class
##' (except \code{\linkS4class{EffFlexi}} class). It contains all slots from
##' \code{\linkS4class{GeneralSimulations}} and \code{\linkS4class{PseudoSimulations}} object.
##' In comparison to the parent class \code{\linkS4class{PseudoSimulations}},
##' it contains additional slots to
##' capture the dose-efficacy curve and the sigma2 estimates.
##'
##' @slot fitEff list of the final values. If DLE and efficacy samples are generated, it contains the
##' final fitted values. If no DLE and efficacy samples are used, it contains the modal estimates of the
##' parameters in the two models and the posterior estimates of the probabilities of the occurrence of a
##' DLE and the expected efficacy responses.
##' @slot FinalGstarEstimates a vector of the final estimates of Gstar at the end of each simulations.
##' @slot FinalGstarAtDoseGrid is a vector of the final estimates of Gstar at dose Grid at the end of each simulations
##' @slot FinalGstarCIs is the list of all 95% credibility interval of the final estimates of Gstar
##' @slot FinalGstarRatios is the vector of the ratios of the CI, the ratio of the upper to the lower 95% credibility interval
##' of the final estimates of Gstar
##' @slot FinalOptimalDose is the vector of the final optimal dose, the minimum of the final TDtargetEndOfTrial estimates and Gstar
##' estimates
##' @slot FinalOptimalDoseAtDoseGrid is the vector of the final optimal dose, the minimum of the final TDtargetEndOfTrial estimates
##' and Gstar estimates at dose Grid
##' @slot sigma2est the vector of the final posterior mean sigma2 estimates
##'
##' @export
.PseudoDualSimulations <-
  setClass(
    Class = "PseudoDualSimulations",
    representation(
      fitEff = "list",
      FinalGstarEstimates = "numeric",
      FinalGstarAtDoseGrid = "numeric",
      FinalGstarCIs = "list",
      FinalGstarRatios = "numeric",
      FinalOptimalDose = "numeric",
      FinalOptimalDoseAtDoseGrid = "numeric",
      sigma2est = "numeric"
    ),
    prototype(
      FinalGstarEstimates = c(0.1, 0.1),
      FinalGstarAtDoseGrid = c(0.1, 0.1),
      FinalGstarCIs = list(
        c(0.1, 0.2),
        c(0.1, 0.2)
      ),
      FinalGstarRatios = c(0.01, 0.01),
      FinalOptimalDose = c(0.01, 0.01),
      FinalOptimalDoseAtDoseGrid = c(0.01, 0.01),
      sigma2est = c(0.001, 0.002)
    ),
    contains = "PseudoSimulations",
    validity = v_pseudo_dual_simulations
  )

validObject(.PseudoDualSimulations())

##' Initialization function for 'DualPseudoSimulations' class
##' @param fitEff please refer to \code{\linkS4class{PseudoDualSimulations}} class object
##' @param  FinalGstarEstimates please refer to \code{\linkS4class{PseudoDualSimulations}} class object
##' @param FinalGstarAtDoseGrid please refer to \code{\linkS4class{PseudoDualSimulations}} class object
##' @param FinalGstarCIs please refer to \code{\linkS4class{PseudoDualSimulations}} class object
##' @param FinalGstarRatios please refer to \code{\linkS4class{PseudoDualSimulations}} class object
##' @param FinalOptimalDose please refer to \code{\linkS4class{PseudoDualSimulations}} class object
##' @param FinalOptimalDoseAtDoseGrid please refer to \code{\linkS4class{PseudoDualSimulations}} class object
##' @param sigma2est please refer to \code{\linkS4class{PseudoDualSimulations}} class object
##' @param \dots additional parameters from \code{\linkS4class{PseudoSimulations}}
##' @return the \code{\linkS4class{PseudoDualSimulations}} object
PseudoDualSimulations <- function(fitEff,
                                  FinalGstarEstimates,
                                  FinalGstarAtDoseGrid,
                                  FinalGstarCIs,
                                  FinalGstarRatios,
                                  FinalOptimalDose,
                                  FinalOptimalDoseAtDoseGrid,
                                  sigma2est,
                                  ...) {
  start <- PseudoSimulations(...)
  .PseudoDualSimulations(start,
    fitEff = fitEff,
    FinalGstarEstimates = FinalGstarEstimates,
    FinalGstarAtDoseGrid = FinalGstarAtDoseGrid,
    FinalGstarCIs = FinalGstarCIs,
    FinalGstarRatios = FinalGstarRatios,
    FinalOptimalDose = FinalOptimalDose,
    FinalOptimalDoseAtDoseGrid = FinalOptimalDoseAtDoseGrid,
    sigma2est = sigma2est
  )
}


## default constructor ----

#' @rdname PseudoDualSimulations-class
#' @note Typically, end users will not use the `.DefaultPseudoDualSimulations()` function.
#' @export
.DefaultPseudoDualSimulations <- function() {
  stop(paste0("Class PseudoDualSimulations cannot be instantiated directly.  Please use one of its subclasses instead."))
}


# PseudoDualFlexiSimulations ----

## class ----

## -------------------------------------------------------------------------------
## Class for Pseudo simulation using DLE and efficacy responses using 'EffFlex' efficacy model
## -----------------------------------------------------------------------------------
##' This is a class which captures the trial simulations design using both the
##' DLE and efficacy responses. The design of model from \code{\linkS4class{ModelTox}}
##' class and the efficacy model from \code{\linkS4class{EffFlexi}} class
##'  It contains all slots from
##' \code{\linkS4class{GeneralSimulations}}, \code{\linkS4class{PseudoSimulations}}
##' and \code{\linkS4class{PseudoDualSimulations}} object.
##' In comparison to the parent class \code{\linkS4class{PseudoDualSimulations}},
##' it contains additional slots to
##' capture the sigma2betaW estimates.
##'
##' @slot sigma2betaWest the vector of the final posterior mean sigma2betaW estimates
##'
##' @export
##' @keywords class
.PseudoDualFlexiSimulations <-
  setClass(
    Class = "PseudoDualFlexiSimulations",
    representation(sigma2betaWest = "numeric"),
    prototype(sigma2betaWest = c(0.001, 0.002)),
    contains = "PseudoDualSimulations",
    validity = v_pseudo_dual_flex_simulations
  )

validObject(.PseudoDualFlexiSimulations())

##' Initialization function for 'PseudoDualFlexiSimulations' class
##' @param sigma2betaWest please refer to \code{\linkS4class{PseudoDualFlexiSimulations}} class object
##' @param \dots additional parameters from \code{\linkS4class{PseudoDualSimulations}}
##' @return the \code{\linkS4class{PseudoDualFlexiSimulations}} object
PseudoDualFlexiSimulations <- function(sigma2betaWest,
                                       ...) {
  start <- PseudoDualSimulations(...)
  .PseudoDualFlexiSimulations(start,
    sigma2betaWest = sigma2betaWest
  )
}

## default constructor ----

#' @rdname PseudoFlexiSimulations-class
#' @note Typically, end users will not use the `.DefaultPseudoFlexiSimulations()` function.
#' @export
.DefaultPseudoFlexiSimulations <- function() {
  stop(paste0("Class PseudoFlexiSimulations cannot be instantiated directly.  Please use one of its subclasses instead."))
}

## -------------------------------------------------------------------------------------------------------
## ================================================================================================

##' Class for the summary of pseudo-models simulations output
##'
##' Note that objects should not be created by users, therefore no
##' initialization function is provided for this class.
##'
##' @slot targetEndOfTrial the target probability of DLE wanted at the end of a trial
##' @slot targetDoseEndOfTrial the dose level corresponds to the target probability
##' of DLE wanted at the end of a trial, TDEOT
##' @slot targetDoseEndOfTrialAtDoseGrid the dose level at dose grid corresponds to the target probability
##' of DLE wanted at the end of a trial
##' @slot targetDuringTrial the target probability of DLE wanted during a trial
##' @slot targetDoseDuringTrial the dose level corresponds to the target probability of DLE
##' wanted during the trial. TDDT
##' @slot targetDoseDuringTrialAtDoseGrid the dose level at dose grid corresponds to the target probability
##' of DLE wanted during a trial
##' @slot TDEOTSummary the six-number table summary, include the lowest, the 25th precentile (lower quartile),
##' the 50th percentile (median), the mean, the 27th percentile and the highest values of the
##' final dose levels obtained corresponds to the target probability of DLE
##' want at the end of a trial across all simulations
##' @slot TDDTSummary the six-number table summary, include the lowest, the 25th precentile (lower quartile),
##' the 50th percentile (median), the mean, the 27th percentile and the highest values of the
##' final dose levels obtained corresponds to the target probability of DLE
##' want during a trial across all simulations
##' @slot FinalDoseRecSummary the six-number table summary, include the lowest, the 25th precentile (lower quartile),
##' the 50th percentile (median), the mean, the 27th percentile and the highest values of the
##' final optimal doses, which is either the TDEOT when only DLE response are incorporated into
##' the escalation procedure or the minimum of the TDEOT and Gstar when DLE and efficacy responses are
##' incorporated, across all simulations
##' @slot ratioTDEOTSummary the six-number summary table of the final ratios of the upper to the lower 95%
##' credibility intervals of the final TDEOTs across all simulations
##' @slot FinalRatioSummary the six-number summary table of the final ratios of the upper to the lower 95%
##' credibility intervals of the final optimal doses across all simulations
##' #@slot doseRec the dose level that will be recommend for subsequent study
##' @slot nsim number of simulations
##' @slot propDLE proportions of DLE in the trials
##' @slot meanToxRisk mean toxicity risks for the patients
##' @slot doseSelected doses selected as MTD (targetDoseEndOfTrial)
##' @slot toxAtDosesSelected true toxicity at doses selected
##' @slot propAtTargetEndOfTrial Proportion of trials selecting at the doseGrid closest below the MTD, the
##' targetDoseEndOfTrial
##' @slot propAtTargetDuringTrial Proportion of trials selecting at the doseGrid closest below the
##' targetDoseDuringTrial
##' @slot doseMostSelected dose most often selected as MTD
##' @slot obsToxRateAtDoseMostSelected observed toxicity rate at dose most often
##' selected
##' @slot nObs number of patients overall
##' @slot nAboveTargetEndOfTrial number of patients treated above targetDoseEndOfTrial
##' @slot nAboveTargetDuringTrial number of patients treated above targetDoseDuringTrial
##' @slot doseGrid the dose grid that has been used
##' @slot fitAtDoseMostSelected fitted toxicity rate at dose most often selected
##' @slot meanFit list with the average, lower (2.5%) and upper (97.5%)
##' quantiles of the mean fitted toxicity at each dose level
##'
##'
##' @export
##' @keywords classes
.PseudoSimulationsSummary <-
  setClass(
    Class = "PseudoSimulationsSummary",
    representation(
      targetEndOfTrial = "numeric",
      targetDoseEndOfTrial = "numeric",
      targetDoseEndOfTrialAtDoseGrid = "numeric",
      targetDuringTrial = "numeric",
      targetDoseDuringTrial = "numeric",
      targetDoseDuringTrialAtDoseGrid = "numeric",
      TDEOTSummary = "table",
      TDDTSummary = "table",
      FinalDoseRecSummary = "table",
      ratioTDEOTSummary = "table",
      FinalRatioSummary = "table",
      # doseRec="numeric",
      nsim = "integer",
      propDLE = "numeric",
      meanToxRisk = "numeric",
      doseSelected = "numeric",
      toxAtDosesSelected = "numeric",
      propAtTargetEndOfTrial = "numeric",
      propAtTargetDuringTrial = "numeric",
      doseMostSelected = "numeric",
      obsToxRateAtDoseMostSelected = "numeric",
      nObs = "integer",
      nAboveTargetEndOfTrial = "integer",
      nAboveTargetDuringTrial = "integer",
      doseGrid = "numeric",
      fitAtDoseMostSelected = "numeric",
      meanFit = "list"
    )
  )

## default constructor ----

#' @rdname GeneralSimulationsSummary-class
#' @note Typically, end users will not use the `.DefaultPseudoSimulationsSummary()` function.
#' @export
.DefaultPseudoSimulationsSummary <- function() {
  stop(paste0("Class PseudoSimulationsSummary cannot be instantiated directly.  Please use one of its subclasses instead."))
}

## ---------------------------------------------------------------------------------------------
##' Class for the summary of the dual responses simulations using pseudo models
##'
##' It contains all slots from \code{\linkS4class{PseudoSimulationsSummary}} object. In addition to
##' the slots in the parent class \code{\linkS4class{PseudoSimulationsSummary}}, it contains four
##' more slots for the efficacy model fit information.
##'
##' Note that objects should not be created by users, therefore no initialization function
##' is provided for this class.
##'
##' @slot targetGstar the target dose level such that its gain value is at maximum
##' @slot targetGstarAtDoseGrid the dose level at dose Grid closest and below Gstar
##' @slot GstarSummary the six-number table summary (lowest, 25th, 50th (median), 75th percentile, mean
##' and highest value) of the final Gstar values obtained across all simulations
##' @slot ratioGstarSummary the six-number summary table of the ratios of the upper to the lower 95%
##' credibility intervals of the final Gstar across all simulations
##' @slot EffFitAtDoseMostSelected fitted expected mean efficacy value at dose most often
##' selected
##' @slot meanEffFit list with mean, lower (2.5%) and upper (97.5%) quantiles of the fitted expected
##' efficacy value at each dose level.
##'
##' @export
##' @keywords class
.PseudoDualSimulationsSummary <-
  setClass(
    Class = "PseudoDualSimulationsSummary",
    contains = "PseudoSimulationsSummary",
    representation =
      representation(
        targetGstar = "numeric",
        targetGstarAtDoseGrid = "numeric",
        GstarSummary = "table",
        ratioGstarSummary = "table",
        EffFitAtDoseMostSelected = "numeric",
        meanEffFit = "list"
      )
  )

## default constructor ----

#' @rdname PseudoDualSimulationsSummary-class
#' @note Typically, end users will not use the `.DefaultPseudoDualSimulationsSummary()` function.
#' @export
.DefaultPseudoDualSimulationsSummary <- function() {
  stop(paste0("Class PseudoDualSimulationsSummary cannot be instantiated directly.  Please use one of its subclasses instead."))
}

## ---------------------------------------------------------------------------------------------

##' Class for the simulations output from DA based designs
##'
##' This class captures the trial simulations from DA based
##' designs. In comparison to the parent class \code{\linkS4class{Simulations}},
##' it contains additional slots to capture the time to DLT fits, additional
##' parameters and the trial duration.
##'
##' @slot trialduration the vector of trial duration values for all simulations.
##'
##' @export
##' @keywords classes
.DASimulations <-
  setClass(
    Class = "DASimulations",
    representation(trialduration = "numeric"),
    prototype(trialduration = rep(0, 2)),
    contains = "Simulations",
    validity = v_da_simulations
  )
validObject(.DASimulations())


##' Initialization function for `DASimulations`
##'
##' @param trialduration see \code{\linkS4class{DASimulations}}
##' @param \dots additional parameters from \code{\link{Simulations}}
##' @return the \code{\linkS4class{DASimulations}} object
##'
##' @export
##' @keywords methods
DASimulations <- function(trialduration,
                          ...) {
  start <- Simulations(...)
  .DASimulations(start,
    trialduration = trialduration
  )
}


## default constructor ----

#' @rdname DASimulations-class
#' @note Typically, end users will not use the `.DASimulations()` function.
#' @export
.DefaultDASimulations <- function() {
  design <- .DefaultDADesign()
  myTruth <- probFunction(design@model, alpha0 = 2, alpha1 = 3)
  exp_cond.cdf <- function(x, onset = 15) {
    a <- stats::pexp(28, 1 / onset, lower.tail = FALSE)
    1 - (stats::pexp(x, 1 / onset, lower.tail = FALSE) - a) / (1 - a)
  }

  simulate(
    design,
    args = NULL,
    truthTox = myTruth,
    truthSurv = exp_cond.cdf,
    trueTmax = 80,
    nsim = 2,
    seed = 819,
    mcmcOptions = .DefaultMcmcOptions(),
    firstSeparate = TRUE,
    deescalate = FALSE,
    parallel = FALSE
  )
}
# nolint end
