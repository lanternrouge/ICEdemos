# Analyze.R - this script analyzes results from OLS experiments
#
# This script generates analyzes the bias of OLS Monte Carlo experiments.
#
# This script can be run with the following syntax:
#
#   R --no-save [ --silent ] < Analyze.R --args truthFile resultFile
#
# where
#
#   truthFile       : file with true parameter values
#   resultsDir      : root of tree which holds results
#


#================================================================================
# Define functions for data analysis

#--------------------
# LoadExpResultsDir - load point estimates for each experiment 
#
# This function creates a matrix with all the point estimates for
# the experiment for the specified number of observations.
#
# Args:
#     szRootDir     : root of tree with experiment nObs subdirectories
#     nObs          : number of observations of experiment to process
#
# Returns:            matrix with all parameter estimates for this experiment
#
LoadExpResultsDir <- function( szRootDir, nObs ) {

  # Load point estimate results
  szExpDir <- paste( szRootDir, '/nObs.', nObs, sep='' )
  vPointEstFiles <- list.files( szExpDir, 'PointEst.*' )

  nFiles <- length( vPointEstFiles )
  szFullName  <- paste( szExpDir, vPointEstFiles[ 1 ], sep='/' )
  mExpResults <- as.matrix( read.table( szFullName, header=FALSE ) )
  for( szFile in vPointEstFiles[ 2 : nFiles ] ) {
    szFullName  <- paste( szExpDir, szFile, sep='/' )
    mExpResults <- cbind( mExpResults, 
        as.matrix( read.table( szFullName, header=FALSE ) ) )
  }

  return( mExpResults )
}


#--------------------
# CalcBias - computes bias for a set of experimental results
#
# Args:
#     mExpResults     : matrix with point estimates computed by LoadExpResultsDir()
#     vTruth          : true parameter values
#
CalcBias <- function( mExpResults, vTruth ) {
  vMeans <- rowMeans( mExpResults )
  vBias  <- vMeans - vTruth
  
  return ( vBias )
}

#================================================================================

#--------------------
# Determine data to estimate and where to write results
vArgs <- commandArgs( trailingOnly=TRUE )
if( 2 != length( vArgs ) ) {
  stop( 'Syntax: R --no-save [ --silent ] < Analyze.R --args truthFile resultsDir' )
}

szTruth   <- vArgs[ 1 ]                   # where to store true parameter values
szRootDir <- vArgs[ 2 ]                   # where to store the results


#--------------------
# Setup parameters of experiments
vSubDirs  <- list.dirs( szRootDir )
vnObsDirs <- vSubDirs[ grep('nObs',vSubDirs)]   # Extract list of nObs subdirectories

# get list of different numbers of observations used in experiments
vnObs     <- as.numeric( gsub( '.*nObs.', '', vnObsDirs ) )

# Load true parameters
vTruth  <- as.matrix( read.table( szTruth, header=FALSE ) )

if( 1 != ncol( vTruth ) ) {
  stop( 'Invalid data for true parameters.' )
}

nParams <- nrow( vTruth )
nX      <- nParams - 1    # number of non-constant Xs
nMaxObs <- max( vnObs )


#----------------------------------------
# Compute bias for each experiment
for( nObs in vnObs ) {
  mExpResults <- LoadExpResultsDir( szRootDir, nObs )
  vBias       <- CalcBias( mExpResults, vTruth )

  if( ! exists( 'mBiasResults' ) ) {
    mBiasResults <- cbind( nObs, t( vBias ) )
  } else {
    mBiasResults <- rbind( mBiasResults, cbind( nObs, t( vBias ) ) )
  }
}

colnames( mBiasResults ) <- c( 'nObs', paste( 'Param', 1 : nParams, sep='' ) )
mBiasResults
