# Generate.R - generates synthetic OLS data to show consistency
#
# This script generates synthetic data for a large scale study of OLS.
# For a more complex problem, this script would need to work in parallel.
# Because this problem is simple, I generate all of the data from a 
# single script.
#
# This script must be run with the following syntax:
#
#   R --no-save [ --silent ] < Generate.R --args truthFile resultFile
#
# where
#
#   truthFile       : file with true parameter values
#   nObs            : number of observations to generate
#   repID           : number of synthetic dataset to generate (1..100)
#   resultsDir      : root of tree which holds results
#

#--------------------
# Setup parameters of experiments
library( R.utils )

vnObs <- c( 10, 100, 1000, 10000 )     # Number observations in each experiment
nRep  <- 10   # number of replications per experiment

vTruth <- matrix( seq( 5 ), ncol=1 )
vTruth <- 1.1 * vTruth 
vTruth[ c(2,4), ] <- -1 * vTruth[ c(2,4), ]

nParams <- nrow( vTruth )
nX      <- nParams - 1    # number of non-constant Xs
nMaxObs <- max( vnObs )

# names for variables in data
# -1 because we don't store the column of ones in the data.
vVarNames <- c( 'Y', paste( 'X', 1 : nX, sep='' ) )

#--------------------
# Determine data to estimate and where to write results
vArgs <- commandArgs( trailingOnly=TRUE )
if( 2 != length( vArgs ) ) {
  stop( 'Syntax: R --no-save [ --silent ] < Generate.R --args truthFile resultsDir' )
}

szTruth   <- vArgs[ 1 ]                   # where to store true parameter values
szResults <- vArgs[ 2 ]                   # where to store the results


#------------------------------
# Compute synthetic data


nObs  <- -1     # Number of observations to generate
repID <- -1     # Replication ID

for( nObs in vnObs ) {
  # Reset seed for generating data and specify algorithm to generate 
  # pseudo random numbers so data has correct statistical properties.
  # I.e., smaller samples are subsets of larger samples.
  set.seed( 1945, 'Mersenne-Twister' )
  vOnes <- matrix( rep( 1, nObs ), nrow=nObs, ncol=1 )

  for( repID in seq( nRep ) ) {
    # Create name of output file for this replication and experiment
    # should be something like data/nObsNNNN/synthetic.NN.txt
    szObsDir    <- paste( szResults, '/nObs.', nObs, sep='' )  # dir containing output
    szDataFile  <- paste( 'synthetic.', repID, '.txt', sep='' )# name of data file
    szOutFile   <- paste( szObsDir, '/', szDataFile, sep='' )  # full path to data 

    mkdirs( szObsDir )

    # Draw X always draw maximum data to ensure smaller datasets
    # are contained in larger ones.  This ensures data has correct
    # statistical properties
    mX <- matrix( -1.0 + 2.0 * runif( nMaxObs * ( nX ) ), 
                    nrow=nMaxObs, ncol=nX )[ 1:nObs, ]
    mX <- cbind( vOnes, mX )

    # Draw shock
    vShock <- 2.0 * matrix( rnorm( nMaxObs ), nrow=nMaxObs )[ 1:nObs, 1 ]

    # Compute Y
    vY <- mX %*% vTruth + vShock

    mData <- cbind( vY, mX[ , 2:nParams ] )
    colnames( mData ) <- vVarNames

    # Store output
    write.table( mData, szOutFile, row.names=FALSE )


  }     # for( repID in seq( nRep ) ) {
}         # for( nObs in vnObs )


#------------------------------
# write true parameters
write.table( vTruth, szTruth, row.names=FALSE, col.names=FALSE )

