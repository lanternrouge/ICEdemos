# Estimate.R - estimate a simple linear model via OLS
#
# The syntax to run this script is: 
#
#   R --no-save [ --silent ] < Estimate.R --args nObs repID resultsDir
#
# Make sure you generate synthetic data first using Generate.R.
#

# Process arguments
vArgs <- commandArgs( trailingOnly=TRUE )
if( 3 != length( vArgs ) ) {
  stop( 'Syntax: R --no-save [ --silent ] < Estimate.R --args nObs repID resultsDir' )
}

nObs      <- as.numeric( vArgs[ 1 ] )
repID     <- as.numeric( vArgs[ 2 ] )
szResults <- vArgs[ 3 ]

# Compute filenames
szObsDir    <- paste( szResults, '/nObs.', nObs, sep='' ) # dir containing experiment
szDataFile  <- paste( 'synthetic.', repID, '.txt', sep='' ) # name of data file
szInFile    <- paste( szObsDir, '/', szDataFile, sep='' )   # full path to data 

szPEFileName   <- paste( 'PointEst.', repID, '.txt', sep='' ) # name of file
szPointEstFile <- paste( szObsDir, '/', szPEFileName, sep='' )# full path to estimates

szSEFileName   <- paste( 'StdErr.', repID, '.txt', sep='' ) # name of file
szSEFile       <- paste( szObsDir, '/', szSEFileName, sep='' )# full path to std. err.

# Load data
mData <- read.table( szInFile, header=TRUE )

# Estimate model via OLS
lm.out <- lm( Y ~ ., data=mData )
lm.sum <- summary( lm( Y ~ ., data=mData ) )

vPointEst <- matrix( lm.out$coefficients, ncol=1 )
vSE <- matrix( lm.sum$coefficients[,'Std. Error'], ncol=1 )

# Save results
write.table( vPointEst, szPointEstFile, row.names=FALSE, col.names=FALSE )
write.table( vSE, szSEFile, row.names=FALSE, col.names=FALSE )

